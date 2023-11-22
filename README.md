# THROTTLING DART LIBRARY

##### _contain "throttling" and "debouncing" classes_

[![Actions Status](https://github.com/PlugFox/throttling/workflows/checkout/badge.svg)](https://github.com/PlugFox/throttling/actions)
[![Coverage](https://codecov.io/gh/PlugFox/throttling/branch/master/graph/badge.svg)](https://codecov.io/gh/PlugFox/throttling)
[![Pub](https://img.shields.io/pub/v/throttling.svg)](https://pub.dev/packages/throttling)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Effective Dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![Star on Github](https://img.shields.io/github/stars/plugfox/throttling.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/PlugFox/throttling)

## Using

See a demonstration of use at [dartpad.dev](https://dartpad.dev/?id=8630021e5c7ab9d27b74e86372f74c31)

### Throttling example

```dart
final thr = Throttling<void>(duration: const Duration(milliseconds: 200));
thr.throttle(() {print(' * 1');}); // print ' * 1'
await Future<void>.delayed(const Duration(milliseconds: 100));
thr.throttle(() {print(' * 2');});
await Future<void>.delayed(const Duration(milliseconds: 100));
thr.throttle(() {print(' * 3');}); // print ' * 3'
thr.close();
```

### Debouncing example

```dart
final deb = Debouncing<void>(duration: const Duration(milliseconds: 200));
deb.debounce(() {print(' * 1');});
await Future<void>.delayed(const Duration(milliseconds: 100));
deb.debounce(() {print(' * 2');});
await Future<void>.delayed(const Duration(milliseconds: 100));
deb.debounce(() {print(' * 3');});
await Future<void>.delayed(const Duration(milliseconds: 200));
// print ' * 3'
deb.close();
```
