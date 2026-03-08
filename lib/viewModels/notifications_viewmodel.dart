import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/notification_model.dart';

class NotificationsViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  NotificationsViewModel() {
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    FirebaseFirestore.instance
        .collection('shop_users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        return NotificationModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('shop_users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    }
  }
}
