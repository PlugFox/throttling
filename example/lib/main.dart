import 'package:throttling/throttling.dart';


void throttleExample() async {
  print('\n### Throttling example');

  final Throttling thr = new Throttling(duration: Duration(seconds: 1));
  thr.duration = Duration(seconds: 3);

  thr.listen((bool state) {
    print(' *throttling#${thr.hashCode.toRadixString(36)} is ${state ? 'ready' : 'busy'}');
  });

  thr.throttle(() {print('. 1');});
  await Future.delayed(Duration(seconds: 1));
  thr.throttle(() {print('. 2');});
  await Future.delayed(Duration(seconds: 1));
  thr.throttle(() {print('. 3');});
  await Future.delayed(Duration(seconds: 1));
  thr.throttle(() {print('. 4');});
  await Future.delayed(Duration(seconds: 1));
  thr.throttle(() {print('. 5');});

  await Future.delayed(Duration(seconds: 3));
}

void debounceExample() async {
  print('\n### Debouncing example');

  final Debouncing deb = new Debouncing(duration: Duration(seconds: 1));
  deb.duration = Duration(seconds: 3);

  deb.listen((bool state) {
    print(' *debouncing#${deb.hashCode.toRadixString(36)} is ${state ? 'ready' : 'busy'}');
  });

  deb.debounce(() {print('. 1');});
  await Future.delayed(Duration(seconds: 1));
  deb.debounce(() {print('. 2');});
  await Future.delayed(Duration(seconds: 1));
  deb.debounce(() {print('. 3');});
  await Future.delayed(Duration(seconds: 1));
  deb.debounce(() {print('. 4');});
  await Future.delayed(Duration(seconds: 1));
  deb.debounce(() {print('. 5');});

  await Future.delayed(Duration(seconds: 3));
}

void main() async {
  print('\n# BEGIN');
  await throttleExample();
  await debounceExample();
  print('\n# END');
}
