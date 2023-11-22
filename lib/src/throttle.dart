import 'dart:async';

/// Throttling status
enum ThrottlingStatus {
  /// Ready to accept new events
  idle,

  /// Waiting for the end of the pause
  busy,
}

/// Throttling
/// Have method [throttle]
class Throttling<T> extends Stream<ThrottlingStatus>
    implements Sink<T Function()> {
  /// Throttling
  /// Have method [throttle]
  /// Must be closed with [close] method
  Throttling({Duration duration = const Duration(seconds: 1)})
      : assert(!duration.isNegative, 'Duration must be positive'),
        _duration = duration {
    _stateSC.sink.add(ThrottlingStatus.idle);
  }
  Duration _duration;

  /// Get current duration
  Duration get duration => _duration;

  /// Set new duration
  set duration(Duration value) {
    assert(!duration.isNegative, 'Duration must be positive');
    _duration = value;
  }

  bool _isReady = true;

  /// is ready
  bool get isReady => _isReady;
  Future<void> get _waiter => Future.delayed(_duration);
  // ignore: close_sinks
  final StreamController<ThrottlingStatus> _stateSC =
      StreamController<ThrottlingStatus>.broadcast(sync: true);

  /// Limits the maximum number of times a given
  /// event handler can be called over time
  T? throttle(T Function() func) {
    if (!_isReady) return null;
    _stateSC.sink.add(ThrottlingStatus.busy);
    _isReady = false;
    _waiter.then((_) {
      _isReady = true;
      if (!_stateSC.isClosed) {
        _stateSC.sink.add(ThrottlingStatus.idle);
      }
    });
    return func();
  }

  @override
  StreamSubscription<ThrottlingStatus> listen(
    // ignore: avoid_positional_boolean_parameters
    void Function(ThrottlingStatus status)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _stateSC.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  /// Closing instances of Sink prevents
  /// memory leaks and unexpected behavior.
  @Deprecated('Use [close] instead')
  void dispose() => close();

  /// Shortcut for [throttle] method
  @override
  T? add(T Function() data) => throttle(data);

  @override
  Future<void> close() => _stateSC.close();
}
