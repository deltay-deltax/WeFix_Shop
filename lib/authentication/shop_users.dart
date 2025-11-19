// shop_users.dart
class ShopUser {
  final String email;
  final String password;
  final DateTime createdAt;

  ShopUser({required this.email, required this.password})
    : createdAt = DateTime.now();
}

class ShopUserRepository {
  static final List<ShopUser> _users = [];

  static bool exists(String email) =>
      _users.any((u) => u.email.toLowerCase() == email.toLowerCase());

  static void addUser(String email, String password) {
    if (exists(email)) {
      throw Exception('User already exists');
    }
    _users.add(ShopUser(email: email, password: password));
  }

  static ShopUser? authenticate(String email, String password) {
    try {
      return _users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }
}
