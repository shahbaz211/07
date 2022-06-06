import 'package:flutter/material.dart';
import '../other/AGlobalVariables.dart';
import 'ASignup.dart';
import '../responsive/AMobileScreenLayout.dart';
import '../responsive/AResponsiveScreenLayout.dart';
import '../responsive/AWebScreenLayout.dart';
import '../other/ATextField.dart';
import '../methods/AAuthMethods.dart';
import '../other/AUtils.dart';

//add image: 40 minutes in video (Rivaan IG clone) - 1:23 -- image_picker is downloaded

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);

    if (res == "success") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                )),
      );
    } else {
      showSnackBar(res, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                padding: MediaQuery.of(context).size.width > webScreenSize
                    ? const EdgeInsets.symmetric(horizontal: 200)
                    : const EdgeInsets.symmetric(horizontal: 32),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: Container(), flex: 1),
                    const SizedBox(height: 64),
                    TextFieldInputNext(
                      hintText: 'Enter your email',
                      textInputType: TextInputType.emailAddress,
                      textEditingController: _emailController,
                    ),
                    const SizedBox(height: 24),
                    TextFieldInputDone(
                        hintText: 'Enter your password',
                        textInputType: TextInputType.text,
                        textEditingController: _passwordController,
                        isPass: true),
                    const SizedBox(height: 24),

                    //button login
                    InkWell(
                      onTap: loginUser,
                      child: Container(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              )
                            : const Text('Log in'),
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Flexible(child: Container(), flex: 2),

                    //transitioning
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text("Don't have an account?"),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                        ),
                        GestureDetector(
                          onTap: navigateToSignup,
                          child: Container(
                            child: const Text(
                              " Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ))));
  }
}
