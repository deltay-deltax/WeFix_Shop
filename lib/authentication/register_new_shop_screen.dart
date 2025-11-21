import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../viewModels/register_view_model.dart';
// removed email verification flow

class RegisterNewShopScreen extends StatelessWidget {
  static const String routeName = '/register';
  const RegisterNewShopScreen({super.key});

  static const List<String> _kShopCategories = [
    'HouseHold Electronics (Repairable)',
    'Computer & Peripherals (Repairable)',
  ];

  static const List<String> _kHouseholdSubs = [
    'Refrigerator (Fridge)',
    'Washing Machine',
    'Microwave Oven',
    'Air Conditioner (AC)',
    'Water Purifier / RO System',
    'Geyser / Water Heater',
    'Mixer / Grinder',
    'Induction Cooktop',
    'Electric Kettle',
    'Vacuum Cleaner',
    'Electric Iron',
    'Air Cooler',
    'Inverter / UPS',
    'Smart TV / LED TV',
    'Home Theatre System',
    'Room Heater',
    'Chimney / Exhaust Fan',
    'Dishwasher',
  ];

  static const List<String> _kComputerSubs = [
    'Laptop',
    'Desktop CPU',
    'Monitor',
    'Printer',
    'Scanner',
    'Keyboard',
    'Mouse',
    'External Hard Disk / SSD / HDD',
    'RAM',
    'Graphic Card (GPU)',
    'Motherboard',
    'SMPS / Power Supply',
    'Router / Modem',
    'Webcam',
    'Headphones / Headset',
    'Microphone',
    'UPS (for PC)',
    'Pen Drive (logical repair / recovery)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ChangeNotifierProvider<RegisterViewModel>(
                create: (_) => RegisterViewModel()..prefillFromAuthAndDb(),
                child: Consumer<RegisterViewModel>(
                  builder: (context, vm, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Register as a new Shop ",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Do you have a GSTIN?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _segmented(
                          left: 'Yes',
                          right: 'No',
                          activeLeft: vm.hasGstin,
                          onChanged: (left) => vm.setHasGstin(left),
                        ),
                        const SizedBox(height: 12),
                        if (vm.hasGstin)
                          _formField(
                            'GSTIN',
                            vm.gstinController,
                            hint: 'Enter your GSTIN',
                          ),
                        _formField(
                          'Company Legal Name',
                          vm.companyLegalNameController,
                          hint: 'Enter your company legal name',
                        ),
                        _label('Company Type*'),
                        _companyTypeDropdown(vm),
                        const SizedBox(height: 12),
                        _label('Shop Image'),
                        // Image picker and Shop Category below Company Type
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: vm.uploadingImage
                                  ? null
                                  : vm.pickAndUploadImage,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(140, 44),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                vm.uploadingImage
                                    ? 'Uploading...'
                                    : 'Choose Image',
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (vm.uploadedImageUrl != null &&
                                vm.uploadedImageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  vm.uploadedImageUrl!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _label('Shop Category'),
                        _shopCategoryDropdown(vm),
                        const SizedBox(height: 8),
                        _label('Subcategories (select multiple)'),
                        _subcategoriesMulti(vm),
                        const SizedBox(height: 6),
                        _commonRepairsHelper(vm),
                        const SizedBox(height: 8),

                        const SizedBox(height: 16),
                        const Text(
                          'Shop Address',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        _formField(
                          'Address Line 1*',
                          vm.address1Controller,
                          hint: 'Enter address',
                        ),
                        _formField('Address Line 2', vm.address2Controller),
                        _formField('Landmark', vm.landmarkController),
                        _formField('City*', vm.cityController),
                        _formField('State*', vm.stateController),
                        _formField(
                          'Pincode*',
                          vm.pincodeController,
                          keyboardType: TextInputType.number,
                        ),

                        _label('Shop Description'),
                        _roundedField(
                          controller: vm.shopDescriptionController,
                          hint:
                              'Tell customers about your shop, specialties, experience, etc.',
                        ),
                        const SizedBox(height: 8),
                        _label('Shop Google Maps URL (optional)'),
                        _roundedField(
                          controller: vm.gmapUrlController,
                          hint: 'Paste your shop Google Maps URL',
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 12),
                        _label('Phone Number*'),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: vm.phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Enter phone number',
                                  prefixText: '+91 ',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: (vm.verifyingPhone || vm.phoneVerified)
                                ? null
                                : () => vm.verifyPhoneWithContext(context),
                            child: Text(
                              vm.phoneVerified
                                  ? 'Verified'
                                  : (vm.verifyingPhone
                                        ? 'Verifying...'
                                        : 'Verify Phone Number'),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Password fields remain removed
                        if (vm.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              vm.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _primaryButton(
                                label: vm.submitting
                                    ? 'Submitting...'
                                    : 'Submit',
                                color: AppColors.primary,
                                onPressed: vm.submitting
                                    ? null
                                    : () => vm.submit(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _primaryButton(
                                label: 'Cancel',
                                color: AppColors.error,

                                onPressed: () => vm.cancel(context),
                              ),
                            ),
                          ],
                        ),
                        if (vm.submitting) ...[
                          const SizedBox(height: 12),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        children: text.split('').map((ch) {
          if (ch == '*') {
            return const TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            );
          }
          return TextSpan(
            text: ch,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
      ),
    ),
  );

  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _formField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        _roundedField(
          controller: controller,
          hint: hint ?? label,
          keyboardType: keyboardType,
          obscureText: obscure,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _companyTypeDropdown(RegisterViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:
              (vm.selectedCompanyType != null &&
                  vm.selectedCompanyType!.isNotEmpty)
              ? vm.selectedCompanyType
              : null,
          hint: const Text('Select Company Type'),
          items: vm.companyTypes
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: vm.setCompanyType,
        ),
      ),
    );
  }

  Widget _shopCategoryDropdown(RegisterViewModel vm) {
    final items = _kShopCategories;
    final current = vm.shopCategoryController.text;
    final value = (current.isEmpty || !items.contains(current))
        ? null
        : current;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text('Select Shop Category (optional)'),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: vm.setShopCategory,
        ),
      ),
    );
  }

  Widget _subcategoriesMulti(RegisterViewModel vm) {
    List<String> options = const [];
    final cat = vm.shopCategoryController.text;
    if (cat == _kShopCategories[0]) {
      options = _kHouseholdSubs;
    } else if (cat == _kShopCategories[1]) {
      options = _kComputerSubs;
    }
    if (options.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Select a shop category first'),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final sub in options)
          FilterChip(
            label: Text(sub),
            selected: vm.selectedSubcategories.contains(sub),
            onSelected: (_) => vm.toggleSubcategory(sub),
          ),
      ],
    );
  }

  Widget _commonRepairsHelper(RegisterViewModel vm) {
    if (vm.shopCategoryController.text != _kShopCategories[0]) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'Common repairs: motor issues, PCB faults, heating issues, gas leakage, power failure, sensor problems, fan replacement, etc.',
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }

  Widget _segmented({
    required String left,
    required String right,
    required bool activeLeft,
    required void Function(bool) onChanged,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _segBtn(
            label: left,
            active: activeLeft,
            onTap: () => onChanged(true),
          ),
          _segBtn(
            label: right,
            active: !activeLeft,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _segBtn({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required Color color,
    Color? textColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
