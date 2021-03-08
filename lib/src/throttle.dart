import 'dart:async';

///  Throttling
///  Have method [throttle]
class Throttling {
  Duration _duration;
  Duration get duration => _duration;
  set duration(Duration value) {
    assert(duration is Duration && !duration.isNegative);
    _duration = value;
  }

  bool _isReady = true;
  bool get isReady => _isReady;
  Future<void> get _waiter => Future.delayed(_duration);
  // ignore: close_sinks
  final StreamController<bool> _stateSC = StreamController<bool>.broadcast();

  Throttling({Duration duration = const Duration(seconds: 1)})
      : assert(duration is Duration && !duration.isNegative),
        _duration = duration ?? Duration(seconds: 1) {
    _stateSC.sink.add(true);
  }

  /// limits the maximum number of times a given event handler can be called over time
  dynamic throttle(Function func) {
    if (!_isReady) return null;
    _stateSC.sink.add(false);
    _isReady = false;
    _waiter
      ..then((_) {
        _isReady = true;
        if (!_stateSC.isClosed) {
          _stateSC.sink.add(true);
        }
      });
    return Function.apply(func, []);
  }

  StreamSubscription<bool> listen(Function(bool) onData) =>
      _stateSC.stream.listen(onData);

  /// close streams
  void dispose() {
    _stateSC.close();
  }
}
