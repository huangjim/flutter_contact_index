import 'package:flutter_contact_index/flutter_contact_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates singleton instance', () {
    final first = FlutterContactIndex();
    final second = FlutterContactIndex();
    expect(identical(first, second), isTrue);
  });
}
