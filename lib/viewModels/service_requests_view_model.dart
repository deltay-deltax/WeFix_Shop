// service_requests_view_model.dart
import '../data/models/service_request_model.dart';

class ServiceRequestsViewModel {
  final List<ServiceRequest> requests = [
    ServiceRequest(
      customerName: 'Sanchari',
      priority: 'High Priority',
      status: 'PAID',
      problem: 'Screen issue',
      phone: '9886079563',
      address: 'Whitefield',
      date: '11/3/2025',
    ),
    ServiceRequest(
      customerName: 'Rohan Verma',
      priority: 'Medium Priority',
      status: 'Pending',
      problem: 'Battery draining quickly',
      phone: '8765432109',
      address: 'Koramangala',
      date: '12/3/2025',
    ),
  ];
}
