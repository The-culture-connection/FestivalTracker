import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../models/fest_pin.dart';
import '../theme/festmap_theme.dart';

class PinMapView extends StatefulWidget {
  const PinMapView({
    super.key,
    required this.pins,
    required this.initialPosition,
    required this.userPosition,
    required this.pendingPin,
    required this.onMapReady,
    required this.onRecenter,
    this.onLongPress,
  });

  final List<FestPin> pins;
  final LatLng initialPosition;
  final LatLng? userPosition;
  final LatLng? pendingPin;
  final void Function(GoogleMapController controller) onMapReady;
  final VoidCallback onRecenter;
  final void Function(LatLng position)? onLongPress;

  @override
  State<PinMapView> createState() => _PinMapViewState();
}

class _PinMapViewState extends State<PinMapView> {
  FestPin? _selectedPin;
  Set<Marker> _markers = {};

  static const _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#0a0a0a"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0a0a0a"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1a1a1a"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#111111"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]}
]
''';

  @override
  void initState() {
    super.initState();
    _markers = _buildMarkers();
  }

  @override
  void didUpdateWidget(covariant PinMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pins != widget.pins ||
        oldWidget.userPosition != widget.userPosition ||
        oldWidget.pendingPin != widget.pendingPin) {
      _markers = _buildMarkers();
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (widget.pendingPin != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pending'),
          position: widget.pendingPin!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'New pin'),
        ),
      );
    }

    for (final pin in widget.pins) {
      markers.add(
        Marker(
          markerId: MarkerId(pin.id),
          position: LatLng(pin.lat, pin.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          onTap: () => setState(() => _selectedPin = pin),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 16,
            ),
            style: _darkMapStyle,
            myLocationEnabled: widget.userPosition != null,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            buildingsEnabled: false,
            trafficEnabled: false,
            indoorViewEnabled: false,
            markers: _markers,
            onMapCreated: widget.onMapReady,
            onLongPress: widget.onLongPress,
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _MapControlButton(
            icon: Icons.my_location,
            onPressed: widget.onRecenter,
          ),
        ),
        if (_selectedPin != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _PinDetailCard(
              pin: _selectedPin!,
              onClose: () => setState(() => _selectedPin = null),
            ),
          ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC0A0A0A),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: FestMapColors.border),
          ),
          child: Icon(icon, color: FestMapColors.primary),
        ),
      ),
    );
  }
}

class _PinDetailCard extends StatelessWidget {
  const _PinDetailCard({required this.pin, required this.onClose});

  final FestPin pin;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final observedLabel = DateFormat.yMMMd().add_jm().format(pin.observedAt);
    final postedLabel = DateFormat.yMMMd().add_jm().format(pin.createdAt);
    final coordinates =
        '${pin.lat.toStringAsFixed(5)}, ${pin.lng.toStringAsFixed(5)}';

    return Material(
      color: FestMapColors.card,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.45,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FestMapColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 4, 8),
              child: Row(
                children: [
                  const Icon(Icons.place, color: FestMapColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Observation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: FestMapColors.border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  children: [
                    _PinDetailRow(
                      icon: Icons.place,
                      title: 'Location',
                      value: pin.location,
                      emphasized: true,
                    ),
                    _PinDetailRow(
                      icon: Icons.music_note,
                      title: 'Activity',
                      value: pin.activity,
                    ),
                    _PinDetailRow(
                      icon: Icons.groups,
                      title: 'Size',
                      value: pin.size,
                    ),
                    _PinDetailRow(
                      icon: Icons.explore,
                      title: 'Movement / Direction',
                      value: pin.direction,
                    ),
                    _PinDetailRow(
                      icon: Icons.checkroom,
                      title: 'Attire / Style',
                      value: pin.attire,
                    ),
                    _PinDetailRow(
                      icon: Icons.schedule,
                      title: 'Date & Time',
                      value: observedLabel,
                    ),
                    _PinDetailRow(
                      icon: Icons.cloud_upload_outlined,
                      title: 'Posted',
                      value: postedLabel,
                    ),
                    _PinDetailRow(
                      icon: Icons.my_location,
                      title: 'Coordinates',
                      value: coordinates,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinDetailRow extends StatelessWidget {
  const _PinDetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: emphasized
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FestMapColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: FestMapColors.border),
              ),
              child: _PinDetailRowContent(
                icon: icon,
                title: title,
                value: value,
                emphasized: true,
              ),
            )
          : _PinDetailRowContent(
              icon: icon,
              title: title,
              value: value,
            ),
    );
  }
}

class _PinDetailRowContent extends StatelessWidget {
  const _PinDetailRowContent({
    required this.icon,
    required this.title,
    required this.value,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: FestMapColors.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: FestMapColors.primary,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: emphasized ? 15 : 14,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.normal,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
