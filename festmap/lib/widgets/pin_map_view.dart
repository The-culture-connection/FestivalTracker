import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
            myLocationEnabled: true,
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
            child: _PinInfoCard(
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

class _PinInfoCard extends StatelessWidget {
  const _PinInfoCard({required this.pin, required this.onClose});

  final FestPin pin;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FestMapColors.card,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.place, color: FestMapColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pin.location,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pin.activity,
                    style: const TextStyle(color: FestMapColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pin.size,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
