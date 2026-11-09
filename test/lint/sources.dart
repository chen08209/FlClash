import 'dart:io';

const sourceRoots = ['lib'];

List<FileSystemEntity> sourceEntities() => [
  for (final root in sourceRoots) ...Directory(root).listSync(recursive: true),
];
