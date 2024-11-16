function AbortController() {
  this._signal = new AbortSignal();
}

Object.defineProperty(AbortController.prototype, "signal", {
  get: function () {
    return this._signal;
  },
  enumerable: true,
  configurable: true,
});

Object.defineProperty(AbortController.prototype, "abort", {
  value: function (reason) {
    this._signal._abort(reason);
  },
  enumerable: false,
  configurable: true,
});

function AbortSignal() {
  this._subscribers = [];
  this._aborted = false;
  this._reason = undefined;
  this.onabort = undefined;
}

Object.defineProperty(AbortSignal.prototype, "aborted", {
  get: function () {
    return this._aborted;
  },
  enumerable: true,
  configurable: true,
});

Object.defineProperty(AbortSignal.prototype, "reason", {
  get: function () {
    return this._reason;
  },
  enumerable: true,
  configurable: true,
});

Object.defineProperty(AbortSignal.prototype, "throwIfAborted", {
  value: function () {
    if (!this.aborted) return;
    if (this.reason) throw this.reason;
    throw new Error("AbortError: signal is aborted without reason");
  },
  enumerable: false,
  configurable: true,
});

Object.defineProperty(AbortSignal.prototype, "_abort", {
  value: function (reason) {
    if (this.aborted) return;
    const event = { type: "abort", target: this };
    this._aborted = true;
    this._reason = reason;
    this.onabort?.(event);
    this._subscribers.forEach((s) => s(event));
  },
  enumerable: false,
  configurable: true,
});

// NB: It seems that JSCore doesn't provide EventTarget, so we'll have to implement event
// listeners by hand.

Object.defineProperty(AbortSignal.prototype, "addEventListener", {
  value: function (event, listener) {
    if (event !== "abort") return;
    this._subscribers.push(listener);
  },
  enumerable: false,
  configurable: true,
});

Object.defineProperty(AbortSignal.prototype, "removeEventListener", {
  value: function (event, listener) {
    if (event !== "abort") return;
    this._subscribers = this._subscribers.filter((s) => s !== listener);
  },
  enumerable: false,
  configurable: true,
});
