import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String fName, String lName, String email, String password) async { //Register
    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }catch (e) {
      print("Sign Up Error");
    }
    return null;
  }

  Future<User?> signIn(String email, String password) async { //Login
    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }catch (e) {
      print(e);
    }
    return null;
  }
}