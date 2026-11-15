import 'package:flutter_test/flutter_test.dart';

import '../../tool/sort_l10n.dart';

const _header = '''
class CodegenLoader extends AssetLoader {
  const CodegenLoader();

''';

String _generated(List<String> order) {
  final blocks = {
    'en':
        '  static const Map<String, dynamic> _en = {\n    "hello": "Hello",\n  };\n',
    'it':
        '  static const Map<String, dynamic> _it = {\n    "hello": "Ciao",\n  };\n',
  };
  return '$_header'
      '${order.map((l) => blocks[l]).join()}'
      '  static const Map<String, Map<String, dynamic>> mapLocales = {\n'
      '${order.map((l) => '    "$l": _$l,\n').join()}'
      '  };\n}\n';
}

void main() {
  test('locales come out sorted whatever order the file system gave', () {
    expect(
      sortTranslations(_generated(['it', 'en'])),
      _generated(['en', 'it']),
    );
  });

  test('an already sorted file is left untouched', () {
    final sorted = _generated(['en', 'it']);
    expect(sortTranslations(sorted), sorted);
  });
}
