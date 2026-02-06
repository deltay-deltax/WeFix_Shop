import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wefix_shop/authentication/privacy_and_policy_screen.dart';
import 'package:wefix_shop/authentication/terms_and_use_1_screen.dart';
import 'package:wefix_shop/views/profile_screen.dart';
import '../core/constants/app_routes.dart'; // Assume this file exists
import '../widgets/BottomNavWidget.dart'; // Assume this file exists
import '../core/constants/app_colors.dart'; // Assume this file exists
import 'chat_screen.dart'; // Assume this file exists
import 'chat_users_screen.dart';
import 'request_details_screen.dart';

class ServiceRequestsScreen extends StatefulWidget {
  final String? shopUidOverride;
  const ServiceRequestsScreen({Key? key, this.shopUidOverride})
    : super(key: key);

  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

enum _ReqFilter { all, newOnly, inProgress }

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen> {
  _ReqFilter _filter = _ReqFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _RequestsDrawer(),
      appBar: AppBar(
        title: const Text(
          'Service Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage and process all service requests',
              style: TextStyle(color: Colors.grey[700], fontSize: 15),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by customer, status...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _filter = _ReqFilter.newOnly),
                    child: _tab('New', _filter == _ReqFilter.newOnly),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _filter = _ReqFilter.inProgress),
                    child: _tab(
                      'In Progress',
                      _filter == _ReqFilter.inProgress,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _filter = _ReqFilter.all),
                    child: _tab('All', _filter == _ReqFilter.all),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _RequestsList(
                filter: _filter,
                searchQuery: _searchQuery,
                shopUid:
                    (widget.shopUidOverride ??
                    FirebaseAuth.instance.currentUser?.uid ??
                    ''),
              ),
            ),
          ],
        ),
      ),
      // FloatingActionButton removed as per request
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.blue,
      //   onPressed: () {},
      //   child: const Icon(Icons.add),
      // ),
      bottomNavigationBar: BottomNavWidget(
        currentIndex: 1,
        onTap: (idx) {
          switch (idx) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.home);
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatUsersScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _tab(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFC8D9FF) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFF156EF5) : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// --- Requests Drawer ---

