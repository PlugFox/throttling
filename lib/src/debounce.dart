import 'dart:async';

///  Debouncing
///  Have method [debounce]
class Debouncing {
  Duration _duration;
  Duration get duration => _duration;
  set duration(Duration value) {
    assert(duration is Duration && !duration.isNegative);
    _duration = value;
  }

  Timer _waiter;
  bool _isReady = true;
  bool get isReady => _isReady;
  // ignore: close_sinks
  final StreamController<dynamic> _resultSC =
      StreamController<dynamic>.broadcast();
  // ignore: close_sinks
  final StreamController<bool> _stateSC = StreamController<bool>.broadcast();

  Debouncing({Duration duration = const Duration(seconds: 1)})
      : assert(duration is Duration && !duration.isNegative),
        _duration = duration ?? Duration(seconds: 1) {
    _stateSC.sink.add(true);
  }

  /// allows you to control events being triggered successively and, if the interval between two sequential occurrences is less than a certain amount of time (e.g. one second), it completely ignores the first one.
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

  StreamSubscription<bool> listen(Function(bool) onData) =>
      _stateSC.stream.listen(onData);

  /// close streams
  void dispose() {
    _resultSC.close();
    _stateSC.close();
  }
}
