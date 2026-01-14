import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';

/// Location Message Widget
///
/// Displays a location on an interactive map with coordinates
/// and option to open in external maps app.
class LocationMessageWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? address;
  final double? maxHeight;

  const LocationMessageWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.address,
    this.maxHeight = 180,
  });

  /// Format coordinates for display
  String _formatCoordinates() {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';
    return '${latitude.abs().toStringAsFixed(6)}° $latDir, ${longitude.abs().toStringAsFixed(6)}° $lngDir';
  }

  /// Open location in external maps app
  Future<void> _openInMaps() async {
    // Try Google Maps first, then fallback to general geo URI
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to geo URI scheme
      final geoUrl = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');
      if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Map preview
        GestureDetector(
          onTap: _openInMaps,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: maxHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  // Interactive map
                  IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(latitude, longitude),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        // OpenStreetMap tiles
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.viernes.mobile',
                        ),
                        // Location marker
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(latitude, longitude),
                              width: 40,
                              height: 40,
                              child: const _LocationMarker(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tap overlay hint
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.open_in_new,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Open in Maps',
                            style: ViernesTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: ViernesSpacing.xs),

        // Coordinates and address
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 14,
              color: ViernesColors.getTextColor(isDark).withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                address ?? _formatCoordinates(),
                style: ViernesTextStyles.caption.copyWith(
                  color: ViernesColors.getTextColor(isDark).withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom location marker widget
class _LocationMarker extends StatelessWidget {
  const _LocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Shadow
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        // Outer circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ViernesColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
        // Inner dot
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
