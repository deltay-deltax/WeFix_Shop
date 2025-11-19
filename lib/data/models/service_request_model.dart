// service_request_model.dart
class ServiceRequest {
  final String customerName;
  final String priority;
  final String status;
  final String problem;
  final String phone;
  final String address;
  final String date;

  ServiceRequest({
    required this.customerName,
    required this.priority,
    required this.status,
    required this.problem,
    required this.phone,
    required this.address,
    required this.date,
  });
}
