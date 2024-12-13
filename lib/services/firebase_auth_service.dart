import 'package:adapt/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user.dart' as app;
import '../utils/app_routes.dart';
import '../utils/app_keys.dart';

class FirebaseAuthService {

  Future<app.User> getLoggedInUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    // Access the document by ID
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (document.exists) {
      return app.User(
        userId: user.uid,
        userCode: document.get('user_code'),
        displayName: document.get('display_name'),
        email: user.email!,
        createdDate: user.metadata.creationTime!,
        role: document.get('role'),
      );
    } else {
      throw FirebaseAuthException(code: 'user-data-not-found');
    }
  }

  void register(String displayName, String email, String password, String passwordConfirm) async {
    try {
      if (password != passwordConfirm) {
        throw FirebaseAuthException(code: 'password-not-match');
      }

      // Create user with email and password
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User user = credential.user!;

      // Transaction to add additional user data
      await FirebaseFirestore.instance.runTransaction((transaction) async {

        DocumentSnapshot variables = await FirebaseFirestore.instance
            .collection('global')
            .doc('variables')
            .get();

        int lastUserCode = variables.get('client_user_count');

        // Access the document by ID
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        //Check if document already exists (should not happen during sign-up)
        DocumentSnapshot userSnapshot = await transaction.get(userDocRef);

        if (userSnapshot.exists) {
          throw FirebaseException(
            plugin: 'fire-store',
            message: 'User data already exists.',
          );
        }

        transaction.set(userDocRef, {
          'display_name': displayName,
          'role': 'client',
          'user_code': lastUserCode + 1
        });

        //Update last user code back
        DocumentReference variablesDocRef = FirebaseFirestore.instance.collection('global').doc('variables');
        transaction.set(variablesDocRef, {
          'client_user_count': lastUserCode + 1
        });

        print('User data saved successfully');
      });

      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

      // Add a short delay to wait until the next page is built
      Future.delayed(const Duration(milliseconds: 1000), () {
        _showSnackBar(
            loginPageScaffold, 'Registration Successful. Please Login!');
      });
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            _showSnackBar(registerPageScaffold, 'Email is already in use!');
            break;
          case 'invalid-email':
            _showSnackBar(registerPageScaffold, 'Email is invalid!');
            break;
          case 'operation-not-allowed':
            _showSnackBar(registerPageScaffold, 'Email registration not allowed!');
            break;
          case 'weak-password':
            _showSnackBar(registerPageScaffold, 'Password is week!');
            break;
          case 'password-not-match':
            _showSnackBar(registerPageScaffold, 'Password does not match!');
            break;
          case 'network-request-failed':
            _showSnackBar(registerPageScaffold, 'Network connection failed!');
            break;
          default:
            _showSnackBar(loginPageScaffold, 'Registration unsuccessful!');
        }
        return;
      }

      print('Error occurred during registration: $e');

      // Delete the created user if any part fails
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
        print('User creation rolled back.');
      }

      _showSnackBar(registerPageScaffold, 'Registration error!');
    }
  }

  void login(String email, String password) async {
    try {
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      if (credential.user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      app.User user = await getLoggedInUser();

      if(user.role != 'client'){
        throw FirebaseAuthException(code: 'invalid-user-type');
      }

      mainNavigator.currentState!.pushReplacementNamed(Routes.routeMain);

      // Add a short delay to wait until the next page is built
      Future.delayed(const Duration(milliseconds: 1000), () {
        _showSnackBar(mainPageScaffold, 'Login successful');
      });

    } catch (e) {
      // Signs out the current user.
      await FirebaseAuth.instance.signOut();

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            _showSnackBar(loginPageScaffold, 'Email is invalid!');
            break;
          case 'invalid-user-type':
            _showSnackBar(loginPageScaffold, 'User type is invalid!');
            break;
          case 'user-disabled':
            _showSnackBar(loginPageScaffold, 'User is disabled!');
            break;
          case 'user-not-found':
            _showSnackBar(loginPageScaffold, 'User not exists!');
            break;
          case 'user-data-not-found':
            _showSnackBar(loginPageScaffold, 'User data not found!');
            break;
          case 'wrong-password':
            _showSnackBar(loginPageScaffold, 'Password is invalid!');
            break;
          case 'network-request-failed':
            _showSnackBar(loginPageScaffold, 'Network connection failed!');
            break;
          case 'invalid-credential':
            _showSnackBar(loginPageScaffold, 'Login credentials invalid!');
            break;
          case 'operation-not-allowed':
            _showSnackBar(loginPageScaffold, 'Email login not allowed!');
            break;
          default:
            _showSnackBar(loginPageScaffold, 'Login unsuccessful!');
        }
        return;
      }

      _showSnackBar(loginPageScaffold, 'Login error!');
    }
  }

  void logout() async {
    try {
      // Sign out the user from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // Navigate to the login page
      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

      // Add a short delay to wait until the next page is built
      Future.delayed(const Duration(milliseconds: 1000), () {
        _showSnackBar(loginPageScaffold, 'Log out successful');
      });
    } catch (e) {
      _showSnackBar(mainPageScaffold, 'Log out unsuccessful. Please try again!');
    }
  }

  //Show particular message
  void _showSnackBar(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    print(message);
    // Show a success message
    if (scaffold.currentState != null) {
      scaffold.currentState!.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.darkYellow),
      );
    }
  }
}
