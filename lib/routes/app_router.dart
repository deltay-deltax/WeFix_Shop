import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../authentication/login.dart' as auth_login;
import '../authentication/signup.dart' as auth_signup;
import '../views/home_screen.dart';
import '../views/service_requesr-t_screen.dart';
import '../views/service_history.dart';
import '../views/analytics_screen.dart';
import '../views/add_service_screen.dart';
import '../views/chat_screen.dart';
import '../views/profile_screen.dart';
import '../views/notifications_screen.dart';
import '../authentication/privacy_and_policy_screen.dart';
import '../authentication/terms_and_use_1_screen.dart';
import '../views/public_privacy_policy.dart';
import '../views/public_terms_of_use.dart';
import '../views/ledger_screen.dart';

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const auth_login.LoginScreen(),
        );
      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const auth_signup.SignupScreen(),
        );
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case AppRoutes.requests:
        return MaterialPageRoute(builder: (_) => ServiceRequestsScreen());
      case AppRoutes.orders:
        return MaterialPageRoute(builder: (_) => ServiceHistoryScreen());
      case AppRoutes.analytics:
        return MaterialPageRoute(builder: (_) => AnalyticsScreen());
      case AppRoutes.addService:
        return MaterialPageRoute(builder: (_) => AddServiceScreen());
      case AppRoutes.chat:
        return MaterialPageRoute(builder: (_) => ChatScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => NotificationsScreen());
      case AppRoutes.privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PublicPrivacyPolicy());
      case AppRoutes.termsOfUse:
        return MaterialPageRoute(builder: (_) => const PublicTermsOfUse());
      case AppRoutes.ledger:
        return MaterialPageRoute(builder: (_) => const LedgerScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const auth_login.LoginScreen(),
        );
    }
  }
}
