import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth? _auth; // Nullable
  final FirebaseFirestore? _firestore; // Nullable
  final bool _isMock;

  UserModel? _user;
  UserModel? get user => _user;

  bool get isAuthenticated => _user != null; // Use _user instead of auth.currentUser for unified check

  AuthService({bool isFirebaseInitialized = true}) 
      : _isMock = !isFirebaseInitialized,
        _auth = isFirebaseInitialized ? FirebaseAuth.instance : null,
        _firestore = isFirebaseInitialized ? FirebaseFirestore.instance : null {
    
    if (!_isMock) {
      _auth!.authStateChanges().listen((User? firebaseUser) {
        if (firebaseUser != null) {
          // Listen to real-time changes
          _firestore!.collection('users').doc(firebaseUser.uid).snapshots().listen((doc) {
             if (doc.exists) {
              try {
                var data = doc.data() as Map<String, dynamic>;
                _user = UserModel(
                  uid: firebaseUser.uid,
                  email: data['email'] ?? '',
                  displayName: data['displayName'] ?? 'User',
                  avatarUrl: data['avatarUrl'],
                  totalPoints: data['totalPoints'] ?? 0,
                  activityCount: data['activityCount'] ?? 0,
                  plasticCollected: (data['plasticCollected'] as num?)?.toDouble() ?? 0.0,
                  treesPlanted: (data['treesPlanted'] as num?)?.toInt() ?? 0,
                  co2Saved: (data['co2Saved'] as num?)?.toDouble() ?? 0.0,
                );
                notifyListeners();
              } catch (e) {
                print("Error parsing user data: $e");
              }
            }
          });
        } else {
          _user = null;
          notifyListeners();
        }
      });
    }
  }

  // Deprecated single fetch in favor of stream above, but kept for helper if needed
  Future<void> _fetchUserDetails(String uid) async {}

  Future<String?> signIn(String email, String password) async {
    if (_isMock) {
      // Mock Login
      if (email.isNotEmpty && password.isNotEmpty) {
        _user = UserModel(uid: 'mock_user_123', email: email, displayName: 'Mock User', totalPoints: 100);
        notifyListeners();
        return null;
      }
      return "Mock Login Failed";
    }

    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getTurkishError(e.code);
    }
  }

  Future<String?> signUp(String email, String password, String displayName) async {
    if (_isMock) {
        _user = UserModel(uid: 'mock_user_123', email: email, displayName: displayName, totalPoints: 0);
        notifyListeners();
        return null;
    }

    try {
      UserCredential cred = await _auth!.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        // Create user record in Firestore
        UserModel newUser = UserModel(
          uid: cred.user!.uid,
          email: email,
          displayName: displayName,
          totalPoints: 0,
        );
        await _firestore!.collection('users').doc(cred.user!.uid).set(newUser.toMap());
        await _fetchUserDetails(cred.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _getTurkishError(e.code);
    }
  }

  String _getTurkishError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre. Lütfen tekrar deneyin.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Lütfen geçerli bir e-posta adresi giriniz.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı.';
      case 'operation-not-allowed':
        return 'E-posta/Şifre girişi devre dışı bırakılmış.';
      default:
        return 'Bir hata oluştu: $errorCode';
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    if (_isMock) return null; // Mock success
    
    try {
      await _auth!.currentUser?.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      // Re-authentication might be needed if login was long ago
      if (e.code == 'requires-recent-login') {
        return 'Güvenlik gereği yeniden giriş yapmalısınız.';
      }
      return _getTurkishError(e.code);
    } catch (e) {
      return 'Bir hata oluştu.';
    }
  }

  Future<void> signOut() async {
    if (_isMock) {
      _user = null;
      notifyListeners();
      return;
    }
    await _auth!.signOut();
  }
}
