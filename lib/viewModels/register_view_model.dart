import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/services/auth_service.dart';
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
    notifyListeners();
  }

  bool verifyingPhone = false;
  bool phoneVerified = false;
  bool submitting = false;
  String? error;

  String? uploadedImageUrl;
  bool uploadingImage = false;

  Future<void> prefillFromAuthAndDb() async {}

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
    verifyingPhone = true;
    error = null;
    notifyListeners();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone.startsWith('+') ? phone : '+91 $phone',
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
      await AuthService.instance.updateProgress({'registration_done': true});
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
