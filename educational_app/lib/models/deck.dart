class Deck {
  final String id;
  final String name;
  final DateTime createdAt;

  Deck({required this.id, required this.name, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();
}
