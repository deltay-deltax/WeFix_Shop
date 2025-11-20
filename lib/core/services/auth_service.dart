import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? extra,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _ensureUserDoc(
      uid: cred.user!.uid,
      email: email,
      role: role,
      extra: extra,
    );
    return cred;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? extra,
    bool allowRoleAttach = false,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _attachRoleIfNeeded(
      uid: cred.user!.uid,
      role: role,
      allow: allowRoleAttach,
      extra: extra,
    );
    return cred;
  }

  Future<UserCredential> signInWithGoogle({
    required String role,
    bool requireExisting = false,
    String? expectedRole,
  }) async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception('google_sign_in_canceled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    final uid = cred.user!.uid;
    final email = cred.user!.email ?? '';

    final userDoc = await _db.collection('shop_users').doc(uid).get();
    if (!userDoc.exists) {
      if (requireExisting) {
        throw Exception('not_registered');
      }
      await _ensureUserDoc(uid: uid, email: email, role: role);
    } else {
      final roles = List<String>.from(userDoc.data()?['roles'] ?? []);
      if (expectedRole != null &&
          !roles
              .map((e) => e.toLowerCase())
              .contains(expectedRole.toLowerCase())) {
        throw Exception('role_mismatch');
      }
    }
    return cred;
  }

  Future<void> initializeUserDocsForNewAccount({
    required String role,
    Map<String, dynamic>? extra,
  }) async {
    final uid = _auth.currentUser!.uid;
    final email = _auth.currentUser!.email ?? '';
    await _ensureUserDoc(uid: uid, email: email, role: role, extra: extra);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }

  Future<List<String>> getCurrentUserRoles() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _db.collection('shop_users').doc(uid).get();
    final roles = List<String>.from(doc.data()?['roles'] ?? []);
    return roles;
  }

  Future<void> updateProgress(Map<String, dynamic> progressPatch) async {
    final uid = _auth.currentUser!.uid;
    await _db.collection('shop_users').doc(uid).set({
      'progress': progressPatch,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _ensureUserDoc({
    required String uid,
    required String email,
    required String role,
    Map<String, dynamic>? extra,
  }) async {
    final ref = _db.collection('shop_users').doc(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'email': email,
        'roles': [role],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'progress': {
          'terms_done': false,
          'privacy_done': false,
          'registration_done': false,
        },
        ...?extra,
      });
    } else {
      await _attachRoleIfNeeded(
        uid: uid,
        role: role,
        allow: true,
        extra: extra,
      );
    }
  }

  Future<void> _attachRoleIfNeeded({
    required String uid,
    required String role,
    required bool allow,
    Map<String, dynamic>? extra,
  }) async {
    final ref = _db.collection('shop_users').doc(uid);
    final snap = await ref.get();
    final roles = List<String>.from(snap.data()?['roles'] ?? []);
    final hasRole = roles
        .map((e) => e.toLowerCase())
        .contains(role.toLowerCase());
    if (!hasRole) {
      if (!allow) throw Exception('role_exists');
      await ref.set({
        'roles': FieldValue.arrayUnion([role]),
        ...?extra,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
