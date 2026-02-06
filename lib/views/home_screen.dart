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
import 'ratings_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  final DashboardViewModel viewModel = DashboardViewModel();

  HomeScreen({Key? key}) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

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
              return _buildScaffold(context, user.uid, company, incomplete);
            },
          );
        }

        final company = primaryCompany;
        SharedPreferences.getInstance().then((p) {
          if (company.isNotEmpty) {
            p.setString('company_name_${user.uid}', company);
          }
        });
        return _buildScaffold(context, user.uid, company, incomplete);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    String uid,
    String companyName,
    bool incomplete,
  ) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: _AppDrawer(companyName: companyName),
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.icon),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.icon,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
          ],
        ),
        body: incomplete
            ? const _OnboardingGate()
            : RefreshIndicator(
                onRefresh: () async {
                  // Refresh data
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Section
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        companyName.isNotEmpty ? companyName : 'Welcome',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.icon,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Real-time Stats Cards
                      _StatsGrid(shopUid: uid),
                      const SizedBox(height: 24),

                      // Quick Actions
                      Row(
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.icon,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _QuickActionsGrid(),
                      const SizedBox(height: 32),

                      // Earnings Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Earnings Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.icon,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.icon,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'This Month',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _EarningsSection(shopUid: uid),
                      const SizedBox(height: 32),

                      // Customer Insights
                      const Text(
                        'Customer Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.icon,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CustomerInsights(shopUid: uid),
                      const SizedBox(height: 40),
                    ],
                  ),
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
  }
}

