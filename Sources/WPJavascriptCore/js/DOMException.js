function DOMException(message, name) {
  Error.call(this, message);
  this[Symbol._wpJSCorePrivate] = { message, name };
}

DOMException.prototype = Object.create(Error.prototype);
DOMException.prototype.constructor = DOMException;

Object.defineProperties(DOMException.prototype, {
  name: _wpJSCoreReadonlyProperty(function () {
    return this[Symbol._wpJSCorePrivate].name;
  }),
  message: _wpJSCoreReadonlyProperty(function () {
    return this[Symbol._wpJSCorePrivate].message;
  }),
});
