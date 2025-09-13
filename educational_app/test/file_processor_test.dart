import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/services/file_processor.dart';

void main() {
  group('FileProcessor', () {
    test('divides text into sections', () {
      final processor = FileProcessor();
      final text = 'Section 1\n\nSection 2\n\nSection 3';
      final sections = processor.divideSections(text);
      expect(sections.length, 3);
      expect(sections[0], contains('Section 1'));
    });

    test('checks completeness', () {
      final processor = FileProcessor();
      final complete = processor.checkCompleteness('word ' * 51);
      final incomplete = processor.checkCompleteness('short');
      expect(complete, 100.0);
      expect(incomplete, lessThan(100.0));
    });
  });
}
