function AbortController() {
  this[Symbol._wpJSCorePrivate] = new AbortSignal();
}

Object.defineProperties(AbortController.prototype, {
  signal: {
    get: function () {
      return this[Symbol._wpJSCorePrivate];
    },
    enumerable: true,
    configurable: true,
  },
  abort: {
    value: function (reason) {
      this[Symbol._wpJSCorePrivate]._abort(reason);
    },
    enumerable: false,
    configurable: true,
  },
});

function AbortSignal() {
  this[Symbol._wpJSCorePrivate] = {
    subscribers: [],
    aborted: false,
    reason: undefined,
    onabort: undefined,
  };
}

Object.defineProperties(AbortSignal.prototype, {
  aborted: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].aborted;
    },
    enumerable: true,
    configurable: true,
  },
  reason: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].reason;
    },
    enumerable: true,
    configurable: true,
  },
  onabort: {
    get: function () {
      return this[Symbol._wpJSCorePrivate].onabort;
    },
    set: function (fn) {
      this[Symbol._wpJSCorePrivate].onabort = fn;
    },
    enumerable: true,
    configurable: true,
  },
  throwIfAborted: {
    value: function () {
      const state = this[Symbol._wpJSCorePrivate];
      if (!state.aborted) return;
      if (state.reason) throw state.reason;
      throw new DOMException("signal is aborted without reason", "AbortError");
    },
    enumerable: false,
    configurable: true,
  },
  _abort: {
    value: function (reason) {
      const state = this[Symbol._wpJSCorePrivate];
      if (state.aborted) return;
      const event = { type: "abort", target: this };
      state.aborted = true;
      state.reason = reason;
      state.onabort?.(event);
      state.subscribers.forEach((s) => s(event));
    },
    enumerable: false,
    configurable: true,
  },
  // NB: It seems that JSCore doesn't provide EventTarget, so we'll have to implement event
  // listeners by hand.
  addEventListener: {
    value: function (event, listener) {
      if (event !== "abort") return;
      this[Symbol._wpJSCorePrivate].subscribers.push(listener);
    },
    enumerable: false,
    configurable: true,
  },
  removeEventListener: {
    value: function (event, listener) {
      const state = this[Symbol._wpJSCorePrivate];
      if (event !== "abort") return;
      state.subscribers = state.subscribers.filter((s) => s !== listener);
    },
    enumerable: false,
    configurable: true,
  },
});
