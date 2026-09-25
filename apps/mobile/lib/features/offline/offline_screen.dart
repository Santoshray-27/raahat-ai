import 'package:flutter/material.dart';
import 'package:raahat/core/theme/design_tokens.dart';
import 'package:raahat/core/theme/raahat_widgets.dart';
import 'package:raahat/services/api_client.dart';

/// Screen for managing simulated offline packs and on-device AI status.
class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  bool _isDownloading = false;
  bool _isInstalled = false;
  double _downloadProgress = 0.0;
  String _downloadStatusText = '';

  Map<String, dynamic>? _offlinePackData;

  Future<void> _startDownloadSimulation() async {
    setState(() {
      _isDownloading = true;
      _isInstalled = false;
      _downloadProgress = 0.0;
      _downloadStatusText = 'Initializing Download...';
    });

    try {
      final payload = {
        'region_name': 'Indore to Bhopal Corridor',
        'bounding_box': [
          {'latitude': 22.7196, 'longitude': 75.8577},
          {'latitude': 23.2599, 'longitude': 77.4126}
        ],
        'include_categories': [
          'HOSPITAL', 'POLICE', 'MECHANIC', 'PUNCTURE_REPAIR', 'TOWING'
        ]
      };

      setState(() {
        _downloadProgress = 0.25;
        _downloadStatusText = 'Requesting Pack from Server...';
      });

      final response = await ApiClient.instance.post('/offline-packs', payload);
      final data = response['data'];

      setState(() {
        _downloadProgress = 0.75;
        _downloadStatusText = 'Downloading Route Map & Providers...';
      });

      // Simulate a small delay for downloading the full pack data
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      setState(() {
        _downloadProgress = 1.0;
        _downloadStatusText = 'Offline Safety Pack Installed Successfully!';
        _offlinePackData = data;
        _isDownloading = false;
        _isInstalled = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _downloadStatusText = 'Failed to download pack: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download pack: ${e.toString()}'),
          backgroundColor: RaahatColors.emergencyRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 380;

    return Scaffold(
      backgroundColor: RaahatColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: RaahatColors.whiteCard,
        elevation: 0,
        title: Text(
          'Offline Safety Engine',
          style: RaahatTypography.cardTitle(
            color: RaahatColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? RaahatSpacing.base : RaahatSpacing.lg,
                vertical: RaahatSpacing.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Offline Status Strip
                  RaahatStatusStrip(
                    statusText: _isInstalled
                        ? 'LOCAL RAG READY — ZERO CONNECTIVITY ACTIVE'
                        : 'STANDALONE ENGINE READY FOR DOWNLOAD',
                    isOnline: true,
                  ),
                  const SizedBox(height: RaahatSpacing.base),

                  // Demo Notice Banner
                  _buildDemoNoticeBanner(theme),
                  const SizedBox(height: RaahatSpacing.base),

                  // On-Device AI Status Board
                  _buildAiStatusBoard(theme, isSmallScreen),
                  const SizedBox(height: RaahatSpacing.base),

                  // Download / Manifest Section
                  if (_isDownloading)
                    _buildDownloadProgressCard(theme, isSmallScreen)
                  else if (_isInstalled)
                    _buildManifestCard(theme)
                  else
                    _buildInitialPackCard(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoNoticeBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaahatSpacing.base,
        vertical: RaahatSpacing.md,
      ),
      decoration: BoxDecoration(
        color: RaahatColors.blueLight,
        borderRadius: BorderRadius.circular(RaahatRadius.card),
        border: Border.all(color: RaahatColors.blueBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: RaahatColors.primaryBlue,
          ),
          const SizedBox(width: RaahatSpacing.md),
          Expanded(
            child: Text(
              'Demo Mode — On-device AI and offline packs are simulated locally for testing.',
              style: RaahatTypography.bodySmall(
                color: RaahatColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiStatusBoard(ThemeData theme, bool isSmallScreen) {
    return RaahatConsoleCard(
      padding: EdgeInsets.all(isSmallScreen ? RaahatSpacing.base : RaahatSpacing.lg2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: RaahatColors.primaryBlue.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.memory_rounded,
                        color: RaahatColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: RaahatSpacing.sm2),
                    Expanded(
                      child: Text(
                        'ON-DEVICE ENGINE',
                        style: RaahatTypography.mono(
                          fontSize: 11,
                          color: RaahatColors.darkGold,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RaahatSpacing.xs),
              const RaahatLiveBadge(label: 'EMBEDDED'),
            ],
          ),
          const SizedBox(height: RaahatSpacing.md),
          Text(
            'Local AI & Telemetry Board',
            style: RaahatTypography.displayH3(
              color: RaahatColors.darkText,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          const SizedBox(height: RaahatSpacing.base),

          // Gemma Model Status
          _buildStatusItem(
            label: 'Gemma 2B Quantized',
            status: 'MODEL READY',
            isGreen: true,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: RaahatSpacing.sm2),

          // Local RAG Index
          _buildStatusItem(
            label: 'Local Vector Store',
            status: 'SQLITE RAG OK',
            isGreen: true,
            icon: Icons.storage_rounded,
          ),
          const SizedBox(height: RaahatSpacing.sm2),

          // Storage
          _buildStatusItem(
            label: 'Corridor Cache Used',
            status: '1.6 GB / 64 GB',
            isGreen: false,
            icon: Icons.sd_card_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String label,
    required String status,
    required bool isGreen,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaahatSpacing.md,
        vertical: RaahatSpacing.sm2,
      ),
      decoration: BoxDecoration(
        color: RaahatColors.darkSurface,
        borderRadius: BorderRadius.circular(RaahatRadius.card),
        border: Border.all(color: RaahatColors.darkBorder),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isGreen ? RaahatColors.green : RaahatColors.darkMuted,
          ),
          const SizedBox(width: RaahatSpacing.md),
          Expanded(
            child: Text(
              label,
              style: RaahatTypography.bodySmall(
                color: RaahatColors.darkText,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: RaahatSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RaahatSpacing.sm,
              vertical: RaahatSpacing.xs2,
            ),
            decoration: BoxDecoration(
              color: isGreen
                  ? RaahatColors.liveBadgeBg
                  : RaahatColors.darkElevated,
              borderRadius: BorderRadius.circular(RaahatRadius.badge),
            ),
            child: Text(
              status,
              style: RaahatTypography.monoBadge(
                color: isGreen
                    ? RaahatColors.liveBadgeText
                    : RaahatColors.darkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialPackCard(ThemeData theme) {
    return RaahatLightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Indore ➔ Bhopal Corridor',
                  style: RaahatTypography.cardTitle(
                    color: RaahatColors.textPrimary,
                  ).copyWith(fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: RaahatSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RaahatSpacing.sm,
                  vertical: RaahatSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: RaahatColors.blueLight,
                  borderRadius: BorderRadius.circular(RaahatRadius.badge),
                ),
                child: Text(
                  '36.4 MB',
                  style: RaahatTypography.mono(
                    fontSize: 11,
                    color: RaahatColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RaahatSpacing.xs),
          Text(
            'Includes offline map data, emergency providers, and vector RAG indices for zero-connectivity situations.',
            style: RaahatTypography.bodySmall(
              color: RaahatColors.textMuted,
            ),
          ),
          const SizedBox(height: RaahatSpacing.base),
          Wrap(
            spacing: RaahatSpacing.sm,
            runSpacing: RaahatSpacing.xs,
            children: [
              Chip(
                avatar: const Icon(Icons.data_usage_rounded, size: 16, color: RaahatColors.textSecondary),
                label: Text('Map & POIs', style: RaahatTypography.bodySmall().copyWith(fontSize: 11)),
                backgroundColor: RaahatColors.mutedBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RaahatRadius.badge)),
                side: BorderSide.none,
              ),
              Chip(
                avatar: const Icon(Icons.offline_pin_rounded, size: 16, color: RaahatColors.verifiedGreen),
                label: Text('Pre-compiled', style: RaahatTypography.bodySmall().copyWith(fontSize: 11)),
                backgroundColor: RaahatColors.mutedBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RaahatRadius.badge)),
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: RaahatSpacing.lg),
          ElevatedButton.icon(
            onPressed: _startDownloadSimulation,
            icon: const Icon(Icons.download_rounded),
            label: const Text('DOWNLOAD OFFLINE SAFETY PACK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadProgressCard(ThemeData theme, bool isSmallScreen) {
    final progressPct = (_downloadProgress * 100).toInt();

    return RaahatConsoleCard(
      padding: EdgeInsets.all(isSmallScreen ? RaahatSpacing.base : RaahatSpacing.lg2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: RaahatColors.primaryBlue,
                ),
              ),
              const SizedBox(width: RaahatSpacing.md),
              Expanded(
                child: Text(
                  'Installing Safety Pack...',
                  style: RaahatTypography.cardTitle(
                    color: RaahatColors.darkText,
                  ).copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$progressPct%',
                style: RaahatTypography.mono(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: RaahatColors.darkGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: RaahatSpacing.base),
          ClipRRect(
            borderRadius: BorderRadius.circular(RaahatRadius.badge),
            child: LinearProgressIndicator(
              value: _downloadProgress,
              minHeight: 8,
              backgroundColor: RaahatColors.darkSurface,
              color: RaahatColors.primaryBlue,
            ),
          ),
          const SizedBox(height: RaahatSpacing.md),
          Text(
            _downloadStatusText,
            style: RaahatTypography.mono(
              fontSize: 12,
              color: RaahatColors.darkMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildManifestCard(ThemeData theme) {
    final manifest = _offlinePackData?['manifest'];
    final providers = _offlinePackData?['providers'] as List<dynamic>? ?? [];
    
    final version = manifest?['version']?.toString() ?? '1.0.0';
    final sizeBytes = manifest?['file_size_bytes'] ?? 24500000;
    final sizeMb = (sizeBytes / (1024 * 1024)).toStringAsFixed(1);
    final count = providers.length;

    // Build the string for included data categories
    final Map<String, int> providerCounts = {};
    for (var p in providers) {
      final type = p['service_type']?.toString().toUpperCase() ?? 'UNKNOWN';
      providerCounts[type] = (providerCounts[type] ?? 0) + 1;
    }
    final includedDataString = providerCounts.entries
        .map((e) => '${e.value} ${e.key}')
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Banner
        Container(
          padding: const EdgeInsets.all(RaahatSpacing.base),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(RaahatRadius.mainCard),
            border: Border.all(color: RaahatColors.verifiedGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: RaahatColors.verifiedGreen,
                size: 22,
              ),
              const SizedBox(width: RaahatSpacing.md),
              Expanded(
                child: Text(
                  'Offline Safety Pack Ready For Field Operation',
                  style: RaahatTypography.cardTitle(
                    color: RaahatColors.verifiedGreen,
                  ).copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RaahatSpacing.base),

        // Manifest Details Card
        RaahatLightCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PACK MANIFEST',
                    style: RaahatTypography.mono(
                      color: RaahatColors.primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const RaahatLiveBadge(label: 'ACTIVE PACK'),
                ],
              ),
              const SizedBox(height: RaahatSpacing.sm),
              Text(
                manifest?['region_name']?.toString() ?? 'Indore ➔ Bhopal Corridor',
                style: RaahatTypography.cardTitle(
                  color: RaahatColors.textPrimary,
                ).copyWith(fontSize: 16),
              ),
              const SizedBox(height: RaahatSpacing.base),
              const Divider(color: RaahatColors.border),
              const SizedBox(height: RaahatSpacing.sm2),

              _buildManifestRow(
                theme,
                icon: Icons.sd_storage_outlined,
                label: 'Package Size',
                value: '$sizeMb MB (v$version)',
              ),
              const SizedBox(height: RaahatSpacing.md),

              _buildManifestRow(
                theme,
                icon: Icons.local_hospital_outlined,
                label: 'Included Data',
                value: includedDataString.isNotEmpty ? includedDataString : 'No services found',
              ),
              const SizedBox(height: RaahatSpacing.md),

              _buildManifestRow(
                theme,
                icon: Icons.sync_rounded,
                label: 'Last Sync',
                value: 'Just Now (Verified)',
              ),
              const SizedBox(height: RaahatSpacing.lg2),

              OutlinedButton.icon(
                onPressed: _startDownloadSimulation,
                icon: const Icon(Icons.sync_rounded),
                label: const Text('RE-SYNC SAFETY PACK'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManifestRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: RaahatColors.primaryBlue),
        const SizedBox(width: RaahatSpacing.sm2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: RaahatTypography.eyebrow(
                  color: RaahatColors.textMuted,
                ).copyWith(fontSize: 11),
              ),
              const SizedBox(height: RaahatSpacing.xs2),
              Text(
                value,
                style: RaahatTypography.bodyRegular(
                  color: RaahatColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ).copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
