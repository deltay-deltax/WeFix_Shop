import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddServiceListScreen extends StatelessWidget {
  const AddServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view services')),
      );
    }
    final query = FirebaseFirestore.instance
        .collection('shop_users')
        .doc(user.uid)
        .collection('services')
        .orderBy('updatedAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Added Services')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No services added yet'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final name = (d['name'] ?? '').toString();
              final desc = (d['description'] ?? '').toString();
              final category = (d['category'] ?? '').toString();
              final pricingType = (d['pricingType'] ?? '').toString();
              final amount = (d['amount'] ?? 0).toString();
              return ListTile(
                title: Text(name.isEmpty ? 'Untitled Service' : name),
                subtitle: Text(
                  [
                    category,
                    pricingType,
                    desc,
                  ].where((e) => e.isNotEmpty).join(' • '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text('₹ $amount'),
              );
            },
          );
        },
      ),
    );
  }
}
