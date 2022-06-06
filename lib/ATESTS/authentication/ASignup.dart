import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../responsive/AMobileScreenLayout.dart';
import '../responsive/AResponsiveScreenLayout.dart';
import '../responsive/AWebScreenLayout.dart';
import '../other/ATextField.dart';
import '../methods/AAuthMethods.dart';
import '../other/AUtils.dart';
import 'ALogin.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  var country = 'us';

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    // _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      // bio: _bioController.text,
      file: _image!,
      country: country,
    );

    if (res != "success") {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MobileScreenLayout(),
        ),
      );
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
                mobileScreenLayout: MobileScreenLayout(),
                webScreenLayout: WebScreenLayout(),
              )),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32),
                width: double.infinity,
                child: ListView(
                    shrinkWrap: true,
                    reverse: true,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(child: Container(), flex: 1),

                      Stack(
                        children: [
                          _image != null
                              ? CircleAvatar(
                                  radius: 64,
                                  backgroundImage: MemoryImage(_image!),
                                )
                              : const CircleAvatar(
                                  radius: 64,
                                  backgroundImage: NetworkImage(
                                      'https://images.nightcafe.studio//assets/profile.png?tr=w-1600,c-at_max'),
                                ),
                          Positioned(
                            bottom: -10,
                            left: 80,
                            child: IconButton(
                              onPressed: selectImage,
                              icon: const Icon(
                                Icons.add_a_photo,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),

                      const SizedBox(height: 64),
                      TextFieldInputNext(
                        hintText: 'Enter your username',
                        textInputType: TextInputType.text,
                        textEditingController: _usernameController,
                      ),
                      const SizedBox(height: 24),
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
                      // TextFieldInputDone(
                      //   hintText: 'Enter your bio',
                      //   textInputType: TextInputType.text,
                      //   textEditingController: _bioController,
                      // ),
                      // const SizedBox(height: 24),

                      //signup button
                      InkWell(
                        onTap: signUpUser,
                        child: Container(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                )
                              : const Text('Sign Up'),
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
                            child: Text("Already have an account?"),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                          ),
                          GestureDetector(
                            onTap: navigateToLogin,
                            child: Container(
                              child: const Text(
                                " Log In",
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
                    ].reversed.toList()))));
  }
}
