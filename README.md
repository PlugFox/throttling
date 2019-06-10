# THROTTLING DART LIBRARY
##### *contain "throttling" and "debouncing" classes*  
  
See demonstration of use on the <u><a href="https://dartpad.dartlang.org/8630021e5c7ab9d27b74e86372f74c31" target="_blank">dartpad.dartlang.org</a></u>
  
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
  
  