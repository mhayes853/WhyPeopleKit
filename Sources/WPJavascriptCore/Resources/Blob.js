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
    this[Symbol._wpJSCorePrivate] = {
      nativeBlob: new _WPJSCoreBlob(dataIterable, options),
    };
  } else {
    this[Symbol._wpJSCorePrivate] = { nativeBlob: dataIterable };
  }
}

Object.defineProperties(Blob.prototype, {
  type: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].nativeBlob.type;
    },
    enumerable: false,
    configurable: true,
  },
  size: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].nativeBlob.size;
    },
    enumerable: false,
    configurable: true,
  },
  text: {
    value: function () {
      return this[Symbol._wpJSCorePrivate].nativeBlob.text();
    },
    enumerable: false,
    configurable: true,
  },
  bytes: {
    value: async function () {
      return new Uint8Array(await this.arrayBuffer());
    },
    enumerable: false,
    configurable: true,
  },
  arrayBuffer: {
    value: function () {
      return this[Symbol._wpJSCorePrivate].nativeBlob.arrayBuffer();
    },
    enumerable: false,
    configurable: true,
  },
  slice: {
    value: function (start = 0, end = this.size, type = this.type) {
      return new Blob(
        this[Symbol._wpJSCorePrivate].nativeBlob.slice(start, end, type),
      );
    },
    enumerable: false,
    configurable: true,
  },
});
