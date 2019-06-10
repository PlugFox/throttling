library throttling;

/*
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * MIT License
 *
 * Copyright (c) 2019 Plugfox
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 */

import 'dart:async';

///  Throttling
///  Have method [throttle]
class Throttling {
  Duration _duration;
  Duration get duration => this._duration;
  set duration(Duration value) {
    assert(duration is Duration && !duration.isNegative);
    this._duration = value;
  }
  bool _isReady = true;
  bool get isReady => isReady;
  Future<void> get _waiter => Future.delayed(this._duration);
  // ignore: close_sinks
  final StreamController<bool> _stateSC = new StreamController<bool>.broadcast();

  Throttling({Duration duration = const Duration(seconds: 1)})
  : assert(duration is Duration && !duration.isNegative)
  , this._duration = duration ?? Duration(seconds: 1)
  {
    this._stateSC.sink.add(true);
  }

  dynamic throttle(Function func) {
    if (!this._isReady) return null;
    this._stateSC.sink.add(false);
    this._isReady = false;
    _waiter..then((_) {
      this._isReady = true;
      this._stateSC.sink.add(true);
    });
    return Function.apply(func, []);
  }

  StreamSubscription<bool> listen(Function(bool) onData) => this._stateSC.stream.listen(onData);

  dispose() {
    this._stateSC.close();
  }
}

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
  StreamController<dynamic> _resultSC = new StreamController<dynamic>.broadcast();
  // ignore: close_sinks
  final StreamController<bool> _stateSC = new StreamController<bool>.broadcast();

  Debouncing({Duration duration = const Duration(seconds: 1)})
  : assert(duration is Duration && !duration.isNegative)
  , this._duration = duration ?? Duration(seconds: 1)
  {
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

  StreamSubscription<bool> listen(Function(bool) onData) => this._stateSC.stream.listen(onData);

  dispose() {
    this._resultSC.close();
    this._stateSC.close();
  }
}
