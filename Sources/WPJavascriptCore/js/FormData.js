function FormData() {
  this[Symbol._wpJSCorePrivate] = {
    map: new Map(),
    convertValue: (value, filename, kind) => {
      if (value instanceof File) {
        return new File(value, filename ?? value.name, {
          lastModified: value.lastModified,
          type: value.type,
        });
      } else if (value instanceof Blob) {
        return new File(value, filename ?? "blob");
      }
      if (filename !== undefined) {
        throw _wpJSCoreFailedToExecute(
          "FormData",
          kind,
          "parameter 2 is not of type 'Blob'.",
        );
      }
      return value.toString();
    },
  };
  this[Symbol.iterator] = this.entries;
}

function _wpJSCoreCopyFormData(formData) {
  const data = new FormData();
  data[Symbol._wpJSCorePrivate].map = new Map(
    formData[Symbol._wpJSCorePrivate].map,
  );
  return data;
}

function _wpJSCoreFormDataBoundary() {
  return `-----WPJavascriptCoreBoundary${Math.random().toString(36).substring(2)}`;
}

async function _wpJSCoreEncodedFormData(formData, boundary) {
  const entries = Array.from(formData);
  const texts = entries.map(([_, value]) => {
    if (value instanceof File) return value.text();
    return value;
  });
  const parts = [];
  for (let i = 0; i < entries.length; i++) {
    parts.push(`${boundary}\r\n`);
    const [key, file] = entries[i];
    const text = texts[i];
    if (!(text instanceof Promise)) {
      parts.push(
        `Content-Disposition: form-data; name="${key}"\r\n\r\n${text}\r\n`,
      );
      continue;
    }
    parts.push(
      `Content-Disposition: form-data; name="${key}"; filename="${file.name}"\r\nContent-Type: ${file.type}\r\n\r\n${await text}\r\n`,
    );
  }
  parts.push(`${boundary}--\r\n`);
  return parts.join("");
}

Object.defineProperties(FormData.prototype, {
  entries: {
    value: function* () {
      for (const [key, values] of this[Symbol._wpJSCorePrivate].map.entries()) {
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
  forEach: {
    value: function (fn) {
      _wpJSCoreEnsureMinArgCount("forEach", "FormData", [fn], 1);
      if (typeof fn !== "function") {
        throw _wpJSCoreFailedToExecute(
          "FormData",
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
      _wpJSCoreEnsureMinArgCount(
        "append",
        "FormData",
        [key, value, filename],
        3,
      );
      const values =
        this[Symbol._wpJSCorePrivate].map.get(key.toString()) ?? [];
      values.push(
        this[Symbol._wpJSCorePrivate].convertValue(value, filename, "append"),
      );
      this[Symbol._wpJSCorePrivate].map.set(key.toString(), values);
    },
    enumerable: false,
    configurable: true,
  },
  set: {
    value: function (key, value, filename) {
      _wpJSCoreEnsureMinArgCount("set", "FormData", [key, value, filename], 3);
      this[Symbol._wpJSCorePrivate].map.set(key.toString(), [
        this[Symbol._wpJSCorePrivate].convertValue(value, filename, "set"),
      ]);
    },
    enumerable: false,
    configurable: true,
  },
  delete: {
    value: function (key) {
      _wpJSCoreEnsureMinArgCount("delete", "FormData", [key], 1);
      this[Symbol._wpJSCorePrivate].map.delete(key.toString());
    },
    enumerable: false,
    configurable: true,
  },
  has: {
    value: function (key) {
      _wpJSCoreEnsureMinArgCount("has", "FormData", [key], 1);
      return this[Symbol._wpJSCorePrivate].map.has(key.toString());
    },
    enumerable: false,
    configurable: true,
  },
  get: {
    value: function (key) {
      _wpJSCoreEnsureMinArgCount("get", "FormData", [key], 1);
      const values = this[Symbol._wpJSCorePrivate].map.get(key.toString());
      return values !== undefined ? values[0] : null;
    },
    enumerable: false,
    configurable: true,
  },
  getAll: {
    value: function (key) {
      _wpJSCoreEnsureMinArgCount("getAll", "FormData", [key], 1);
      return this[Symbol._wpJSCorePrivate].map.get(key.toString()) ?? [];
    },
    enumerable: false,
    configurable: true,
  },
});
