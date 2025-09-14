import 'dart:math';

import 'package:uuid/uuid.dart';
import '../models/section_model.dart';

class SegmentationService {
  final _uuid = const Uuid();

  /// Public entry: split document text into refined sections.
  /// Steps:
  /// 1. Do heading + paragraph heuristics (fast pass).
  /// 2. For each heuristic section, run sentence-level TF-IDF clustering.
  /// 3. Optionally merge adjacent small sections if semantically similar.
  List<SectionModel> splitIntoSections(String text,
      {double clusterMergeThreshold = 0.45, double adjacentMergeThreshold = 0.6}) {
    final heuristic = _heuristicSplit(text);
    final refined = <SectionModel>[];
    for (final sec in heuristic) {
      final clusters = _clusterSectionSentences(sec.text, mergeThreshold: clusterMergeThreshold);
      if (clusters.isEmpty) continue;
      for (var i = 0; i < clusters.length; i++) {
        final content = clusters[i].trim();
        if (content.isEmpty) continue;
        final keywords = _extractKeywords(content);
        final completeness = _computeCompleteness(content, keywords);
        final title = clusters.length == 1 ? sec.title : '${sec.title} — part ${i + 1}';
        refined.add(SectionModel(id: _uuid.v4(), title: title, text: content, keywords: keywords, completeness: completeness));
      }
    }

    // Merge adjacent sections if they are too similar semantically
    final merged = <SectionModel>[];
    for (final sec in refined) {
      if (merged.isEmpty) {
        merged.add(sec);
        continue;
      }
      final last = merged.last;
      final sim = _cosineSimilarityText(last.text, sec.text);
      if (sim >= adjacentMergeThreshold) {
        // merge into last
        final combinedText = '${last.text}\n\n${sec.text}';
        final keywords = _extractKeywords(combinedText);
        final completeness = _computeCompleteness(combinedText, keywords);
        merged[merged.length - 1] = SectionModel(id: last.id, title: last.title, text: combinedText, keywords: keywords, completeness: completeness);
      } else {
        merged.add(sec);
      }
    }

    return merged;
  }

