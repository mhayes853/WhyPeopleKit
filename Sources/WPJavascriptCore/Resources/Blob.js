function Blob(dataIterable, options = { type: "", endings: "transparent" }) {
  const isIterable =
    typeof dataIterable === "object" && Symbol.iterator in dataIterable;
  const isNative = dataIterable instanceof _WPJSCoreBlob;
  if (!isIterable && !isNative && dataIterable !== undefined) {
    throw new TypeError(
      "Failed to construct 'Blob': The provided value cannot be converted to a sequence.",
    );
  }
  if (!isNative) {
    this[Symbol._wpJSCorePrivate] = new _WPJSCoreBlob(dataIterable, options);
  } else {
    this[Symbol._wpJSCorePrivate] = dataIterable;
  }
}

Object.defineProperties(Blob.prototype, {
  type: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].type;
    },
    enumerable: false,
    configurable: true,
  },
  size: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].size;
    },
    enumerable: false,
    configurable: true,
  },
  text: {
    value: function () {
      return this[Symbol._wpJSCorePrivate].text();
    },
    enumerable: false,
    configurable: true,
  },
  slice: {
    value: function (start, end, type) {
      return new Blob(this[Symbol._wpJSCorePrivate].slice(start, end, type));
    },
    enumerable: false,
    configurable: true,
  },
});
