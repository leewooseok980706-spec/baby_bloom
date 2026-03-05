import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get userStream => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
  
  String? get currentUid => _auth.currentUser?.uid;

  Future<void> signInAnonymously() async {
    try {
      // 이미 로그인된 경우 재사용
      if (_auth.currentUser != null) return;
      await _auth.signInAnonymously();
    } catch (e) {
      developer.log('Anonymous Sign In Failed', name: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      developer.log('Email Sign Up Failed', name: 'AuthService', error: e.code);
      throw _handleAuthException(e);
    } catch (e) {
      throw '알 수 없는 오류가 발생했습니다.';
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      developer.log('Email Sign In Failed', name: 'AuthService', error: e.code);
      throw _handleAuthException(e);
    } catch (e) {
      throw '알 수 없는 오류가 발생했습니다.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return '해당 이메일로 등록된 사용자를 찾을 수 없습니다.';
      case 'wrong-password':
        return '비밀번호가 틀렸습니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'weak-password':
        return '비밀번호가 너무 취약합니다.';
      default:
        return '인증 오류가 발생했습니다. 다시 시도해주세요. (${e.code})';
    }
  }
}
