import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

import '../other/utils.dart.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            // title: Text('Back'),
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blueGrey,
            actions: [
              Container(
                width: MediaQuery.of(context).size.width * 1,
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.keyboard_arrow_left, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'User Credential Recovery',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              shrinkWrap: true,
              reverse: true,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: MediaQuery.of(context).size.width - 32,
                  decoration: BoxDecoration(
                    // color: Colors.red,
                    border: Border(
                      top: BorderSide(width: 0.5, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                    'To reset your password, you must first provide your email address.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.5,
                        color: Colors.grey)),
                const SizedBox(height: 12),
                Container(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    controller: emailController,
                    decoration: new InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              BorderSide(color: Colors.blueGrey, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        // labelText: 'Username',
                        fillColor: Color.fromARGB(255, 245, 245, 245),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          // color: textfield1selected == false
                          //     ? Colors.grey
                          //     : Colors.blueGrey,
                        )),
                    // ElevatedButton.icon(
                    //   onPressed: resetPassword,
                    //   icon: Icon(Icons.email_outlined),
                    //   label: Text('Reset Password'),
                    // )
                  ),
                ),

                // TextFormField(
                //   controller: emailController,
                //   textInputAction: TextInputAction.done,
                //   // autovalidateMode: AutovalidateMode.onUserInteraction,
                //   // validator: (email) => email != null && !EmailValidator.validate(email) ? 'Enter a valid Email' : null)
                // ),
                // ElevatedButton.icon(
                //   onPressed: resetPassword,
                //   icon: Icon(Icons.email_outlined),
                //   label: Text('Reset Password'),
                // )
                const SizedBox(height: 12),
                UnconstrainedBox(
                  child: InkWell(
                    onTap: resetPassword,
                    child: Container(
                      width: 170,
                      child: const Text('Reset Password',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )),
                      // width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25),
                            ),
                          ),
                          color: Colors.blueGrey),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Container(
                  width: MediaQuery.of(context).size.width - 32,
                  decoration: BoxDecoration(
                    // color: Colors.red,
                    border: Border(
                      top: BorderSide(width: 0.5, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Forgot your username or email address?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.5,
                        color: Colors.grey)),
                const SizedBox(height: 12),
                Text('Contact us at:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.5,
                        color: Colors.grey)),
                Text(
                  'Email@Gmail.com',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5,
                    color: Color.fromARGB(255, 96, 96, 96),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: MediaQuery.of(context).size.width - 32,
                  decoration: BoxDecoration(
                    // color: Colors.red,
                    border: Border(
                      top: BorderSide(width: 0.5, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ].reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }

  Future resetPassword() async {
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => Center(),
    // );
    String res = "Some error ocurred";
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      showSnackBar(
          'Reset password email sent, please verify your mailbox.', context);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'unknown' || e.code == 'invalid-email') {
        res = "Please enter a valid email address.";
      } else if (e.code == 'user-not-found') {
        res = "No registered user found under this email address.";
      }
      print(e);
      showSnackBar(res.toString(), context);
      // Navigator.of(context).pop();
    } catch (err) {
      // res = err.toString();
      // showSnackBar(res.toString(), context);
    }
    // return showSnackBar(res.toString(), context);
  }
}
