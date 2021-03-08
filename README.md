# THROTTLING DART LIBRARY
##### *contain "throttling" and "debouncing" classes*  
[![Actions Status](https://github.com/PlugFox/throttling/workflows/throttling/badge.svg)](https://github.com/PlugFox/throttling/actions)
[![Coverage](https://codecov.io/gh/PlugFox/throttling/branch/master/graph/badge.svg)](https://codecov.io/gh/PlugFox/throttling)
[![Pub](https://img.shields.io/pub/v/throttling.svg)](https://pub.dev/packages/throttling)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Effective Dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![Star on Github](https://img.shields.io/github/stars/plugfox/throttling.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/PlugFox/throttling)
  
  
## Using  
See demonstration of use on the [dartpad.dartlang.org](https://dartpad.dartlang.org/8630021e5c7ab9d27b74e86372f74c31)
  
### Throttling example
```dart
final thr = Throttling(duration: const Duration(seconds: 2));
thr.throttle(() {print(' * ping #1');});
await Future<void>.delayed(const Duration(seconds: 1));
thr.throttle(() {print(' * ping #2');});
await Future<void>.delayed(const Duration(seconds: 1));
thr.throttle(() {print(' * ping #3');});
await thr.close();
```
  
### Debouncing example
```dart
final deb = Debouncing(duration: const Duration(seconds: 2));
deb.debounce(() {print(' * ping #1');});
await Future<void>.delayed(const Duration(seconds: 1));
deb.debounce(() {print(' * ping #2');});
await Future<void>.delayed(const Duration(seconds: 1));
deb.debounce(() {print(' * ping #3');});
await deb.close();
```
  
  
