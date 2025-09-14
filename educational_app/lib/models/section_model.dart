class SectionModel {
  final String id;
  final String title;
  final String text;
  final List<String> keywords;
  final double completeness; // 0.0 .. 1.0

  SectionModel({required this.id, required this.title, required this.text, required this.keywords, required this.completeness});
}
