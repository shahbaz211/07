import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../authentication/ALogin.dart';
import '../methods/AAuthMethods.dart';

class ProfileScreen extends StatefulWidget {
  // final String uid;
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () async {
          await AuthMethods().signOut();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
        child: Center(
          child: Container(
            child: Text('LOGOUT'),
          ),
        ),
      ),
    );
  }
}
