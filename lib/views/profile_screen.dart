import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_routes.dart';
import '../viewModels/profile_viewmodel.dart';
import '../widgets/BottomNavWidget.dart';

import '../core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, child) => Scaffold(
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(0),
              children: [
                // Header row
                Padding(
                  padding: EdgeInsets.fromLTRB(18, 26, 0, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Profile",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications_none),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Profile section (hardcoded image for now)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 37,
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          Icons.local_shipping,
                          size: 45,
                          color: Colors.grey[700],
                        ),
                        // Use: backgroundImage: AssetImage('assets/your_profile_image.png'),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vm.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              vm.email,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                // Actions card (hardcoded)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 18),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      ProfileActionTile(
                        icon: Icons.account_balance_wallet,
                        label: "My Wallet",
                      ),
                      ProfileActionTile(
                        icon: Icons.location_on,
                        label: "Saved Addresses",
                      ),
                      ProfileActionTile(
                        icon: Icons.verified_user,
                        label: "Record Warranty",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.warranty);
                        },
                      ),
                      ProfileActionTile(
                        icon: Icons.settings,
                        label: "Account Settings",
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 28,
                        ),
                        title: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 17,
                          color: Colors.red.shade300,
                        ),
                        onTap: () async {
                          await AuthService.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                // Removed 'Track Your Orders' card
                SizedBox(height: 25),
                // Favorite Shops header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Favorite Shops",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "See All",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),

                // Favorite Shops grid
                SizedBox(height: 16),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavWidget(
            currentIndex: 2,
            onTap: (idx) {
              switch (idx) {
                case 0:
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, AppRoutes.chat);
                  break;
                case 2:
                  // already on profile
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}

// Hardcoded as a builder method for readability, but you can extract if needed.
Widget ProfileActionTile({
  required IconData icon,
  required String label,
  bool last = false,
  VoidCallback? onTap,
}) {
  return Column(
    children: [
      ListTile(
        leading: Icon(icon, color: Colors.blue, size: 28),
        title: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 17,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
      if (!last) Divider(height: 0, thickness: 1, indent: 15, endIndent: 15),
    ],
  );
}
