function FormData() {
  this[Symbol._wpJSCorePrivate] = {
    map: new Map(),
  };
  this[Symbol.iterator] = this.entries;
}

function _wpJSCoreFormDataBoundary() {
  return `-----WPJavascriptCoreBoundary${Math.random().toString(36).substring(2)}`;
}

Object.defineProperties(FormData.prototype, {
  entries: _wpJSCoreFunctionProperty(function* () {
    for (const [key, values] of this[Symbol._wpJSCorePrivate].map.entries()) {
      for (const value of values) {
        yield [key, value];
      }
    }
  }),
  values: _wpJSCoreFunctionProperty(function* () {
    for (const [_, value] of this.entries()) {
      yield value;
    }
  }),
  forEach: _wpJSCoreFunctionProperty(function (fn) {
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
  }),
  keys: _wpJSCoreFunctionProperty(function* () {
    for (const [key, _] of this.entries()) {
      yield key;
    }
  }),
  append: _wpJSCoreFunctionProperty(function (key, value, filename) {
    _wpJSCoreEnsureMinArgCount("append", "FormData", [key, value, filename], 3);
    const values = this[Symbol._wpJSCorePrivate].map.get(key.toString()) ?? [];
    values.push(this._wpJSCoreConvertValue(value, filename, "append"));
    this[Symbol._wpJSCorePrivate].map.set(key.toString(), values);
  }),
  set: _wpJSCoreFunctionProperty(function (key, value, filename) {
    _wpJSCoreEnsureMinArgCount("set", "FormData", [key, value, filename], 3);
    this[Symbol._wpJSCorePrivate].map.set(key.toString(), [
      this._wpJSCoreConvertValue(value, filename, "set"),
    ]);
  }),
  delete: _wpJSCoreFunctionProperty(function (key) {
    _wpJSCoreEnsureMinArgCount("delete", "FormData", [key], 1);
    this[Symbol._wpJSCorePrivate].map.delete(key.toString());
  }),
  has: _wpJSCoreFunctionProperty(function (key) {
    _wpJSCoreEnsureMinArgCount("has", "FormData", [key], 1);
    return this[Symbol._wpJSCorePrivate].map.has(key.toString());
  }),
  get: _wpJSCoreFunctionProperty(function (key) {
    _wpJSCoreEnsureMinArgCount("get", "FormData", [key], 1);
    const values = this[Symbol._wpJSCorePrivate].map.get(key.toString());
    return values !== undefined ? values[0] : null;
  }),
  getAll: _wpJSCoreFunctionProperty(function (key) {
    _wpJSCoreEnsureMinArgCount("getAll", "FormData", [key], 1);
    return this[Symbol._wpJSCorePrivate].map.get(key.toString()) ?? [];
  }),
  _wpJSCoreConvertValue: _wpJSCoreFunctionProperty(
    function (value, filename, kind) {
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
  ),
  _wpJSCoreCopy: _wpJSCoreFunctionProperty(function () {
    const data = new FormData();
    data[Symbol._wpJSCorePrivate].map = new Map(
      this[Symbol._wpJSCorePrivate].map,
    );
    return data;
  }),
  _wpJSCoreEncoded: _wpJSCoreFunctionProperty(async function (boundary) {
    const entries = Array.from(this);
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
  }),
});
