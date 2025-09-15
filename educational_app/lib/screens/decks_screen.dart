import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/deck.dart';
import '../services/deck_repository.dart';
import '../services/share_service.dart';

typedef ExportHandler = Future<String?> Function(String deckId, String name);

class DecksScreen extends StatefulWidget {
  final ExportHandler? exportHandler;
  final DeckRepository? repository;
  final ShareService? shareService;
  const DecksScreen({super.key, this.exportHandler, this.repository, this.shareService});

  @override
  State<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends State<DecksScreen> {
  List<Deck> _decks = [];
  bool _loading = true;
  late final DeckRepository repository;

  // NOTE: This screen is designed for testability. The following injection
  // points exist so widget tests can avoid touching the filesystem or sqlite:
  // - `repository`: inject a `FakeDeckRepository` (see `test/utils/fakes.dart`) to avoid DB access
  // - `exportHandler`: inject a function that returns a fake file path to avoid file IO
  // - `shareService`: inject a `FakeShareService` to verify share calls without opening the OS share sheet

  @override
  void initState() {
    super.initState();
    repository = widget.repository ?? DefaultDeckRepository();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
  _decks = await repository.listDecks();
    setState(() => _loading = false);
  }

  Future<void> _createDeck() async {
    final nameController = TextEditingController();
    final result = await showDialog<String?>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Create deck'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Deck name')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(nameController.text.trim()), child: const Text('Create')),
        ],
      );
    });
    if (result == null || result.isEmpty) return;
    final id = const Uuid().v4();
    final deck = Deck(id: id, name: result);
    await repository.createDeck(deck);
    await _load();
  }

  Future<void> _deleteDeck(String id) async {
    final ok = await showDialog<bool?>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete deck'),
      content: const Text('Are you sure you want to delete this deck? Cards will be unassigned.'),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete'))],
    ));
    if (ok != true) return;
    await repository.deleteDeck(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decks'), actions: [IconButton(onPressed: _createDeck, icon: const Icon(Icons.add))]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _decks.length,
        itemBuilder: (context, i) {
          final d = _decks[i];
          return ListTile(
            title: Text(d.name),
            subtitle: Text('Created ${d.createdAt.toLocal()}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.file_download), onPressed: () => _exportToFile(d.id, d.name)),
              IconButton(icon: const Icon(Icons.share), onPressed: () => _shareDeck(d.id, d.name)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteDeck(d.id)),
            ]),
            onTap: () async {
              final json = await repository.exportDeckJson(d.id);
              if (!mounted || !context.mounted) return; // guard State and local BuildContext after async work
              await showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Export'), content: SingleChildScrollView(child: Text(json)), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))]));
            },
          );
        },
      ),
    );
  }

  Future<void> _exportToFile(String deckId, String name) async {
    try {
      String? path;
      if (widget.exportHandler != null) {
        path = await widget.exportHandler!(deckId, name);
      } else {
        final json = await repository.exportDeckJson(deckId);
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${name.replaceAll(' ', '_')}_deck.json');
        await file.writeAsString(json);
        path = file.path;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(path != null ? 'Exported to $path' : 'Export completed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _shareDeck(String deckId, String name) async {
    final shareSvc = widget.shareService;
    if (shareSvc == null) {
      // no share service provided; show a helpful snackbar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share not available')));
      return;
    }

    try {
      String? path;
      if (widget.exportHandler != null) {
        path = await widget.exportHandler!(deckId, name);
      } else {
        final json = await repository.exportDeckJson(deckId);
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${name.replaceAll(' ', '_')}_deck.json');
        await file.writeAsString(json);
        path = file.path;
      }
      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share failed: no file')));
        return;
      }
      await shareSvc.share(path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opened share dialog')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share failed: $e')));
    }
  }
}
