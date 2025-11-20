import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewModels/home_viewmodel.dart';
import '../widgets/BottomNavWidget.dart';
import '../widgets/DashboardGrid.dart';
import '../widgets/RecentActionsList.dart';
import '../core/constants/app_routes.dart';
import '../authentication/terms_and_use_1_screen.dart';
import '../authentication/privacy_and_policy_screen.dart';
import '../authentication/register_new_shop_screen.dart';

class HomeScreen extends StatelessWidget {
  final DashboardViewModel viewModel = DashboardViewModel();

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        } else {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('shop_users')
          .doc(user.uid)
          .get(),
      builder: (context, snap) {
        final data = snap.data?.data();
        final progress = Map<String, dynamic>.from(data?['progress'] ?? {});
        final terms = progress['terms_done'] == true;
        final privacy = progress['privacy_done'] == true;
        final reg = progress['registration_done'] == true;

        // Hide all content and bottom nav if onboarding incomplete
        final incomplete = !(terms && privacy && reg);
        final company = (data?['companyLegalName'] ?? data?['company'] ?? '')
            .toString();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              company.isNotEmpty ? 'Welcome back, $company' : 'Welcome back',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
            ],
          ),
          body: incomplete
              ? const _OnboardingGate()
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardGrid(viewModel: viewModel),
                      const SizedBox(height: 24),
                      Text(
                        'Recent Actions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      RecentActionsList(viewModel: viewModel),
                    ],
                  ),
                ),
          bottomNavigationBar: incomplete
              ? null
              : BottomNavWidget(
                  currentIndex: 0,
                  onTap: (int idx) {
                    switch (idx) {
                      case 0:
                        break;
                      case 1:
                        Navigator.pushNamed(context, AppRoutes.chat);
                        break;
                      case 2:
                        Navigator.pushNamed(context, AppRoutes.profile);
                        break;
                    }
                  },
                ),
        );
      },
    );
  }
}

class _OnboardingGate extends StatelessWidget {
  const _OnboardingGate({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('shop_users')
          .doc(user.uid)
          .get(),
      builder: (context, snap) {
        String title = 'Continue onboarding';
        Widget? next;
        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data();
          final progress = Map<String, dynamic>.from(data?['progress'] ?? {});
          final terms = progress['terms_done'] == true;
          final privacy = progress['privacy_done'] == true;
          final reg = progress['registration_done'] == true;
          if (terms && privacy && reg) return const SizedBox.shrink();

          if (!terms) {
            title = 'Please review Terms';
            next = const TermsAndUse1Screen();
          } else if (!privacy) {
            title = 'Please review Privacy Policy';
            next = const PrivacyAndPolicy();
          } else if (!reg) {
            title = 'Finish shop registration';
            next = RegisterNewShopScreen();
          }
        } else {
          // Fallback: start from Terms if user doc missing/not loaded
          title = 'Please review Terms';
          next = const TermsAndUse1Screen();
        }

        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.black.withOpacity(0.35),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You have pending steps. Tap continue to resume where you left off.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: next == null
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => next!),
                                );
                              },
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
