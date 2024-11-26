function Headers(headers) {
  const convert = (value, delmimeter = ",") => {
    return Array.isArray(value) ? value.join(delmimeter) : value.toString();
  };

  if (typeof headers === "object" && Symbol.iterator in headers) {
    const array = Array.isArray(headers) ? headers : Array.from(headers);
    const stringified = array.map((h) => {
      if (!Array.isArray(h)) {
        throw _wpJSCoreFailedToConstruct(
          "Headers",
          "The provided value cannot be converted to a sequence.",
        );
      }
      if (h.length !== 2) {
        throw _wpJSCoreFailedToConstruct("Headers", "Invalid value.");
      }
      const [key, value] = h;
      return [key.toString().toLowerCase(), convert(value)];
    });
    this[Symbol._wpJSCorePrivate] = { map: new Map(stringified) };
  } else if (headers === undefined) {
    this[Symbol._wpJSCorePrivate] = { map: new Map() };
  } else if (typeof headers === "object") {
    const stringified = Object.entries(headers).map(([key, value]) => {
      return [key.toString().toLowerCase(), convert(value)];
    });
    this[Symbol._wpJSCorePrivate] = { map: new Map(stringified) };
  } else {
    throw _wpJSCoreFailedToConstruct(
      "Headers",
      "The provided value is not of type '(record<ByteString, ByteString> or sequence<sequence<ByteString>>)'.",
    );
  }
  this[Symbol._wpJSCorePrivate].convert = convert;
  this[Symbol.iterator] = this.entries;
}

Object.defineProperties(Headers.prototype, {
  entries: {
    value: function* () {
      for (const [key, value] of this[Symbol._wpJSCorePrivate].map.entries()) {
        yield [
          key.toString(),
          this[Symbol._wpJSCorePrivate].convert(value, ", "),
        ];
      }
    },
    enumerable: false,
    configurable: true,
  },
  values: {
    value: function* () {
      for (const [_, value] of this.entries()) {
        yield value;
      }
    },
    enumerable: false,
    configurable: true,
  },
  keys: {
    value: function* () {
      for (const [key, _] of this.entries()) {
        yield key;
      }
    },
    enumerable: false,
    configurable: true,
  },
  forEach: {
    value: function (fn) {
      _wpJSCoreEnsureMinArgCount("forEach", "Headers", [fn], 1);
      if (typeof fn !== "function") {
        throw _wpJSCoreFailedToExecute(
          "Headers",
          "forEach",
          "parameter 1 is not of type 'Function'.",
        );
      }
      for (const [_, value] of this.entries()) {
        fn(value);
      }
    },
    enumerable: false,
    configurable: true,
  },
  has: {
    value: function (key) {
      _wpJSCoreEnsureMinArgCount("has", "Headers", [key], 1);
      return this.get(key) !== null;
    },
    enumerable: false,
    configurable: true,
  },
  get: {
    value: function (key) {
      _wpJSCoreEnsureMinArgCount("get", "Headers", [key], 1);
      const value = this[Symbol._wpJSCorePrivate].map.get(
        key.toString().toLowerCase(),
      );
      return value ? this[Symbol._wpJSCorePrivate].convert(value, ", ") : null;
    },
    enumerable: false,
    configurable: true,
  },
  getSetCookie: {
    value: function () {
      const cookie = this[Symbol._wpJSCorePrivate].map.get("set-cookie");
      if (Array.isArray(cookie)) {
        return cookie;
      } else if (typeof cookie === "string") {
        return [cookie];
      } else {
        return [];
      }
    },
    enumerable: false,
    configurable: true,
  },
  set: {
    value: function (key, value) {
      _wpJSCoreEnsureMinArgCount("set", "Headers", [key, value], 2);
      this[Symbol._wpJSCorePrivate].map.set(
        key.toString().toLowerCase(),
        this[Symbol._wpJSCorePrivate].convert(value),
      );
    },
    enumerable: false,
    configurable: true,
  },
  append: {
    value: function (key, value) {
      _wpJSCoreEnsureMinArgCount("append", "Headers", [key, value], 2);
      const currentValue = this[Symbol._wpJSCorePrivate].map.get(
        key.toString().toLowerCase(),
      );
      if (currentValue === undefined) {
        this[Symbol._wpJSCorePrivate].map.set(key.toString().toLowerCase(), [
          this[Symbol._wpJSCorePrivate].convert(value),
        ]);
      } else if (Array.isArray(currentValue)) {
        currentValue.push(this[Symbol._wpJSCorePrivate].convert(value));
      } else {
        this[Symbol._wpJSCorePrivate].map.set(key.toString().toLowerCase(), [
          currentValue,
          this[Symbol._wpJSCorePrivate].convert(value),
        ]);
      }
    },
    enumerable: false,
    configurable: true,
  },
  delete: {
    value: function (key) {
      _wpJSCoreEnsureMinArgCount("delete", "Headers", [key], 1);
      this[Symbol._wpJSCorePrivate].map.delete(key.toString().toLowerCase());
    },
    enumerable: false,
    configurable: true,
  },
});
