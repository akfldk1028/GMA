import 'dart:ui' show Offset, Size;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../file_manager/pages/providers/file_manager_provider.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../../../scrapnote/providers/pdf_registry_provider.dart';
import '../../models/knowledge_graph_model.dart';
import '../../utils/force_directed_layout.dart';

part 'knowledge_graph_provider.g.dart';

/// Builds a [KnowledgeGraph] from the current note list, PDF registry
/// and ScrapElement store, then lays it out with force-directed placement.
@riverpod
class KnowledgeGraphProv extends _$KnowledgeGraphProv {
  @override
  Future<KnowledgeGraph> build() async {
    // Watch data sources so graph rebuilds when they change.
    ref.watch(elementStoreProvider); // revision counter
    ref.watch(pdfRegistryProvProvider); // void, but triggers on init

    // Await notes so the graph stays in loading state until ready.
    final notes = await ref.watch(fileManagerProvider.future);
    if (notes.isEmpty) return KnowledgeGraph.empty;

    // Ensure PDF registry is ready before lookups.
    await ref.read(pdfRegistryProvProvider.notifier).ensureReady();
    final registry = ref.read(pdfRegistryProvProvider.notifier);
    final store = ref.read(elementStoreProvider.notifier);

    // ── Collect unique PDFs from notes ───────────────────────
    // key = pdfPath, value = pdfId (UUID, may be null if unregistered)
    final pdfPathToId = <String, String?>{};
    for (final note in notes) {
      if (note.hasLinkedPdf) {
        final path = note.linkedPdfPath!;
        if (!pdfPathToId.containsKey(path)) {
          pdfPathToId[path] = registry.getIdByPath(path);
        }
      }
    }

    // ── Build nodes ──────────────────────────────────────────
    final nodeMap = <String, KnowledgeNode>{};

    // Note nodes
    for (final note in notes) {
      nodeMap['note:${note.id}'] = KnowledgeNode(
        id: 'note:${note.id}',
        label: note.title,
        type: KnowledgeNodeType.note,
        referenceId: note.id,
        linkedPdfPath: note.linkedPdfPath,
      );
    }

    // PDF nodes — create from all linked paths (even unregistered)
    for (final path in pdfPathToId.keys) {
      final pdfId = pdfPathToId[path];
      // Use pdfId if registered, otherwise hash the path for a stable ID
      final nodeId = pdfId != null
          ? 'pdf:$pdfId'
          : 'pdf:${path.hashCode.toRadixString(16)}';
      final segments = path.replaceAll('\\', '/').split('/');
      final label = segments.isNotEmpty ? segments.last : path;
      nodeMap[nodeId] = KnowledgeNode(
        id: nodeId,
        label: label,
        type: KnowledgeNodeType.pdf,
        referenceId: pdfId ?? path, // fallback to path for navigation
        linkedPdfPath: path,
      );
    }

    // ── Build edges ──────────────────────────────────────────
    final edges = <KnowledgeEdge>[];
    final connectionCounts = <String, int>{};

    for (final note in notes) {
      if (!note.hasLinkedPdf) continue;
      final path = note.linkedPdfPath!;
      final pdfId = pdfPathToId[path];

      // Find the PDF node ID (matches creation logic above)
      final pdfNodeId = pdfId != null
          ? 'pdf:$pdfId'
          : 'pdf:${path.hashCode.toRadixString(16)}';
      final noteNodeId = 'note:${note.id}';

      if (!nodeMap.containsKey(pdfNodeId)) continue;

      // Count ScrapElements for this PDF (only if registered)
      final elements =
          pdfId != null ? store.getByPdfId(pdfId) : <dynamic>[];
      final weight = elements.isEmpty ? 1 : elements.length;

      edges.add(KnowledgeEdge(
        fromId: pdfNodeId,
        toId: noteNodeId,
        weight: weight,
        label: weight > 1 ? '$weight scraps' : null,
      ));

      connectionCounts[noteNodeId] =
          (connectionCounts[noteNodeId] ?? 0) + 1;
      connectionCounts[pdfNodeId] =
          (connectionCounts[pdfNodeId] ?? 0) + 1;
    }

    // Update connection counts on nodes
    for (final node in nodeMap.values) {
      final count = connectionCounts[node.id] ?? 0;
      if (count > 0) {
        // Mutate connectionCount via new node (plain class, not frozen)
        nodeMap[node.id] = KnowledgeNode(
          id: node.id,
          label: node.label,
          type: node.type,
          referenceId: node.referenceId,
          linkedPdfPath: node.linkedPdfPath,
          connectionCount: count,
        );
      }
    }

    final graph = KnowledgeGraph(
      nodes: nodeMap.values.toList(),
      edges: edges,
    );

    // Initial layout with default canvas size (will be re-laid out on screen)
    ForceDirectedLayout.layout(graph, const Size(2000, 2000));

    return graph;
  }

  /// Re-run force-directed layout with actual canvas size.
  void relayout(Size canvasSize) {
    final graph = state.valueOrNull;
    if (graph == null || graph.isEmpty) return;

    ForceDirectedLayout.layout(graph, canvasSize);
    // Trigger rebuild by reassigning state with same graph object
    state = AsyncData(KnowledgeGraph(
      nodes: graph.nodes,
      edges: graph.edges,
    ));
  }

  /// Update a single node's position after user drag.
  void updateNodePosition(String nodeId, Offset offset) {
    final graph = state.valueOrNull;
    if (graph == null) return;

    for (final node in graph.nodes) {
      if (node.id == nodeId) {
        node.position = offset;
        break;
      }
    }

    state = AsyncData(KnowledgeGraph(
      nodes: graph.nodes,
      edges: graph.edges,
    ));
  }
}

/// Filter enum for the graph controls bar.
enum GraphFilter { all, pdfs, notes }

/// Simple filter state provider.
@riverpod
class GraphFilterProv extends _$GraphFilterProv {
  @override
  GraphFilter build() => GraphFilter.all;

  void set(GraphFilter filter) => state = filter;
}
