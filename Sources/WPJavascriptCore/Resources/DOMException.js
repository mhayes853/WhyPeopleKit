Symbol._domException = Symbol("_domException");

function DOMException(message, name) {
  Error.call(this, message);
  this[Symbol._domException] = { message, name };
}

Object.defineProperties(DOMException.prototype, {
  name: {
    get: function () {
      return this[Symbol._domException].name;
    },
    enumerable: true,
    configurable: true,
  },
  message: {
    get: function () {
      return this[Symbol._domException].message;
    },
    enumerable: false,
    configurable: true,
  },
});
