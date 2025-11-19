import 'package:flutter/material.dart';
import 'package:wefix_shop/data/models/service_history_model.dart';
import '../data/models/service_request_model.dart';

class ServiceUpdateViewModel extends ChangeNotifier {
  final List<ServiceRequestModel> requests = [
    ServiceRequestModel(
      deviceName: "LGOS23",
      problem: "Screen Flickering",
      date: "15 Oct 23",
      status: "In Progress",
      amount: "\$85.00",
    ),
    ServiceRequestModel(
      deviceName: "IP 320",
      problem: "Won't turn on",
      date: "14 Oct 23",
      status: "Pending",
      amount: "\$150.00",
    ),
    ServiceRequestModel(
      deviceName: "iPhone 12",
      problem: "Battery issue",
      date: "12 Oct 23",
      status: "Paid",
      amount: "\$70.00",
    ),
    ServiceRequestModel(
      deviceName: "LGOS23",
      problem: "Charging port",
      date: "11 Oct 23",
      status: "Payment",
      amount: "\$45.00",
      canPay: true,
    ),
    ServiceRequestModel(
      deviceName: "IP 320",
      problem: "Broken hinge",
      date: "10 Oct 23",
      status: "Declined",
      amount: "-",
    ),
  ];
}
