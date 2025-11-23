import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wefix_shop/core/constants/app_colors.dart';

class UpdateServiceDetailsScreen extends StatefulWidget {
  final String requestId;
  final String shopUid;
  final Map<String, dynamic> currentData;

  const UpdateServiceDetailsScreen({
    Key? key,
    required this.requestId,
    required this.shopUid,
    required this.currentData,
  }) : super(key: key);

  @override
  State<UpdateServiceDetailsScreen> createState() =>
      _UpdateServiceDetailsScreenState();
}

class _UpdateServiceDetailsScreenState
    extends State<UpdateServiceDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _serviceDetailsCtrl;
  late TextEditingController _partsReplacedCtrl;
  late TextEditingController _laborCostCtrl;
  late TextEditingController _partsCostCtrl;
  late TextEditingController _warrantyCtrl;

  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    final details =
        widget.currentData['serviceDetails'] as Map<String, dynamic>? ?? {};

    _serviceDetailsCtrl = TextEditingController(
      text: details['serviceDetails']?.toString() ?? '',
    );
    _partsReplacedCtrl = TextEditingController(
      text: details['partsReplaced']?.toString() ?? '',
    );
    _laborCostCtrl = TextEditingController(
      text: details['laborCost']?.toString() ?? '0',
    );
    _partsCostCtrl = TextEditingController(
      text: details['partsCost']?.toString() ?? '0',
    );
    _warrantyCtrl = TextEditingController(
      text: details['warranty']?.toString() ?? '',
    );

    _calculateTotal();

    _laborCostCtrl.addListener(_calculateTotal);
    _partsCostCtrl.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    double labor = double.tryParse(_laborCostCtrl.text) ?? 0.0;
    double parts = double.tryParse(_partsCostCtrl.text) ?? 0.0;
    setState(() {
      _totalCost = labor + parts;
    });
  }

  @override
  void dispose() {
    _serviceDetailsCtrl.dispose();
    _partsReplacedCtrl.dispose();
    _laborCostCtrl.dispose();
    _partsCostCtrl.dispose();
    _warrantyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveDetails({bool markAsCompleted = false}) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final data = {
        'serviceDetails': {
          'serviceDetails': _serviceDetailsCtrl.text,
          'partsReplaced': _partsReplacedCtrl.text,
          'laborCost': double.tryParse(_laborCostCtrl.text) ?? 0.0,
          'partsCost': double.tryParse(_partsCostCtrl.text) ?? 0.0,
          'totalCost': _totalCost,
          'warranty': _warrantyCtrl.text,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (markAsCompleted) {
        data['status'] = 'payment_required';
      }

      await FirebaseFirestore.instance
          .collection('shop_users')
          .doc(widget.shopUid)
          .collection('requests')
          .doc(widget.requestId)
          .set(data, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              markAsCompleted ? 'Payment Requested!' : 'Details Saved!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving details: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Service Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Service Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _serviceDetailsCtrl,
                label: 'Service Details',
                hint: 'Describe the work done...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _partsReplacedCtrl,
                label: 'Parts Replaced',
                hint: 'List parts replaced...',
              ),
              const SizedBox(height: 24),

              const Text(
                'Cost Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _laborCostCtrl,
                      label: 'Labor Cost (₹)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _partsCostCtrl,
                      label: 'Parts Cost (₹)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Cost',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${_totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildTextField(
                controller: _warrantyCtrl,
                label: 'Warranty on New Service',
                hint: 'e.g., 3 months, 1 year',
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _saveDetails(markAsCompleted: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveDetails(markAsCompleted: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Request Payment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
