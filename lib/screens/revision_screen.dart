import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/study_plan.dart';
import '../utils/revision_utils.dart';
import 'study_mode_screen.dart';

class RevisionScreen extends StatefulWidget {
  const RevisionScreen({super.key});

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  bool _favoritesOnly = false;
  List<RevisionStats> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final box = Hive.box<StudyPlan>('studyPlans');
    final plans = box.values.toList();
    setState(() {
      _items = rankWeakest(plans, favoritesOnly: _favoritesOnly);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revision')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Row(children: [
            const Text('Favorites only'),
            const SizedBox(width: 8),
            Switch(value: _favoritesOnly, onChanged: (v) => setState(() { _favoritesOnly = v; _load(); })),
            const Spacer(),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
          ]),
          const SizedBox(height: 8),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No revision items found — try answering some questions first.'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final it = _items[i];
                      final pct = (it.percentCorrect * 100).toStringAsFixed(0);
                      final subtitle = it.path.length > 1 ? it.path.skip(1).join(' > ') : it.planTopic;
                      return ListTile(
                        title: Text('${it.planTopic} — ${it.path.last}'),
                        subtitle: Text('$subtitle • $pct% correct • ${it.attempts} attempts'),
                        trailing: ElevatedButton(
                          child: const Text('Study'),
                          onPressed: () {
                            // build startPath as Subtopic list for StudyModeScreen
                            // We'll find the matching subtopic chain and pass it as startPath
                            final box = Hive.box<StudyPlan>('studyPlans');
                            final plan = box.values.firstWhere((p) => p.topic == it.planTopic);
                            final pathTitles = it.path.skip(1).toList();
                            final startPath = <Subtopic>[];
                            Subtopic? findIn(List<Subtopic> subs, int idx) {
                              for (final s in subs) {
                                if (s.title == pathTitles[idx]) {
                                  if (idx == pathTitles.length - 1) return s;
                                  return findIn(s.subtopics, idx + 1);
                                }
                              }
                              return null;
                            }
                            if (pathTitles.isNotEmpty) {
                              final root = findIn(plan.subtopics, 0);
                              if (root != null) startPath.add(root);
                            }
                            Navigator.push(context, MaterialPageRoute(builder: (_) => StudyModeScreen(plan: plan, startPath: startPath)));
                          },
                        ),
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}
