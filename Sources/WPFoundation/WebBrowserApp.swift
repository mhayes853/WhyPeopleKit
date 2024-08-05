import Foundation

// MARK: - WebBrowserApp

/// A web browser app used for opening URLs.
public enum WebBrowserApp: String, Sendable, Codable {
  case systemDefault
  case inAppSafari
  case firefox
  case firefoxFocus
  case chrome
  case duckDuckGo
  case opera
  case operaGX
  case edge
  case brave
  case arcSearch
}

// MARK: - Localized Name

extension WebBrowserApp {
  /// A localized name for this web browser app identifier.
  public var localizedName: String {
    switch self {
    case .systemDefault: String(localized: "web.browser.app.system.default", bundle: .module)
    case .inAppSafari: String(localized: "web.browser.app.in.app.safari", bundle: .module)
    case .firefox: String(localized: "web.browser.app.firefox", bundle: .module)
    case .firefoxFocus: String(localized: "web.browser.app.firefox.focus", bundle: .module)
    case .chrome: String(localized: "web.browser.app.chrome", bundle: .module)
    case .duckDuckGo: String(localized: "web.browser.app.ddg", bundle: .module)
    case .opera: String(localized: "web.browser.app.opera", bundle: .module)
    case .operaGX: String(localized: "web.browser.app.opera.gx", bundle: .module)
    case .edge: String(localized: "web.browser.app.edge", bundle: .module)
    case .brave: String(localized: "web.browser.app.brave", bundle: .module)
    case .arcSearch: String(localized: "web.browser.app.arc.search", bundle: .module)
    }
  }
}

// MARK: - Deep Link URL

extension WebBrowserApp {
  /// Returns a `URL` that can be used to open the specified URL inside this browser app.
  public func deepLinkURL(for url: URL) -> URL? {
    switch self {
    case .inAppSafari: nil
    case .systemDefault: url
    case .chrome: url.replacingScheme(with: "googlechrome")
    case .firefox: url.with(browserName: "firefox")
    case .brave: url.with(browserName: "brave")
    case .opera: url.with(prefix: "touch-")
    case .edge: url.with(prefix: "microsoft-edge-")
    case .operaGX: url.with(browserName: "opera-gx")
    case .firefoxFocus: url.with(browserName: "firefox-focus")
    case .duckDuckGo: url.replacingScheme(with: "ddgQuickLink")
    case .arcSearch: url.with(browserName: "arcmobile2", openURLActionName: "goto")
    }
  }
}

extension URL {
  fileprivate func with(prefix: String) -> URL? {
    URL(string: "\(prefix)\(self)")
  }
  
  fileprivate func replacingScheme(with scheme: String) -> URL? {
    var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
    components?.scheme = scheme
    return components?.url
  }
  
  fileprivate func with(browserName: String, openURLActionName: String = "open-url") -> URL? {
    URL(string: "\(browserName)://\(openURLActionName)?url=\(self)")
  }
}

// MARK: - Supported Apps

#if canImport(UIKit) && canImport(SafariServices)
import UIKit
import SafariServices

extension WebBrowserApp {
  /// Returns an array of ``WebBrowserAppID``s that are supported on this device.
  public static var supportedApps: [WebBrowserApp] {
    let example = URL(string: "https://www.example.com")!
    let options: [WebBrowserApp] = [
      .inAppSafari,
      .systemDefault,
      .arcSearch,
      .brave,
      .chrome,
      .duckDuckGo,
      .edge,
      .firefox,
      .firefoxFocus,
      .opera,
      .operaGX
    ]
    let application = MainActor.runSync { UIApplication.shared }
    return options.filter {
      guard let url = $0.deepLinkURL(for: example) else {
        return true // NB: inAppSafari is the only one to return nil, and it is always supported
      }
      return application.canOpenURL(url)
    }
  }
}

// MARK: - Opening

extension WebBrowserApp {
  public struct InAppSafariOpenOptions {
    public var configuration: SFSafariViewController.Configuration
    public var delegate: SFSafariViewControllerDelegate?
    public var dismissButtonStyle: SFSafariViewController.DismissButtonStyle
    public var preferredBarTintColor: UIColor?
    public var preferredControlTintColor: UIColor?
    
    public init(
      configuration: SFSafariViewController.Configuration = SFSafariViewController.Configuration(),
      delegate: SFSafariViewControllerDelegate? = nil,
      dismissButtonStyle: SFSafariViewController.DismissButtonStyle = .done,
      preferredBarTintColor: UIColor? = nil,
      preferredControlTintColor: UIColor? = nil
    ) {
      self.configuration = configuration
      self.delegate = delegate
      self.dismissButtonStyle = dismissButtonStyle
      self.preferredBarTintColor = preferredBarTintColor
      self.preferredControlTintColor = preferredControlTintColor
    }
  }
  
  /// Opens the specified URL in this web browser app.
  ///
  /// - Parameters:
  ///   - url: The `URL` to open.
  ///   - safariOptions: ``InAppSafariOpenOptions`` to use if the URL needs to be opened in safari.
  /// - Returns: `true` if opening suceeded.
  @MainActor
  @discardableResult
  public func open(
    url: URL,
    safariOptions: InAppSafariOpenOptions = InAppSafariOpenOptions()
  ) async -> Bool {
    if let url = self.deepLinkURL(for: url) {
      return await UIApplication.shared.open(url)
    }
    self.openSafariView(url: url, options: safariOptions)
    return true
  }
  
  @MainActor
  private func openSafariView(url: URL, options: InAppSafariOpenOptions) {
    let vc = SFSafariViewController(url: url, configuration: options.configuration)
    vc.modalPresentationStyle = .overFullScreen
    vc.delegate = options.delegate
    vc.dismissButtonStyle = options.dismissButtonStyle
    vc.preferredBarTintColor = options.preferredBarTintColor
    vc.preferredControlTintColor = options.preferredControlTintColor
    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    let rootVc = scene?.windows.first(where: \.isKeyWindow)?.rootViewController
    rootVc?.present(vc, animated: true)
  }
}
#endif
