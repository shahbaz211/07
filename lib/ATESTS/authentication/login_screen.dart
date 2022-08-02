import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../methods/auth_methods.dart';
import '../other/global_variables.dart';
import '../other/text_field.dart';
import '../other/utils.dart.dart';
import 'signup.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String email = _emailController.text;

    // Login with username
    if (!email.contains('@')) {
      var user = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: email)
          .get();
      if (user.docs.isNotEmpty) {
        email = user.docs.first.data()['email'];
      }
    }
    String res = await AuthMethods()
        .loginUser(email: email, password: _passwordController.text);

    if (res == "success") {
      goToHome(context);
    } else {
      showSnackBar(res, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  // void navigateToSignup() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => const VerifyOne(),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? const EdgeInsets.symmetric(horizontal: 200)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Center(
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.center,
              shrinkWrap: true,
              reverse: true,
              children: [
                Flexible(child: Container(), flex: 1),
                const SizedBox(height: 12),
                TextField(
                  textInputAction: TextInputAction.next,
                  controller: _emailController,
                  decoration: new InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    labelText: 'Username or Email',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    // labelText: 'Username',
                    fillColor: Color.fromARGB(255, 245, 245, 245),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.person_outlined,
                    ),
                  ),
                  //   Icon(
                  //     Icons.email_outlined,
                  //   ),
                  // ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    // labelText: 'Password',
                    // labelStyle: TextStyle(
                    //     color: Colors.grey, fontStyle: FontStyle.italic),
                    fillColor: Color.fromARGB(255, 245, 245, 245),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      // color: textfield3selected == false
                      //     ? Colors.grey
                      //     : Colors.blueGrey,
                    ),

                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                      child: Icon(
                        // Based on passwordVisible state choose the icon
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                        size: 22,
                      ),
                    ),
                  ),
                  obscureText: !_passwordVisible,
                ),
                const SizedBox(height: 24),
                // error1 == true ? Text('email not found') : Container(),
                // error2 == true ? Text('email invalid') : Container(),
                // error3 == true ? Text('wrong password') : Container(),
                // error4 == true ? Text('user disabled') : Container(),
                // error5 == true ? Text('too many attempts') : Container(),
                // error0 == true ? Text('empty text fields') : Container(),
                // error01 == true ? Text('empty email') : Container(),
                // error02 == true ? Text('empty password') : Container(),
                //button login
                InkWell(
                  onTap: loginUser,
                  child: Container(
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                height: 18,
                                width: 18),
                          )
                        : const Text('Log In',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5)),
                    width: double.infinity,
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
                const SizedBox(height: 12),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          // color: Colors.red,
                          border: Border(
                            top: BorderSide(
                                width: 1, color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ),
                      Container(width: 4),
                      Text('or',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                      Container(width: 4),
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          // color: Colors.red,
                          border: Border(
                            top: BorderSide(
                                width: 1, color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    goToHome(context);
                  },
                  child: Container(
                    child: const Text('Continue as a Guest',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5)),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                        color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    InkWell(
                      // onTap: navigateToSignup,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()),
                        );
                      },
                      child: Container(
                        // decoration: BoxDecoration(
                        //     color: Color.fromARGB(255, 250, 250, 250),
                        //     borderRadius: BorderRadius.circular(25),
                        //     border: Border.all(width: 0, color: Colors.grey)),
                        width: 160,
                        height: 45,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text("Don't have an account?",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ),
                            Container(height: 2),
                            Container(
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 96, 96, 96),
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
                      },
                      child: Container(
                        width: 160,
                        // decoration: BoxDecoration(
                        //     color: Color.fromARGB(255, 250, 250, 250),
                        //     borderRadius: BorderRadius.circular(25),
                        //     border: Border.all(width: 0, color: Colors.grey)),
                        // color: Colors.blue,
                        height: 45,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text("Forgot password?",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ),
                            Container(height: 2),
                            Container(
                              child: const Text(
                                "Click here",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 96, 96, 96),
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 2),
                // Column(
                //   children: [
                //     InkWell(
                //       onTap: () {
                //         // Navigator.of(context).push(
                //         //   MaterialPageRoute(
                //         //     builder: (context) => const ForgotPassword(),
                //         //   ),
                //         // );
                //       },
                //       child: Container(
                //         // decoration: BoxDecoration(
                //         //     borderRadius: BorderRadius.circular(25),
                //         //     border: Border.all(width: 0, color: Colors.grey)),
                //         // width: 30,
                //         // color: Colors.blue,
                //         height: 45,
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Container(
                //               child: Text("Forgot email or username?",
                //                   style: TextStyle(
                //                       color: Colors.grey, fontSize: 14)),
                //             ),
                //             Container(height: 2),
                //             Container(
                //               child: const Text(
                //                 "Contact us",
                //                 style: TextStyle(
                //                     fontWeight: FontWeight.bold,
                //                     color: Colors.black,
                //                     fontSize: 15),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ].reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }
}
