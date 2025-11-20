import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileViewModel extends ChangeNotifier {
  String name = '';
  String email = '';
  bool loading = true;

  ProfileViewModel() {
    _load();
  }

  Future<void> _load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        name = '';
        email = '';
        return;
      }
      email = user.email ?? '';
      final doc = await FirebaseFirestore.instance
          .collection('shop_users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      name = (data['companyLegalName'] ?? data['company'] ?? '').toString();
      if (name.isEmpty) {
        name = (data['displayName'] ?? user.displayName ?? '').toString();
      }
      if (name.isEmpty && email.isNotEmpty) {
        name = email.split('@').first;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