// Stats Grid with real-time data
class _StatsGrid extends StatelessWidget {
  final String shopUid;
  const _StatsGrid({required this.shopUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('shop_users')
          .doc(shopUid)
          .collection('requests')
          .snapshots(),
      builder: (context, snapshot) {
        int todayCount = 0;
        int pendingCount = 0;
        int inProgressCount = 0;
        int completedCount = 0;

        if (snapshot.hasData) {
          final today = DateTime.now();
          final docs = snapshot.data!.docs;

          for (var doc in docs) {
            final data = doc.data();
            final status = (data['status'] ?? '').toString().toLowerCase();

            // Count today's requests
            if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
              final createdDate = (data['createdAt'] as Timestamp).toDate();
              if (createdDate.year == today.year &&
                  createdDate.month == today.month &&
                  createdDate.day == today.day) {
                todayCount++;
              }
            }

            // Count by status
            if (status == 'pending' || status == 'new' || status.isEmpty) {
              pendingCount++;
            } else if (status == 'in_progress' ||
                status == 'confirm' ||
                status == 'waiting_for_confirmation') {
              inProgressCount++;
            } else if (status == 'completed' ||
                status == 'paid' ||
                status == 'payment_done') {
              completedCount++;
            }
          }
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              title: "Today's Requests",
              value: todayCount.toString(),
              icon: Icons.today_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _StatCard(
              title: 'Pending',
              value: pendingCount.toString(),
              icon: Icons.pending_actions_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _StatCard(
              title: 'In Progress',
              value: inProgressCount.toString(),
              icon: Icons.handyman_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _StatCard(
              title: 'Completed',
              value: completedCount.toString(),
              icon: Icons.check_circle_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 26),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Quick Actions Grid
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _ActionButton(
          label: 'All Requests',
          icon: Icons.list_alt_rounded,
          color: const Color(0xFF156EF5),
          onTap: () => Navigator.pushNamed(context, AppRoutes.requests),
        ),
        _ActionButton(
          label: 'Add Service',
          icon: Icons.add_circle_rounded,
          color: const Color(0xFF10B981),
          onTap: () => Navigator.pushNamed(context, AppRoutes.addService),
        ),
        _ActionButton(
          label: 'History',
          icon: Icons.history_rounded,
          color: const Color(0xFFF59E0B),
          onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
        ),
        _ActionButton(
          label: 'Messages',
          icon: Icons.chat_rounded,
          color: const Color(0xFFEC4899),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatUsersScreen()),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Earnings Section with real data
class _EarningsSection extends StatelessWidget {
  final String shopUid;
  const _EarningsSection({required this.shopUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('shop_users')
          .doc(shopUid)
          .collection('requests')
          .where('status', whereIn: ['completed', 'paid', 'payment_done'])
          .snapshots(),
      builder: (context, snapshot) {
        double monthlyEarning = 0.0;
        double totalEarning = 0.0;

        if (snapshot.hasData) {
          final now = DateTime.now();
          for (var doc in snapshot.data!.docs) {
            final data = doc.data();
            final serviceDetails =
                data['serviceDetails'] as Map<String, dynamic>?;
            final totalCost =
                double.tryParse(
                  serviceDetails?['totalCost']?.toString() ?? '0',
                ) ??
                0.0;

            totalEarning += totalCost;

            // Calculate monthly earning
            if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
              final createdDate = (data['createdAt'] as Timestamp).toDate();
              if (createdDate.year == now.year &&
                  createdDate.month == now.month) {
                monthlyEarning += totalCost;
              }
            }
          }
        }

        return Column(
          children: [
            _EarningCard(
              title: 'Monthly Earning',
              amount: monthlyEarning,
              isDark: true,
            ),
            const SizedBox(height: 12),
            _EarningCard(
              title: 'Total Earning',
              amount: totalEarning,
              isDark: false,
            ),
          ],
        );
      },
    );
  }
}

class _EarningCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool isDark;

  const _EarningCard({
    required this.title,
    required this.amount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.primary.withOpacity(0.3)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(14),
            child: Icon(
              Icons.trending_up_rounded,
              color: isDark ? Colors.white : AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.85)
                        : AppColors.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.icon,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
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

// Monthly chart (keeping existing implementation)
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
  static const double _itemWidth = 58.0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedIdx = now.month - 1;
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToIndex(selectedIdx, animate: false);
    });
  }

  void _scrollToIndex(int i, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
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
    const double baseHeight = 72.0;
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
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      color: isSelected ? null : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [],
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.border, width: 1.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Customer Insights with redesigned layout
class _CustomerInsights extends StatelessWidget {
  final String shopUid;
  const _CustomerInsights({required this.shopUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('shop_users')
          .doc(shopUid)
          .collection('requests')
          .snapshots(),
      builder: (context, snapshot) {
        int uniqueCustomers = 0;
        int newThisMonth = 0;
        int newLastMonth = 0;

        if (snapshot.hasData) {
          final customerIds = <String>{};
          final now = DateTime.now();
          final thisMonthCustomerIds = <String>{};
          final lastMonthCustomerIds = <String>{};

          // Calculate last month's date
          final lastMonth = DateTime(now.year, now.month - 1);

          for (var doc in snapshot.data!.docs) {
            final userId = doc.data()['userId']?.toString();
            if (userId != null && userId.isNotEmpty) {
              customerIds.add(userId);

              // Count new customers this month and last month
              if (doc.data()['createdAt'] != null &&
                  doc.data()['createdAt'] is Timestamp) {
                final createdDate = (doc.data()['createdAt'] as Timestamp)
                    .toDate();
                
                // This month's new customers
                if (createdDate.year == now.year &&
                    createdDate.month == now.month) {
                  thisMonthCustomerIds.add(userId);
                }
                
                // Last month's new customers
                if (createdDate.year == lastMonth.year &&
                    createdDate.month == lastMonth.month) {
                  lastMonthCustomerIds.add(userId);
                }
              }
            }
          }
          uniqueCustomers = customerIds.length;
          newThisMonth = thisMonthCustomerIds.length;
          newLastMonth = lastMonthCustomerIds.length;
        }

        // Calculate growth rate
        double growthRate = 0.0;
        if (newLastMonth > 0) {
          growthRate = ((newThisMonth - newLastMonth) / newLastMonth) * 100;
        } else if (newThisMonth > 0) {
          growthRate = 100.0; // 100% growth if we had 0 last month and some this month
        }

        final growthText = growthRate >= 0
            ? '+${growthRate.toStringAsFixed(0)}%'
            : '${growthRate.toStringAsFixed(0)}%';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row - Total Customers and Growth
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.people_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                uniqueCustomers.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Total Customers',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success,
                          AppColors.success.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.trending_up_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          growthText,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Growth',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bottom row - Additional metrics
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.person_add_rounded,
                    value: newThisMonth.toString(),
                    label: 'New This Month',
                    color: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('shop_users')
                        .doc(shopUid)
                        .collection('ratings')
                        .snapshots(),
                    builder: (context, ratingsSnapshot) {
                      double avgRating = 0.0;
                      if (ratingsSnapshot.hasData && ratingsSnapshot.data!.docs.isNotEmpty) {
                        final ratings = ratingsSnapshot.data!.docs;
                        avgRating = ratings.fold<double>(
                              0.0,
                              (sum, doc) => sum + (doc.data()['rating'] ?? 0).toDouble(),
                            ) /
                            ratings.length;
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RatingsListScreen(),
                            ),
                          );
                        },
                        child: _MetricCard(
                          icon: Icons.star_rounded,
                          value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '0.0',
                          label: 'Satisfaction',
                          color: const Color(0xFFF59E0B),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Helper widget for small metric cards
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.icon,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// App Drawer (keeping existing implementation)
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
