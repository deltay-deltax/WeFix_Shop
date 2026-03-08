import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/notification_model.dart';
import '../viewModels/notifications_viewmodel.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notif;
  NotificationTile({required this.notif});

  Color tileColor(String type) {
    switch (type) {
      case "success":
        return Color(0xFFD4F7D3);
      case "info":
        return Color(0xFFE5F0FF);
      case "error":
        return Color(0xFFFDE9EA);
      case "warning":
        return Color(0xFFFFF4D6);
      default:
        return Colors.grey.shade100;
    }
  }

  Color iconColor(String type) {
    switch (type) {
      case "success":
        return Colors.green;
      case "info":
        return Colors.blue;
      case "error":
        return Colors.red;
      case "warning":
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  IconData iconFor(String type) {
    switch (type) {
      case "success":
        return Icons.check_circle;
      case "info":
        return Icons.local_shipping;
      case "error":
        return Icons.cancel;
      case "warning":
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        color: tileColor(notif.type),
        elevation: 0,
        shape: RoundedRectangleBorder(
          // Added for a softer look
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!notif.isRead) {
              // mark as read via ViewModel
              try {
                final vm = Provider.of<NotificationsViewModel>(context, listen: false);
                vm.markAsRead(notif.id);
              } catch (_) {}
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding inside the card
            child: Column(
              // Aligns all children to the start (left)
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TOP ROW: Icon, Title, and Date ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon (from old 'leading')
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            iconFor(notif.type),
                            color: iconColor(notif.type),
                            size: 28, // Slightly smaller icon
                          ),
                        ),
                        if (!notif.isRead)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 12),

                    // Title (from old 'title')
                    // We wrap it in Expanded so it takes the available space
                    // and pushes the date to the end.
                    Expanded(
                      child: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w900,
                          fontSize: 16,
                          color: notif.isRead ? Colors.black87 : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Space before date
                    // Date (from old 'trailing')
                    Text(
                      notif.dateTime,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w600),
                    ),
                  ],
                ),

                SizedBox(height: 12), // Vertical space
                // --- BOTTOM: Description (from old 'subtitle') ---
                // This is now below the top row
                Padding(
                  // Optional: Add left padding to align with title
                  padding: const EdgeInsets.only(left: 40.0), // (28+12)
                  child: Text(
                    notif.description,
                    style: TextStyle(
                      fontSize: 14, // Slightly larger
                      color: notif.isRead ? Colors.black87 : Colors.black,
                      fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w500,
                    ),
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
