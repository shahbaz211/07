import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

import '../other/AUtils.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TextFormField(
              controller: emailController,
              textInputAction: TextInputAction.done,
              // autovalidateMode: AutovalidateMode.onUserInteraction,
              // validator: (email) => email != null && !EmailValidator.validate(email) ? 'Enter a valid Email' : null)
            ),
            ElevatedButton.icon(
              onPressed: resetPassword,
              icon: Icon(Icons.email_outlined),
              label: Text('Reset Password'),
            )
          ],
        ),
      ),
    );
  }

  Future resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      showSnackBar('Password Reset Email Sent', context);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      print(e);
      showSnackBar(e.toString(), context);
      Navigator.of(context).pop();
    }
  }
}
