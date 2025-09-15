import 'deck_db.dart';
import '../models/deck.dart';

abstract class DeckRepository {
  Future<List<Deck>> listDecks();
  Future<void> createDeck(Deck d);
  Future<void> deleteDeck(String id);
  Future<String> exportDeckJson(String id);
}

class DefaultDeckRepository implements DeckRepository {
  @override
  Future<void> createDeck(Deck d) => DeckDb.createDeck(d);

  @override
  Future<List<Deck>> listDecks() => DeckDb.listDecks();

  @override
  Future<void> deleteDeck(String id) => DeckDb.deleteDeck(id);

  @override
  Future<String> exportDeckJson(String id) => DeckDb.exportDeckJson(id);
}
