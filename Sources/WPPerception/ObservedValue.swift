import Perception

// MARK: - ObservedValue

/// A utility class for efficiently observing value types using `Perceptible` and `Observable`.
///
/// # Overview
///
/// Value types cannot use the `@Perceptible` or `@Observable` macro, and this often creates
/// problems when using value types within `@Perceptible` or `@Observable` classes.
///
/// For instance, let's say we have a large value type called `Preferences` that is used for
/// reading application preferences in many areas throughout an application, and we use it inside
/// an `@Perceptible` model like so:
/// ```swift
/// struct Preferences {
///   var isAnalyticsEnabled = true
///   var isDarkModeEnabled = true
///   // Many more properties...
/// }
///
/// @Perceptible
/// final class PreferencesModel {
///   var preferences = Preferences()
/// }
/// ```
///
/// Since it contains the app's preferences, `PreferencesModel` is used by many views and is passed
/// through the environment. However, any single view only needs to access 1 or a small subset of
/// properties of the `Preferences`. Let's say we have 2 views, the first contains a toggle for
/// analytics, and the second contains a toggle for dark mode.
/// ```swift
/// struct AnalyticsView: View {
///   @Environment(PreferencesModel.self) var model
///
///   var body: some View {
///     @Bindable var model = self.model
///     VStack {
///       // 🔴 This toggle will cause the body of DarkModeView to recompute even though we're
///       // only changing isAnalyticsEnabled!
///       Toggle(isOn: $model.preferences.isAnalyticsEnabled) {
///         Text("Is Analytics Enabled")
///       }
///     }
///   }
/// }
///
/// struct DarkModeView: View {
///   @Environment(PreferencesModel.self) var model
///
///   var body: some View {
///     @Bindable var model = self.model
///     VStack {
///       // 🔴 This toggle will cause the body of AnalyticsView to recompute even though we're
///       // only changing isDarkModeEnabled!
///       Toggle(isOn: $model.preferences.isDarkModeEnabled) {
///         Text("Is Dark Mode Enabled")
///       }
///     }
///   }
/// }
/// ```
///
/// The reason this phenomenon occurs is because the `@Perceptible` and `@Observable` macro have no
/// way of detecting access to a single property of `Preferences`. Rather, they only detect the
/// access to `Preferences` as a whole because it is a value type.
///
/// To get around this, you can use ``ObservedValue`` and the ``ObservableValue`` protocol. First,
/// conform your value type to the ``ObservableValue`` protocol.
/// ```swift
/// struct Preferences: ObservableValue {
///   var isAnalyticsEnabled = true
///   var isDarkModeEnabled = true
///   // Many more properties...
/// }
/// ```
///
/// Next, leverage ``ObservedValue`` inside your model class.
/// ```swift
/// @Perceptible
/// final class BetterPreferencesModel {
///   var preferences = ObservedValue(Preferences())
/// }
/// ```
///
/// And finally, connect it with the view.
/// ```swift
/// struct BetterAnalyticsView: View {
///   @Environment(BetterPreferencesModel.self) var model
///
///   var body: some View {
///     @Bindable var model = self.model
///     VStack {
///       // ✅ This toggle will only cause this view's body to recompute.
///       Toggle(isOn: $model.preferences.isAnalyticsEnabled) {
///         Text("Is Analytics Enabled")
///       }
///     }
///   }
/// }
///
/// struct BetterDarkModeView: View {
///   @Environment(BetterPreferencesModel.self) var model
///
///   var body: some View {
///     @Bindable var model = self.model
///     VStack {
///       // ✅ This toggle will only cause this view's body to recompute.
///       Toggle(isOn: $model.preferences.isDarkModeEnabled) {
///         Text("Is Dark Mode Enabled")
///       }
///     }
///   }
/// }
/// ```
///
/// # Sharing an ObservedValue
///
/// You can also use ``ObservedValue`` to communicate value type changes from a parent to child
/// model, since ``ObservedValue`` is a reference type.
/// ```swift
/// // ✅ When the preferences change in ChildModel, those changes will be reflected in ParentModel.
///
/// @Perceptible
/// final class ParentModel {
///   var preferences: ObservedValue<Preferences>
///   var childModel: ChildModel
///
///   init() {
///     let preferences = ObservedValue(Preferences())
///     self.preferences = preferences
///     self.childModel = ChildModel(preferences: preferences)
///   }
/// }
///
/// @Perceptible
/// final class ChildModel {
///   var preferences: ObservedValue<Preferences>
///
///   init(preferences: ObservedValue<Preferences>) {
///     self.preferences = preferences
///   }
/// }
/// ```
@Perceptible
@dynamicMemberLookup
public final class ObservedValue<Value: ObservableValue> {
  private let willSet: ((Value, Value) -> Void)?
  private let didSet: ((Value, Value) -> Void)?
  
  @PerceptionIgnored private var _value: Value {
    willSet { self.willSet?(newValue, self._value) }
    didSet { self.didSet?(oldValue, self._value) }
  }
  
