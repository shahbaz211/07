import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/AUser.dart' as model;
import 'AStorageMethods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool idk = true;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

//sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    // required String bio,
    required Uint8List file,
    required String country,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          file != null) {
        //register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        //add user to our database

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          country: country,
          // bio: '',
          // followers: [],
          // following: [],
        );

        await _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );
        res = "success";
      } else if (email.isEmpty || username.isEmpty || password.isEmpty) {
        res = "One or more text input fields are empty.";
      }
    }
    //IF YOU WANT TO PUT MORE DETAILS IN ERRORS
    on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email address is badly formatted.';
      } else if (err.code == 'email-already-in-use') {
        res = 'The email address is already in use by another account.';
      } else if (err.code == 'weak-password') {
        res = 'Password needs to be at least 6 characters long.';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> countryMessage(
      String uid, String userName, String country) async {
    try {
      await _firestore.collection('users').doc(uid).update(
        {'country': country},
      );
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  //logging in user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some error ocurred";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else if (email.isEmpty && password.isEmpty) {
        res = "Input fields cannot be blank.";
      } else if (email.isEmpty) {
        res = "Email input field cannot be blank.";
      } else if (password.isEmpty) {
        res = "Password input field cannot be blank.";
      }
    }

    //OTHER DETAILED ERRORS
    on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        res = "Too many login attempts, please try again later.";
      } else if (e.code == 'user-disabled') {
        res =
            "This account has been disabled. If you believe this was a mistake, please contact us at: email@gmail.com";
      } else if (e.code == 'user-not-found') {
        res = "No registered user found under this email address.";
      } else if (e.code == 'invalid-email') {
        res = "No registered user found under this email address.";
      } else if (e.code == 'wrong-password') {
        res = "Wrong password!";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
