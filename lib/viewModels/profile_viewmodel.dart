import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileViewModel extends ChangeNotifier {
  bool loading = true;
  bool saving = false;
  bool editing = false;

  // Base identity
  String email = '';

  // Controllers for editable fields
  final TextEditingController companyLegalName = TextEditingController();
  final TextEditingController companyType = TextEditingController();
  final TextEditingController shopCategory = TextEditingController();
  final TextEditingController gstin = TextEditingController();
  final TextEditingController address1 = TextEditingController();
  final TextEditingController address2 = TextEditingController();
  final TextEditingController landmark = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController gmapUrl = TextEditingController();

  ProfileViewModel() {
    load();
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      email = user.email ?? '';

      // shop_users base
      final su = await FirebaseFirestore.instance
          .collection('shop_users')
          .doc(user.uid)
          .get();
      final suData = su.data() ?? {};

      // registered_shop_users detailed profile
      final reg = await FirebaseFirestore.instance
          .collection('registered_shop_users')
          .doc(user.uid)
          .get();
      final r = reg.data() ?? {};

      companyLegalName.text =
          (r['companyLegalName'] ?? suData['companyLegalName'] ?? '')
              .toString();
      companyType.text = (r['companyType'] ?? '').toString();
      shopCategory.text = (r['shopCategory'] ?? '').toString();
      gstin.text = (r['gstin'] ?? '').toString();

      final addr = Map<String, dynamic>.from(r['address'] ?? {});
      address1.text = (addr['line1'] ?? '').toString();
      address2.text = (addr['line2'] ?? '').toString();
      landmark.text = (addr['landmark'] ?? '').toString();
      city.text = (addr['city'] ?? '').toString();
      state.text = (addr['state'] ?? '').toString();
      pincode.text = (addr['pincode'] ?? '').toString();

      phone.text = (r['phone'] ?? suData['phone'] ?? '').toString();
      gmapUrl.text = (r['gmapUrl'] ?? '').toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void startEditing() {
    editing = true;
    notifyListeners();
  }

  void cancelEditing() {
    editing = false;
    notifyListeners();
  }

  Future<void> save() async {
    if (saving) return;
    saving = true;
    notifyListeners();
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final payload = {
        'companyLegalName': companyLegalName.text.trim(),
        'companyType': companyType.text.trim(),
        'shopCategory': shopCategory.text.trim(),
        'gstin': gstin.text.trim(),
        'address': {
          'line1': address1.text.trim(),
          'line2': address2.text.trim(),
          'landmark': landmark.text.trim(),
          'city': city.text.trim(),
          'state': state.text.trim(),
          'pincode': pincode.text.trim(),
        },
        'phone': phone.text.trim(),
        'gmapUrl': gmapUrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('registered_shop_users')
          .doc(uid)
          .set(payload, SetOptions(merge: true));

      // Mirror key fields to shop_users for quick read
      await FirebaseFirestore.instance.collection('shop_users').doc(uid).set({
        'companyLegalName': companyLegalName.text.trim(),
        'phone': phone.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      editing = false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    companyLegalName.dispose();
    companyType.dispose();
    shopCategory.dispose();
    gstin.dispose();
    address1.dispose();
    address2.dispose();
    landmark.dispose();
    city.dispose();
    state.dispose();
    pincode.dispose();
    phone.dispose();
    gmapUrl.dispose();
    super.dispose();
  }
}
