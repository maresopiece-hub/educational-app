import 'package:flutter/material.dart';
import '../services/file_service.dart';
import '../services/document_parser.dart';
import '../services/segmentation_service.dart';
import '../services/lesson_generator_service.dart';
import '../widgets/lesson_preview.dart';
import '../models/lesson_plan.dart';
import '../services/srs_service.dart';
import '../services/flashcard_db.dart';
import '../services/deck_db.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final _fileService = FileService();
  final _parser = DocumentParser();
  final _seg = SegmentationService();
  final _gen = LessonGeneratorService();
  final _srs = SrsService();
  String? _lastDeckId;
  String? _selectedDeckId;
  String? _extracted;
  bool _busy = false;
  LessonPlan? _plan;
  List<Deck> _availableDecks = [];

  // Notes for maintainers and tests:
  // - The import screen exposes a persistent deck selector (dropdown) to make
  //   saving generated lesson plans simpler and more testable compared to a
  //   nested modal dialog. Tests may pre-create decks via a FakeDeckRepository
  //   and set `_selectedDeckId` (or use SharedPreferences) to simulate user
  //   selection.
  // - When writing widget tests, prefer injecting fakes from
  //   `test/utils/fakes.dart` and avoid calls to `DeckDb` or file system APIs.

  Future<void> _saveAsDeck() async {
    if (_plan == null) return;
    final cards = _srs.generateFromLesson(_plan!);
    // Use selected deck if present, otherwise fall back to creating one
    String? chosen = _selectedDeckId;
    if (chosen == null) {
      // no deck selected; prompt for a new deck name inline
      final nameController = TextEditingController();
      final name = await showDialog<String?>(context: context, builder: (c2) => AlertDialog(
        title: const Text('New deck name'),
        content: TextField(controller: nameController),
        actions: [TextButton(onPressed: () => Navigator.of(c2).pop(null), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.of(c2).pop(nameController.text.trim()), child: const Text('Create'))],
      ));
      if (name == null || name.isEmpty) return;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final deck = Deck(id: id, name: name);
      await DeckDb.createDeck(deck);
      chosen = deck.id;
      // refresh deck list
      _availableDecks = await DeckDb.listDecks();
      setState(() => _selectedDeckId = chosen);
    }
    for (final c in cards) {
      final cardWithDeck = Flashcard(id: c.id, front: c.front, back: c.back, deckId: chosen, ease: c.ease, interval: c.interval, repetitions: c.repetitions, due: c.due);
      await FlashcardDb.saveCard(cardWithDeck);
    }
    // persist last chosen deck id
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_deck_id', chosen);
      _lastDeckId = chosen;
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved deck to local storage')));
  }

  @override
  void initState() {
    super.initState();
    _loadLastDeck();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    try {
      final decks = await DeckDb.listDecks();
      setState(() => _availableDecks = decks);
    } catch (_) {}
  }

  Future<void> _loadLastDeck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('last_deck_id');
      if (id != null) setState(() => _lastDeckId = id);
    } catch (_) {}
  }

  Future<void> _pickAndParse() async {
    setState(() => _busy = true);
    final path = await _fileService.pickAndSaveFile();
    if (path != null) {
      String text = '';
      if (path.toLowerCase().endsWith('.pdf')) {
        text = await _parser.extractPdfText(path);
      } else if (path.toLowerCase().endsWith('.pptx')) {
        text = await _parser.extractPptxText(path);
      }
      // Run segmentation and generate lesson plan
      final sections = _seg.splitIntoSections(text);
      final plan = _gen.generateFromSections(sections, title: 'Auto-generated plan');
      setState(() {
        _extracted = text;
        _plan = plan;
      });
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Document')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.upload_file), label: const Text('Pick PDF/PPTX'), onPressed: _busy ? null : _pickAndParse)),
              const SizedBox(width: 12),
              // Deck selector
              SizedBox(
                width: 200,
                child: Row(children: [
                  Expanded(child: DropdownButton<String?>(
                    value: _selectedDeckId ?? _lastDeckId,
                    hint: const Text('Select deck'),
                    isExpanded: true,
                    items: _availableDecks.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                    onChanged: (v) async {
                      setState(() => _selectedDeckId = v);
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        if (v != null) await prefs.setString('last_deck_id', v);
                      } catch (_) {}
                    },
                  )),
                  IconButton(onPressed: () async {
                    // quick create new deck
                    final nameController = TextEditingController();
                    final name = await showDialog<String?>(context: context, builder: (c2) => AlertDialog(
                      title: const Text('New deck name'),
                      content: TextField(controller: nameController),
                      actions: [TextButton(onPressed: () => Navigator.of(c2).pop(null), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.of(c2).pop(nameController.text.trim()), child: const Text('Create'))],
                    ));
                    if (name != null && name.isNotEmpty) {
                      final id = DateTime.now().millisecondsSinceEpoch.toString();
                      final deck = Deck(id: id, name: name);
                      await DeckDb.createDeck(deck);
                      await _loadDecks();
                      setState(() => _selectedDeckId = deck.id);
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('last_deck_id', deck.id);
                      } catch (_) {}
                    }
                  }, icon: const Icon(Icons.add))
                ]),
              )
            ]),
            const SizedBox(height: 12),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(_extracted ?? 'No document imported yet.'),
                    const SizedBox(height: 12),
                    if (_plan != null) ...[
                      const Divider(),
                      const Text('Generated lesson plan preview', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      LessonPreview(plan: _plan!),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(onPressed: _saveAsDeck, icon: const Icon(Icons.save), label: const Text('Save as deck'))
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
