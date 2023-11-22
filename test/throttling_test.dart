// ignore_for_file: avoid_print

import 'dart:async';

import 'package:test/test.dart';
import 'package:throttling/throttling.dart';

void main() => group('unit', () {
      const defaultDuration = Duration(milliseconds: 50);
      late Throttling<int> thr;
      late Debouncing<int> deb;

      setUp(() {
        thr = Throttling<int>(duration: defaultDuration);
        deb = Debouncing<int>(duration: defaultDuration);
      });

      tearDown(() {
        thr.close();
        deb.close();
      });

      group('throttling', () {
        test('constructor', () {
          expect(() => Throttling<int>(duration: const Duration(seconds: 1)),
              returnsNormally);
        });

        test('types', () {
          expect(thr, isA<Throttling<int>>());
          expect(thr.duration, isA<Duration>());
          expect(thr.duration, equals(defaultDuration));
        });

        test('setter', () {
          thr.duration = const Duration(milliseconds: 100);
          expect(thr.duration, equals(const Duration(milliseconds: 100)));
        });

        test('1', () {
          final result = thr.throttle(() => 1);
          expect(result, equals(1));
        });

        test('1 -> 2', () {
          var result = thr.throttle(() => 1);
          expect(result, equals(1));
          result = thr.throttle(() => 2);
          expect(result, isNull);
        });

        test('1 -> pause -> 2', () async {
          var result = thr.throttle(() => 1);
          expect(result, equals(1));
          await Future<void>.delayed(thr.duration);
          result = thr.throttle(() => 2);
          expect(result, equals(2));
        });

        test('1 -> pause/2 -> 2 -> pause/2 -> 3', () async {
          var result = thr.throttle(() => 1);
          expect(result, equals(1));
          await Future<void>.delayed(thr.duration ~/ 2);
          result = thr.throttle(() => 2);
          expect(result, isNull);
          await Future<void>.delayed(thr.duration ~/ 2);
          result = thr.throttle(() => 3);
          expect(result, equals(3));
        });

        test('subscribe', () async {
          var idle = 1, busy = 0, total = 1;
          final subscription = thr.listen((status) {
            print(status);
            total++;
            if (status == ThrottlingStatus.idle) {
              idle++;
            } else {
              busy++;
            }
          });

          /* unawaited(
            expectLater(
                thr, emitsInOrder(<Object>[true, false, true, emitsDone])),
          ); */

          // Idle
          thr.throttle(() => 1);
          // Busy
          await Future<void>.delayed(thr.duration ~/ 2);
          thr.throttle(() => 2);
          await Future<void>.delayed(thr.duration ~/ 2);
          thr.throttle(() => 3);

          expect(idle, equals(2), reason: 'idle');
          expect(busy, equals(2), reason: 'busy');
          expect(total, equals(4), reason: 'total');

          await expectLater(subscription.cancel, completes);
        });
      });

      /*
      test('Debouncing', () async {
        print('# Debouncing test');
        expect(deb, isA<Debouncing<int>>());
        expect(deb.duration, isA<Duration>());
        expect(deb.duration, defaultDuration);

        deb.duration = const Duration(milliseconds: 100);
        expect(deb.duration, equals(const Duration(milliseconds: 100)));

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
        Future<void> pause([int ms = 25]) =>
            Future<void>.delayed(Duration(milliseconds: ms));

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
      }, timeout: const Timeout(Duration(seconds: 7))); */
    });
