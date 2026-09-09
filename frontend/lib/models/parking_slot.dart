class ParkingSlot {
  ParkingSlot({
    required this.id,
    required this.isOccupied,
    required this.timeSlots,
    this.location = '',
    this.backendId,
  });

  final String id;
  final String location;
  final String? backendId;
  bool isOccupied;
  final List<String> timeSlots;

  bool get isAvailable => !isOccupied;

  static List<ParkingSlot> seed() {
    return [
      ParkingSlot(
        id: 'A-1',
        location: 'PES UNIVERSITY',
        isOccupied: false,
        timeSlots: const [
          '08:00 - 10:00',
          '12:00 - 14:00',
          '16:00 - 18:00',
        ],
      ),
      ParkingSlot(
        id: 'A-2',
        location: 'PES UNIVERSITY',
        isOccupied: true,
        timeSlots: const [
          '09:00 - 11:00',
          '13:00 - 15:00',
          '18:00 - 20:00',
        ],
      ),
      ParkingSlot(
        id: 'B-1',
        location: 'PES UNIVERSITY',
        isOccupied: false,
        timeSlots: const [
          '07:00 - 09:00',
          '11:00 - 13:00',
          '15:00 - 17:00',
        ],
      ),
      ParkingSlot(
        id: 'B-2',
        location: 'PES UNIVERSITY',
        isOccupied: false,
        timeSlots: const [
          '10:00 - 12:00',
          '14:00 - 16:00',
          '19:00 - 21:00',
        ],
      ),
      ParkingSlot(
        id: 'C-1',
        location: 'PES UNIVERSITY',
        isOccupied: true,
        timeSlots: const [
          '08:30 - 10:30',
          '12:30 - 14:30',
          '17:00 - 19:00',
        ],
      ),
      ParkingSlot(
        id: 'C-2',
        location: 'PES UNIVERSITY',
        isOccupied: false,
        timeSlots: const [
          '06:00 - 08:00',
          '13:00 - 15:00',
          '20:00 - 22:00',
        ],
      ),
    ];
  }
}