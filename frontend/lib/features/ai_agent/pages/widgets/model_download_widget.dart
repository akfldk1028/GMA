import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../model_manager/model_downloader.dart';
import '../../model_manager/model_registry.dart';

/// Widget showing model download button + progress bar.
///
/// Planner decision: user presses "Agent 다운로드" button to download.
class ModelDownloadWidget extends StatefulWidget {
  const ModelDownloadWidget({super.key});

  @override
  State<ModelDownloadWidget> createState() => _ModelDownloadWidgetState();
}

class _ModelDownloadWidgetState extends State<ModelDownloadWidget> {
  ModelStatus _status = ModelStatus.notInstalled;
  int _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final installed = await ModelDownloader.isInstalled();
    if (mounted) {
      setState(() {
        _status = installed ? ModelStatus.installed : ModelStatus.notInstalled;
      });
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _status = ModelStatus.downloading;
      _progress = 0;
      _error = null;
    });

    try {
      await ModelDownloader.downloadWithProgress((progress) {
        if (mounted) setState(() => _progress = progress);
      });
      if (mounted) setState(() => _status = ModelStatus.installed);
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = ModelStatus.error;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _statusIcon,
                size: 16,
                color: _statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Gemma 4 E4B',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${gemmaE4B.sizeGB.toStringAsFixed(1)} GB',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_status == ModelStatus.downloading) ...[
            LinearProgressIndicator(
              value: _progress / 100,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              '$_progress%',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ] else if (_status == ModelStatus.error) ...[
            Text(
              _error ?? '다운로드 실패',
              style: const TextStyle(fontSize: 11, color: Colors.red),
            ),
            const SizedBox(height: 4),
            _buildButton('다시 시도', _startDownload),
          ] else if (_status == ModelStatus.installed) ...[
            const Text(
              '설치됨 — 사용 가능',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ] else ...[
            _buildButton('Agent 다운로드', _startDownload),
          ],
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed,
      {bool danger = false}) {
    return SizedBox(
      height: 28,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: danger ? Colors.red : AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(fontSize: 11),
        ),
        child: Text(label),
      ),
    );
  }

  IconData get _statusIcon => switch (_status) {
        ModelStatus.notInstalled => Icons.download_outlined,
        ModelStatus.downloading => Icons.downloading,
        ModelStatus.installed => Icons.check_circle_outline,
        ModelStatus.error => Icons.error_outline,
      };

  Color get _statusColor => switch (_status) {
        ModelStatus.notInstalled => AppColors.textMuted,
        ModelStatus.downloading => AppColors.primary,
        ModelStatus.installed => Colors.green,
        ModelStatus.error => Colors.red,
      };
}
