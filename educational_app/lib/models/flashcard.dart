class Flashcard {
  final String id;
  final String front;
  final String back;
  double ease; // ease factor
  int interval; // days
  int repetitions; // repetitions count
  DateTime due;

  Flashcard({required this.id, required this.front, required this.back, double? ease, int? interval, int? repetitions, DateTime? due})
      : ease = ease ?? 2.5,
        interval = interval ?? 0,
        repetitions = repetitions ?? 0,
        due = due ?? DateTime.now();
}
