import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) =>
    String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class FirebaseAppleAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signInWithApple({
    required Function(String uid, String appleId, String name, String email) onSuccess,
    required Function(String message) onError,
  }) async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user?.uid == null) {
        onError('User id is empty');
        return;
      }
      final randomUser = "user${getRandomString(5)}";
      onSuccess(
        userCredential.user!.uid,
        appleIdCredential.userIdentifier ?? "",
        appleIdCredential.givenName?.isEmpty == true ? randomUser : appleIdCredential.givenName ?? randomUser,
        appleIdCredential.email ?? "$randomUser@email.com",
      );
    } catch (error) {
      onError(error.toString());
    }
  }
}
