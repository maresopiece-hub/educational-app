import 'pdf_parser.dart';
import 'pptx_parser.dart';

class FileProcessor {
  Future<String> extractTextFromFile(String type) async {
    if (type == 'pdf') {
      return await PDFParser().extractText();
    } else if (type == 'pptx') {
      return await PPTXParser().extractText();
    }
    return '';
  }

  List<String> divideSections(String text) {
    // Simple: Split by headers (e.g., lines with all caps or numbered)
    return text.split(RegExp(r'\n\s*\n'));
  }

  double checkCompleteness(String sectionText) {
    // Example: Word count > 50 and has keywords
    int wordCount = sectionText.split(' ').length;
    return (wordCount > 50) ? 100.0 : (wordCount / 50 * 100);
  }

  Map<String, dynamic> generateLessonPlan(List<String> sections) {
    Map<String, dynamic> plan = {};
    for (int i = 0; i < sections.length; i++) {
      String section = sections[i];
      double completeness = checkCompleteness(section);
      if (completeness < 80) {
        plan['section_$i'] = {'text': section, 'complete': false, 'note': 'Incomplete - add more details'};
      } else {
        plan['section_$i'] = {
          'explanation': _simplifyExplanation(section),
          'examples': _extractExamples(section),
          'questions': _generateQuestions(section),
          'complete': true
        };
      }
    }
    return plan;
  }

  String _simplifyExplanation(String text) => text.substring(0, text.length > 200 ? 200 : text.length) + (text.length > 200 ? '...' : '');

  List<String> _extractExamples(String text) => ['Example1 from text', 'Example2']; // Parse "e.g." etc.

  List<Map<String, dynamic>> _generateQuestions(String text) {
    // Generate covering all subtopics
    return List.generate(5, (i) => {
      'question': 'Q$i: Detail from text?',
      'options': ['A', 'B', 'C', 'D'],
      'answer': 'A',
      'whyWrong': {'B': 'Reason B wrong', 'C': 'Reason C wrong', 'D': 'Reason D wrong'}
    });
  }
}
