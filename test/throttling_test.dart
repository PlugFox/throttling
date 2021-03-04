import 'package:test/test.dart';
import 'package:flutter_throttling/flutter_throttling.dart';
import 'dart:async';

void main() {
  test('Throttling', () async {
    print('# Throttling test');
    final Throttling thr = new Throttling(duration: Duration(seconds: 1));
    expect(thr is Throttling, true);
    expect(thr.duration is Duration, true);
    expect(thr.duration == Duration(seconds: 1), true);

    thr.duration = Duration(seconds: 3);
    expect(thr.duration == Duration(seconds: 3), true);

    int numberOfAllStates = 0;
    int numberOfReadyStates = 0;
    int numberOfBusyStates = 0;
    StreamSubscription<bool> subscription = thr.listen((bool state) {
      expect(state is bool, true);
      print(
          ' *throttling#${thr.hashCode.toRadixString(36)} is ${state ? 'ready' : 'busy'}');
      numberOfAllStates++;
      if (state) {
        numberOfReadyStates++;
      } else {
        numberOfBusyStates++;
      }
    });

    dynamic result;
    Future<void> pause([int sec = 1]) =>
        Future.delayed(Duration(seconds: sec)).whenComplete(() => null);

    result = thr.throttle(() {
      print('. 1');
      return 1;
    });
    expect(result, 1);
    await pause();

    result = thr.throttle(() {
      print('. 2');
      return 2;
    });
    expect(result, null);
    await pause();

    result = thr.throttle(() {
      print('. 3');
      return 3;
    });
    expect(result, null);
    await pause();

    result = thr.throttle(() {
      print('. 4');
      return 4;
    });
    expect(result, 4);
    await pause();

    result = thr.throttle(() {
      print('. 5');
      return 5;
    });
    expect(result, null);
    await pause();

    subscription.cancel();
    expect(numberOfAllStates, 3);
    expect(numberOfReadyStates, 1);
    expect(numberOfBusyStates, 2);
  }, timeout: Timeout(Duration(seconds: 7)));

  test('Debouncing', () async {
    print('# Debouncing test');
    final Debouncing deb = new Debouncing(duration: Duration(seconds: 1));
    expect(deb is Debouncing, true);
    expect(deb.duration is Duration, true);
    expect(deb.duration, const Duration(seconds: 1));

    deb.duration = Duration(seconds: 3);
    expect(deb.duration, const Duration(seconds: 3));

    int numberOfAllStates = 0;
    int numberOfReadyStates = 0;
    int numberOfBusyStates = 0;
    StreamSubscription<bool> subscription = deb.listen((bool state) {
      expect(state is bool, true);
      print(
          ' *debouncing#${deb.hashCode.toRadixString(36)} is ${state ? 'ready' : 'busy'}');
      numberOfAllStates++;
      if (state) {
        numberOfReadyStates++;
      } else {
        numberOfBusyStates++;
      }
    });

    Future<dynamic> result;
    Future<void> pause([int sec = 1]) =>
        Future.delayed(Duration(seconds: sec)).whenComplete(() => null);

    result = deb.debounce(() {
      print('. 1');
      return 1;
    });
    await pause();
    result.then((dynamic value) {
      expect(value, null);
    });

    result = deb.debounce(() {
      print('. 2');
      return 2;
    });
    await pause();
    result.then((dynamic value) {
      expect(value, null);
    });

    result = deb.debounce(() {
      print('. 3');
      return 3;
    });
    await pause(4);
    result.then((dynamic value) {
      expect(value, 3);
    });

    subscription.cancel();
    expect(numberOfAllStates, 4);
    expect(numberOfReadyStates, 1);
    expect(numberOfBusyStates, 3);
  }, timeout: Timeout(Duration(seconds: 7)));
}
