import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/services/auth_service.dart';
import '../core/constants/app_routes.dart';
import '../authentication/enter_otp_screen.dart';

// UI-only lightweight RegisterViewModel to let screens render without backend
class RegisterViewModel extends ChangeNotifier {
  bool hasGstin = true;
  void setHasGstin(bool v) {
    hasGstin = v;
    notifyListeners();
  }

  // Controllers used by UI
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController companyLegalNameController =
      TextEditingController();
  final TextEditingController profilePhotoController = TextEditingController();
  final TextEditingController shopCategoryController = TextEditingController();
  final TextEditingController shopDescriptionController =
      TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController gmapUrlController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final List<String> companyTypes = const [
    'Proprietorship',
    'Partnership',
    'LLP',
    'Private Ltd',
    'Public Ltd',
    'Other',
  ];
  String? selectedCompanyType;
  void setCompanyType(String? v) {
    selectedCompanyType = v;
    notifyListeners();
  }

  void setShopCategory(String? v) {
    shopCategoryController.text = v ?? '';
    // Reset subcategories when category changes
    selectedSubcategories.clear();
    notifyListeners();
  }

  // Subcategories multi-select state
  final List<String> selectedSubcategories = [];
  void toggleSubcategory(String sub) {
    if (selectedSubcategories.contains(sub)) {
      selectedSubcategories.remove(sub);
    } else {
      selectedSubcategories.add(sub);
    }
    notifyListeners();
  }

  bool verifyingPhone = false;
  bool phoneVerified = false;
  bool submitting = false;
  String? error;

  String? uploadedImageUrl;
  bool uploadingImage = false;

