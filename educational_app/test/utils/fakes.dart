import 'package:educational_app/models/deck.dart';
import 'package:educational_app/services/deck_repository.dart';
import 'package:educational_app/services/share_service.dart';

typedef ExportHandler = Future<String?> Function(String deckId, String name);

class FakeDeckRepository implements DeckRepository {
  final List<Deck> _decks = [];

  @override
  Future<void> createDeck(Deck d) async {
    _decks.add(d);
  }

  @override
  Future<List<Deck>> listDecks() async => List.of(_decks);

  @override
  Future<void> deleteDeck(String id) async {
    _decks.removeWhere((d) => d.id == id);
  }

  @override
  Future<String> exportDeckJson(String id) async => '{"decks":[] }';
}

class FakeShareService implements ShareService {
  String? lastSharedPath;
  @override
  Future<void> share(String path) async {
    lastSharedPath = path;
  }
}

Future<String?> fakeExportHandler(String deckId, String name) async => '/tmp/${name}_deck.json';
