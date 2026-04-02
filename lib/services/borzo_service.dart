import 'package:cloud_functions/cloud_functions.dart';

class BorzoService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Calculates the delivery cost using Borzo API
  Future<Map<String, dynamic>> calculateOrder({
    required String userAddress,
    double? userLat,
    double? userLng,
    required String userName,
    required String userPhone,
    required String shopAddress,
    double? shopLat,
    double? shopLng,
    required String shopName,
    required String shopPhone,
    String type = 'standard',
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable(
        'calculateBorzoOrder',
      );

      final Map<String, dynamic> userPoint = {
        'address': userAddress,
        'note': 'Exact Address: $userAddress',
        'contact_person': {'name': userName, 'phone': userPhone},
      };
      if (userLat != null && userLng != null) {
        userPoint['latitude'] = userLat;
        userPoint['longitude'] = userLng;
      }

      final Map<String, dynamic> shopPoint = {
        'address': shopAddress,
        'note': 'Exact Address: $shopAddress',
        'contact_person': {'name': shopName, 'phone': shopPhone},
      };
      if (shopLat != null && shopLng != null) {
        shopPoint['latitude'] = shopLat;
        shopPoint['longitude'] = shopLng;
      }

      final response = await callable.call(<String, dynamic>{
        'type': type,
        'points': [userPoint, shopPoint],
      });
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to calculate Borzo delivery cost: $e');
    }
  }

  String _formatAddress(String addr) {
    if (addr.isEmpty) return 'Detailed address missing, please contact';
    if (addr.length < 10) return '$addr, please contact for details';
    return addr;
  }

  String _formatPhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) return digits.substring(digits.length - 10);
    return '9999999999';
  }

  String _formatDateTime(DateTime dt) {
    final tzOffset = dt.timeZoneOffset;
    final sign = tzOffset.isNegative ? '-' : '+';
    final hours = tzOffset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (tzOffset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return "${dt.toIso8601String().split('.')[0]}$sign$hours:$minutes";
  }

  /// Creates a Borzo delivery order
  Future<Map<String, dynamic>> createOrder({
    required String userAddress,
    double? userLat,
    double? userLng,
    required String userName,
    required String userPhone,
    required String shopAddress,
    double? shopLat,
    double? shopLng,
    required String shopName,
    required String shopPhone,
    required String requestId,
    required String shopId,
    String? requiredStartDatetime,
    String? requiredFinishDatetime,
    String type = 'standard',
    bool isReverseDrop = false,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable(
        'createBorzoOrder',
      );

      final userPoint = <String, dynamic>{
        'address': _formatAddress(userAddress),
        'note': 'Exact Address: $userAddress',
        'contact_person': {
          'name': userName.isEmpty ? 'Customer' : userName,
          'phone': _formatPhone(userPhone),
        },
      };
      if (userLat != null && userLng != null) {
        userPoint['latitude'] = userLat;
        userPoint['longitude'] = userLng;
      }

      final shopPoint = <String, dynamic>{
        'address': _formatAddress(shopAddress),
        'note': 'Exact Address: $shopAddress',
        'contact_person': {
          'name': shopName.isEmpty ? 'Shop' : shopName,
          'phone': _formatPhone(shopPhone),
        },
      };
      if (shopLat != null && shopLng != null) {
        shopPoint['latitude'] = shopLat;
        shopPoint['longitude'] = shopLng;
      }

      // Reverse drop: courier goes shop → customer, so shop is pickup (index 0)
      List<Map<String, dynamic>> finalPoints = isReverseDrop
          ? [shopPoint, userPoint]
          : [userPoint, shopPoint];

      final now = DateTime.now();
      finalPoints[0]['required_start_datetime'] =
          requiredStartDatetime ??
          _formatDateTime(now.add(const Duration(minutes: 10)));
      finalPoints[1]['required_finish_datetime'] =
          requiredFinishDatetime ??
          _formatDateTime(now.add(const Duration(hours: 3)));

      final response = await callable.call(<String, dynamic>{
        'type': type,
        'requestId': requestId,
        'shopId': shopId,
        'isReverseDrop': isReverseDrop, // ✅ THE FIX — was missing before!
        'points': finalPoints,
      });
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to create Borzo order: $e');
    }
  }
}