  Future<void> prefillFromAuthAndDb() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      // Prefill from auth
      final authPhone = user?.phoneNumber;
      if (authPhone != null && authPhone.trim().isNotEmpty) {
        // strip +91 and spaces for UI field
        final p = authPhone.replaceAll('+91', '').trim();
        if (p.isNotEmpty) phoneController.text = p;
      }
      // Prefill from Firestore registered_shop_users
      if (uid != null) {
        final regSnap = await FirebaseFirestore.instance
            .collection('registered_shop_users')
            .doc(uid)
            .get();
        final reg = regSnap.data();
        if (reg != null) {
          companyLegalNameController.text = (reg['companyLegalName'] ?? '')
              .toString();
          selectedCompanyType = (reg['companyType'] as String?);
          shopCategoryController.text = (reg['shopCategory'] ?? '').toString();
          final subs =
              (reg['subcategories'] as List?)?.cast<String>() ?? const [];
          selectedSubcategories
            ..clear()
            ..addAll(subs);
          shopDescriptionController.text = (reg['shopDescription'] ?? '')
              .toString();
          final addr = (reg['address'] as Map<String, dynamic>?) ?? {};
          address1Controller.text = (addr['line1'] ?? '').toString();
          address2Controller.text = (addr['line2'] ?? '').toString();
          landmarkController.text = (addr['landmark'] ?? '').toString();
          cityController.text = (addr['city'] ?? '').toString();
          stateController.text = (addr['state'] ?? '').toString();
          pincodeController.text = (addr['pincode'] ?? '').toString();
          gmapUrlController.text = (reg['gmapUrl'] ?? '').toString();
          final phoneDb = (reg['phone'] ?? '').toString();
          if (phoneDb.isNotEmpty) {
            final p = phoneDb.replaceAll('+91', '').trim();
            phoneController.text = p;
          }
        }
      }
    } catch (_) {
      // ignore silent prefill errors
    } finally {
      notifyListeners();
    }
  }

  void resetForNewForm() {
    hasGstin = true;
    selectedCompanyType = null;
    verifyingPhone = false;
    phoneVerified = false;
    submitting = false;
    error = null;
    uploadedImageUrl = null;
    gstinController.clear();
    companyLegalNameController.clear();
    profilePhotoController.clear();
    shopCategoryController.clear();
    shopDescriptionController.clear();
    selectedSubcategories.clear();
    address1Controller.clear();
    address2Controller.clear();
    landmarkController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    gmapUrlController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }

  String? _verificationId;
  int? _resendToken;

  Future<void> verifyPhoneWithContext(BuildContext context) async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      error = 'Enter phone number';
      notifyListeners();
      return;
    }
    // Check if phone exists in DB before verifying
    final normalized = phone.startsWith('+') ? phone : '+91 ${phone.trim()}';
    try {
      final existing = await FirebaseFirestore.instance
          .collection('registered_shop_users')
          .where('phone', isEqualTo: normalized)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        error = 'Phone number already exists';
        notifyListeners();
        return;
      }
    } catch (_) {
      // continue to verify if lookup fails
    }

    verifyingPhone = true;
    error = null;
    notifyListeners();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: normalized,
      forceResendingToken: _resendToken,
      verificationCompleted: (credential) async {
        // Auto-retrieval or instant verification
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await user.linkWithCredential(credential);
          } else {
            await FirebaseAuth.instance.signInWithCredential(credential);
          }
          phoneVerified = true;
        } catch (e) {
          error = e.toString();
        } finally {
          verifyingPhone = false;
          notifyListeners();
        }
      },
      verificationFailed: (e) {
        error = e.message;
        verifyingPhone = false;
        notifyListeners();
      },
      codeSent: (verificationId, resendToken) async {
        _verificationId = verificationId;
        _resendToken = resendToken;
        verifyingPhone = false;
        notifyListeners();

        final code = await Navigator.of(context).push<String>(
          MaterialPageRoute(builder: (_) => EnterOTPScreen(phone: phone)),
        );
        if (code != null && code.length == 6 && _verificationId != null) {
          try {
            final credential = PhoneAuthProvider.credential(
              verificationId: _verificationId!,
              smsCode: code,
            );
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await user.linkWithCredential(credential);
            } else {
              await FirebaseAuth.instance.signInWithCredential(credential);
            }
            phoneVerified = true;
          } on FirebaseAuthException catch (e) {
            error = e.message;
          } finally {
            notifyListeners();
          }
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> submit(BuildContext context) async {
    try {
      submitting = true;
      notifyListeners();
      if (!phoneVerified) {
        error = 'Please verify your phone number before submitting.';
        return;
      }
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        error = 'You must be logged in to submit registration.';
        return;
      }
      final payload = _buildRegistrationPayload();
      await FirebaseFirestore.instance
          .collection('registered_shop_users')
          .doc(uid)
          .set(payload, SetOptions(merge: true));
      // Mirror essential fields to shop_users for quick header rendering
      await FirebaseFirestore.instance.collection('shop_users').doc(uid).set({
        'companyLegalName': companyLegalNameController.text.trim(),
        'company': companyLegalNameController.text.trim(),
        'phone': phoneController.text.trim().startsWith('+')
            ? phoneController.text.trim()
            : '+91 ${phoneController.text.trim()}',
      }, SetOptions(merge: true));
      await AuthService.instance.updateProgress({'registration_done': true});
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      error = e.toString();
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  void cancel(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    gstinController.dispose();
    companyLegalNameController.dispose();
    profilePhotoController.dispose();
    shopCategoryController.dispose();
    shopDescriptionController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> pickAndUploadImage() async {
    try {
      uploadingImage = true;
      notifyListeners();
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) {
        uploadingImage = false;
        notifyListeners();
        return;
      }
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        uploadingImage = false;
        notifyListeners();
        return;
      }
      final fileName =
          'shop_images/$uid/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putData(await picked.readAsBytes());
      uploadedImageUrl = await ref.getDownloadURL();
    } finally {
      uploadingImage = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildRegistrationPayload() {
    return {
      'hasGstin': hasGstin,
      'gstin': gstinController.text.trim(),
      'companyLegalName': companyLegalNameController.text.trim(),
      'companyType': selectedCompanyType,
      'shopCategory': shopCategoryController.text.trim(),
      'subcategories': selectedSubcategories,
      'shopDescription': shopDescriptionController.text.trim(),
      'address': {
        'line1': address1Controller.text.trim(),
        'line2': address2Controller.text.trim(),
        'landmark': landmarkController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'pincode': pincodeController.text.trim(),
      },
      'gmapUrl': gmapUrlController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
      'imageUrl': uploadedImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
