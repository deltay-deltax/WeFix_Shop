import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wefix_shop/core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  List<String> _imageUrls = [];
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

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
    _imageUrls = List<String>.from(details['photos'] ?? []);

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

  Future<void> _pickAndUploadImage() async {
    if (_imageUrls.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 photos allowed')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('service_photos')
          .child(widget.requestId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      setState(() {
        _imageUrls.add(url);
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
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
          'photos': _imageUrls,
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

              const SizedBox(height: 24),
              const Text(
                'Service Photos (Max 3)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length + (_imageUrls.length < 3 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _imageUrls.length && _imageUrls.length < 3) {
                      return GestureDetector(
                        onTap: _isUploading ? null : _pickAndUploadImage,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _isUploading
                              ? const Center(child: CircularProgressIndicator())
                              : const Icon(Icons.add_a_photo, color: Colors.grey),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(_imageUrls[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
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
