# EXAMPLES

See demonstration of use on the [dartpad.dartlang.org](https://dartpad.dartlang.org/8630021e5c7ab9d27b74e86372f74c31) 
  
### Throttling example
```dart
final thr = Throttling(duration: const Duration(seconds: 2));
thr.throttle(() {print(' * ping #1');});
await Future.delayed(const Duration(seconds: 1));
thr.throttle(() {print(' * ping #2');});
await Future.delayed(const Duration(seconds: 1));
thr.throttle(() {print(' * ping #3');});
await thr.close();
```
  
### Debouncing example
```dart
final deb = Debouncing(duration: const Duration(seconds: 2));
deb.debounce(() {print(' * ping #1');});
await Future.delayed(const Duration(seconds: 1));
deb.debounce(() {print(' * ping #2');});
await Future.delayed(const Duration(seconds: 1));
deb.debounce(() {print(' * ping #3');});
await deb.close();
```
  
  