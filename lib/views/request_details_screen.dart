import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wefix_shop/core/constants/app_colors.dart';
import 'package:wefix_shop/views/update_service_details_screen.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> requestData;
  final String shopUid;

  const RequestDetailsScreen({
    Key? key,
    required this.requestId,
    required this.requestData,
    required this.shopUid,
  }) : super(key: key);

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}


class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  bool _paymentReceived = false;


  Future<void> _updateStatus(String newStatus, {String? amount}) async {
    try {
      final data = <String, dynamic>{
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (amount != null) {
        data['amount'] = amount;
      }

      await FirebaseFirestore.instance
          .collection('shop_users')
          .doc(widget.shopUid)
          .collection('requests')
          .doc(widget.requestId)
          .set(data, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  void _showAcceptDialog() {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please set an estimated amount for this service.'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                _updateStatus('waiting_for_confirmation', amount: amountController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('shop_users')
            .doc(widget.shopUid)
            .collection('requests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             if (widget.requestData.isNotEmpty) {
                return _buildContent(widget.requestData);
             }
             return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final d = snapshot.data?.data() ?? widget.requestData;
          return _buildContent(d);
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> d) {
    final status = (d['status'] ?? 'Pending').toString();
    final images = (d['images'] as List<dynamic>?) ?? [];
    final problem = (d['problem'] ?? d['description'] ?? 'No description').toString();
    final brand = (d['brand'] ?? '').toString();
    final model = (d['modelName'] ?? '').toString();
    final modelNumber = (d['modelNumber'] ?? '').toString();
    final deviceType = (d['deviceType'] ?? '').toString();
    final phone = (d['phone'] ?? '').toString();
    final address = (d['pickupAddress'] ?? d['address'] ?? '').toString();
    final priority = (d['priority'] ?? 'Medium').toString();
    final userId = (d['userId'] ?? '').toString();
    
    // Service Details
    final serviceData = d['serviceDetails'] as Map<String, dynamic>?;

    // Timestamp handling
    String createdAtStr = '';
    if (d['createdAt'] != null) {
      if (d['createdAt'] is Timestamp) {
        createdAtStr = (d['createdAt'] as Timestamp).toDate().toString().split('.')[0];
      } else {
        createdAtStr = d['createdAt'].toString();
      }
    }

    // Name handling
    String initialName = (d['customerName'] ?? d['name'] ?? d['yourName'] ?? '').toString();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Carousel
          if (images.isNotEmpty)
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index].toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    Text('No images provided'),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$brand $model',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          if (modelNumber.isNotEmpty)
                            Text(
                              'Model No: $modelNumber',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                    _StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(deviceType),
                      backgroundColor: Colors.grey[100],
                    ),
                    Chip(
                      label: Text('Priority: $priority'),
                      backgroundColor: priority.toLowerCase() == 'high' ? Colors.red[50] : Colors.amber[50],
                      labelStyle: TextStyle(
                        color: priority.toLowerCase() == 'high' ? Colors.red : Colors.orange[800],
                      ),
                    ),
                    if (d['amount'] != null && d['amount'].toString().isNotEmpty)
                      Chip(
                        avatar: const Icon(Icons.currency_rupee, size: 16, color: Colors.green),
                        label: Text(
                          '${d['amount']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        backgroundColor: Colors.green[50],
                      ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Problem Description
                const Text('Problem Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(problem, style: const TextStyle(fontSize: 16)),
                ),
                
                // --- SERVICE DETAILS SECTION ---
                if (serviceData != null && serviceData.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('Technician Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (serviceData['serviceDetails'] != null && serviceData['serviceDetails'].toString().isNotEmpty) ...[
                          _detailRow(Icons.build, 'Work Done', serviceData['serviceDetails'].toString()),
                          const SizedBox(height: 12),
                        ],
                        if (serviceData['partsReplaced'] != null && serviceData['partsReplaced'].toString().isNotEmpty) ...[
                          _detailRow(Icons.settings_input_component, 'Parts Replaced', serviceData['partsReplaced'].toString()),
                          const SizedBox(height: 12),
                        ],
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Labor Cost:', style: TextStyle(color: Colors.grey[700])),
                            Text('₹${serviceData['laborCost'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Parts Cost:', style: TextStyle(color: Colors.grey[700])),
                            Text('₹${serviceData['partsCost'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Cost:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('₹${serviceData['totalCost'] ?? 0}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        if (serviceData['warranty'] != null && serviceData['warranty'].toString().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.verified_user, size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              Text('Warranty: ${serviceData['warranty']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Customer Details
                const Text('Customer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                if (initialName.isNotEmpty && initialName.toLowerCase() != 'customer')
                  _detailRow(Icons.person, 'Name', initialName)
                else
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                    builder: (context, snapshot) {
                      String name = 'Loading...';
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final userData = snapshot.data!.data() as Map<String, dynamic>;
                        name = (userData['Name'] ?? userData['name'] ?? 'Customer').toString();
                      }
                      return _detailRow(Icons.person, 'Name', name);
                    },
                  ),

                const SizedBox(height: 12),
                _detailRow(Icons.phone, 'Phone', phone),
                const SizedBox(height: 12),
                _detailRow(Icons.location_on, 'Address', address),
                if (createdAtStr.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _detailRow(Icons.calendar_today, 'Created At', createdAtStr),
                ],

                const SizedBox(height: 40),

                // Action Buttons
                _buildActionButtons(context, status, d),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, String status, Map<String, dynamic> d) {
    // Only show buttons if we have the needed context/data.
    // The previous implementation had this nested.
    
    if (status.toLowerCase() == 'pending' || status.toLowerCase() == 'new') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showAcceptDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Accept', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus('declined'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Decline', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      );
    } else if (status.toLowerCase() == 'in_progress' || status.toLowerCase() == 'confirm') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateServiceDetailsScreen(
                      requestId: widget.requestId,
                      shopUid: widget.shopUid,
                      currentData: d,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Update Details', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateStatus('completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF027A48), // Green
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Mark as Completed', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      );
    } else if (status.toLowerCase() == 'payment_required') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Column(
          children: const [
            Icon(Icons.pending_actions, size: 40, color: Colors.orange),
            SizedBox(height: 8),
            Text(
              'Waiting for Payment',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Customer has been notified to make payment.',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
      );
    } else if (status.toLowerCase() == 'payment_on_delivery') {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: const [
                Icon(Icons.handshake, size: 40, color: Colors.blue),
                SizedBox(height: 8),
                Text(
                  'Payment on Delivery',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'User will pay while accepting device',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _paymentReceived,
            onChanged: (val) {
              setState(() {
                _paymentReceived = val ?? false;
              });
            },
            title: const Text("Payment Received from Customer"),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _paymentReceived ? () => _updateStatus('completed') : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF027A48), // Green
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Mark as Completed', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      );
    } else if (status.toLowerCase() == 'payment_done' || status.toLowerCase() == 'completed') {
       return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[100], // Darker green background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: const Center(
          child: Text(
            'Service Completed',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg = Colors.grey[200]!;
    Color text = Colors.black87;

    if (s == 'paid' || s == 'completed' || s == 'payment_done') {
      bg = const Color(0xFFD1FADF);
      text = const Color(0xFF027A48);
    } else if (s == 'pending' || s == 'new') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB54708);
    } else if (s == 'in_progress' || s == 'confirm' || s == 'waiting_for_confirmation') {
      bg = const Color(0xFFD1E9FF);
      text = const Color(0xFF175CD3);
    } else if (s == 'declined') {
       bg = const Color(0xFFFEE4E2);
       text = const Color(0xFFB42318);
    } else if (s == 'payment_required') {
      bg = const Color(0xFFFFFAEB);
      text = const Color(0xFFB54708);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
