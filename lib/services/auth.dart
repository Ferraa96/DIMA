import 'package:dima/models/shoppingList.dart';
import 'package:dima/models/user.dart';
import 'package:dima/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create user object based on firebase User
  MyUser? _userFromFirebaseUser(User? user) {
    return user != null ? MyUser(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<MyUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sing in email + pass
  Future signInWithEmailAndPass(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign in Google
  Future signInWithGoogle() async {
    try {
      print('1');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      print('4');
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign in Facebook
  Future signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);
      return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //register email + pass
  Future registerWithEmailAndPass(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      await DatabaseService(uid: user!.uid).updateUserData(ShoppingList());

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
