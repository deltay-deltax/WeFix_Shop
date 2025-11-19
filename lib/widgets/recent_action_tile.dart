import 'package:flutter/material.dart';
import '../data/models/service_action.dart';

class RecentActionTile extends StatelessWidget {
  final ServiceAction action;

  const RecentActionTile({Key? key, required this.action}) : super(key: key);

  Color getIconColor() {
    switch (action.type) {
      case ActionType.completed:
        return Colors.blue;
      case ActionType.review:
        return Colors.amber;
      case ActionType.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getIcon() {
    switch (action.type) {
      case ActionType.completed:
        return Icons.check_circle;
      case ActionType.review:
        return Icons.star;
      case ActionType.cancelled:
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: getIconColor(),
        child: Icon(getIcon(), color: Colors.white),
      ),
      title: Text(action.description),
      subtitle: Text(action.date),
    );
  }
}