class _RequestsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Drawer(
      // AppColors is assumed to be defined
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: uid == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('shop_users')
                        .doc(uid)
                        .get(),
              builder: (context, snap) {
                final data = snap.data?.data();
                final company =
                    (data?['companyLegalName'] ?? data?['company'] ?? '')
                        .toString();
                final initial = company.isNotEmpty
                    ? company[0].toUpperCase()
                    : '?';
                return Container(
                  // AppColors is assumed to be defined
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 28,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 24,
                            // AppColors is assumed to be defined
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.isNotEmpty ? company : 'My Shop',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Service Requests'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Service History'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.orders);
              },
            ),
            ListTile(
              leading: const Icon(Icons.design_services),
              title: const Text('Add Services'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.addService);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Terms of Use'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const TermsAndUse1Screen(returnToDashboard: true),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const PrivacyAndPolicy(returnToDashboard: true),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (r) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Requests List and Widgets ---

class _RequestsList extends StatelessWidget {
  final _ReqFilter filter;
  final String shopUid;
  final String searchQuery;
  const _RequestsList({
    required this.filter,
    required this.shopUid,
    required this.searchQuery,
  });

  static Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'No new requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "You're all caught up!",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    String uid,
    String requestId,
    String status, {
    String? amount,
  }) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (amount != null) {
      data['amount'] = amount;
    }
    await FirebaseFirestore.instance
        .collection('shop_users')
        .doc(uid)
        .collection('requests')
        .doc(requestId)
        .set(data, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUid = shopUid;
    if (effectiveUid.isEmpty) return _empty();

    final reqCol = FirebaseFirestore.instance
        .collection('shop_users')
        .doc(effectiveUid)
        .collection('requests')
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: reqCol.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snap.data?.docs ?? const [];

        docs = docs.where((doc) {
          final d = doc.data();
          final status = (d['status'] ?? '').toString().toLowerCase();
          final customerName = (d['customerName'] ?? d['name'] ?? '').toString().toLowerCase();
          final problem = (d['problem'] ?? d['description'] ?? '').toString().toLowerCase();
          
          // Search Filter
          if (searchQuery.isNotEmpty) {
            if (!customerName.contains(searchQuery) && !problem.contains(searchQuery) && !status.contains(searchQuery)) {
              return false;
            }
          }

          switch (filter) {
            case _ReqFilter.all:
              return true;
            case _ReqFilter.newOnly:
              return status.isEmpty || status == 'pending' || status == 'new';
            case _ReqFilter.inProgress:
              return status == 'confirm' || status == 'in_progress' || status == 'payment_required' || status == 'accepted' || status == 'waiting_for_confirmation';
          }
        }).toList();

        if (docs.isEmpty) return _empty();

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final d = docs[index].data();
            final reqId = docs[index].id;

            final status = (d['status'] ?? 'Pending').toString();
            final priority = (d['priority'] ?? 'Medium').toString();
            final problem =
                (d['problem'] ?? d['description'] ?? 'No description')
                    .toString();
            final phone = (d['phone'] ?? 'No phone').toString();
            final address = (d['pickupAddress'] ?? d['address'] ?? 'No address')
                .toString();
            final amount = (d['amount'] ?? '').toString();

            String customerName = (d['customerName'] ?? d['name'] ?? d['yourName'] ?? '')
                .toString();
            final userId = (d['userId'] ?? d['uid'] ?? d['customerId'] ?? '')
                .toString();

            return _RequestCard(
              reqId: reqId,
              status: status,
              priority: priority,
              problem: problem,
              phone: phone,
              address: address,
              customerName: customerName,
              userId: userId,
              amount: amount,
              onAccept: () {
                _showAcceptDialog(context, effectiveUid, reqId);
              },
              onDecline: () {
                _updateStatus(effectiveUid, reqId, 'declined');
              },
              onMarkCompleted: () {
                 _updateStatus(effectiveUid, reqId, 'completed');
              },
              onViewDetails: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestDetailsScreen(
                      requestId: reqId,
                      requestData: d,
                      shopUid: effectiveUid,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAcceptDialog(
    BuildContext context,
    String uid,
    String reqId,
  ) {
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
                // Status becomes 'accepted' or 'in_progress' waiting for user confirmation
                // The user request says: "on click to aacpet ask user to set an amount and then , : status :in_progress/decline"
                // And "when users confirm and writes ,status as confirm"
                // So let's set it to 'in_progress' or 'waiting_confirmation'. 
                // Based on "users req service ,status :pending ... on click to aacpet ... status :in_progress"
                // I will set it to 'in_progress' for now as per the prompt "status :in_progress/decline"
                _updateStatus(uid, reqId, 'in_progress', amount: amountController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String reqId;
  final String status;
  final String priority;
  final String problem;
  final String phone;
  final String address;
  final String customerName;
  final String userId;
  final String amount;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onMarkCompleted;
  final VoidCallback onViewDetails;

  const _RequestCard({
    required this.reqId,
    required this.status,
    required this.priority,
    required this.problem,
    required this.phone,
    required this.address,
    required this.customerName,
    required this.userId,
    required this.amount,
    required this.onAccept,
    required this.onDecline,
    required this.onMarkCompleted,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    Widget nameWidget;
    // Check if name is valid (not empty and not just "Customer" placeholder)
    if (customerName.isNotEmpty && customerName.toLowerCase() != 'customer') {
      nameWidget = Text(
        customerName,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else {
      nameWidget = FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!.data();
            final name = (data?['Name'] ?? 'Customer').toString();
            return Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            );
          }
          return const Text(
            'Loading...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          );
        },
      );
    }

    final s = status.toLowerCase();
    final isPending = s == 'pending' || s == 'new' || s == '';
    final isInProgress = s == 'in_progress' || s == 'confirm' || s == 'accepted' || s == 'waiting_for_confirmation';
    final isCompleted = s == 'completed' || s == 'paid';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: nameWidget),
                Row(
                  children: [
                    if (priority.isNotEmpty) ...[
                      _PriorityChip(priority: priority),
                      const SizedBox(width: 8),
                    ],
                    _StatusChip(status: status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow('Problem', problem),
            const SizedBox(height: 6),
            _infoRow('Phone', phone),
            const SizedBox(height: 6),
            _infoRow('Address', address),
            if (amount.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoRow('Amount', '₹$amount'),
            ],
            const SizedBox(height: 16),
            
            // Action Buttons
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onViewDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF156EF5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            else if (isInProgress)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onViewDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF156EF5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onViewDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          TextSpan(text: value),
        ],
      ),
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

    if (s == 'paid') {
      bg = const Color(0xFFD1FADF);
      text = const Color(0xFF027A48);
    } else if (s == 'pending' || s == 'new') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB54708);
    } else if (s == 'in_progress' || s == 'confirm' || s == 'waiting_for_confirmation') {
      bg = const Color(0xFFD1E9FF);
      text = const Color(0xFF175CD3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final p = priority.toLowerCase();
    Color bg = Colors.grey[200]!;
    Color text = Colors.black87;

    if (p.contains('high')) {
      bg = const Color(0xFFFEE4E2);
      text = const Color(0xFFB42318);
    } else if (p.contains('medium')) {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB54708);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority, // Keep original case or capitalize
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
