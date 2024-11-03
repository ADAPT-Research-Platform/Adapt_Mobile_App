import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService{

  Future<String?> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  Future<User?> signUp(String fName, String lName, String email, String password) async { //Register
    try{
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      return credential.user;
    }catch (e) {
      print("Sign Up Error");
    }
    return null;
  }

  Future<User?> signIn(String email, String password) async { //Login
    try{
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return credential.user;
    }catch (e) {
      print(e);
    }
    return null;
  }
}