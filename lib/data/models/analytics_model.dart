// analytics_model.dart
class MonthlyEarning {
  final String month;
  final double amount;

  MonthlyEarning({required this.month, required this.amount});
}

class CustomerReview {
  final String name;
  final int rating;
  final String review;

  CustomerReview({
    required this.name,
    required this.rating,
    required this.review,
  });
}

class AnalyticsData {
  final double totalEarnings;
  final double avgPerService;
  final int totalRequests;
  final int completedRequests;
  final double successRate;
  final int pendingRequests;
  final List<MonthlyEarning> monthlyTrend;
  final List<CustomerReview> reviews;

  AnalyticsData({
    required this.totalEarnings,
    required this.avgPerService,
    required this.totalRequests,
    required this.completedRequests,
    required this.successRate,
    required this.pendingRequests,
    required this.monthlyTrend,
    required this.reviews,
  });
}
