import '../data/models/service_model.dart';

class DashboardViewModel {
  List<Service> services = [
    Service(
      id: 1245,
      status: 'complete',
      date: DateTime.now().subtract(Duration(hours: 2)),
    ),
    Service(
      id: 1240,
      status: 'cancelled',
      date: DateTime.now().subtract(Duration(days: 2)),
    ),
    // Add more services as needed
  ];

  int get serviceRequests => 12;
  int get serviceHistory => 5;
  double get analyticsGrowth => 0.15;
  List<Service> get recentActions => services;

  String getReview() => 'You received a new 5-star review.';
}
