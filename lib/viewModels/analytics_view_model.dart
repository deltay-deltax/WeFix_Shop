// analytics_view_model.dart
import 'package:wefix_shop/data/models/analytics_model.dart';

class AnalyticsViewModel {
  AnalyticsData get analytics => AnalyticsData(
    totalEarnings: 5700,
    avgPerService: 1900,
    totalRequests: 4,
    completedRequests: 3,
    successRate: 0.75,
    pendingRequests: 1,
    monthlyTrend: [
      MonthlyEarning(month: "Jun 2025", amount: 0),
      MonthlyEarning(month: "Jul 2025", amount: 0),
      MonthlyEarning(month: "Sept 2025", amount: 4000),
      MonthlyEarning(month: "Oct 2025", amount: 0),
      MonthlyEarning(month: "Nov 2025", amount: 1700),
    ],
    reviews: [
      CustomerReview(
        name: "Alex Johnson",
        rating: 5,
        review:
            "Absolutely fantastic service! Arrived on time and did an amazing job. Highly recommended.",
      ),
      CustomerReview(
        name: "Maria Garcia",
        rating: 5,
        review:
            "Professional, efficient, and very friendly. The quality of work exceeded my expectations.",
      ),
      CustomerReview(
        name: "James Smith",
        rating: 5,
        review:
            "Good work overall, though started a bit later than scheduled. Would use again.",
      ),
    ],
  );
}
