// ignore_for_file: avoid_print

import 'dart:io';

main() async {
  final result = await Process.run(
    'netstat',
    ["-ano","|","findstr",":7890","|","findstr","LISTENING"],
    runInShell: true,
  );
  final output = result.stdout as String;
  final line = output.split('\n').first;
  final pid = line.split(' ').firstWhere(
        (value) => value.trim().contains(RegExp(r'^\d+$')),
    orElse: () => '',
  );
  print(pid);
}
