import 'dart:async';

import 'package:throttling/throttling.dart';

abstract class Example {
  static Future<void> throttleExample() async {
    print('\n### Throttling example');

    final thr = Throttling<void>(duration: const Duration(milliseconds: 300));

    final sub = thr.listen((state) {
      print(' * throttling is '
          '${state.isIdle ? 'ready' : 'busy'}');
    });

    thr.throttle(() {
      print('. 1');
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
    thr.throttle(() {
      print('. 2');
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
    thr.throttle(() {
      print('. 3');
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
    thr.throttle(() {
      print('. 4');
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
    thr.throttle(() {
      print('. 5');
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await sub.cancel();
    thr.close();
  }

  static Future<void> debounceExample() async {
    print('\n### Debouncing example');

    final deb = Debouncing<void>(duration: const Duration(milliseconds: 300));

    final sub = deb.listen((status) {
      print(' * debouncing is '
          '${status.isIdle ? 'ready' : 'busy'}');
    });

    await deb.debounce(() {
      print('. 1');
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await deb.debounce(() {
      print('. 2');
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await deb.debounce(() {
      print('. 3');
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await deb.debounce(() {
      print('. 4');
    });
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await deb.debounce(() {
      print('. 5');
    });

    await Future<void>.delayed(const Duration(milliseconds: 100));
    await sub.cancel();
    deb.close();
  }
}
