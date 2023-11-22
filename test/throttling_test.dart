// ignore_for_file: avoid_print, cascade_invocations

import 'dart:async';

import 'package:test/test.dart';
import 'package:throttling/throttling.dart';

void main() => group('unit', () {
      const defaultDuration = Duration(milliseconds: 50);

      group('throttling', () {
        late Throttling<int> thr;

        setUp(() {
          thr = Throttling<int>(duration: defaultDuration);
        });

        tearDown(() {
          thr.close();
        });

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

        test('status', () {
          expect(thr.isIdle, isTrue);
          expect(thr.isBusy, isFalse);
          expect(ThrottlingStatus.idle.isIdle, isTrue);
          expect(ThrottlingStatus.busy.isBusy, isTrue);
          expect(ThrottlingStatus.idle.toString, returnsNormally);
          expect(ThrottlingStatus.busy.toString, returnsNormally);
        });

        test('close', () {
          expect(() => thr.close(), returnsNormally);
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

        test(
          'subscribe',
          () async {
            // Initial state is idle
            var idle = 1, busy = 0, total = 1;
            final subscription = thr.listen((status) {
              total++;
              if (status.isIdle)
                idle++;
              else
                busy++;
            });

            unawaited(
              expectLater(
                  thr,
                  emitsInOrder(<Object>[
                    ThrottlingStatus.busy,
                    ThrottlingStatus.idle,
                    ThrottlingStatus.busy,
                    ThrottlingStatus.idle,
                    emitsDone
                  ])),
            );

            thr.add(() => 1);
            await Future<void>.delayed(thr.duration ~/ 2);
            thr.add(() => 2);
            await Future<void>.delayed(thr.duration ~/ 2);
            thr.add(() => 3);
            await Future<void>.delayed(thr.duration);

            expect(idle, equals(3), reason: 'idle');
            expect(busy, equals(2), reason: 'busy');
            expect(total, equals(5), reason: 'total');

            await expectLater(subscription.cancel(), completes);
            thr.close();
          },
          timeout: const Timeout(Duration(seconds: 5)),
        );

        test('example', () async {
          final thr =
              Throttling<void>(duration: const Duration(milliseconds: 200));
          thr.throttle(() {
            /* print(' * 1'); */
          });
          await Future<void>.delayed(const Duration(milliseconds: 100));
          thr.throttle(() {
            /* print(' * 2'); */
          });
          await Future<void>.delayed(const Duration(milliseconds: 100));
          thr.throttle(() {
            /* print(' * 3'); */
          });
          thr.close();
        });
      });

      group('debouncing', () {
        late Debouncing<int> deb;

        setUp(() {
          deb = Debouncing<int>(duration: defaultDuration);
        });

        tearDown(() {
          deb.close();
        });

        test('constructor', () {
          expect(() => Debouncing<int>(duration: const Duration(seconds: 1)),
              returnsNormally);
        });

        test('types', () {
          expect(deb, isA<Debouncing<int>>());
          expect(deb.duration, isA<Duration>());
          expect(deb.duration, equals(defaultDuration));
        });

        test('setter', () {
          deb.duration = const Duration(milliseconds: 100);
          expect(deb.duration, equals(const Duration(milliseconds: 100)));
        });

        test('status', () {
          expect(deb.isIdle, isTrue);
          expect(deb.isBusy, isFalse);
          expect(DebouncingStatus.idle.isIdle, isTrue);
          expect(DebouncingStatus.busy.isBusy, isTrue);
          expect(DebouncingStatus.idle.toString, returnsNormally);
          expect(DebouncingStatus.busy.toString, returnsNormally);
        });

        test('close', () {
          expect(() => deb.close(), returnsNormally);
        });

        test('1', () {
          final result = deb.debounce(() => 1);
          expectLater(result, completion(equals(1)));
        });

        test('1 -> 2', () {
          var result = deb.debounce(() => 1);
          expectLater(result, completion(equals(2)));
          result = deb.debounce(() => 2);
          expectLater(result, completion(equals(2)));
        });

        test('1 -> pause -> 2', () async {
          var result = deb.debounce(() => 1);
          unawaited(expectLater(result, completion(equals(1))));
          await Future<void>.delayed(deb.duration);
          result = deb.debounce(() => 2);
          unawaited(expectLater(result, completion(equals(2))));
        });

        test('1 -> pause/2 -> 2 -> pause/2 -> 3', () async {
          var result = deb.debounce(() => 1);
          unawaited(expectLater(result, completion(equals(3))));
          await Future<void>.delayed(deb.duration ~/ 2);
          result = deb.debounce(() => 2);
          unawaited(expectLater(result, completion(equals(3))));
          await Future<void>.delayed(deb.duration ~/ 2);
          result = deb.debounce(() => 3);
          unawaited(expectLater(result, completion(equals(3))));
        });

        test(
          'subscribe',
          () async {
            // Initial state is idle
            var idle = 1, busy = 0, total = 1;
            final subscription = deb.listen((status) {
              total++;
              if (status.isIdle)
                idle++;
              else
                busy++;
            });

            unawaited(
              expectLater(
                  deb,
                  emitsInOrder(<Object>[
                    DebouncingStatus.busy,
                    DebouncingStatus.idle,
                    DebouncingStatus.busy,
                    DebouncingStatus.idle,
                    emitsDone
                  ])),
            );

            await expectLater(deb.add(() => 1), completion(equals(1)));
            unawaited(expectLater(deb.add(() => 2), completion(equals(3))));
            await Future<void>.delayed(deb.duration ~/ 2);
            await expectLater(deb.add(() => 3), completion(equals(3)));

            expect(idle, equals(3), reason: 'idle');
            expect(busy, equals(2), reason: 'busy');
            expect(total, equals(5), reason: 'total');

            await expectLater(subscription.cancel(), completes);
            deb.close();
          },
          timeout: const Timeout(Duration(seconds: 5)),
        );

        test('example', () async {
          final deb =
              Debouncing<void>(duration: const Duration(milliseconds: 200));
          // ignore: unawaited_futures
          deb.debounce(() {
            /* print(' * 1'); */
          });
          await Future<void>.delayed(const Duration(milliseconds: 100));
          // ignore: unawaited_futures
          deb.debounce(() {
            /* print(' * 2'); */
          });
          await Future<void>.delayed(const Duration(milliseconds: 100));
          // ignore: unawaited_futures
          deb.debounce(() {
            /* print(' * 3'); */
          });
          await Future<void>.delayed(const Duration(milliseconds: 200));
          deb.close();
        });
      });
    });
