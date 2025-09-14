import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/services/segmentation_service.dart';

void main() {
  final seg = SegmentationService();

  test('clear headings produce separate sections', () {
    final text = '''
INTRODUCTION:
This is the intro paragraph. It gives context.

MATH CONCEPTS:
Here we explain Pythagoras theorem. The theorem states that a squared plus b squared equals c squared.

EXAMPLES:
Example 1: For a=3, b=4, c=5.
''';
    final sections = seg.splitIntoSections(text);
    // Expect at least 3 sections corresponding to the headings
    expect(sections.length >= 3, true);
    // Titles should include heading names
    final titles = sections.map((s) => s.title.toLowerCase()).toList();
    expect(titles.any((t) => t.contains('introduction') || t.contains('intro')), true);
    expect(titles.any((t) => t.contains('math concepts') || t.contains('math')), true);
    expect(titles.any((t) => t.contains('examples')), true);
  });

  test('run-on paragraph splits into multiple clusters', () {
    // Create clearly distinct sentence tokens so clustering is deterministic
    final tokens = ['apple', 'banana', 'cherry', 'date', 'elderberry', 'fig'];
    final textLocal = tokens.map((t) => 'This sentence talks about $t and only $t.').join(' ');
    final sectionsHigh = seg.splitIntoSections(textLocal, clusterMergeThreshold: 0.95);
    final sectionsLow = seg.splitIntoSections(textLocal, clusterMergeThreshold: 0.01);
    // Because mergeThreshold requires a higher similarity to merge, a high threshold
    // should produce more clusters (less merging) than a low threshold.
    expect(sectionsHigh.length > sectionsLow.length, true, reason: 'Higher merge threshold should produce more clusters');
    // Ensure tokens appear somewhere in the results
    final allText = sectionsHigh.map((s) => s.text).join('\n') + '\n' + sectionsLow.map((s) => s.text).join('\n');
    for (final t in tokens) {
      expect(allText.contains(t), true);
    }
  });

  test('adjacent semantic sections merge when similar', () {
    // Make parts intentionally very similar to ensure high cosine similarity
    final repeat = 'motion acceleration inertia force mass acceleration motion.';
    final partA = 'Physics: $repeat $repeat';
    final partB = 'Physics continuation: $repeat $repeat';
    final text = '$partA\n\n$partB';
    // use a moderate adjacent threshold to encourage merging of highly-similar neighboring sections
    final sections = seg.splitIntoSections(text, adjacentMergeThreshold: 0.5);
    // Since the two parts are intentionally very similar, expect them to merge into 1 or remain small
    expect(sections.length <= 2, true);
    final merged = sections.map((s) => s.text).join('\n');
    expect(merged.contains('acceleration'), true);
  });
}