  @PerceptionIgnored private var observedPaths = Set<WritableKeyPath<Value, Box>>()
  
  /// Creates an observed value.
  ///
  /// - Parameters:
  ///   - value: The initial value.
  ///   - willSet: A closure to run as the willSet of the underlying value.
  ///   - didSet: A closure to run as the didSet of the underlying value.
  public init(
    _ value: Value,
    willSet: ((_ newValue: Value, _ oldValue: Value) -> Void)? = nil,
    didSet: ((_ oldValue: Value, _ newValue: Value) -> Void)? = nil
  ) {
    self._value = value
    self.willSet = willSet
    self.didSet = didSet
  }
}

// MARK: - Value

extension ObservedValue {
  /// The underlying value of this observed value.
  ///
  /// Only access this property if you need access to the entire value. If you only need to access
  /// a subset of properties from the entire value, prefer to use the dynamic member lookup
  /// capabilities of this observed value instead. Otherwise, you risk unnecessary observation
  /// changes that result from mutations to properties unrelated to those you've accessed.
  public var value: Value {
    get {
      self.access(keyPath: \.value)
      return self._value
    }
    set {
      self.withMutation(keyPath: \.value) {
        for path in self.observedPaths {
          self.withMutation(keyPath: self.modelKeyPath(for: path)) {
            self._value[keyPath: path] = newValue[keyPath: path]
          }
        }
        self._value = newValue
      }
    }
    _modify {
      for path in self.observedPaths {
        self._$perceptionRegistrar.willSet(self, keyPath: self.modelKeyPath(for: path))
      }
      self._$perceptionRegistrar.willSet(self, keyPath: \.value)
      defer {
        for path in self.observedPaths {
          self._$perceptionRegistrar.didSet(self, keyPath: self.modelKeyPath(for: path))
        }
        self._$perceptionRegistrar.didSet(self, keyPath: \.value)
      }
      yield &self._value
    }
  }
}

// MARK: - Dynamic Member Lookup

extension ObservedValue {
  /// Returns a value for the specified key path to the underlying value.
  public subscript<R>(dynamicMember keyPath: WritableKeyPath<Value, R>) -> R {
    get {
      self.access(keyPath: self.modelKeyPath(for: keyPath))
      return self._value[keyPath: keyPath]
    }
    set {
      self.withMutation(keyPath: self.modelKeyPath(for: keyPath)) {
        self.withMutation(keyPath: \.value) {
          self._value[keyPath: keyPath] = newValue
        }
      }
    }
  }
}

// MARK: - ModelKeyPath

extension ObservedValue {
  private func modelKeyPath<R>(
    for keyPath: WritableKeyPath<Value, R>
  ) -> KeyPath<ObservedValue<Value>, Box> {
    self.modelKeyPath(for: \.[keyPath])
  }
  
  private func modelKeyPath(
    for keyPath: WritableKeyPath<Value, Box>
  ) -> KeyPath<ObservedValue<Value>, Box> {
    self.observedPaths.insert(keyPath)
    return (\ObservedValue<Value>._value).appending(path: keyPath)
  }
}

// MARK: - Identifiable

// TODO: - Should this perform an access?

extension ObservedValue: Identifiable where Value: Identifiable {
  public var id: Value.ID {
    self._value.id
  }
}

// MARK: - Equatable

extension ObservedValue: Equatable where Value: Equatable {
  public static func == (lhs: ObservedValue<Value>, rhs: ObservedValue<Value>) -> Bool {
    lhs._value == rhs._value
  }
}

// MARK: - Hashable

extension ObservedValue: Hashable where Value: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self._value)
  }
}

// MARK: - Comparable

extension ObservedValue: Comparable where Value: Comparable {
  public static func < (lhs: ObservedValue<Value>, rhs: ObservedValue<Value>) -> Bool {
    lhs._value < rhs._value
  }
}

// MARK: - Encodable

extension ObservedValue: Encodable where Value: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self._value)
  }
}

// MARK: - Decodable

extension ObservedValue: Decodable where Value: Decodable {
  public convenience init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(try container.decode(Value.self))
  }
}

// MARK: - Strideable

extension ObservedValue: Strideable where Value: Strideable {
  public func distance(to other: ObservedValue<Value>) -> Value.Stride {
    self._value.distance(to: other._value)
  }
  
  public func advanced(by n: Value.Stride) -> ObservedValue<Value> {
    ObservedValue(self._value.advanced(by: n))
  }
}

// MARK: - CustomStringConvertible

extension ObservedValue: CustomStringConvertible where Value: CustomStringConvertible {
  public var description: String {
    self._value.description
  }
}

// MARK: - CustomDebugStringConvertible

extension ObservedValue: CustomDebugStringConvertible where Value: CustomDebugStringConvertible {
  public var debugDescription: String {
    self._value.debugDescription
  }
}

// MARK: - CustomReflectable

extension ObservedValue: CustomReflectable where Value: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(reflecting: self._value)
  }
}
