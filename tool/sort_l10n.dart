// easy_localization:generate scrive le lingue nell'ordine in cui il file
// system elenca assets/translations, che cambia da un disco all'altro: qui
// si riordinano blocchi e mapLocales per lingua, così il file generato è
// identico in locale e in CI.
import 'dart:io';

final _block = RegExp(
  r'^  static const Map<String, dynamic> _(\w+) = \{\n.*?^  \};\n',
  multiLine: true,
  dotAll: true,
);
final _mapLocales = RegExp(
  r'(^  static const Map<String, Map<String, dynamic>> mapLocales = \{\n)(.*?)(^  \};\n)',
  multiLine: true,
  dotAll: true,
);

String sortTranslations(String source) {
  final blocks = _block.allMatches(source).toList();
  if (blocks.isEmpty) return source;
  final sorted = [...blocks]
    ..sort((a, b) => a.group(1)!.compareTo(b.group(1)!));
  final buffer = StringBuffer(source.substring(0, blocks.first.start));
  for (final block in sorted) {
    buffer.write(block.group(0));
  }
  final rest = source.substring(blocks.last.end).replaceFirstMapped(
    _mapLocales,
    (m) {
      final entries =
          m.group(2)!.split('\n').where((l) => l.isNotEmpty).toList()..sort();
      return '${m.group(1)}${entries.map((e) => '$e\n').join()}${m.group(3)}';
    },
  );
  return '$buffer$rest';
}

void main(List<String> args) {
  for (final path in args) {
    final file = File(path);
    file.writeAsStringSync(sortTranslations(file.readAsStringSync()));
  }
}
