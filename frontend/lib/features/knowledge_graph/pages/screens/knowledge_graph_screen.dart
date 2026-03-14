import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common_widgets/responsive.dart';
import '../../../../constants/app_colors.dart';
import '../../../scrapnote/providers/pdf_registry_provider.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';
import '../../models/knowledge_graph_model.dart';
import '../providers/knowledge_graph_provider.dart';
import '../widgets/graph_canvas.dart';
import '../widgets/graph_controls_bar.dart';

class KnowledgeGraphScreen extends ConsumerStatefulWidget {
  const KnowledgeGraphScreen({super.key});

  @override
  ConsumerState<KnowledgeGraphScreen> createState() =>
      _KnowledgeGraphScreenState();
}

class _KnowledgeGraphScreenState extends ConsumerState<KnowledgeGraphScreen> {
  final _canvasKey = GlobalKey<GraphCanvasState>();

  @override
  Widget build(BuildContext context) {
    final graphAsync = ref.watch(knowledgeGraphProvProvider);
    final filter = ref.watch(graphFilterProvProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          _buildHeader(context, isMobile),

          // Graph area
          Expanded(
            child: graphAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.error.withValues(alpha: 0.6)),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load graph',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              data: (graph) {
                if (graph.isEmpty) return _buildEmptyState();

                return Stack(
                  children: [
                    // Graph canvas
                    GraphCanvas(
                      key: _canvasKey,
                      graph: graph,
                      filter: filter,
                      onNodeTap: (node) => _handleNodeTap(node),
                      onNodeDrag: (id, pos) {
                        ref
                            .read(knowledgeGraphProvProvider.notifier)
                            .updateNodePosition(id, pos);
                      },
                      onRelayout: () => _relayout(),
                    ),

                    // Legend (top-right)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: _buildLegend(),
                    ),

                    // Controls bar (bottom-center)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GraphControlsBar(
                          currentFilter: filter,
                          onFilterChanged: (f) {
                            ref
                                .read(graphFilterProvProvider.notifier)
                                .set(f);
                          },
                          onRelayout: _relayout,
                          onResetZoom: () {
                            _canvasKey.currentState?.resetZoom();
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final graphAsync = ref.watch(knowledgeGraphProvProvider);
    final nodeCount = graphAsync.valueOrNull?.nodes.length ?? 0;
    final edgeCount = graphAsync.valueOrNull?.edges.length ?? 0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 16 : 24,
        isMobile ? 16 : 24,
        16,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Knowledge Graph',
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 12),
          if (nodeCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$nodeCount nodes \u00B7 $edgeCount edges',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hub_rounded,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No connections yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open a PDF and create notes to see\nyour knowledge graph grow.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendRow(color: Color(0xFF3B82F6), label: 'PDF'),
          SizedBox(height: 6),
          _LegendRow(color: Color(0xFF10B981), label: 'Note'),
        ],
      ),
    );
  }

  void _relayout() {
    ref
        .read(knowledgeGraphProvProvider.notifier)
        .relayout(const Size(2000, 2000));
  }

  void _handleNodeTap(KnowledgeNode node) async {
    switch (node.type) {
      case KnowledgeNodeType.pdf:
        // Try registry first, fall back to linkedPdfPath on the node
        final pdfPath = ref
                .read(pdfRegistryProvProvider.notifier)
                .getPathById(node.referenceId) ??
            node.linkedPdfPath;
        if (pdfPath != null) {
          await ref.read(workspaceProviderProvider.notifier).loadPdf(pdfPath);
          if (mounted) context.go('/workspace');
        }
      case KnowledgeNodeType.note:
        await ref
            .read(workspaceProviderProvider.notifier)
            .loadNote(node.referenceId);
        // If the note has a linked PDF, also load it
        if (node.linkedPdfPath != null && node.linkedPdfPath!.isNotEmpty) {
          await ref
              .read(workspaceProviderProvider.notifier)
              .loadPdf(node.linkedPdfPath!);
        }
        if (mounted) context.go('/workspace');
    }
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
