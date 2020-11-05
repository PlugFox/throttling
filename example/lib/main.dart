import 'package:throttling_example/src/example.dart';

void main() async {
  print('\n# BEGIN');
  await Example.throttleExample();
  await Example.debounceExample();
  print('\n# END');
}
