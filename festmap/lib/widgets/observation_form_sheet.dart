import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/fest_pin.dart';
import '../services/location_service.dart';
import '../theme/festmap_theme.dart';

class ObservationFormSheet extends StatefulWidget {
  const ObservationFormSheet({
    super.key,
    required this.initialLocation,
    required this.lat,
    required this.lng,
    required this.locationService,
    required this.onSubmit,
    required this.onCancel,
    this.onPinMoved,
  });

  final String initialLocation;
  final double lat;
  final double lng;
  final LocationService locationService;
  final Future<void> Function(PinDraft draft) onSubmit;
  final VoidCallback onCancel;
  final void Function(double lat, double lng)? onPinMoved;

  @override
  State<ObservationFormSheet> createState() => _ObservationFormSheetState();
}

class _ObservationFormSheetState extends State<ObservationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _locationController;
  late final TextEditingController _activityController;
  late final TextEditingController _sizeController;
  late final TextEditingController _directionController;
  late final TextEditingController _attireController;
  late DateTime _observedAt;
  late double _lat;
  late double _lng;
  bool _saving = false;
  bool _geocodingLocation = false;
  bool _locationEditedByUser = false;
  String? _geocodeHint;
  Timer? _geocodeDebounce;

  @override
  void initState() {
    super.initState();
    _lat = widget.lat;
    _lng = widget.lng;
    _locationController = TextEditingController(text: widget.initialLocation);
    _locationController.addListener(_onLocationTextChanged);
    _activityController = TextEditingController();
    _sizeController = TextEditingController();
    _directionController = TextEditingController();
    _attireController = TextEditingController();
    _observedAt = DateTime.now();
  }

  void _onLocationTextChanged() {
    if (!_locationEditedByUser) {
      _locationEditedByUser = true;
    }
    _scheduleAddressGeocode();
  }

  void _scheduleAddressGeocode() {
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 900), () {
      unawaited(_resolveAddressToPin());
    });
  }

  Future<void> _resolveAddressToPin() async {
    if (!_locationEditedByUser) return;

    final query = _locationController.text.trim();
    if (query.length < 5) {
      if (mounted) {
        setState(() => _geocodeHint = null);
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _geocodingLocation = true;
      _geocodeHint = null;
    });

    final coords = await widget.locationService.forwardGeocode(query);
    if (!mounted) return;

    if (coords == null) {
      setState(() {
        _geocodingLocation = false;
        _geocodeHint = 'Could not find that address on the map';
      });
      return;
    }

    setState(() {
      _geocodingLocation = false;
      _lat = coords.lat;
      _lng = coords.lng;
      _geocodeHint = 'Pin moved to this address';
    });
    widget.onPinMoved?.call(coords.lat, coords.lng);
  }

  @override
  void didUpdateWidget(covariant ObservationFormSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLocation != widget.initialLocation &&
        _locationController.text == oldWidget.initialLocation) {
      _locationEditedByUser = false;
      _locationController.text = widget.initialLocation;
    }
    if (oldWidget.lat != widget.lat || oldWidget.lng != widget.lng) {
      _lat = widget.lat;
      _lng = widget.lng;
    }
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _locationController.removeListener(_onLocationTextChanged);
    _locationController.dispose();
    _activityController.dispose();
    _sizeController.dispose();
    _directionController.dispose();
    _attireController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _observedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: FestMapColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_observedAt),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: FestMapColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (time == null || !mounted) return;

    setState(() {
      _observedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      _geocodeDebounce?.cancel();
      final locationText = _locationController.text.trim();
      final coords = await widget.locationService.forwardGeocode(locationText);
      final lat = coords?.lat ?? _lat;
      final lng = coords?.lng ?? _lng;

      await widget.onSubmit(
        PinDraft(
          lat: lat,
          lng: lng,
          location: locationText,
          activity: _activityController.text.trim(),
          size: _sizeController.text.trim(),
          direction: _directionController.text.trim(),
          attire: _attireController.text.trim(),
          observedAt: _observedAt,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat.yMMMd().add_jm().format(_observedAt);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: const BoxDecoration(
          color: FestMapColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: FestMapColors.border),
            left: BorderSide(color: FestMapColors.border),
            right: BorderSide(color: FestMapColors.border),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: BoxDecoration(
                color: FestMapColors.primary.withValues(alpha: 0.1),
                border: const Border(bottom: BorderSide(color: FestMapColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FestMapColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.music_note, color: FestMapColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Text('New Observation', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _highlightField(
                        label: 'Location',
                        icon: Icons.place,
                        child: TextFormField(
                          controller: _locationController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Venue or area name',
                            suffixIcon: _geocodingLocation
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: FestMapColors.primary,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        helper: _geocodeHint ??
                            'Editing the address moves the pin on the map',
                      ),
                      const SizedBox(height: 14),
                      _field(
                        label: 'Activity',
                        icon: Icons.music_note,
                        child: TextFormField(
                          controller: _activityController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'e.g., Main stage performance, DJ set',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _field(
                        label: 'Size',
                        icon: Icons.groups,
                        child: TextFormField(
                          controller: _sizeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'e.g., 500–1000 people, high energy',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _field(
                        label: 'Movement / Direction',
                        icon: Icons.explore,
                        child: TextFormField(
                          controller: _directionController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'e.g., Moving toward food area',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _field(
                        label: 'Attire / Style',
                        icon: Icons.checkroom,
                        child: TextFormField(
                          controller: _attireController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'e.g., Festival wristbands, vintage tees',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _field(
                        label: 'Date & Time',
                        icon: Icons.schedule,
                        child: InkWell(
                          onTap: _pickDateTime,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: FestMapColors.primary,
                              ),
                            ),
                            child: Text(
                              dateLabel,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _saving ? null : widget.onCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: FestMapColors.border),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _saving ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: FestMapColors.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Save Pin',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, icon),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _highlightField({
    required String label,
    required IconData icon,
    required Widget child,
    required String helper,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FestMapColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FestMapColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, icon, emphasized: true),
          const SizedBox(height: 8),
          child,
          const SizedBox(height: 6),
          Text(helper, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _label(String text, IconData icon, {bool emphasized = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: emphasized ? 20 : 18,
          color: FestMapColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
