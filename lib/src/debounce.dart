import 'dart:async';

/// Debouncing status
enum DebouncingStatus {
  /// Ready to accept new events
  idle,

  /// Waiting for the end of the pause
  busy,
}

/// Debouncing
/// Have method [debounce]
class Debouncing<T> extends Stream<DebouncingStatus>
    implements Sink<T Function()> {
  ///  Debouncing
  ///  Have method [debounce]
  /// Must be closed with [close] method
  Debouncing({Duration duration = const Duration(seconds: 1)})
      : assert(!duration.isNegative, 'Duration must be positive'),
        _duration = duration {
    _stateSC.sink.add(DebouncingStatus.idle);
  }
  Duration _duration;

  /// Get current duration
  Duration get duration => _duration;

  /// Set new duration
  set duration(Duration value) {
    assert(!duration.isNegative, 'Duration must be positive');
    _duration = value;
  }

  Timer? _waiter;
  bool _isReady = true;

  /// is ready
  bool get isReady => _isReady;
  // ignore: close_sinks
  final StreamController<T?> _resultSC = StreamController<T?>.broadcast();
  // ignore: close_sinks
  final StreamController<DebouncingStatus> _stateSC =
      StreamController<DebouncingStatus>.broadcast(sync: true);

  /// Allows you to control events being triggered successively and,
  /// if the interval between two sequential occurrences is less than
  /// a certain amount of time (e.g. one second),
  /// it completely ignores the first one.
  Future<T?> debounce(T Function() func) async {
    if (_waiter?.isActive ?? false) {
      _waiter?.cancel();
      _resultSC.sink.add(null);
    }
    _isReady = false;
    _stateSC.sink.add(DebouncingStatus.busy);
    _waiter = Timer(_duration, () {
      _isReady = true;
      _stateSC.sink.add(DebouncingStatus.idle);
      _resultSC.sink.add(func());
    });
    return _resultSC.stream.first;
  }

  @override
  StreamSubscription<DebouncingStatus> listen(
    // ignore: avoid_positional_boolean_parameters
    void Function(DebouncingStatus status)? onData, {
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

  /// Shortcut for [debounce] method
  @override
  Future<T?> add(T Function() data) => debounce(data);

  @override
  Future<void> close() => Future.wait<void>([
        _resultSC.close(),
        _stateSC.close(),
      ]);
}
