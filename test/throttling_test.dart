// ignore_for_file: avoid_print

import 'dart:async';

import 'package:test/test.dart';
import 'package:throttling/throttling.dart';

void main() {
  test('Throttling', () async {
    print('# Throttling test');
    final thr = Throttling(duration: const Duration(seconds: 1));
    expect(thr, isA<Throttling>());
    expect(thr.duration, isA<Duration>());
    expect(thr.duration, equals(const Duration(seconds: 1)));

    thr.duration = const Duration(seconds: 3);
    expect(thr.duration == const Duration(seconds: 3), true);

    var numberOfAllStates = 0;
    var numberOfReadyStates = 0;
    var numberOfBusyStates = 0;
    var subscription = thr.listen((state) {
      expect(state, isTrue);
      print(' *throttling#${thr.hashCode.toRadixString(36)}'
          ' is ${state ? 'ready' : 'busy'}');
      numberOfAllStates++;
      if (state) {
        numberOfReadyStates++;
      } else {
        numberOfBusyStates++;
      }
    });

    dynamic result;
    Future<void> pause([int sec = 1]) =>
        Future<void>.delayed(Duration(seconds: sec)).whenComplete(() => null);

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

    await subscription.cancel();
    expect(numberOfAllStates, 3);
    expect(numberOfReadyStates, 1);
    expect(numberOfBusyStates, 2);
  }, timeout: const Timeout(Duration(seconds: 7)));

  test('Debouncing', () async {
    print('# Debouncing test');
    final deb = Debouncing(duration: const Duration(seconds: 1));
    expect(deb, isA<Debouncing>());
    expect(deb.duration, isA<Duration>());
    expect(deb.duration, const Duration(seconds: 1));

    deb.duration = const Duration(seconds: 3);
    expect(deb.duration, const Duration(seconds: 3));

    var numberOfAllStates = 0;
    var numberOfReadyStates = 0;
    var numberOfBusyStates = 0;
    var subscription = deb.listen((state) {
      expect(state, isTrue);
      print(' *debouncing#${deb.hashCode.toRadixString(36)}'
          ' is ${state ? 'ready' : 'busy'}');
      numberOfAllStates++;
      if (state) {
        numberOfReadyStates++;
      } else {
        numberOfBusyStates++;
      }
    });

    Future<dynamic> result;
    Future<void> pause([int sec = 1]) =>
        Future<void>.delayed(Duration(seconds: sec)).whenComplete(() => null);

    result = deb.debounce(() {
      print('. 1');
      return 1;
    });
    await pause();
    await result.then((value) {
      expect(value, null);
    });

    result = deb.debounce(() {
      print('. 2');
      return 2;
    });
    await pause();
    await result.then((value) {
      expect(value, null);
    });

    result = deb.debounce(() {
      print('. 3');
      return 3;
    });
    await pause(4);
    await result.then((value) {
      expect(value, 3);
    });

    await subscription.cancel();
    expect(numberOfAllStates, 4);
    expect(numberOfReadyStates, 1);
    expect(numberOfBusyStates, 3);
  }, timeout: const Timeout(Duration(seconds: 7)));
}
