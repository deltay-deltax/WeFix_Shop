class ServiceRequestModel {
  final String deviceName;
  final String problem;
  final String date;
  final String status;
  final String amount;
  final bool canPay;
  ServiceRequestModel({
    required this.deviceName,
    required this.problem,
    required this.date,
    required this.status,
    required this.amount,
    this.canPay = false,
  });
}
