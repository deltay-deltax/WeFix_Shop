// analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:wefix_shop/data/models/analytics_model.dart';
import 'package:wefix_shop/viewModels/analytics_view_model.dart';

class AnalyticsScreen extends StatelessWidget {
  final AnalyticsViewModel viewModel = AnalyticsViewModel();

  AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnalyticsData data = viewModel.analytics;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Service Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          DropdownButton<String>(
            value: "All Time",
            dropdownColor: Colors.white,
            underline: Container(),
            items: ["All Time", "This Month"]
                .map(
                  (String v) =>
                      DropdownMenuItem<String>(value: v, child: Text(v)),
                )
                .toList(),
            onChanged: (v) {},
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Track your performance and earnings',
              style: TextStyle(color: Colors.grey[700], fontSize: 15),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _numberStatCard(
                  'Total Earnings',
                  '\$${data.totalEarnings}',
                  'Average per service:\n\$${data.avgPerService.toInt()}',
                ),
                const SizedBox(width: 12),
                _numberStatCard(
                  'Total Requests',
                  '${data.totalRequests}',
                  'Completed: ${data.completedRequests}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _numberStatCard(
                  'Success Rate',
                  '${(data.successRate * 100).toInt()}%',
                  'Problem resolution rate',
                ),
                const SizedBox(width: 12),
                _numberStatCard(
                  'Pending Requests',
                  '${data.pendingRequests}',
                  'Awaiting your action',
                ),
              ],
            ),
            const SizedBox(height: 18),
            _monthlyTrendCard(data.monthlyTrend),
            const SizedBox(height: 26),
            const Text(
              'Latest Customer Reviews',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ...data.reviews.map((r) => _reviewCard(r)).toList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: "Jobs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _numberStatCard(String title, String value, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthlyTrendCard(List<MonthlyEarning> monthlyList) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Earnings Trend',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          ...monthlyList.map((e) => _trendBar(e)).toList(),
        ],
      ),
    );
  }

  Widget _trendBar(MonthlyEarning earning) {
    double maxVal = 4000; // for demo purpose, set max for relative bar width
    double ratio = earning.amount / maxVal;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(earning.month)),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: ratio > 0 ? Colors.teal[200] : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              width: 180 * ratio,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              earning.amount == 0 ? '\$0' : '\$${earning.amount.toInt()}',
              style: TextStyle(
                color: Colors.teal[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(CustomerReview r) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.person)),
        title: Row(
          children: [
            Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Row(
              children: List.generate(
                r.rating,
                (i) => const Icon(Icons.star, color: Colors.amber, size: 18),
              ),
            ),
          ],
        ),
        subtitle: Text(r.review),
      ),
    );
  }
}
