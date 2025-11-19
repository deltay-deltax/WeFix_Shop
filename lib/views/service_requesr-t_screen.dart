// service_requests_screen.dart
import 'package:flutter/material.dart';
import '../viewModels/service_requests_view_model.dart';
import '../widgets/service_request_card.dart';
import '../data/models/service_request_model.dart';

class ServiceRequestsScreen extends StatelessWidget {
  final ServiceRequestsViewModel viewModel = ServiceRequestsViewModel();

  ServiceRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ServiceRequest> requests = viewModel.requests;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Service Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage and process all service requests',
              style: TextStyle(color: Colors.grey[700], fontSize: 15),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by customer, status...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _tab('New', true),
                  _tab('In Progress', false),
                  _tab('High Priority', false),
                  _tab('Completed', false),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: requests.isEmpty
                  ? _noRequestsWidget()
                  : ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, idx) {
                        return ServiceRequestCard(request: requests[idx]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _tab(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? Colors.blue[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(color: selected ? Colors.blue : Colors.black),
      ),
    );
  }

  Widget _noRequestsWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.inbox, size: 40, color: Colors.grey),
            SizedBox(height: 18),
            Text(
              'No new requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "You're all caught up!",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
