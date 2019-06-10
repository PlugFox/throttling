import 'dart:async';

///  Debouncing
///  Have method [debounce]
class Debouncing {
  Duration _duration;
  Duration get duration => this._duration;
  set duration(Duration value) {
    assert(duration is Duration && !duration.isNegative);
    this._duration = value;
  }

  Timer _waiter;
  bool _isReady = true;
  bool get isReady => isReady;
  // ignore: close_sinks
  StreamController<dynamic> _resultSC =
      new StreamController<dynamic>.broadcast();
  // ignore: close_sinks
  final StreamController<bool> _stateSC =
      new StreamController<bool>.broadcast();

  Debouncing({Duration duration = const Duration(seconds: 1)})
      : assert(duration is Duration && !duration.isNegative),
        this._duration = duration ?? Duration(seconds: 1) {
    this._stateSC.sink.add(true);
  }

  Future<dynamic> debounce(Function func) async {
    if (this._waiter?.isActive ?? false) {
      this._waiter?.cancel();
      this._resultSC.sink.add(null);
    }
    this._isReady = false;
    this._stateSC.sink.add(false);
    this._waiter = Timer(this._duration, () {
      this._isReady = true;
      this._stateSC.sink.add(true);
      this._resultSC.sink.add(Function.apply(func, []));
    });
    return this._resultSC.stream.first;
  }

  StreamSubscription<bool> listen(Function(bool) onData) =>
      this._stateSC.stream.listen(onData);

  dispose() {
    this._resultSC.close();
    this._stateSC.close();
  }
}
