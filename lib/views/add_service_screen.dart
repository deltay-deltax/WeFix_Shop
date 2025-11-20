// add_service_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wefix_shop/viewModels/add_service_view_model.dart';

class AddServiceScreen extends StatefulWidget {
  final AddServiceViewModel viewModel = AddServiceViewModel();

  AddServiceScreen({Key? key}) : super(key: key);

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> categories = [
    "Plumbing",
    "Electrical",
    "Carpentry",
    "Cleaning",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add a New Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Service Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'e.g., Kitchen Sink Repair',
                  border: OutlineInputBorder(),
                ),
                onChanged: widget.viewModel.setServiceName,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter service name' : null,
              ),
              const SizedBox(height: 18),

              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Provide a detailed explanation of the service…',
                  border: OutlineInputBorder(),
                ),
                onChanged: widget.viewModel.setDescription,
                maxLines: 3,
              ),
              const SizedBox(height: 18),

              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select a category',
                ),
                items: categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => widget.viewModel.setCategory(val ?? ''),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Select a category' : null,
              ),
              const SizedBox(height: 18),

              const Text(
                'Pricing Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _pricingTypeBtn('Fixed'),
                  const SizedBox(width: 12),
                  _pricingTypeBtn('Hourly'),
                  const SizedBox(width: 12),
                  _pricingTypeBtn('Per Item'),
                ],
              ),
              const SizedBox(height: 18),

              const Text(
                'Amount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) =>
                    widget.viewModel.setAmount(double.tryParse(val) ?? 0.0),
                validator: (val) => (double.tryParse(val ?? '') ?? 0.0) <= 0
                    ? 'Enter valid amount'
                    : null,
              ),
              const SizedBox(height: 38),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Save Service",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please login to continue'),
                          ),
                        );
                        return;
                      }
                      final service = widget.viewModel.service;
                      final ref = FirebaseFirestore.instance
                          .collection('shop_users')
                          .doc(user.uid)
                          .collection('services');
                      await ref.add({
                        'name': service.name,
                        'description': service.description,
                        'category': service.category,
                        'pricingType': service.pricingType,
                        'amount': service.amount,
                        'createdAt': FieldValue.serverTimestamp(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Service saved')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save: $e')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pricingTypeBtn(String label) {
    final selected = widget.viewModel.service.pricingType == label;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? Colors.blue[50] : Colors.white,
          side: BorderSide(color: selected ? Colors.blue : Colors.grey),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.blue : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () => setState(() {
          widget.viewModel.setPricingType(label);
        }),
      ),
    );
  }
}
