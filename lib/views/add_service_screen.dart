// add_service_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wefix_shop/viewModels/add_service_view_model.dart';
import 'add_service_list_screen.dart';

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

  // For Quick Add
  Map<String, TextEditingController> _controllers = {};
  String _shopCategory = '';
  bool _isLoadingQuickAdd = false;

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add Service',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Manual Add'),
              Tab(text: 'Quick Add'),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddServiceListScreen(),
                  ),
                );
              },
              child: const Text(
                'Added services',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        body: TabBarView(children: [_buildManualAddTab(), _buildQuickAddTab()]),
      ),
    );
  }

  Widget _buildManualAddTab() {
    return Padding(
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
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => widget.viewModel.setCategory(val ?? ''),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Select a category' : null,
            ),
            const SizedBox(height: 18),
            const Text(
              'Amount',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                prefixText: '₹ ',
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
                  foregroundColor: Colors.white,
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
    );
  }

  Widget _buildQuickAddTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please login to see subcategories'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('registered_shop_users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text('No subcategories found in your profile.'),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final subcategories = List<String>.from(data['subcategories'] ?? []);
        _shopCategory = data['shopCategory'] ?? 'Other';

        if (subcategories.isEmpty) {
          return const Center(child: Text('No subcategories to list.'));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('shop_users')
              .doc(user.uid)
              .collection('services')
              .snapshots(),
          builder: (context, serviceSnap) {
            if (serviceSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            Map<String, double> existingAmounts = {};
            if (serviceSnap.hasData) {
              for (var doc in serviceSnap.data!.docs) {
                final d = doc.data() as Map<String, dynamic>;
                final name = (d['name'] ?? '').toString();
                final amt = double.tryParse(d['amount']?.toString() ?? '0') ?? 0;
                if (name.isNotEmpty) {
                  existingAmounts[name] = amt;
                }
              }
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: subcategories.length,
                    itemBuilder: (context, index) {
                      final subcat = subcategories[index];
                      // If the controller for this subcategory doesn't exist, create it with the stored price
                      if (!_controllers.containsKey(subcat)) {
                        final existingAmt = existingAmounts[subcat];
                        final initialText = (existingAmt != null && existingAmt > 0)
                            ? existingAmt.toStringAsFixed(0)
                            : '0';
                        _controllers[subcat] = TextEditingController(text: initialText);
                      }
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  subcat,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: _controllers[subcat],
                                  decoration: const InputDecoration(
                                    prefixText: '₹ ',
                                    hintText: '0',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isLoadingQuickAdd
                          ? null
                          : () async {
                              setState(() => _isLoadingQuickAdd = true);
                              try {
                                Map<String, double> amounts = {};
                                _controllers.forEach((key, controller) {
                                  final val =
                                      double.tryParse(controller.text) ?? 0.0;
                                  if (val > 0) {
                                    amounts[key] = val;
                                  }
                                });

                                if (amounts.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter at least one amount',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                await widget.viewModel.saveBulkServices(
                                  _shopCategory,
                                  amounts,
                                );

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Services saved successfully',
                                    ),
                                  ),
                                );
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              } finally {
                                if (mounted)
                                  setState(() => _isLoadingQuickAdd = false);
                              }
                            },
                      child: _isLoadingQuickAdd
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Save All",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
