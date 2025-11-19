import 'package:flutter/material.dart';
import 'DashboardCard.dart';
import '../viewModels/home_viewmodel.dart';
import '../core/constants/app_routes.dart';

class DashboardGrid extends StatelessWidget {
  final DashboardViewModel viewModel;
  const DashboardGrid({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.requests),
          child: DashboardCard(
            icon: Icons.list_alt,
            title: 'Service Request',
            value: viewModel.serviceRequests.toString(),
            color: Colors.blue[50]!,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
          child: DashboardCard(
            icon: Icons.history,
            title: 'Service History',
            value: viewModel.serviceHistory.toString(),
            color: Colors.green[50]!,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.analytics),
          child: DashboardCard(
            icon: Icons.bar_chart,
            title: 'Analytics',
            value: '+${(viewModel.analyticsGrowth * 100).toInt()}%',
            color: Colors.yellow[50]!,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.addService),
          child: DashboardCard(
            icon: Icons.add_circle_outline,
            title: 'Add Service',
            value: '',
            color: Colors.blue[100]!,
          ),
        ),
      ],
    );
  }
}
