import 'package:hooks/hooks.dart';
import 'package:setup_hooks/setup_hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    await const CoreBuilder().run(input: input, output: output);
  });
}
