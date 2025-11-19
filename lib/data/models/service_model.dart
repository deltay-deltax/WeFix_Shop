class Service {
  final int id;
  final String status; // 'complete', 'cancelled', etc.
  final DateTime date;
  final String? review; // 5-star review, etc.

  Service({
    required this.id,
    required this.status,
    required this.date,
    this.review,
  });
}
