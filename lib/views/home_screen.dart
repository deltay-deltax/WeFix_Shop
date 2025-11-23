import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewModels/home_viewmodel.dart';
import '../widgets/BottomNavWidget.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_colors.dart';
import 'profile_screen.dart';
import '../authentication/terms_and_use_1_screen.dart';
import '../authentication/privacy_and_policy_screen.dart';
import '../authentication/register_new_shop_screen.dart';
import 'service_requesr-t_screen.dart';
import 'chat_users_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  final DashboardViewModel viewModel = DashboardViewModel();

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('shop_users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snap.data?.data();
        final progress = Map<String, dynamic>.from(data?['progress'] ?? {});
        final terms = progress['terms_done'] == true;
        final privacy = progress['privacy_done'] == true;
        final reg = progress['registration_done'] == true;

        // Hide all content and bottom nav if onboarding incomplete
        final incomplete = !(terms && privacy && reg);
        final primaryCompany =
            (data?['companyLegalName'] ?? data?['company'] ?? '')
                .toString()
                .trim();

        if (primaryCompany.isEmpty) {
          final futureCompany = (() async {
            final prefs = await SharedPreferences.getInstance();
            final cached = prefs.getString('company_name_${user.uid}') ?? '';
            if (cached.isNotEmpty) return cached;
            final regSnap = await FirebaseFirestore.instance
                .collection('registered_shop_users')
                .doc(user.uid)
                .get();
            final regData = regSnap.data();
            final name = (regData?['companyLegalName'] ?? '').toString().trim();
            if (name.isNotEmpty) {
              await prefs.setString('company_name_${user.uid}', name);
            }
            return name;
          })();
          return FutureBuilder<String>(
            future: futureCompany,
            builder: (ctx, futureSnap) {
              final company = (futureSnap.data ?? '').trim();
              return WillPopScope(
                onWillPop: () async => false,
                child: Scaffold(
                  drawer: _AppDrawer(companyName: company),
                  appBar: AppBar(
                    backgroundColor: AppColors.background,
                    leading: Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
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
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                company.isNotEmpty ? 'Hi $company' : 'Hi',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _BalanceCard(
                                title: 'Monthly Earning',
                                amount: 27980.24,
                                dark: true,
                                percent: 13.0,
                              ),
                              const SizedBox(height: 10),
                              _BalanceCard(
                                title: 'Total Earning',
                                amount: 27980.24,
                                dark: false,
                                percent: 3.0,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Earnings',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Month',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SizedBox(height: 120, child: _SalesBar()),
                              const SizedBox(height: 24),
                              Row(
                                children: const [
                                  Expanded(
                                    child: _GrowthCard(growthRate: 32.0),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(child: _CustomerCount(count: 2135)),
                                ],
                              ),
                              const SizedBox(height: 40),
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
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ServiceRequestsScreen(),
                                  ),
                                );
                                break;
                              case 2:
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ChatUsersScreen(),
                                  ),
                                );
                                break;
                            }
                          },
                        ),
                ),
              );
            },
          );
        }

        final company = primaryCompany;
        // Cache company name for faster next loads
        SharedPreferences.getInstance().then((p) {
          if (company.isNotEmpty) {
            p.setString('company_name_${user.uid}', company);
          }
        });
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            drawer: _AppDrawer(companyName: company),
            appBar: AppBar(
              backgroundColor: AppColors.background,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          company.isNotEmpty ? 'Hi $company' : 'Hi',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _BalanceCard(
                          title: 'Monthly Earning',
                          amount: 27980.24,
                          dark: true,
                          percent: 13.0,
                        ),
                        const SizedBox(height: 10),
                        _BalanceCard(
                          title: 'Total Earning',
                          amount: 27980.24,
                          dark: false,
                          percent: 3.0,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Earnings',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Month',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(height: 120, child: _SalesBar()),
                        const SizedBox(height: 24),
                        Text(
                          'Customer Growth',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Expanded(child: _GrowthCard(growthRate: 32.0)),
                            SizedBox(width: 16),
                            Expanded(child: _CustomerCount(count: 2135)),
                          ],
                        ),
                        const SizedBox(height: 40),
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
                          // Home
                          break;
                        case 1:
                          // Service
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceRequestsScreen(),
                            ),
                          );
                          break;
                        case 2:
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatUsersScreen(),
                            ),
                          );
                          break;
                      }
                    },
                  ),
          ),
        );
      },
    );
  }
}

// Balance card
class _BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool dark;
  final double? percent;
  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.dark,
    this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark ? AppColors.bar : AppColors.chipBlue;
    final textColor = dark ? Colors.white : AppColors.icon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.account_balance_wallet, color: AppColors.primary),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor)),
                const SizedBox(height: 4),
                Text(
                  '\$ ${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          if (percent != null)
            Container(
              constraints: const BoxConstraints(minWidth: 55),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${percent!.toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

// Simple sales bar visuals
class _SalesBar extends StatefulWidget {
  @override
  State<_SalesBar> createState() => _SalesBarState();
}

class _SalesBarState extends State<_SalesBar> {
  final List<String> labels = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late int selectedIdx;
  late final ScrollController _scrollController;
  static const double _itemWidth = 58.0; // fixed width per month item

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedIdx = now.month - 1; // current month
    _scrollController = ScrollController();
    // Center current month after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToIndex(selectedIdx, animate: false);
    });
  }

  void _scrollToIndex(int i, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    // Determine viewport width from render box
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      // Try again next frame if size not ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToIndex(i, animate: animate);
      });
      return;
    }
    final double viewportWidth = box.size.width;
    final double contentWidth = labels.length * _itemWidth;
    final double maxScroll = (contentWidth - viewportWidth).clamp(
      0,
      double.infinity,
    );
    // Center selected item
    final double target = i * _itemWidth - (viewportWidth / 2 - _itemWidth / 2);
    final double offset = target.clamp(0.0, maxScroll);
    if (animate) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double baseHeight = 72.0; // fits in 120 container height
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: List.generate(labels.length, (i) {
          final bool isSelected = i == selectedIdx;
          return InkWell(
            onTap: () {
              setState(() => selectedIdx = i);
              _scrollToIndex(i);
            },
            child: Container(
              width: _itemWidth,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 54.0 : 46.0,
                    height: isSelected ? baseHeight + 16.0 : baseHeight,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromARGB(255, 55, 125, 232)
                          : AppColors.bar,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i], style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GrowthCard extends StatelessWidget {
  final double growthRate;
  const _GrowthCard({required this.growthRate});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bar,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(20),
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '+${growthRate.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Growth rate',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _CustomerCount extends StatelessWidget {
  final int count;
  const _CustomerCount({required this.count});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.icon,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.black,
            color: AppColors.primary,
            minHeight: 9,
            borderRadius: BorderRadius.circular(24),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final String companyName;
  const _AppDrawer({required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _DrawerHeader(name: companyName),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),

            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Service Requests'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.requests);
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
                // Best-effort: Go to login
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

class _DrawerHeader extends StatelessWidget {
  final String name;
  const _DrawerHeader({required this.name});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 28,
            child: Text(
              (name.isNotEmpty ? name[0] : '?').toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
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
                  name.isNotEmpty ? name : 'My Shop',
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
          return const SizedBox.shrink();
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
