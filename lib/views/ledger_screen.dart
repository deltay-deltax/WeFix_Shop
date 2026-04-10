import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please login')));

    final eligibleStatuses = ['payment_done', 'completed', 'paid', 'delivered'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shop Ledger'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('shop_users')
            .doc(user.uid)
            .collection('requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allDocs = snapshot.data?.docs ?? [];
          final filteredDocs = allDocs.where((doc) {
            final status = (doc.data()['status'] ?? '').toString().toLowerCase();
            return eligibleStatuses.contains(status);
          }).toList();

          double totalSettlementDue = 0;
          for (var doc in filteredDocs) {
            final data = doc.data();
            final serviceDetails = data['serviceDetails'] as Map<String, dynamic>?;
            final gross = double.tryParse(serviceDetails?['totalCost']?.toString() ?? '0') ?? 0;
            totalSettlementDue += gross * 0.8; // 80% payout
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSummaryCard(totalSettlementDue),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Transaction History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.icon,
                    ),
                  ),
                ),
              ),
              if (filteredDocs.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No settled transactions found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data();
                      final serviceDetails = data['serviceDetails'] as Map<String, dynamic>?;
                      final gross = double.tryParse(serviceDetails?['totalCost']?.toString() ?? '0') ?? 0;
                      final commission = gross * 0.2;
                      final settlement = gross * 0.8;
                      final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                      final serviceType = data['problem'] ?? 'Repair Service';

                      return _TransactionTile(
                        date: date,
                        serviceType: serviceType,
                        gross: gross,
                        commission: commission,
                        settlement: settlement,
                      );
                    },
                    childCount: filteredDocs.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF156EF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Settlement Due',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'Calculated at 80% payout',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final DateTime date;
  final String serviceType;
  final double gross;
  final double commission;
  final double settlement;

  const _TransactionTile({
    required this.date,
    required this.serviceType,
    required this.gross,
    required this.commission,
    required this.settlement,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormat.format(date),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SETTLEMENT: ${currencyFormat.format(settlement)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            serviceType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.icon,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _amountDetail('Gross', gross, Colors.black87),
              _amountDetail('Commission (-20%)', -commission, Colors.redAccent),
              _amountDetail('Net Payout', settlement, AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountDetail(String label, double amount, Color amountColor) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
