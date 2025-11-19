// service_request_card.dart
import 'package:flutter/material.dart';
import '../data/models/service_request_model.dart';

class ServiceRequestCard extends StatelessWidget {
  final ServiceRequest request;

  const ServiceRequestCard({Key? key, required this.request}) : super(key: key);

  Widget _chip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (request.priority == 'High Priority') {
      chips.add(_chip(request.priority, Colors.redAccent));
    } else {
      chips.add(_chip(request.priority, Colors.amber));
    }
    chips.add(
      _chip(
        request.status,
        request.status == 'PAID' ? Colors.green : Colors.amber,
      ),
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  request.customerName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                ),
                const Spacer(),
                ...chips,
              ],
            ),
            const SizedBox(height: 8),
            Text('Problem: ${request.problem}'),
            Text('Phone: ${request.phone}'),
            Text('Address: ${request.address} - ${request.date}'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    onPressed: () {}, // Update logic
                    child: const Text(
                      'Update Status',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {}, // Details logic
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
