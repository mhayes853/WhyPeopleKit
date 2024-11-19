function FormData() {
  this[Symbol._wpJSCorePrivate] = new Map();
  this[Symbol.iterator] = this.entries;
}

Object.defineProperties(FormData.prototype, {
  entries: {
    value: function* () {
      for (const [key, values] of this[Symbol._wpJSCorePrivate].entries()) {
        for (const value of values) {
          yield [key, value];
        }
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
  append: {
    value: function (key, value, filename) {
      const values = this[Symbol._wpJSCorePrivate].get(key.toString()) ?? [];
      values.push(this._convertValue(value, filename, "append"));
      this[Symbol._wpJSCorePrivate].set(key.toString(), values);
    },
    enumerable: false,
    configurable: true,
  },
  set: {
    value: function (key, value, filename) {
      this[Symbol._wpJSCorePrivate].set(key.toString(), [
        this._convertValue(value, filename, "set"),
      ]);
    },
    enumerable: false,
    configurable: true,
  },
  delete: {
    value: function (key) {
      this[Symbol._wpJSCorePrivate].delete(key.toString());
    },
    enumerable: false,
    configurable: true,
  },
  has: {
    value: function (key) {
      return this[Symbol._wpJSCorePrivate].has(key.toString());
    },
    enumerable: false,
    configurable: true,
  },
  get: {
    value: function (key) {
      const values = this[Symbol._wpJSCorePrivate].get(key.toString());
      return values !== undefined ? values[0] : null;
    },
    enumerable: false,
    configurable: true,
  },
  getAll: {
    value: function (key) {
      return this[Symbol._wpJSCorePrivate].get(key.toString()) ?? [];
    },
    enumerable: false,
    configurable: true,
  },
  _convertValue: {
    value: function (value, filename, kind) {
      if (value instanceof File) {
        return new File(value, filename ?? value.name, {
          lastModified: value.lastModified,
          type: value.type,
        });
      } else if (value instanceof Blob) {
        return new File(value, filename ?? "blob");
      }
      if (filename !== undefined) {
        throw new TypeError(
          `Failed to execute '${kind}' on 'FormData': parameter 2 is not of type 'Blob'.`,
        );
      }
      return value.toString();
    },
    enumerable: false,
    configurable: true,
  },
});
