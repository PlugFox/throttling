# FORKED FROM https://github.com/PlugFox/throttling

# THROTTLING DART LIBRARY
##### *contain "throttling" and "debouncing" classes*  
[![pub package](https://img.shields.io/pub/v/throttling.svg)](https://pub.dev/packages/throttling)  
  
  
## Using  
See demonstration of use on the [dartpad.dartlang.org](https://dartpad.dartlang.org/8630021e5c7ab9d27b74e86372f74c31)
  
### Throttling example
```dart
final Throttling thr = new Throttling(duration: Duration(seconds: 2));
thr.throttle(() {print(' *ping #1');});
await Future.delayed(Duration(seconds: 1));
thr.throttle(() {print(' *ping #2');});
await Future.delayed(Duration(seconds: 1));
thr.throttle(() {print(' *ping #3');});
```
  
### Debouncing example
```dart
final Debouncing deb = new Debouncing(duration: Duration(seconds: 2));
deb.debounce(() {print(' *ping #1');});
await Future.delayed(Duration(seconds: 1));
deb.debounce(() {print(' *ping #2');});
await Future.delayed(Duration(seconds: 1));
deb.debounce(() {print(' *ping #3');});
```
  
  
