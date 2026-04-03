// add_service_view_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wefix_shop/data/models/new_service_model.dart';

class AddServiceViewModel {
  NewService service = NewService(
    name: '',
    description: '',
    category: '',
    pricingType: 'Fixed',
    amount: 0.0,
  );

  void setServiceName(String name) => service.name = name;
  void setDescription(String desc) => service.description = desc;
  void setCategory(String cat) => service.category = cat;
  void setPricingType(String type) => service.pricingType = type;
  void setAmount(double amt) => service.amount = amt;

  bool validate() {
    return service.name.isNotEmpty &&
        service.category.isNotEmpty &&
        service.amount > 0;
  }

  Future<void> saveBulkServices(
      String shopCategory, Map<String, double> subcategoryAmounts) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final batch = FirebaseFirestore.instance.batch();
    final servicesRef = FirebaseFirestore.instance
        .collection('shop_users')
        .doc(uid)
        .collection('services');

    for (var entry in subcategoryAmounts.entries) {
      if (entry.value > 0) {
        // Use a deterministic ID based on the subcategory name to allow updating
        final docId =
            entry.key.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();

        batch.set(
          servicesRef.doc(docId),
          {
            'name': entry.key,
            'description': entry.key,
            'category': shopCategory,
            'amount': entry.value,
            'updatedAt': FieldValue.serverTimestamp(),
            'active': true,
          },
          SetOptions(merge: true),
        );
      }
    }
    await batch.commit();
  }
}
