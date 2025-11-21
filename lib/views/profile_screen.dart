import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_colors.dart';
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
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                          ),
                          Row(
                            children: [
                              if (!vm.editing)
                                TextButton.icon(
                                  onPressed: vm.startEditing,
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppColors.primary,
                                  ),
                                  label: const Text(
                                    'Edit',
                                    style: TextStyle(color: AppColors.primary),
                                  ),
                                )
                              else ...[
                                TextButton.icon(
                                  onPressed: vm.saving ? null : vm.save,
                                  icon: const Icon(
                                    Icons.save,
                                    color: AppColors.primary2,
                                  ),
                                  label: const Text(
                                    'Save',
                                    style: TextStyle(color: AppColors.primary2),
                                  ),
                                ),
                                TextButton(
                                  onPressed: vm.saving
                                      ? null
                                      : vm.cancelEditing,
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _avatarHeader(vm),
                      const SizedBox(height: 16),
                      _sectionTitle('Business'),
                      _field(
                        'Company Legal Name',
                        vm.companyLegalName,
                        vm.editing,
                      ),
                      _field('Company Type', vm.companyType, vm.editing),
                      _field('Shop Category', vm.shopCategory, vm.editing),
                      _field('GSTIN', vm.gstin, vm.editing),
                      const SizedBox(height: 10),
                      _sectionTitle('Address'),
                      _field('Address Line 1', vm.address1, vm.editing),
                      _field('Address Line 2', vm.address2, vm.editing),
                      _field('Landmark', vm.landmark, vm.editing),
                      _field('Google Maps URL', vm.gmapUrl, vm.editing),
                      _field('City', vm.city, vm.editing),
                      _field('State', vm.state, vm.editing),
                      _field(
                        'Pincode',
                        vm.pincode,
                        vm.editing,
                        keyboard: TextInputType.number,
                      ),
                      _field(
                        'Phone',
                        vm.phone,
                        vm.editing,
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 28,
                          ),
                          title: const Text(
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
                            if (!context.mounted) return;
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (route) => false,
                            );
                          },
                        ),
                      ),
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
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}

Widget _avatarHeader(ProfileViewModel vm) {
  final title = vm.companyLegalName.text.isNotEmpty
      ? vm.companyLegalName.text
      : 'My Shop';
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            (title.isNotEmpty ? title[0] : '?').toUpperCase(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vm.email,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _sectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
    ),
  );
}

Widget _field(
  String label,
  TextEditingController controller,
  bool editable, {
  TextInputType? keyboard,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: !editable,
          keyboardType: keyboard,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    ),
  );
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
