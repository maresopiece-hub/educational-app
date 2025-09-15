# educational_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Review UX (Flashcards)

The app includes a review flow for flashcards used in the Study Today screen.

- Cards are shown one at a time with the question on the front.
- The answer is hidden until the user taps the "Show answer" button.
- After revealing the answer, rating buttons (Hard / Good / Easy) appear and the user's choice is recorded.
- The reveal uses a small AnimatedSwitcher transition and Semantics wrappers to improve accessibility.

TODOs:
- Add reveal animations for card content (flip or fade + scale) and polish the rating UI.
- Add localization for the review strings and further accessibility tests.

## Decks, export & testing

This project includes a small Decks feature for organizing generated flashcards and exporting decks as JSON. Important developer notes:

- Deck data is stored in a local sqlite database (`flashcards.db`) via `DeckDb` and `FlashcardDb`.
- The `DecksScreen` UI supports these injection points to make testing deterministic:
	- `repository` (type `DeckRepository`): inject a `FakeDeckRepository` from `test/utils/fakes.dart` to avoid DB access in widget tests.
	- `exportHandler` (type `Future<String?> Function(String deckId, String name)`): inject a fake exporter to avoid file system writes. The handler should return the exported file path or `null`.
	- `shareService` (type `ShareService`): inject a `FakeShareService` to verify share behavior without opening the OS share dialog.

Usage notes for tests
- Use `test/utils/fakes.dart` which provides `FakeDeckRepository`, `FakeShareService` and `fakeExportHandler` to keep widget tests fast and isolated.
- Example: when testing `DecksScreen`, construct the widget as `DecksScreen(repository: FakeDeckRepository(), exportHandler: fakeExportHandler, shareService: FakeShareService())` and then assert UI behavior and that fake services recorded expected calls.

Enabling real OS sharing
- A `ShareService` interface exists in `lib/services/share_service.dart`. The default implementation is a placeholder; to enable real sharing add `share_plus` to your `pubspec.yaml` (already listed) and update `DefaultShareService` to use `Share.share` or `Share.shareXFiles`.


