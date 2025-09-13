class TutorGenerator {
  List<Map<String, String>> generateFlashcards(String pdfText) {
    // Simple extraction: Split into sentences, pick potential terms (capitalized words)
    List<String> sentences = pdfText.split('. ');
    List<Map<String, String>> flashcards = [];
    for (String sentence in sentences) {
      // Basic "AI": Assume first capitalized word is term
      RegExp termRegex = RegExp(r'\b[A-Z][a-z]+');
      Match? match = termRegex.firstMatch(sentence);
      if (match != null) {
        String term = match.group(0)!;
        String explanation = sentence.replaceAll(term, '').trim(); // Simple rephrase
        flashcards.add({'front': 'What is $term?', 'back': explanation});
      }
    }
    return flashcards.take(20).toList(); // Limit for perf
  }

  List<Map<String, dynamic>> generateQuestions(String pdfText) {
    // Template-based MCQs
    List<Map<String, dynamic>> questions = [];
    // Similar logic: Extract terms, generate "What is X? A) Correct B) Wrong1 C) Wrong2 D) Wrong3"
    // Explanation: From context
    // Add 10-20 questions
    questions.add({
      'question': 'What is the main topic?',
      'options': ['A) Example1', 'B) Example2', 'C) Correct', 'D) Example3'],
      'answer': 'C',
      'explanation': 'Based on PDF text...'
    });
    return questions;
  }

  Map<String, dynamic> generateStudyPlan(String pdfText, int sessionLength) {
    // Estimate: Word count / words per session
    int wordCount = pdfText.split(' ').length;
    int days = (wordCount / (sessionLength * 50)).ceil(); // Rough estimate
    return {
      'days': days,
      'dailySessions': List.generate(days, (i) => 'Day ${i+1}: Review flashcards & questions (${sessionLength} mins)'),
      'totalTime': days * sessionLength
    };
  }
}
