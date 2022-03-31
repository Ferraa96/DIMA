import 'package:dima/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  MyUser? _myUser;

  void setUser(MyUser _myUser) {
    this._myUser = _myUser;
  }

  MyUser? getUser() {
    return _myUser;
  }

  String getUserId() {
    return auth.currentUser!.uid;
  }

  //create user object based on firebase User
  MyUser? _userFromFirebaseUser(User? user) {
    if (user != null) {
      MyUser myUser = MyUser();
      myUser.setUserId(user.uid);
      return myUser;
    } else {
      return null;
    }
  }

  //auth change user stream
  Stream<MyUser?> get user {
    return auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //sing in email + pass
  Future signInWithEmailAndPass(String email, String password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      _myUser = _userFromFirebaseUser(result.user);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  //sign in Google
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential result = await auth.signInWithCredential(credential);
      _myUser = _userFromFirebaseUser(result.user);
      return googleUser!.email;
    } catch (e) {
      print(e.toString());
      return '';
    }
  }

  //sign in Facebook
  Future signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);
      UserCredential result = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
      _myUser = _userFromFirebaseUser(result.user);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  //register email + pass
  Future registerWithEmailAndPass(String email, String password) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _myUser = _userFromFirebaseUser(result.user);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
