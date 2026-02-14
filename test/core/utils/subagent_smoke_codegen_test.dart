import 'package:artio/core/utils/subagent_smoke_codegen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("formatUserGreeting('An') phải bằng Xin chào, An!", () {
    expect(formatUserGreeting('An'), 'Xin chào, An!');
  });
}
