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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₹ $amount', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                      onPressed: () => _updatePriceDialog(context, user.uid, docs[i].id, name, amount),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: () => _deleteService(context, user.uid, docs[i].id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updatePriceDialog(BuildContext context, String uid, String docId, String name, String currentAmount) {
    final TextEditingController controller = TextEditingController(text: currentAmount);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Price: $name'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '₹ ',
            labelText: 'New Price',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newAmt = double.tryParse(controller.text) ?? 0.0;
              if (newAmt <= 0) return;
              await FirebaseFirestore.instance
                  .collection('shop_users')
                  .doc(uid)
                  .collection('services')
                  .doc(docId)
                  .update({'amount': newAmt, 'updatedAt': FieldValue.serverTimestamp()});
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteService(BuildContext context, String uid, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('shop_users')
                  .doc(uid)
                  .collection('services')
                  .doc(docId)
                  .delete();
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
