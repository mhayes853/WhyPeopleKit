function DOMException(message, name) {
  Error.call(this, message);
  this[Symbol._wpJSCorePrivate] = { message, name };
}

Object.defineProperties(DOMException.prototype, {
  name: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].name;
    },
    enumerable: true,
    configurable: true,
  },
  message: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].message;
    },
    enumerable: false,
    configurable: true,
  },
});
