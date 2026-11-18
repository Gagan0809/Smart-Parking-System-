class ParkingLocation {
  const ParkingLocation({
    this.id,
    required this.name,
    required this.address,
    required this.slots,
    required this.status,
    this.latitude,
    this.longitude,
  });

  final String? id;
  final String name;
  final String address;
  final int slots;
  final String status;
  final double? latitude;
  final double? longitude;

  factory ParkingLocation.fromJson(Map<String, dynamic> json) {
    return ParkingLocation(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      slots: int.tryParse(json['slots']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'Active',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'slots': slots,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }
}

