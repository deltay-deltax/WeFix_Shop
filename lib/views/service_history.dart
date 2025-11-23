import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_routes.dart';
import 'request_details_screen.dart';

class ServiceHistoryScreen extends StatelessWidget {
  const ServiceHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Service History",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.home),
          ),
        ),
        body: uid == null
            ? const Center(child: Text("Please login to view history"))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('shop_users')
                    .doc(uid)
                    .collection('requests')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final allDocs = snapshot.data?.docs ?? [];

                  // Filter for completed/paid requests
                  final docs = allDocs.where((doc) {
                    final status = (doc.data()['status'] ?? '')
                        .toString()
                        .toLowerCase();
                    return status == 'completed' ||
                        status == 'payment_done' ||
                        status == 'paid';
                  }).toList();

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No completed services yet",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final d = docs[index].data();
                      final reqId = docs[index].id;
                      final userId = (d['userId'] ?? '').toString();

                      // Name logic
                      final initialName =
                          (d['customerName'] ??
                                  d['name'] ??
                                  d['yourName'] ??
                                  '')
                              .toString();

                      final date =
                          (d['createdAt'] as Timestamp?)
                              ?.toDate()
                              .toString()
                              .split(' ')[0] ??
                          '';
                      final status = (d['status'] ?? '')
                          .toString()
                          .toUpperCase();
                      final totalCost = (d['serviceDetails']?['totalCost'] ?? 0)
                          .toString();

                      final problem =
                          (d['problem'] ?? d['description'] ?? 'No description')
                              .toString();
                      final brand = (d['brand'] ?? '').toString();
                      final model = (d['modelName'] ?? '').toString();

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$brand $model',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                problem,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: initialName.isNotEmpty
                                        ? Text(
                                            initialName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        : FutureBuilder<DocumentSnapshot>(
                                            future: FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userId)
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Text(
                                                  'Loading...',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                );
                                              }
                                              final userData =
                                                  snapshot.data?.data()
                                                      as Map<String, dynamic>?;
                                              final name =
                                                  (userData?['Name'] ??
                                                          userData?['name'] ??
                                                          'Customer')
                                                      .toString();
                                              return Text(
                                                name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(date),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                      ),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: Colors.green[800],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "₹$totalCost",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestDetailsScreen(
                                  requestId: reqId,
                                  requestData: d,
                                  shopUid: uid,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
