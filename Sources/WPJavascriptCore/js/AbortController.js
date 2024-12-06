function AbortController() {
  this[Symbol._wpJSCorePrivate] = new AbortSignal(Symbol._wpJSCorePrivate);
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
      const signal = this[Symbol._wpJSCorePrivate];
      signal[Symbol._wpJSCorePrivate].abort(signal, reason);
    },
    enumerable: false,
    configurable: true,
  },
});

function AbortSignal(key) {
  if (key !== Symbol._wpJSCorePrivate) {
    throw new TypeError("Illegal constructor");
  }
  this[Symbol._wpJSCorePrivate] = {
    subscribers: [],
    dependencies: [],
    aborted: false,
    reason: undefined,
    onabort: undefined,
    abort: (signal, reason) => {
      const state = signal[Symbol._wpJSCorePrivate];
      if (state.aborted) return;
      const event = { type: "abort", target: signal };
      state.aborted = true;
      state.reason = reason;
      state.onabort?.(event);
      for (const subscriber of state.subscribers) {
        subscriber({ ...event });
      }
      for (dependentSignal of state.dependencies) {
        dependentSignal[Symbol._wpJSCorePrivate].abort(dependentSignal, reason);
      }
    },
    addDependency: (signal, other) => {
      signal[Symbol._wpJSCorePrivate].dependencies.push(other);
    },
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
  // NB: It seems that JSCore doesn't provide EventTarget, so we'll have to implement event
  // listeners by hand.
  addEventListener: {
    value: function (event, listener) {
      _wpJSCoreEnsureMinArgCount(
        "addEventListener",
        "AbortSignal",
        [event, listener],
        2,
      );
      if (typeof listener !== "object" && typeof listener !== "function") {
        throw _wpJSCoreFailedToExecute(
          "AbortSignal",
          "addEventListener",
          "parameter 2 is not of type 'Object'",
        );
      }
      if (event !== "abort") return;
      this[Symbol._wpJSCorePrivate].subscribers.push(listener);
    },
    enumerable: false,
    configurable: true,
  },
  removeEventListener: {
    value: function (event, listener) {
      _wpJSCoreEnsureMinArgCount(
        "removeEventListener",
        "AbortSignal",
        [event, listener],
        2,
      );
      if (typeof listener !== "object" && typeof listener !== "function") {
        throw _wpJSCoreFailedToExecute(
          "AbortSignal",
          "removeEventListener",
          "parameter 2 is not of type 'Object'",
        );
      }
      const state = this[Symbol._wpJSCorePrivate];
      if (event !== "abort") return;
      state.subscribers = state.subscribers.filter((s) => s !== listener);
    },
    enumerable: false,
    configurable: true,
  },
});

AbortSignal.abort = function (reason) {
  const controller = new AbortController();
  controller.abort(reason);
  return controller.signal;
};

AbortSignal.timeout = function (millis) {
  _wpJSCoreEnsureMinArgCount("timeout", "AbortSignal", [millis], 1);
  if (typeof millis !== "number") {
    throw _wpJSCoreFailedToExecute(
      "AbortSignal",
      "timeout",
      "Value is not of type 'unsigned long long'.",
    );
  }
  const controller = new AbortController();
  _wpJSCoreAbortSignalTimeout(controller, millis / 1000);
  return controller.signal;
};

AbortSignal.any = function (signals) {
  _wpJSCoreEnsureMinArgCount("any", "AbortSignal", [signals], 1);
  if (!(Symbol.iterator in signals)) {
    throw _wpJSCoreFailedToExecute(
      "AbortSignal",
      "any",
      "The provided value cannot be converted to a sequence.",
    );
  }
  const controller = new AbortController();
  for (const s of signals) {
    if (!(s instanceof AbortSignal)) {
      throw _wpJSCoreFailedToExecute(
        "AbortSignal",
        "any",
        "Failed to convert value to 'AbortSignal'.",
      );
    }
    if (s.aborted) {
      controller.abort(s.reason);
      return controller.signal;
    }
  }
  for (const s of signals) {
    s[Symbol._wpJSCorePrivate].addDependency(s, controller.signal);
  }
  return controller.signal;
};
