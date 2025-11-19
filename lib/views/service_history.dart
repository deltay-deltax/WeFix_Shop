import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_routes.dart';
import '../viewModels/service_update_viewmodel.dart';
import '../widgets/request_card.dart';

class ServiceUpdateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceUpdateViewModel(),
      child: Consumer<ServiceUpdateViewModel>(
        builder: (context, vm, child) => Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 0, 0),
                  child: Text(
                    "Your Service Requests",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 6, bottom: 10),
                  child: Text(
                    "Track and manage all your service requests",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search Requests",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 14),
                // Filter Tabs (hardcoded)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      FilterTab("All Status", active: true),
                      SizedBox(width: 10),
                      FilterTab("Pending"),
                      SizedBox(width: 10),
                      FilterTab("Accepted"),
                      SizedBox(width: 10),
                      FilterTab("In Progress"),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Cards List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    itemCount: vm.requests.length,
                    itemBuilder: (context, i) =>
                        RequestCard(request: vm.requests[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Hardcoded filter tab widget inside the view
Widget FilterTab(String label, {bool active = false}) => Container(
  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 9),
  decoration: BoxDecoration(
    color: active ? Color(0xFF2F74F9) : Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey[300]!),
  ),
  child: Text(
    label,
    style: TextStyle(
      color: active ? Colors.white : Colors.black87,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
);
