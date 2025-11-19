import 'package:flutter/material.dart';
import 'package:wefix_shop/data/models/service_history_model.dart';
import '../data/models/service_request_model.dart';

class RequestCard extends StatelessWidget {
  final ServiceRequestModel request;
  RequestCard({required this.request});
  Color statusColor(String status) {
    switch (status) {
      case "In Progress":
        return Color(0xFFD1B7FF);
      case "Pending":
        return Color(0xFFFFE6B0);
      case "Paid":
        return Color(0xFFCFF6DF);
      case "Payment":
        return Color(0xFFFBD7DF);
      case "Declined":
        return Color(0xFFFBD7DF);
      default:
        return Colors.grey.shade300;
    }
  }

  Color statusTextColor(String status) {
    switch (status) {
      case "In Progress":
        return Color(0xFF914DFF);
      case "Pending":
        return Color(0xFFFFB500);
      case "Paid":
        return Color(0xFF039855);
      case "Payment":
        return Color(0xFFEB5685);
      case "Declined":
        return Color(0xFFEB5685);
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Device", style: TextStyle(color: Colors.grey[700])),
                    Text(
                      request.deviceName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Text(request.date, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            SizedBox(height: 10),
            Text("Problem", style: TextStyle(color: Colors.grey[700])),
            Text(request.problem, style: TextStyle(fontSize: 15)),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor(request.status),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: statusTextColor(request.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Text("Amount", style: TextStyle(color: Colors.grey[600])),
                SizedBox(width: 8),
                Text(
                  request.amount,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(width: 8),
                if (request.canPay)
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Pay"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      backgroundColor: Color(0xFF2F74F9),
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(fontWeight: FontWeight.bold),
                      minimumSize: Size(44, 34),
                    ),
                  )
                else
                  TextButton(
                    child: Text(
                      "View",
                      style: TextStyle(color: Color(0xFF2F74F9)),
                    ),
                    onPressed: () {},
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