  // --- Heuristic splitting (original behavior) ---
  List<SectionModel> _heuristicSplit(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final sections = <SectionModel>[];
    StringBuffer current = StringBuffer();
    String currentTitle = 'Intro';

    void flush() {
      final content = current.toString().trim();
      if (content.isNotEmpty) {
        sections.add(SectionModel(id: _uuid.v4(), title: currentTitle, text: content, keywords: _extractKeywords(content), completeness: _computeCompleteness(content, _extractKeywords(content))));
      }
      current = StringBuffer();
    }

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        current.writeln('');
        continue;
      }
      // heading heuristics
      final isAllCaps = line == line.toUpperCase() && line.length > 3;
      final endsWithColon = line.endsWith(':');
      if (isAllCaps || endsWithColon) {
        // flush previous
        flush();
        currentTitle = line.replaceAll(':', '');
        continue;
      }
      current.writeln(line);
      // fallback: if section becomes very large, split
      if (current.toString().split(RegExp(r'\s+')).length > 800) {
        flush();
      }
    }
    flush();
    return sections;
  }

  // --- Sentence-level TF-IDF clustering ---
  List<String> _clusterSectionSentences(String text, {double mergeThreshold = 0.45}) {
    final sentences = _splitToSentences(text);
    if (sentences.length <= 1) return sentences.map((s) => s.trim()).toList();

    final vectors = _tfIdfVectors(sentences);

    // Precompute similarity matrix
    final n = sentences.length;
    final sim = List.generate(n, (_) => List<double>.filled(n, 0.0));
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        final vi = vectors[i] ?? <String, double>{};
        final vj = vectors[j] ?? <String, double>{};
        final s = _cosine(vi, vj);
        sim[i][j] = s;
        sim[j][i] = s;
      }
      sim[i][i] = 1.0;
    }

    // Agglomerative clustering by average-link until next merge would be below threshold
    var clusters = List<List<int>>.generate(n, (i) => [i]);
    while (true) {
      double bestScore = -1.0;
      int a = -1, b = -1;
      for (var i = 0; i < clusters.length; i++) {
        for (var j = i + 1; j < clusters.length; j++) {
          final score = _averageLinkSim(clusters[i], clusters[j], sim);
          if (score > bestScore) {
            bestScore = score;
            a = i;
            b = j;
          }
        }
      }
      if (bestScore < mergeThreshold || a == -1 || b == -1) break;
      // merge b into a
      final merged = List<int>.from(clusters[a])..addAll(clusters[b]);
      clusters[a] = merged;
      clusters.removeAt(b);
    }

    // reconstruct cluster texts preserving sentence order
    final clusterTexts = <String>[];
    for (final c in clusters) {
      c.sort();
      final sb = StringBuffer();
      for (final idx in c) {
        sb.writeln(sentences[idx].trim());
      }
      clusterTexts.add(sb.toString().trim());
    }
    return clusterTexts;
  }

  List<String> _splitToSentences(String text) {
    // naive sentence splitter: split on .!?\n followed by space+capital or EOL
    final raw = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final parts = <String>[];
    final pattern = RegExp(r'(?<=[.!?])\s+');
    final tentative = raw.split(pattern);
    for (final t in tentative) {
      final s = t.trim();
      if (s.isNotEmpty) parts.add(s);
    }
    return parts;
  }

  Map<int, Map<String, double>> _tfIdfVectors(List<String> sentences) {
    final tokenized = <List<String>>[];
    final df = <String, int>{};
    for (final s in sentences) {
      final tokens = s.toLowerCase().replaceAll(RegExp(r"[^a-z0-9\s]"), ' ').split(RegExp(r'\s+')).where((t) => t.length > 2).toList();
      final uniq = <String>{};
      for (final t in tokens) {
        uniq.add(t);
      }
      for (final u in uniq) {
        df[u] = (df[u] ?? 0) + 1;
      }
      tokenized.add(tokens);
    }
    final n = sentences.length;
    final vectors = <int, Map<String, double>>{};
    for (var i = 0; i < n; i++) {
      final tf = <String, double>{};
      final tokens = tokenized[i];
      for (final t in tokens) {
        tf[t] = (tf[t] ?? 0.0) + 1.0;
      }
      // normalize tf
      final len = tokens.isEmpty ? 1.0 : tokens.length.toDouble();
      for (final k in tf.keys.toList()) {
        tf[k] = tf[k]! / len;
      }
      // tf-idf
      final vec = <String, double>{};
      for (final k in tf.keys) {
        final idf = log(n / (1 + (df[k] ?? 0))) + 1.0; // smoothed idf
        vec[k] = tf[k]! * idf;
      }
      vectors[i] = vec;
    }
    return vectors;
  }

  double _averageLinkSim(List<int> a, List<int> b, List<List<double>> sim) {
    double sum = 0.0;
    int count = 0;
    for (final i in a) {
      for (final j in b) {
        sum += sim[i][j];
        count++;
      }
    }
    return count == 0 ? 0.0 : sum / count;
  }

  double _cosine(Map<String, double> a, Map<String, double> b) {
    double dot = 0.0;
    double na = 0.0;
    double nb = 0.0;
    for (final k in a.keys) {
      final av = a[k] ?? 0.0;
      na += av * av;
      final bv = b[k] ?? 0.0;
      dot += av * bv;
    }
    for (final v in b.values) {
      nb += v * v;
    }
    if (na == 0 || nb == 0) return 0.0;
    return dot / (sqrt(na) * sqrt(nb));
  }

  double _cosineSimilarityText(String a, String b) {
    final sa = _splitToSentences(a);
    final sb = _splitToSentences(b);
    if (sa.isEmpty || sb.isEmpty) return 0.0;
    final va = _tfIdfVectors(sa);
    final vb = _tfIdfVectors(sb);
    // compute average sentence-sentence cosine
    double sum = 0.0;
    int cnt = 0;
    for (var i = 0; i < sa.length; i++) {
      for (var j = 0; j < sb.length; j++) {
        sum += _cosine(va[i]!, vb[j]!);
        cnt++;
      }
    }
    return cnt == 0 ? 0.0 : sum / cnt;
  }

  List<String> _extractKeywords(String text, {int top = 6}) {
    final words = text.toLowerCase().replaceAll(RegExp(r"[^a-z0-9\s]"), ' ').split(RegExp(r'\s+')).where((w) => w.length > 3).toList();
    final freq = <String, int>{};
    for (final w in words) {
      freq[w] = (freq[w] ?? 0) + 1;
    }
    final sorted = freq.keys.toList()..sort((a, b) => freq[b]!.compareTo(freq[a]!));
    return sorted.take(top).toList();
  }

  double _computeCompleteness(String content, List<String> keywords) {
    if (keywords.isEmpty) return 0.0;
    int found = 0;
    final lower = content.toLowerCase();
    for (final k in keywords) {
      if (lower.contains(k)) found++;
    }
    return found / keywords.length;
  }
}
