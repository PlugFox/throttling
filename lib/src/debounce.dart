import 'dart:async';

/// Debouncing
/// Have method [debounce]
class Debouncing extends Stream<bool> implements Sink<Function> {
  Duration _duration;

  /// Get current duration
  Duration get duration => _duration;

  /// Set new duration
  set duration(Duration value) {
    assert(duration is Duration && !duration.isNegative);
    _duration = value;
  }

  Timer? _waiter;
  bool _isReady = true;

  /// is ready
  bool get isReady => _isReady;
  // ignore: close_sinks
  final StreamController<dynamic> _resultSC =
      StreamController<dynamic>.broadcast();
  // ignore: close_sinks
  final StreamController<bool> _stateSC = StreamController<bool>.broadcast();

  ///  Debouncing
  ///  Have method [debounce]
  /// Must be closed with [close] method
  Debouncing({Duration duration = const Duration(seconds: 1)})
      : assert(duration is Duration && !duration.isNegative),
        _duration = duration {
    _stateSC.sink.add(true);
  }

  /// allows you to control events being triggered successively and,
  /// if the interval between two sequential occurrences is less than
  /// a certain amount of time (e.g. one second),
  /// it completely ignores the first one.
  Future<dynamic> debounce(Function func) async {
    if (_waiter?.isActive ?? false) {
      _waiter?.cancel();
      _resultSC.sink.add(null);
    }
    _isReady = false;
    _stateSC.sink.add(false);
    _waiter = Timer(_duration, () {
      _isReady = true;
      _stateSC.sink.add(true);
      _resultSC.sink.add(Function.apply(func, []));
    });
    return _resultSC.stream.first;
  }

  @override
  StreamSubscription<bool> listen(
    void onData(bool event)?, {
    Function? onError,
    void onDone()?,
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
  dynamic add(Function data) => debounce(data);

  @override
  void close() => Future.wait<void>([
        _resultSC.close(),
        _stateSC.close(),
      ]);
}
