/*
 * Throttling and Debouncing in dart for https://pub.dev/packages/throttling
 * https://gist.github.com/PlugFox/8630021e5c7ab9d27b74e86372f74c31
 * https://dartpad.dev?id=8630021e5c7ab9d27b74e86372f74c31
 * Matiunin Mikhail <plugfox@gmail.com>, 22 November 2023
 */

// ignore_for_file: avoid_print, cascade_invocations, unawaited_futures

import 'dart:async';

void main([List<String>? arguments]) => Future<void>(() async {
      print('\n' '# Throttling');
      await throttling();
      print('\n' '# Debouncing');
      await debouncing();
    });

Future<void> throttling() async {
  final thr = Throttling<void>(duration: const Duration(milliseconds: 200));
  thr.throttle(() {
    print(' * 1');
  }); // print ' * 1'
  await Future<void>.delayed(const Duration(milliseconds: 100));
  thr.throttle(() {
    print(' * 2');
  });
  await Future<void>.delayed(const Duration(milliseconds: 100));
  thr.throttle(() {
    print(' * 3');
  }); // print ' * 3'
  thr.close();
}

Future<void> debouncing() async {
  final deb = Debouncing<void>(duration: const Duration(milliseconds: 200));
  deb.debounce(() {
    print(' * 1');
  });
  await Future<void>.delayed(const Duration(milliseconds: 100));
  deb.debounce(() {
    print(' * 2');
  });
  await Future<void>.delayed(const Duration(milliseconds: 100));
  deb.debounce(() {
    print(' * 3');
  });
  await Future<void>.delayed(const Duration(milliseconds: 200));
  // print ' * 3'
  deb.close();
}

/* LIBRARY */

/// Throttling status
enum ThrottlingStatus {
  /// Ready to accept new events
  idle,

  /// Waiting for the end of the pause
  busy;

  const ThrottlingStatus();

  /// Ready to accept new events
  bool get isIdle => this == ThrottlingStatus.idle;

  /// Waiting for the end of the pause
  bool get isBusy => this == ThrottlingStatus.busy;

  @override
  String toString() => switch (this) {
        ThrottlingStatus.idle => 'idle',
        ThrottlingStatus.busy => 'busy',
      };
}

/// Debouncing status
enum DebouncingStatus {
  /// Ready to accept new events
  idle,

  /// Waiting for the end of the pause
  busy;

  const DebouncingStatus();

  /// Ready to accept new events
  bool get isIdle => this == DebouncingStatus.idle;

  /// Waiting for the end of the pause
  bool get isBusy => this == DebouncingStatus.busy;

  @override
  String toString() => switch (this) {
        DebouncingStatus.idle => 'idle',
        DebouncingStatus.busy => 'busy',
      };
}

/// Throttling
/// Have method [throttle]
final class Throttling<T> extends Stream<ThrottlingStatus>
    implements Sink<T Function()> {
  /// Throttling
  /// Have method [throttle]
  /// Must be closed with [close] method
  Throttling({Duration duration = const Duration(seconds: 1)})
      : assert(!duration.isNegative, 'Duration must be positive'),
        _duration = duration {
    _stateSC.sink.add(ThrottlingStatus.idle);
  }
  Duration _duration;

  /// Get current duration
  Duration get duration => _duration;

  /// Set new duration
  set duration(Duration value) {
    assert(!duration.isNegative, 'Duration must be positive');
    _duration = value;
  }

  /// {@nodoc}
  Timer? _timer;

  /// Is ready to accept new events
  bool get isIdle => switch (_timer?.isActive) {
        true => false,
        _ => true,
      };

  /// Waiting for the end of the pause
  bool get isBusy => !isIdle;

  /// {@nodoc}
  final StreamController<ThrottlingStatus> _stateSC =
      StreamController<ThrottlingStatus>.broadcast(sync: true);

  /// Limits the maximum number of times a given
  /// event handler can be called over time.
  ///
  /// Returns the result of the function.
  /// If the function is not ready to accept new events,
  /// it returns null.
  T? throttle(T Function() func) {
    if (_stateSC.isClosed || !isIdle) return null;
    _timer = Timer(_duration, () {
      _timer = null;
      if (_stateSC.isClosed) return;
      _stateSC.sink.add(ThrottlingStatus.idle);
    });
    _stateSC.sink.add(ThrottlingStatus.busy);
    try {
      return func();
    } on Object {
      rethrow;
    }
  }

  @override
  StreamSubscription<ThrottlingStatus> listen(
    void Function(ThrottlingStatus status)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _stateSC.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  /// Shortcut for [throttle] method
  @override
  T? add(T Function() data) => throttle(data);

  @override
  void close() {
    _timer?.cancel();
    _timer = null;
    _stateSC.close().ignore();
  }
}

/// Debouncing
/// Have method [debounce]
final class Debouncing<T> extends Stream<DebouncingStatus>
    implements Sink<T Function()> {
  ///  Debouncing
  ///  Have method [debounce]
  /// Must be closed with [close] method
  Debouncing({Duration duration = const Duration(seconds: 1)})
      : assert(!duration.isNegative, 'Duration must be positive'),
        _duration = duration {
    _stateSC.sink.add(DebouncingStatus.idle);
  }
  Duration _duration;

  /// Get current duration
  Duration get duration => _duration;

  /// Set new duration
  set duration(Duration value) {
    assert(!duration.isNegative, 'Duration must be positive');
    _duration = value;
  }

  /// {@nodoc}
  Timer? _timer;

  /// {@nodoc}
  Completer<T?>? _completer;

  /// Is ready to accept new events
  bool get isIdle => switch (_timer?.isActive) {
        true => false,
        _ => true,
      };

  /// Waiting for the end of the pause
  bool get isBusy => !isIdle;

  // ignore: close_sinks
  final StreamController<DebouncingStatus> _stateSC =
      StreamController<DebouncingStatus>.broadcast(sync: true);

  /// Allows you to control events being triggered successively and,
  /// if the interval between two sequential occurrences is less than
  /// a certain amount of time (e.g. one second),
  /// it completely ignores the first one.
  Future<T?> debounce(T Function() func) async {
    if (_stateSC.isClosed) return null;
    if (isIdle) _stateSC.sink.add(DebouncingStatus.busy);
    final completer = _completer ??= Completer<T?>();
    _timer?.cancel();
    _timer = Timer(_duration, () {
      _completer = null;
      _timer = null;
      try {
        final result = func();
        completer.complete(result);
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace); // coverage:ignore-line
      } finally {
        if (!_stateSC.isClosed) _stateSC.sink.add(DebouncingStatus.idle);
      }
    });
    return completer.future;
  }

  @override
  StreamSubscription<DebouncingStatus> listen(
    void Function(DebouncingStatus status)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _stateSC.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  /// Shortcut for [debounce] method
  @override
  Future<T?> add(T Function() data) => debounce(data);

  /// Free resources
  /// If [force] is true, then the current event will be canceled.
  @override
  void close({bool force = false}) {
    // coverage:ignore-start
    if (force) {
      _timer?.cancel();
      _completer?.completeError(StateError('closed'));
      _timer = null;
      _completer = null;
    }
    // coverage:ignore-end
    _stateSC.close().ignore();
  }
}
