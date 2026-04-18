import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/cache_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/toast_helper.dart';

/// GetX controller for Firebase Authentication (sign in, sign up, logout).
class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Loading States ─────────────────────────────────────────────────────
  final signInLoading = false.obs;
  final signUpLoading = false.obs;

  // ── Current User ───────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ── Sign In ────────────────────────────────────────────────────────────
  Future<bool> signIn(String email, String password) async {
    try {
      signInLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = _auth.currentUser;
      if (user != null) {
        final cache = Get.find<CacheService>();
        await cache.setBool(AppConstants.keyIsLoggedIn, true);
        await cache.setString(AppConstants.keyUserId, user.uid);
        await cache.setString(AppConstants.keyUserEmail, user.email ?? '');
      }
      ToastHelper.showSuccess('Welcome back!');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      ToastHelper.showError('Something went wrong. Please try again.');
      return false;
    } finally {
      signInLoading.value = false;
    }
  }

  // ── Sign Up ────────────────────────────────────────────────────────────
  Future<bool> signUp(String email, String password, String name) async {
    try {
      signUpLoading.value = true;
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name.trim());

        // Store user profile in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Cache locally
        final cache = Get.find<CacheService>();
        await cache.setBool(AppConstants.keyIsLoggedIn, true);
        await cache.setString(AppConstants.keyUserId, user.uid);
        await cache.setString(AppConstants.keyUserName, name.trim());
        await cache.setString(AppConstants.keyUserEmail, email.trim());
      }
      ToastHelper.showSuccess('Account created successfully!');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      ToastHelper.showError('Something went wrong. Please try again.');
      return false;
    } finally {
      signUpLoading.value = false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    final cache = Get.find<CacheService>();
    await cache.clearAll();
  }

  // ── Error Handling ─────────────────────────────────────────────────────
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No account found with this email.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email.';
        break;
      case 'weak-password':
        message = 'Password is too weak.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'invalid-credential':
        message = 'Invalid credentials. Please check your email and password.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      default:
        message = e.message ?? 'Authentication failed.';
    }
    ToastHelper.showError(message);
  }
}
