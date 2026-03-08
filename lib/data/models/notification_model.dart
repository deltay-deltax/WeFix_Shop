class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String dateTime;
  final String type; // e.g., "success", "warning", "error", "info"
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String docId) {
    String formattedDate = '';
    if (data['createdAt'] != null) {
      DateTime dt = data['createdAt'].toDate();
      formattedDate = "${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    }

    return NotificationModel(
      id: docId,
      title: data['title'] ?? 'Notification',
      description: data['body'] ?? '',
      type: data['type'] ?? 'info',
      dateTime: formattedDate,
      isRead: data['isRead'] ?? false,
    );
  }
}
