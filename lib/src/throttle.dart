import 'dart:async';

/// Throttling status
enum ThrottlingStatus {
  /// Ready to accept new events
  idle,

  /// Waiting for the end of the pause
  busy;

  const ThrottlingStatus();

  /// Ready to accept new events
  bool get isIdle => this == ThrottlingStatus.idle;

  /// Waiting for the end of the pause
  bool get isBusy => this == ThrottlingStatus.busy;
}

/// Throttling
/// Have method [throttle]
final class Throttling<T> extends Stream<ThrottlingStatus>
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

  /// Is ready to accept new events
  bool get isReady => _isReady;
  bool _isReady = true;

  final StreamController<ThrottlingStatus> _stateSC =
      StreamController<ThrottlingStatus>.broadcast(sync: true);

  /// Limits the maximum number of times a given
  /// event handler can be called over time.
  ///
  /// Returns the result of the function.
  /// If the function is not ready to accept new events,
  /// it returns null.
  T? throttle(T Function() func) {
    if (!_isReady) return null;
    _isReady = false;
    _stateSC.sink.add(ThrottlingStatus.busy);
    Timer(_duration, () {
      _isReady = true;
      if (_stateSC.isClosed) return;
      _stateSC.sink.add(ThrottlingStatus.idle);
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

  /// Shortcut for [throttle] method
  @override
  T? add(T Function() data) => throttle(data);

  @override
  void close() => _stateSC.close().ignore();
}
