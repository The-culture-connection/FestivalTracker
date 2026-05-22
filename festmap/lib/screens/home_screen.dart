import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/fest_pin.dart';
import '../services/location_service.dart';
import '../services/pin_repository.dart';
import '../theme/festmap_theme.dart';
import '../widgets/festmap_header.dart';
import '../widgets/observation_form_sheet.dart';
import '../widgets/pin_map_view.dart';

/// Default camera until GPS resolves (emulator-friendly).
const _fallbackPosition = LatLng(34.0522, -118.2437);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _locationService = LocationService();
  final _pinRepository = PinRepository();

  GoogleMapController? _mapController;
  LatLng _mapCenter = _fallbackPosition;
  LatLng? _userPosition;
  LatLng? _pendingPin;
  String? _pendingLocationLabel;
  List<FestPin> _pins = [];
  StreamSubscription<List<FestPin>>? _pinsSub;
  bool _locating = true;
  String? _locationBanner;
  String? _error;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initLocation());
    });
  }

  @override
  void dispose() {
    _pinsSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (!mounted) return;
    setState(() {
      _locating = true;
      _error = null;
      _locationBanner = 'Finding your location…';
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _userPosition = latLng;
        _mapCenter = latLng;
        _locating = false;
        _locationBanner = null;
      });

      _listenForNearbyPins(latLng);
      await _animateTo(latLng);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _locationBanner = null;
        _error = e.toString();
        _userPosition ??= _mapCenter;
      });
      if (_userPosition != null) {
        _listenForNearbyPins(_userPosition!);
      }
    }
  }

  Future<void> _animateTo(LatLng target) async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16),
      ),
    );
  }

  void _listenForNearbyPins(LatLng center) {
    _pinsSub?.cancel();
    _pinsSub = _pinRepository
        .watchNearbyPins(lat: center.latitude, lng: center.longitude)
        .listen((pins) {
      if (!mounted) return;
      setState(() => _pins = pins);
    });
  }

  Future<void> _recenter() async {
    if (_userPosition == null) {
      await _initLocation();
      return;
    }
    await _animateTo(_userPosition!);
  }

  Future<void> _openDropPinForm({LatLng? at}) async {
    final target = at ?? _userPosition;
    if (target == null) {
      _showSnack('Waiting for your location…');
      return;
    }

    setState(() {
      _pendingPin = target;
      _pendingLocationLabel = null;
      _showForm = true;
    });

    try {
      final label = await _locationService.reverseGeocode(
        target.latitude,
        target.longitude,
      );
      if (!mounted || !_showForm) return;
      setState(() => _pendingLocationLabel = label);
    } catch (e) {
      if (!mounted || !_showForm) return;
      setState(
        () => _pendingLocationLabel =
            '${target.latitude.toStringAsFixed(5)}, ${target.longitude.toStringAsFixed(5)}',
      );
    }
  }

  Future<void> _savePin(PinDraft draft) async {
    try {
      await _pinRepository.savePin(draft);
      if (!mounted) return;
      setState(() {
        _showForm = false;
        _pendingPin = null;
        _pendingLocationLabel = null;
      });
      _showSnack('Pin saved');
      await _recenter();
    } catch (e) {
      _showSnack('Failed to save pin: $e');
    }
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _pendingPin = null;
      _pendingLocationLabel = null;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: FestMapColors.card,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showMap = _error == null;

    return Scaffold(
      backgroundColor: FestMapColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FestMapHeader(pinCount: _pins.length),
            Expanded(
              child: Stack(
                children: [
                  if (showMap)
                    PinMapView(
                      pins: _pins,
                      initialPosition: _mapCenter,
                      userPosition: _userPosition,
                      pendingPin: _pendingPin,
                      onMapReady: (controller) {
                        _mapController = controller;
                        if (_userPosition != null) {
                          unawaited(_animateTo(_userPosition!));
                        }
                      },
                      onRecenter: () => unawaited(_recenter()),
                      onLongPress: (pos) => unawaited(_openDropPinForm(at: pos)),
                    ),
                  if (_error != null)
                    _ErrorState(message: _error!, onRetry: _initLocation),
                  if (_locating && showMap)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: _LocationBanner(
                        message: _locationBanner ?? 'Finding your location…',
                      ),
                    ),
                  if (!_showForm && showMap)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 88,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xCC0A0A0A),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: FestMapColors.border),
                          ),
                          child: const Text(
                            'Tap + to drop a pin at your location',
                            style: TextStyle(
                              color: FestMapColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_showForm && _pendingPin != null)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _closeForm,
                        child: Container(color: Colors.black54),
                      ),
                    ),
                  if (_showForm && _pendingPin != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ObservationFormSheet(
                        initialLocation: _pendingLocationLabel ??
                            '${_pendingPin!.latitude.toStringAsFixed(5)}, ${_pendingPin!.longitude.toStringAsFixed(5)}',
                        lat: _pendingPin!.latitude,
                        lng: _pendingPin!.longitude,
                        onCancel: _closeForm,
                        onSubmit: _savePin,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => unawaited(_openDropPinForm()),
              backgroundColor: FestMapColors.primary,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add_location_alt),
              label: const Text(
                'Drop Pin',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
    );
  }
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xE60A0A0A),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: FestMapColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, color: FestMapColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
