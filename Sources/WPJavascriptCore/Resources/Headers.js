function Headers(headers) {
  const convert = (value, delmimeter = ",") => {
    return Array.isArray(value) ? value.join(delmimeter) : value.toString();
  };

  if (Array.isArray(headers)) {
    const stringified = headers.map((h) => {
      if (!Array.isArray(h)) {
        throw new TypeError(
          "Failed to construct 'Headers': The provided value cannot be converted to a sequence.",
        );
      }
      if (h.length !== 2) {
        throw new TypeError("Failed to construct 'Headers': Invalid value.");
      }
      const [key, value] = h;
      return [key.toString().toLowerCase(), convert(value)];
    });
    this[Symbol._wpJSCorePrivate] = { map: new Map(stringified) };
  } else if (headers === undefined) {
    this[Symbol._wpJSCorePrivate] = { map: new Map() };
  } else if (headers instanceof Map) {
    const stringified = Array.from(headers).map(([key, value]) => {
      return [key.toString().toLowerCase(), convert(value)];
    });
    this[Symbol._wpJSCorePrivate] = { map: new Map(stringified) };
  } else if (typeof headers === "object") {
    const stringified = Object.entries(headers).map(([key, value]) => {
      return [key.toString().toLowerCase(), convert(value)];
    });
    this[Symbol._wpJSCorePrivate] = { map: new Map(stringified) };
  } else {
    throw new TypeError(
      "Failed to construct 'Headers': The provided value is not of type '(record<ByteString, ByteString> or sequence<sequence<ByteString>>)'.",
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
      for (const [_, value] of this.entries()) {
        fn(value);
      }
    },
    enumerable: false,
    configurable: true,
  },
  has: {
    value: function (key) {
      return this.get(key) !== null;
    },
    enumerable: false,
    configurable: true,
  },
  get: {
    value: function (key) {
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
      this[Symbol._wpJSCorePrivate].map.delete(key.toString().toLowerCase());
    },
    enumerable: false,
    configurable: true,
  },
});
