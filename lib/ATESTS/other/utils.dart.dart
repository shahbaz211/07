import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../authentication/login_screen.dart';
import '../authentication/signup.dart';
import '../camera/camera_screen.dart';
import '../methods/re_auth_methods.dart';
import '../models/user.dart';

import '../provider/user_provider.dart';

import '../responsive/AMobileScreenLayout.dart';
import '../responsive/AResponsiveLayout.dart';
import '../responsive/AWebScreenLayout.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source);

  if (_file != null) {
    return await _file.readAsBytes();
  }
  print("No image selected");
}

pickVideo(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickVideo(source: source);

  if (_file != null) {
    return File(_file.path);
  }
  print("No image selected");
}

showSnackBar(
  String content,
  BuildContext context,
) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        content,
        textAlign: TextAlign.center,
      ),
      width: MediaQuery.of(context).size.width * 0.85,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color.fromARGB(255, 104, 104, 104).withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      )));
}

void goToLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ),
    (route) => false,
  );
}

void goToSignup(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const SignupScreen(),
    ),
    (route) => false,
  );
}

void goToHome(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            )),
    (route) => false,
  );
}

Future<String?> usernameValidator({required String? username}) async {
  // Validates username complexity
  bool isUsernameComplex(String? text) {
    final String _text = (text ?? "");
    // String? p = r"^(?=(.*[0-9]))(?=(.*[A-Za-z]))";
    String? p = r"^(?=(.*[ @$!%*?&=_+/#^.~`]))";
    RegExp regExp = RegExp(p);
    return regExp.hasMatch(_text);
  }

  final String _text = (username ?? "");

  // Complexity check
  if (isUsernameComplex(_text)) {
    return "Username can only contain letters and numbers.";
  }
  // Length check
  else if (_text.length < 3 || _text.length > 16) {
    return "Username must be between 3-16 characters long.";
  }

  // Availability check
  var val = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: _text)
      .get();
  if (val.docs.isNotEmpty) {
    return "This username is already taken.";
  }

  return null;
}

// Returns screen size
Size getScreenSize({required BuildContext context}) {
  return MediaQuery.of(context).size;
}

Future<dynamic> openCamera({
  required BuildContext context,
  required CameraFileType cameraFileType,
  required add,
}) async {
  dynamic photo;
  try {
    final cameras = await availableCameras();
    print('cameras.length: ${cameras.length}');
    final firstCamera = cameras.first;
    CameraDescription? secondaryCamera;
    final addU = add;
    if (cameras.length > 1) {
      secondaryCamera = cameras[1];
    }

    List<File>? selectedImages = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<List<File>>(CupertinoPageRoute(builder: (BuildContext context) {
      return CameraScreen(
        camera: firstCamera,
        secondaryCamera: secondaryCamera,
        cameraFileType: cameraFileType,
        add: addU,
      );
    }));

    if (selectedImages?.isNotEmpty ?? false) {
      print(selectedImages?.first);
      photo = cameraFileType == CameraFileType.image
          ? selectedImages?.first.readAsBytesSync()
          : selectedImages?.first;
      // Navigator.pop(context, selectedImages?.first.readAsBytesSync());
    }
  } catch (e) {
    // showAlert(
    //   context: context,
    //   titleText: Localization.of(context).trans(LocalizationValues.error),
    //   message: '$e',
    //   actionCallbacks: {
    //     Localization.of(context).trans(LocalizationValues.ok): () {}
    //   },
    // );
  }
  return photo;
}

// Future<dynamic> openCameraOne({
//   required BuildContext context,
//   required CameraFileType cameraFileType,
//   required idk,
// }) async {
//   dynamic photo;
//   try {
//     final cameras = await availableCameras();
//     print('cameras.length: ${cameras.length}');
//     final firstCamera = cameras.first;
//     CameraDescription? secondaryCamera;
//     if (cameras.length > 1) {
//       secondaryCamera = cameras[1];
//     }

//     List<File>? selectedImages = await Navigator.of(
//       context,
//       rootNavigator: true,
//     ).push<List<File>>(CupertinoPageRoute(builder: (BuildContext context) {
//       return CameraScreenOne(
//         camera: firstCamera,
//         secondaryCamera: secondaryCamera,
//         cameraFileType: cameraFileType,
//         // idc: idk,
//       );
//     }));

