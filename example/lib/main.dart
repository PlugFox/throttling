import 'package:throttling_example/src/example.dart';

void main() async {
  print('\n# BEGIN');
  await throttleExample();
  await debounceExample();
  print('\n# END');
}
