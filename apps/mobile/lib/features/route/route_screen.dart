import 'package:flutter/material.dart';
import 'package:raahat/core/theme/design_tokens.dart';
import 'package:raahat/core/theme/raahat_widgets.dart';
import 'package:raahat/services/api_client.dart';

/// Screen for planning safe emergency and evacuation routes.
class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  late final TextEditingController _originController;
  late final TextEditingController _destinationController;

  bool _isCalculating = false;
  bool _hasRouteResult = false;
  String? _validationError;
  Map<String, dynamic>? _routeData;

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController(text: 'My Current Location');
    _destinationController = TextEditingController(text: 'Bhopal');
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _handlePlanJourney() async {
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      setState(() {
        _validationError = 'Please specify both Origin and Destination.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify both Origin and Destination.'),
        ),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
      _validationError = null;
    });

    try {
      // 1. Geocode Origin
      final originGeo = await ApiClient.instance.get('/routes/geocode', queryParams: {'q': origin});
      if (!originGeo.containsKey('data') || originGeo['data'] == null) {
        throw Exception('Could not resolve Origin location.');
      }
      final originLat = originGeo['data']['latitude'];
      final originLng = originGeo['data']['longitude'];

      // 2. Geocode Destination
      final destGeo = await ApiClient.instance.get('/routes/geocode', queryParams: {'q': destination});
      if (!destGeo.containsKey('data') || destGeo['data'] == null) {
        throw Exception('Could not resolve Destination location.');
      }
      final destLat = destGeo['data']['latitude'];
      final destLng = destGeo['data']['longitude'];

      // 3. Plan Route
      final routePayload = {
        'origin': {'latitude': originLat, 'longitude': originLng},
        'destination': {'latitude': destLat, 'longitude': destLng},
        'avoid_highways': false,
        'avoid_tolls': false,
      };

      final routeResponse = await ApiClient.instance.post('/routes/plan', routePayload);
      
      if (!mounted) return;

      setState(() {
        _isCalculating = false;
        _hasRouteResult = true;
        _routeData = routeResponse['data'];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCalculating = false;
        _validationError = 'Failed to plan route: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to plan route: ${e.toString()}'),
          backgroundColor: RaahatColors.emergencyRed,
        ),
      );
    }
  }

  void _handlePrepareOfflinePack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Offline Pack navigation ready — switch to Offline tab to download.',
        ),
      ),
    );
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
          'Safe Route Planner',
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
                  // System Status
                  const RaahatStatusStrip(
                    statusText: 'EVACUATION & HAZARD ROUTING ONLINE',
                    isOnline: true,
                  ),
                  const SizedBox(height: RaahatSpacing.base),

                  // Inputs Card
                  _buildInputsCard(theme),
                  const SizedBox(height: RaahatSpacing.base),

                  // Loading Card
                  if (_isCalculating) _buildLoadingCard(theme),

                  // Route Summary Result Card
                  if (_hasRouteResult && !_isCalculating)
                    _buildRouteSummaryCard(theme, isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputsCard(ThemeData theme) {
    return RaahatLightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: RaahatColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(RaahatRadius.badge),
                ),
                child: const Icon(
                  Icons.alt_route_rounded,
                  color: RaahatColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: RaahatSpacing.sm2),
              Expanded(
                child: Text(
                  'Corridor Selection',
                  style: RaahatTypography.cardTitle(
                    color: RaahatColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: RaahatSpacing.xs),
          Text(
            'Specify origin and destination to compute hazard-avoiding corridors.',
            style: RaahatTypography.bodySmall(
              color: RaahatColors.textMuted,
            ),
          ),
          const SizedBox(height: RaahatSpacing.base),

          // Origin Field
          TextField(
            controller: _originController,
            enabled: !_isCalculating,
            style: theme.textTheme.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Origin',
              hintText: 'My Current Location',
              prefixIcon: Icon(Icons.my_location_rounded),
            ),
          ),
          const SizedBox(height: RaahatSpacing.md),

          // Destination Field
          TextField(
            controller: _destinationController,
            enabled: !_isCalculating,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Destination',
              hintText: 'e.g., Bhopal',
              errorText: _validationError,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: RaahatSpacing.lg),

          // PLAN JOURNEY Button
          ElevatedButton.icon(
            onPressed: _isCalculating ? null : _handlePlanJourney,
            icon: _isCalculating
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.navigation_rounded),
            label: Text(_isCalculating ? 'CALCULATING ROUTE...' : 'PLAN SAFE JOURNEY'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return RaahatConsoleCard(
      padding: const EdgeInsets.all(RaahatSpacing.xl),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: RaahatColors.primaryBlue,
            strokeWidth: 3,
          ),
          const SizedBox(height: RaahatSpacing.base),
          Text(
            'Analyzing Hazard-Free Corridors...',
            style: RaahatTypography.mono(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: RaahatColors.darkText,
            ),
          ),
          const SizedBox(height: RaahatSpacing.xs),
          Text(
            'Querying weather reports, roadblock telemetry, and service density.',
            style: RaahatTypography.bodySmall(
              color: RaahatColors.darkMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummaryCard(ThemeData theme, bool isSmallScreen) {
    final distanceText = _routeData?['route']?['distance']?.toString() ?? 'N/A';
    final durationText = _routeData?['route']?['duration']?.toString() ?? 'N/A';
    final List<dynamic> services = _routeData?['services'] ?? [];
    final originText = _originController.text.trim() == 'My Current Location'
        ? 'Indore (Current)'
        : _originController.text.trim();
    final destText = _destinationController.text.trim();

    return RaahatConsoleCard(
      padding: EdgeInsets.all(isSmallScreen ? RaahatSpacing.base : RaahatSpacing.lg2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Route title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: RaahatColors.verifiedGreen.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: RaahatColors.verifiedGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: RaahatSpacing.sm2),
                    Expanded(
                      child: Text(
                        'OPTIMAL SAFE CORRIDOR',
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
              const RaahatLiveBadge(label: 'VERIFIED'),
            ],
          ),
          const SizedBox(height: RaahatSpacing.md),
          Text(
            '$originText ➔ $destText',
            style: RaahatTypography.displayH3(
              color: RaahatColors.darkText,
              fontSize: isSmallScreen ? 20 : 22,
            ),
            softWrap: true,
          ),
          const SizedBox(height: RaahatSpacing.base),
          const Divider(color: RaahatColors.darkBorder),
          const SizedBox(height: RaahatSpacing.base),

          // Distance & Duration Metrics Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(RaahatSpacing.md),
                  decoration: BoxDecoration(
                    color: RaahatColors.darkSurface,
                    borderRadius: BorderRadius.circular(RaahatRadius.card),
                    border: Border.all(color: RaahatColors.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DISTANCE',
                        style: RaahatTypography.mono(
                          fontSize: 10,
                          color: RaahatColors.darkMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: RaahatSpacing.xs2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$distanceText km',
                          style: RaahatTypography.cardTitle(
                            color: RaahatColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        'EST. $durationText',
                        style: RaahatTypography.mono(
                          fontSize: 12,
                          color: RaahatColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: RaahatSpacing.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(RaahatSpacing.md),
                  decoration: BoxDecoration(
                    color: RaahatColors.darkSurface,
                    borderRadius: BorderRadius.circular(RaahatRadius.card),
                    border: Border.all(color: RaahatColors.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EST. DURATION',
                        style: RaahatTypography.mono(
                          fontSize: 10,
                          color: RaahatColors.darkMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: RaahatSpacing.xs2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          durationText.toUpperCase(),
                          style: RaahatTypography.displayHero(
                            fontSize: 30,
                            color: RaahatColors.darkGold,
                          ),
                        ),
                      ),
                      Text(
                        '${services.length} Emergency Facilities Found',
                        style: RaahatTypography.bodySmall(
                          color: RaahatColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RaahatSpacing.lg2),
          if (services.isNotEmpty) ...[
            Text(
              'FACILITIES ALONG CORRIDOR',
              style: RaahatTypography.mono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: RaahatColors.textMuted,
              ),
            ),
            const SizedBox(height: RaahatSpacing.base),
            Wrap(
              spacing: RaahatSpacing.sm,
              runSpacing: RaahatSpacing.sm,
              children: _groupServicesByType(services).entries.map((entry) {
                return _buildFacilityBadge(
                  label: '${entry.key}: ${entry.value}',
                  icon: _getIconForServiceType(entry.key),
                  color: _getColorForServiceType(entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: RaahatSpacing.lg2),
          ],
          // Offline Pack CTA Button
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: RaahatColors.orange,
              borderRadius: BorderRadius.circular(RaahatRadius.button),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handlePrepareOfflinePack,
                borderRadius: BorderRadius.circular(RaahatRadius.button),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: RaahatSpacing.md2,
                    horizontal: RaahatSpacing.base,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.download_for_offline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: RaahatSpacing.sm),
                      Flexible(
                        child: Text(
                          'PREPARE OFFLINE SAFETY PACK',
                          style: RaahatTypography.buttonText(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityBadge({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaahatSpacing.sm2,
        vertical: RaahatSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(RaahatRadius.badge),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: RaahatTypography.monoBadge(color: color),
          ),
        ],
      ),
    );
  }

  Map<String, int> _groupServicesByType(List<dynamic> services) {
    final Map<String, int> counts = {};
    for (var s in services) {
      final type = s['service_type']?.toString().toUpperCase() ?? 'UNKNOWN';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  IconData _getIconForServiceType(String type) {
    switch (type) {
      case 'HOSPITAL':
      case 'AMBULANCE':
        return Icons.local_hospital_rounded;
      case 'POLICE':
        return Icons.local_police_rounded;
      case 'MECHANIC':
      case 'PUNCTURE_REPAIR':
      case 'TOWING':
        return Icons.car_repair_rounded;
      case 'FIRE_BRIGADE':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  Color _getColorForServiceType(String type) {
    switch (type) {
      case 'HOSPITAL':
      case 'AMBULANCE':
        return RaahatColors.primaryBlue;
      case 'POLICE':
        return RaahatColors.textSecondary;
      case 'MECHANIC':
      case 'PUNCTURE_REPAIR':
      case 'TOWING':
        return RaahatColors.amber;
      case 'FIRE_BRIGADE':
        return RaahatColors.emergencyRed;
      default:
        return RaahatColors.textMuted;
    }
  }
}
