function Headers(headers) {
  if (Array.isArray(headers)) {
    const stringified = headers.map((h) => {
      if (!Array.isArray(h)) {
        throw new TypeError(
          "Failed to construct 'Headers': The provided value cannot be converted to a sequence.",
        );
      }
      const [key, value] = h;
      return [key.toString().toLowerCase(), value];
    });
    this[Symbol._wpJSCorePrivate] = new Map(stringified);
  } else if (headers === undefined) {
    this[Symbol._wpJSCorePrivate] = new Map();
  } else if (headers instanceof Map) {
    const stringified = Array.from(headers).map(([key, value]) => {
      return [key.toString().toLowerCase(), value];
    });
    this[Symbol._wpJSCorePrivate] = new Map(stringified);
  } else if (typeof headers === "object") {
    const stringified = Object.entries(headers).map(([key, value]) => {
      return [key.toString().toLowerCase(), value];
    });
    this[Symbol._wpJSCorePrivate] = new Map(stringified);
  } else {
    throw new TypeError(
      "Failed to construct 'Headers': The provided value is not of type '(record<ByteString, ByteString> or sequence<sequence<ByteString>>)'.",
    );
  }
}

Object.defineProperties(Headers.prototype, {
  entries: {
    value: function* () {
      for (const [key, value] of this[Symbol._wpJSCorePrivate].entries()) {
        yield [key.toString(), this._convert(value)];
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
      const value = this[Symbol._wpJSCorePrivate].get(
        key.toString().toLowerCase(),
      );
      return value ? this._convert(value) : null;
    },
    enumerable: false,
    configurable: true,
  },
  getSetCookie: {
    value: function () {
      return this[Symbol._wpJSCorePrivate].get("set-cookie") ?? [];
    },
    enumerable: false,
    configurable: true,
  },
  set: {
    value: function (key, value) {
      this[Symbol._wpJSCorePrivate].set(key.toString().toLowerCase(), value);
    },
    enumerable: false,
    configurable: true,
  },
  append: {
    value: function (key, value) {
      const currentValue = this[Symbol._wpJSCorePrivate].get(
        key.toString().toLowerCase(),
      );
      if (currentValue === undefined) {
        this[Symbol._wpJSCorePrivate].set(key.toString().toLowerCase(), [
          value,
        ]);
      } else if (Array.isArray(currentValue)) {
        currentValue.push(value);
      } else {
        this[Symbol._wpJSCorePrivate].set(key.toString().toLowerCase(), [
          currentValue,
          value,
        ]);
      }
    },
    enumerable: false,
    configurable: true,
  },
  delete: {
    value: function (key) {
      this[Symbol._wpJSCorePrivate].delete(key.toString().toLowerCase());
    },
    enumerable: false,
    configurable: true,
  },
  _convert: {
    value: function (value) {
      return Array.isArray(value) ? value.join(",") : value.toString();
    },
    enumerable: false,
    configurable: true,
  },
});
