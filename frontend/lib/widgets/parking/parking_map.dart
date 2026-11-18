import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/parking_controller.dart';
import '../../models/parking_slot.dart';

class ParkingMap extends StatefulWidget {
  const ParkingMap({
    required this.controller,
    this.location = '',
    this.maxDistanceKm,
    this.maxPrice,
    this.availableOnly = false,
    super.key,
  });

  final ParkingController controller;
  final String location;
  final double? maxDistanceKm;
  final double? maxPrice;
  final bool availableOnly;

  @override
  State<ParkingMap> createState() => _ParkingMapState();
}

class _ParkingMapState extends State<ParkingMap> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;

  static const LatLng _defaultCenter = LatLng(
    12.934884,
    77.534128,
  );

  static const LatLng _basketballCourtParking = LatLng(
    12.935473,
    77.532413,
  );

  static const LatLng _pesBikeParking = LatLng(
    12.9342951,
    77.5358424,
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _initializeLocation();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = position;
      });

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      });
    } catch (_) {}
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(
            title: 'Your Location',
          ),
        ),
      );
    }

    final slots = widget.controller.searchParking(
      query: widget.location,
      maxDistanceKm: widget.maxDistanceKm,
      maxPrice: widget.maxPrice,
      availableOnly: widget.availableOnly,
      userLatitude: _currentPosition?.latitude,
      userLongitude: _currentPosition?.longitude,
    );

    final grouped = <String, List<ParkingSlot>>{};

    for (final slot in slots) {
      final latitude = slot.latitude;
      final longitude = slot.longitude;

      if (latitude == null || longitude == null) {
        continue;
      }

      final key =
          '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';

      grouped.putIfAbsent(key, () => []).add(slot);
    }

    for (final entry in grouped.entries) {
      final parkingSlots = entry.value;

      final first = parkingSlots.first;

      final latitude = first.latitude;
      final longitude = first.longitude;

      if (latitude == null || longitude == null) {
        continue;
      }

      final availableCount =
          parkingSlots.where((slot) => !slot.isOccupied).length;

      final totalCount = parkingSlots.length;

      final occupied = availableCount == 0;

      markers.add(
        Marker(
          markerId: MarkerId(
            'parking_${latitude}_$longitude',
          ),
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            occupied
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: first.location.isNotEmpty
                ? first.location
                : 'Parking',
            snippet:
            '$availableCount / $totalCount slots available',
          ),
          onTap: () {
            _showParkingDetails(
              first.location.isNotEmpty
                  ? first.location
                  : 'Parking',
              parkingSlots,
            );
          },
        ),
      );
    }

    if (!_containsLocation(
      markers,
      _basketballCourtParking,
    )) {
      markers.add(
        Marker(
          markerId: const MarkerId(
            'basketball_court_parking',
          ),
          position: _basketballCourtParking,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(
            title: 'Basketball Court Parking',
            snippet: 'PES University',
          ),
          onTap: () {
            _showStaticParkingDetails(
              'Basketball Court Parking',
              'PES University',
              4,
              6,
            );
          },
        ),
      );
    }

    if (!_containsLocation(
      markers,
      _pesBikeParking,
    )) {
      markers.add(
        Marker(
          markerId: const MarkerId(
            'pes_bike_parking',
          ),
          position: _pesBikeParking,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(
            title: 'PES Bike Parking Lot',
            snippet: 'PES University',
          ),
          onTap: () {
            _showStaticParkingDetails(
              'PES Bike Parking Lot',
              'PES University',
              8,
              10,
            );
          },
        ),
      );
    }

    return markers;
  }

  bool _containsLocation(
      Set<Marker> markers,
      LatLng location,
      ) {
    for (final marker in markers) {
      if ((marker.position.latitude - location.latitude).abs() < 0.00001 &&
          (marker.position.longitude - location.longitude).abs() < 0.00001) {
        return true;
      }
    }

    return false;
  }

  Future<void> _goToCurrentLocation() async {
    final position = _currentPosition;

    if (position == null || _mapController == null) {
      await _initializeLocation();
      return;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          position.latitude,
          position.longitude,
        ),
        16,
      ),
    );
  }

  void _showStaticParkingDetails(
      String title,
      String subtitle,
      int available,
      int total,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ParkingDetailsSheet(
          title: title,
          subtitle: subtitle,
          available: available,
          total: total,
        );
      },
    );
  }

  void _showParkingDetails(
      String title,
      List<ParkingSlot> slots,
      ) {
    final available = slots.where((slot) => !slot.isOccupied).length;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ParkingDetailsSheet(
          title: title,
          subtitle: 'Parking',
          available: available,
          total: slots.length,
          slots: slots,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers();

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _defaultCenter,
              zoom: 15.5,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            buildingsEnabled: true,
            trafficEnabled: false,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
              ),
            },
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            right: 14,
            bottom: 20,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  onPressed: () async {
                    await _mapController?.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                ),
                const SizedBox(height: 2),
                _MapButton(
                  icon: Icons.remove,
                  onPressed: () async {
                    await _mapController?.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _MapButton(
                  icon: Icons.my_location,
                  onPressed: _goToCurrentLocation,
                ),
              ],
            ),
          ),
          if (widget.location.isNotEmpty)
            Positioned(
              left: 16,
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      offset: Offset(0, 2),
                      color: Color(0x22000000),
                    ),
                  ],
                ),
                child: Text(
                  widget.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202938),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: const Color(0xFF4A5568),
          ),
        ),
      ),
    );
  }
}

class _ParkingDetailsSheet extends StatelessWidget {
  const _ParkingDetailsSheet({
    required this.title,
    required this.subtitle,
    required this.available,
    required this.total,
    this.slots,
  });

  final String title;
  final String subtitle;
  final int available;
  final int total;
  final List<ParkingSlot>? slots;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD5DAE2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_parking_rounded,
                      color: Color(0xFF1769E0),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF202938),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF747B87),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Available',
                      value: '$available',
                      color: const Color(0xFF1E9E50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Total',
                      value: '$total',
                      color: const Color(0xFF1769E0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (slots != null)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                  ),
                  itemCount: slots!.length,
                  itemBuilder: (context, index) {
                    final slot = slots![index];

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 9,
                      ),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFE6E9EE),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            slot.isOccupied
                                ? Icons.block_rounded
                                : Icons.local_parking_rounded,
                            color: slot.isOccupied
                                ? const Color(0xFFE53935)
                                : const Color(0xFF1E9E50),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              slot.location.isNotEmpty
                                  ? slot.location
                                  : 'Parking Slot',
                              style: const TextStyle(
                                color: Color(0xFF202938),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            slot.isOccupied
                                ? 'Occupied'
                                : 'Available',
                            style: TextStyle(
                              color: slot.isOccupied
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF1E9E50),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF747B87),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}