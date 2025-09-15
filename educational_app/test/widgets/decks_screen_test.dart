import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/screens/decks_screen.dart';
import 'package:educational_app/models/deck.dart';
import '../utils/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create deck via UI updates list (fake repo)', (tester) async {
    final repo = FakeDeckRepository();
    await tester.pumpWidget(MaterialApp(home: DecksScreen(repository: repo)));
    // initial load
    await tester.pumpAndSettle();

    // tap add
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // dialog appears; enter name
    await tester.enterText(find.byType(TextField), 'Fake Deck');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    await tester.pumpAndSettle();

    // now the fake repo should have the deck and UI should show it
    expect(find.text('Fake Deck'), findsOneWidget);
  });

  testWidgets('delete deck via UI (fake repo)', (tester) async {
    final repo = FakeDeckRepository();
    // pre-populate repository
    final d = Deck(id: 'd1', name: 'To Delete');
    await repo.createDeck(d);

    await tester.pumpWidget(MaterialApp(home: DecksScreen(repository: repo)));
    await tester.pumpAndSettle();

    expect(find.text('To Delete'), findsOneWidget);

    // tap delete icon for the list tile
    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete));
    await tester.pumpAndSettle();

    // confirm dialog appears and press Delete
    expect(find.text('Delete deck'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();

    // deck should be removed
    expect(find.text('To Delete'), findsNothing);
  });

  testWidgets('export shows snackbar with path using exportHandler (fake repo)', (tester) async {
    final repo = FakeDeckRepository();
    final d = Deck(id: 'd2', name: 'Exportable');
    await repo.createDeck(d);

    // fake exportHandler returns a path
    Future<String?> fakeExport(String deckId, String name) async => '/tmp/${name}_deck.json';

    await tester.pumpWidget(MaterialApp(home: DecksScreen(repository: repo, exportHandler: fakeExport)));
    await tester.pumpAndSettle();

    // tap export icon
    await tester.tap(find.widgetWithIcon(IconButton, Icons.file_download));
    await tester.pumpAndSettle();

    // snackbar with exported path should appear
    expect(find.textContaining('Exported to'), findsOneWidget);
  });

  testWidgets('share calls share service and shows snackbar (fake services)', (tester) async {
    final repo = FakeDeckRepository();
    final d = Deck(id: 'd3', name: 'Shareable');
    await repo.createDeck(d);

    final fakeShare = FakeShareService();

    // use an exportHandler that returns a fake path instantly
    Future<String?> fakeExport(String deckId, String name) async => '/tmp/${name}_deck.json';

  await tester.pumpWidget(MaterialApp(home: DecksScreen(repository: repo, exportHandler: fakeExport, shareService: fakeShare)));
    await tester.pumpAndSettle();

    // tap share icon
    await tester.tap(find.widgetWithIcon(IconButton, Icons.share));
    await tester.pumpAndSettle();

    // fakeShare should have recorded the path
    expect(fakeShare.lastSharedPath, isNotNull);
    expect(find.text('Opened share dialog'), findsOneWidget);
  });
}
