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

  @override
  String toString() => switch (this) {
        ThrottlingStatus.idle => 'idle',
        ThrottlingStatus.busy => 'busy',
      };
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

  /// {@nodoc}
  Timer? _timer;

  /// Is ready to accept new events
  bool get isIdle => switch (_timer?.isActive) {
        true => false,
        _ => true,
      };

  /// Waiting for the end of the pause
  bool get isBusy => !isIdle;

  /// {@nodoc}
  final StreamController<ThrottlingStatus> _stateSC =
      StreamController<ThrottlingStatus>.broadcast(sync: true);

  /// Limits the maximum number of times a given
  /// event handler can be called over time.
  ///
  /// Returns the result of the function.
  /// If the function is not ready to accept new events,
  /// it returns null.
  T? throttle(T Function() func) {
    if (_stateSC.isClosed || !isIdle) return null;
    _timer = Timer(_duration, () {
      _timer = null;
      if (_stateSC.isClosed) return;
      _stateSC.sink.add(ThrottlingStatus.idle);
    });
    _stateSC.sink.add(ThrottlingStatus.busy);
    try {
      return func();
    } on Object {
      rethrow;
    }
  }

  @override
  StreamSubscription<ThrottlingStatus> listen(
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
  void close() {
    _timer?.cancel();
    _timer = null;
    _stateSC.close().ignore();
  }
}
