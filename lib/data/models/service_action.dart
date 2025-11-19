enum ActionType { completed, review, cancelled }

class ServiceAction {
  final String description;
  final String date; // Keep date as String for hardcoding/demo
  final ActionType type;

  ServiceAction({
    required this.description,
    required this.date,
    required this.type,
  });
}
