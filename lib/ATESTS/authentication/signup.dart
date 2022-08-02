import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../methods/auth_methods.dart';
import '../other/text_field.dart';
import '../other/utils.dart.dart';

import '../screens/filter_arrays.dart';

import 'login_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _countryController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  // bool textfield1selected = false;
  // bool textfield2selected = false;
  // bool textfield3selected = false;
  bool _passwordVisible = false;

  var country = 'us';
  String oneValue = '';
  String isFT = 'false';
  var countryIndex;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

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

  // // Validates "username" field
  // Future<String?> usernameValidator({required String? username}) async {
  //   // Validates username complexity
  //   bool isUsernameComplex(String? text) {
  //     final String _text = (text ?? "");
  //     // String? p = r"^(?=(.*[0-9]))(?=(.*[A-Za-z]))";
  //     String? p = r"^(?=(.*[ @$!%*?&=_+/#^.~`]))";
  //     RegExp regExp = RegExp(p);
  //     return regExp.hasMatch(_text);
  //   }

  //   final String _text = (username ?? "");

  //   // Complexity check
  //   if (isUsernameComplex(_text)) {
  //     return "Username should only be letters and numbers";
  //   }
  //   // Length check
  //   else if (_text.length < 3 || _text.length > 16) {
  //     return "Username should be 3-16 characters long";
  //   }

  //   // Availability check
  //   var val = await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('username', isEqualTo: _text)
  //       .get();
  //   if (val.docs.isNotEmpty) {
  //     return "This username is not available";
  //   }

  //   return null;
  // }

  void signUpUser() async {
    // Validates username
    String? userNameValid =
        await usernameValidator(username: _usernameController.text);
    if (userNameValid != null) {
      showSnackBar(userNameValid, context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,

      // file: _image!,
      profilePicFile: _image,
      country: country,
      isFT: isFT,
      bio: '',
    );

    if (res != "success") {
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          _isLoading = false;
        });
      });
      print('INSIDE res != "success"');
      showSnackBar(res, context);
    } else {
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => const VerifyComplete()));
      goToHome(context);
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  Widget build(BuildContext context) {
    var safePadding = MediaQuery.of(context).padding.top;
    var appBarPadding = AppBar().preferredSize.height;
    var countryIndex = long.indexOf(oneValue);
    if (countryIndex >= 0) {
      country = short[countryIndex];

      print(country);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   // title: Text('Back'),
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.white,
      //   actions: [
      //     // Container(
      //     //   width: MediaQuery.of(context).size.width * 1,
      //     //   child: Row(
      //     //     children: [
      //     //       IconButton(
      //     //         icon: Icon(Icons.keyboard_arrow_left, color: Colors.grey),
      //     //         onPressed: () {
      //     //           Navigator.of(context).pop();
      //     //         },
      //     //       ),
      //     //       Text(
      //     //         'Sign Up',
      //     //         // 'Step 3/3',
      //     //         style: TextStyle(
      //     //             color: Colors.grey,
      //     //             fontSize: 20,
      //     //             fontWeight: FontWeight.w500),
      //     //       ),
      //     //     ],
      //     //   ),
      //     // ),
      //   ],
      // ),
      body: Container(
        color: Colors.transparent,
        child: SafeArea(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 1,
            // height: double.infinity,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                // reverse: true,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(bottom: 40.0, top: 20),
                        //   child: Container(
                        //     child: Text(
                        //       'Almost done, sign up below!',
                        //       textAlign: TextAlign.center,
                        //       style: TextStyle(
                        //           fontSize: 18,
                        //           color: Color.fromARGB(255, 85, 85, 85),
                        //           fontWeight: FontWeight.w500),
                        //     ),
                        //   ),
                        // ),

                        // Flexible(child: Container(), flex: 1),
                        // Stack(
                        //   children: [
                        //     _image != null
                        //         ? CircleAvatar(
                        //             radius: 64,
                        //             backgroundImage: MemoryImage(_image!),
                        //             backgroundColor: Colors.white,
                        //           )
                        //         : CircleAvatar(
                        //             radius: 64,
                        //             // backgroundImage: NetworkImage(
                        //             //     'https://images.nightcafe.studio//assets/profile.png?tr=w-1600,c-at_max'),
                        //             backgroundColor: Colors.grey.shade200,

                        //             // backgroundImage: NetworkImage(
                        //             //   'https://images.nightcafe.studio//assets/profile.png?tr=w-1600,c-at_max',
                        //             // ),
                        //           ),
                        //     Positioned(
                        //       bottom: -10,
                        //       left: 80,
                        //       child: IconButton(
                        //         onPressed: selectImage,
                        //         icon: const Icon(
                        //           Icons.add_a_photo,
                        //         ),
                        //       ),
                        //     )
                        //   ],
                        // ),

                        Container(
                          // color: Colors.green,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                height: 24,
                              ),

                              // const SizedBox(height: 64),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 0.0),
                                    child: Container(
                                      // color: Colors.blue,
                                      height: 60,
                                      // width:
                                      //     MediaQuery.of(context).size.width * 1 -
                                      //         64,
                                      // height: 70,
                                      child: TextField(
                                        textInputAction: TextInputAction.next,
                                        controller: _usernameController,
                                        maxLength: 16,
                                        decoration: new InputDecoration(
                                            counterText: '',
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              borderSide: BorderSide(
                                                  color: Colors.blueGrey,
                                                  width: 2),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            // hintText: 'Username',
                                            labelText: 'Username',
                                            labelStyle: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                            hintStyle: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                            // labelText: 'Username',
                                            fillColor: Color.fromARGB(
                                                255, 245, 245, 245),
                                            filled: true,
                                            prefixIcon: Icon(
                                              Icons.person_outlined,
                                              // color: textfield1selected == false
                                              //     ? Colors.grey
                                              //     : Colors.blueGrey,
                                            )),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  TextField(
                                    textInputAction: TextInputAction.next,
                                    controller: _emailController,
                                    decoration: new InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          borderSide: BorderSide(
                                              color: Colors.blueGrey, width: 2),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                        // hintText: 'Email Address',
                                        labelText: 'Email Address',
                                        labelStyle: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                        hintStyle: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                        // labelText: 'Email Address',
                                        fillColor:
                                            Color.fromARGB(255, 245, 245, 245),
                                        filled: true,
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          // color: textfield2selected == false
                                          //     ? Colors.grey
                                          //     : Colors.blueGrey,
                                        )),
                                  ),
                                  const SizedBox(height: 24),
                                  // SizedBox(
                                  //   height: 48,
                                  //   child: FlatButton(
                                  //     onPressed: () {
                                  //       Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //             builder: (context) => RegisterCountries()),
                                  //       ).then((value) => {getValue()});
                                  //     },
                                  //     padding: EdgeInsets.only(left: 8.0),
                                  //     textColor: Colors.black,
                                  //     color: Color(0xFFEDEDED),
                                  //     shape: RoundedRectangleBorder(
                                  //         side: const BorderSide(
                                  //             color: Color(0XFFD0D0D0),
                                  //             width: 0.5,
                                  //             style: BorderStyle.solid),
                                  //         borderRadius: BorderRadius.circular(5)),
                                  //     child: country == "us"
                                  //         ? const Align(
                                  //             alignment: Alignment.centerLeft,
                                  //             child: Text("Select your Country",
                                  //                 textAlign: TextAlign.left,
                                  //                 style: TextStyle(
                                  //                   color: Color(0XFFA8A8A8),
                                  //                   fontSize: 16,
                                  //                   fontWeight: FontWeight.normal,
                                  //                   fontFamily: 'Roboto',
                                  //                 )),
                                  //           )
                                  //         : Align(
                                  //             alignment: Alignment.centerLeft,
                                  //             child: Text("$country",
                                  //                 textAlign: TextAlign.left,
                                  //                 style: TextStyle(
                                  //                   color: Colors.black,
                                  //                   fontSize: 16,
                                  //                   fontWeight: FontWeight.normal,
                                  //                   fontFamily: 'Roboto',
                                  //                 )),
                                  //           ),
                                  //   ),
                                  // ),

                                  // const SizedBox(height: 24),
                                  TextField(
                                    controller: _passwordController,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                      hintStyle: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                      // labelText: 'Password',
                                      // labelStyle: TextStyle(
                                      //     color: Colors.grey, fontStyle: FontStyle.italic),
                                      fillColor:
                                          Color.fromARGB(255, 245, 245, 245),
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
                                            _passwordVisible =
                                                !_passwordVisible;
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
                                ],
                              ),
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
                                          child: SizedBox(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                              height: 18,
                                              width: 18),
                                        )
                                      : const Text('Sign Up',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.5)),
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: const ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(25),
                                        ),
                                      ),
                                      color: Colors.blueGrey),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),

                        Container(
                          // color: Colors.orange,
                          // height: (MediaQuery.of(context).size.height -
                          //         395 -
                          //         safePadding -
                          //         appBarPadding) *
                          //     0.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: navigateToLogin,
                                child: Container(
                                  // width: 30,

                                  height: 45,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Text("Already have an account?",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14)),
                                      ),
                                      Container(
                                        child: const Text(
                                          "Log In",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromARGB(
                                                  255, 96, 96, 96),
                                              fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Column(
                        //   children: [
                        //     InkWell(
                        //       onTap: () {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) => const VerifyOne()),
                        //         );
                        //       },
                        //       child: Container(
                        //         // width: 30,
                        //         // color: Colors.blue,
                        //         height: 45,
                        //         child: Column(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             Container(
                        //               child: Text("EDIT",
                        //                   style: TextStyle(
                        //                       color: Colors.grey, fontSize: 14)),
                        //             ),
                        //             Container(
                        //               child: const Text(
                        //                 "LATER",
                        //                 style: TextStyle(
                        //                     fontWeight: FontWeight.w500,
                        //                     color: Color.fromARGB(255, 96, 96, 96),
                        //                     fontSize: 15),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // )
                      ]),
                ].reversed.toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  getValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      oneValue = prefs.getString('selected_radio') ?? '';

      var countryIndex = long.indexOf(oneValue);
      if (countryIndex >= 0) {
        country = short[countryIndex];

        print('abc');
        print(country);

        prefs.setString('cont', country);
      }
    });
  }
}
