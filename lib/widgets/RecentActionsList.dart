import 'package:flutter/material.dart';
import 'RecentActionTile.dart';
import '../viewModels/home_viewmodel.dart';

class RecentActionsList extends StatelessWidget {
  final DashboardViewModel viewModel;

  const RecentActionsList({Key? key, required this.viewModel})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          RecentActionTile(
            icon: Icons.check_circle,
            iconColor: Colors.blue,
            title: 'Service #1245 marked as complete.',
            subtitle: '2 hours ago',
          ),
          RecentActionTile(
            icon: Icons.star,
            iconColor: Colors.amber,
            title: viewModel.getReview(),
            subtitle: 'Yesterday',
          ),
          RecentActionTile(
            icon: Icons.cancel,
            iconColor: Colors.redAccent,
            title: 'Service #1240 was cancelled by client.',
            subtitle: '2 days ago',
          ),
        ],
      ),
    );
  }
}
