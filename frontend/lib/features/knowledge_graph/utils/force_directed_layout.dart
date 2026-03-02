import 'dart:math';
import 'dart:ui' show Offset, Size;

import '../models/knowledge_graph_model.dart';

/// Fruchterman-Reingold force-directed layout algorithm.
class ForceDirectedLayout {
  ForceDirectedLayout._();

  /// Lay out [graph] nodes within the given [canvasSize].
  ///
  /// * max 300 iterations
  /// * early exit when max displacement < 0.5 px
  /// * linear temperature cooling
  /// * positions clamped to canvas bounds
  static void layout(KnowledgeGraph graph, Size canvasSize) {
    final nodes = graph.nodes;
    if (nodes.isEmpty) return;

    final n = nodes.length;

    if (n == 1) {
      nodes[0].position = Offset(canvasSize.width / 2, canvasSize.height / 2);
      return;
    }

    // Area & ideal spring length
    final area = canvasSize.width * canvasSize.height;
    final k = sqrt(area / n); // ideal edge length

    // Initial placement: deterministic random (seeded)
    final rng = Random(42);
    final margin = 60.0;
    for (final node in nodes) {
      node.position = Offset(
        margin + rng.nextDouble() * (canvasSize.width - margin * 2),
        margin + rng.nextDouble() * (canvasSize.height - margin * 2),
      );
    }

    // Pre-build node index (once, outside loop)
    final nodeIndex = <String, int>{};
    for (int i = 0; i < n; i++) {
      nodeIndex[nodes[i].id] = i;
    }

    const maxIterations = 300;
    double temperature = canvasSize.width / 10;
    final coolingFactor = temperature / (maxIterations + 1);

    for (int iter = 0; iter < maxIterations; iter++) {
      // Displacement accumulator
      final disp = List<Offset>.filled(n, Offset.zero);

      // Repulsive forces (all pairs)
      for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
          var delta = nodes[i].position - nodes[j].position;
          final dist = max(delta.distance, 0.01);
          final force = (k * k) / dist;
          final normalized = delta / dist;
          disp[i] = disp[i] + normalized * force;
          disp[j] = disp[j] - normalized * force;
        }
      }

      // Attractive forces (edges)
      for (final edge in graph.edges) {
        final ui = nodeIndex[edge.fromId];
        final vi = nodeIndex[edge.toId];
        if (ui == null || vi == null) continue;

        var delta = nodes[ui].position - nodes[vi].position;
        final dist = max(delta.distance, 0.01);
        final force = (dist * dist) / k;
        final normalized = delta / dist;
        disp[ui] = disp[ui] - normalized * force;
        disp[vi] = disp[vi] + normalized * force;
      }

      // Apply displacement, limited by temperature
      double maxDisp = 0;
      for (int i = 0; i < n; i++) {
        final d = disp[i];
        final dist = max(d.distance, 0.01);
        final capped = min(dist, temperature);
        final move = d / dist * capped;
        maxDisp = max(maxDisp, capped);

        var newPos = nodes[i].position + move;

        // Clamp to canvas bounds
        newPos = Offset(
          newPos.dx.clamp(margin, canvasSize.width - margin),
          newPos.dy.clamp(margin, canvasSize.height - margin),
        );
        nodes[i].position = newPos;
      }

      // Cool down
      temperature -= coolingFactor;
      if (temperature < 0) temperature = 0;

      // Early termination
      if (maxDisp < 0.5) break;
    }
  }
}