//     if (selectedImages?.isNotEmpty ?? false) {
//       print(selectedImages?.first);
//       photo = cameraFileType == CameraFileType.image
//           ? selectedImages?.first.readAsBytesSync()
//           : selectedImages?.first;
//       // Navigator.pop(context, selectedImages?.first.readAsBytesSync());
//     }
//   } catch (e) {
//     // showAlert(
//     //   context: context,
//     //   titleText: Localization.of(context).trans(LocalizationValues.error),
//     //   message: '$e',
//     //   actionCallbacks: {
//     //     Localization.of(context).trans(LocalizationValues.ok): () {}
//     //   },
//     // );
//   }
//   return photo;
// }

// Checks whether user is logged in
performLoggedUserAction({
  required BuildContext context,
  required Function action,
}) {
  final User? user = Provider.of<UserProvider>(context, listen: false).getUser;
  if (user != null) {
    action();
  } else {
    showDialog(
        context: context,
        builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  // width: double.infinity,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.42,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  padding: EdgeInsets.fromLTRB(10, 45, 10, 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 14.0,
                        ),
                        child: Text('Action Failed',
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text('A registered account is required.',
                            style: TextStyle(
                              fontSize: 16,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            // color: Colors.red,
                            border: Border(
                                // top: BorderSide(
                                //     width: 1,
                                //     color: Color.fromARGB(255, 218, 216, 216)),
                                ),
                          ),
                          // child: Padding(
                          //   padding:
                          //       const EdgeInsets.only(top: 14.0, bottom: 14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () async {
                                  goToLogin(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.height *
                                      0.195,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blueGrey,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Login',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Container(width: 10),
                                      Icon(Icons.login,
                                          size: 22, color: Colors.white)
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50,
                                      decoration: BoxDecoration(
                                        // color: Colors.red,
                                        border: Border(
                                          top: BorderSide(
                                              width: 1,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)),
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
                                      width: 50,
                                      decoration: BoxDecoration(
                                        // color: Colors.red,
                                        border: Border(
                                          top: BorderSide(
                                              width: 1,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  goToSignup(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.height *
                                      0.195,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blueGrey,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Sign Up',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Container(width: 10),
                                      Icon(Icons.verified_user,
                                          size: 22, color: Colors.white)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: FittedBox(
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: Icon(
                          Icons.info,
                          size: 200,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )));
  }
}

performLoggedUserActionProfile({
  required BuildContext context,
  required Function action,
}) {
  final User? user = Provider.of<UserProvider>(context, listen: false).getUser;
  if (user != null) {
    action();
  } else {
    showDialog(
        context: context,
        builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  // width: double.infinity,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.42,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  padding: EdgeInsets.fromLTRB(10, 45, 10, 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 14.0,
                        ),
                        child: Text('Action Failed',
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text('A registered account is required.',
                            style: TextStyle(
                              fontSize: 16,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            // color: Colors.red,
                            border: Border(
                                // top: BorderSide(
                                //     width: 1,
                                //     color: Color.fromARGB(255, 218, 216, 216)),
                                ),
                          ),
                          // child: Padding(
                          //   padding:
                          //       const EdgeInsets.only(top: 14.0, bottom: 14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () async {
                                  goToLogin(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.height *
                                      0.195,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blueGrey,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Login',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Container(width: 10),
                                      Icon(Icons.login,
                                          size: 22, color: Colors.white)
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50,
                                      decoration: BoxDecoration(
                                        // color: Colors.red,
                                        border: Border(
                                          top: BorderSide(
                                              width: 1,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)),
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
                                      width: 50,
                                      decoration: BoxDecoration(
                                        // color: Colors.red,
                                        border: Border(
                                          top: BorderSide(
                                              width: 1,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  goToSignup(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.height *
                                      0.195,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blueGrey,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Sign Up',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Container(width: 10),
                                      Icon(Icons.verified_user,
                                          size: 22, color: Colors.white)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: FittedBox(
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: Icon(
                          Icons.info,
                          size: 200,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )));
  }
}

Future<bool> performReAuthenticationAction({
  required BuildContext context,
  required username,
}) async {
  bool? authenticated = false;
  final User? user = Provider.of<UserProvider>(context, listen: false).getUser;
  var idk = username;
  if (user != null) {
    authenticated = await showDialog<bool>(
      context: context,
      builder: (_) => ReAuthenticationDialog(username: idk),
    );
  }
  return authenticated ?? false;
}

String trimText({
  required String text,
}) {
  String trimmedText = text;
  // Removes all line breaks and end blank spaces
  trimmedText = trimmedText.replaceAll('\n', ' ').trim();

  // Removes all consecutive blank spaces
  while (trimmedText.contains('  ')) {
    trimmedText = trimmedText.replaceAll('  ', ' ');
  }

  return trimmedText;
}
