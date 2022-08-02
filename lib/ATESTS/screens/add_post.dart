import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as ytplayer;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:core';

import '../camera/camera_screen.dart';
import '../camera/preview.dart';
import '../methods/firestore_methods.dart';
import '../methods/storage_methods.dart';
import '../models/user.dart';
import '../other/utils.dart.dart';
import '../provider/user_provider.dart';
import 'filter_arrays.dart';
import 'full_image_add.dart';

// import '../models/user.dart';

// import '../providers/user_provider.dart';
// import '../resources/firestore_methods.dart';
// import '../resources/storage_methods.dart';
// import '../utils/utils.dart';

// import 'filter_screen_lists.dart';
// import 'full_image_add.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  late YoutubePlayerController controller;
  final TextEditingController _pollController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();

  List<TextEditingController>? _cont = [];

  final int _optionTextfieldMaxLength = 25;
  final int _pollQuestionTextfieldMaxLength = 300;
  final int _messageTitleTextfieldMaxLength = 600;

  bool _isVideoFile = false;
  bool done = false;
  File? _videoFile;
  bool _isLoading = false;
  var messages = 'true';
  var global = 'true';
  Uint8List? _file;
  var selected = 0;
  String? videoUrl = '';
  bool textfield1selected = false;
  bool textfield1selected2 = false;
  int i = 2;
  String proxyurl = 'abc';
  bool emptyTittle = false;
  bool emptyOptionOne = false;
  bool emptyOptionTwo = false;
  bool emptyPollQuestion = false;
  String country = '';
  String oneValue = '';
  User? user;
  var add = "true";

  late final KeyboardVisibilityController _keyboardVisibilityController;
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
    print('entered add post');

    _keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        _keyboardVisibilityController.onChange.listen((isVisible) {
      print('aaaa');
      print(_keyboardVisibilityController.isVisible);
      print('abc');

      if (!isVisible) {
        print('bbbb');

        setState(() {
          textfield1selected2 = false;
          textfield1selected = false;
        });

        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    getValueM();
    getValueG();
    controller = YoutubePlayerController(
      initialVideoId: '${videoUrl}',
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        desktopMode: false,
        privacyEnhanced: true,
        useHybridComposition: true,
      ),
    );
    controller.onEnterFullscreen = () {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      log('Entered Fullscreen');
    };
    controller.onExitFullscreen = () {
      log('Exited Fullscreen');
    };
  }

  _selectYoutube(BuildContext context) async {
    // bool greyHover = false;
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              // height: MediaQuery.of(context).size.height * 0.43,
              height: 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              padding: EdgeInsets.fromLTRB(10, 45, 10, 0),
              child: Column(
                children: [
                  SimpleDialogOption(
                    padding: const EdgeInsets.only(
                        top: 20, left: 5, right: 5, bottom: 2),
                    child: Text("Upload YouTube Video",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.transparent,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(offset: Offset(0, -5), color: Colors.black)
                          ],
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                        )),
                    onPressed: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 12.0, left: 12, top: 20, bottom: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 248, 248, 248),
                        // color: Color.fromARGB(255, 241, 239, 239),
                        border: Border.all(
                          width: 0,
                          color: Color.fromARGB(255, 133, 133, 133),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(25.0),
                        ),
                      ),
                      // decoration: BoxDecoration(
                      //   color: Color.fromARGB(255, 246, 245, 245),
                      //   // color: Color.fromARGB(255, 241, 239, 239),
                      //   border: Border.all(
                      //     width: 0.8,
                      //     color: Color.fromARGB(255, 226, 226, 226),
                      //   ),
                      //   borderRadius: BorderRadius.all(
                      //     Radius.circular(15.0),
                      //   ),
                      // ),
                      child: TextField(
                        // textAlign: TextAlign.center,

                        onChanged: (t) {
                          videoUrl = ytplayer.YoutubePlayer.convertUrlToId(
                              _videoUrlController.text)!;
                          print('this is the video id:');
                          print(videoUrl);

                          setState(() {
                            videoUrl;
                          });

                          if (videoUrl != null) {
                            print('video id not null');

                            setState(() {
                              controller = YoutubePlayerController(
                                initialVideoId: '${videoUrl}',
                                params: const YoutubePlayerParams(
                                  showControls: true,
                                  showFullscreenButton: true,
                                  desktopMode: false,
                                  privacyEnhanced: true,
                                  useHybridComposition: true,
                                ),
                              );
                            });
                          }
                        },
                        onSubmitted: (t) {
                          if (_videoUrlController.text.length == 0) {
                            setState(() {
                              selected = 0;
                            });
                          } else {
                            print(videoUrl);
                          }
                        },
                        controller: _videoUrlController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          hintText: "Paste YouTube URL",
                          prefixIcon:
                              Icon(Icons.link, size: 16, color: Colors.grey),
                          prefixIconColor: Color.fromARGB(255, 136, 136, 136),

                          contentPadding:
                              const EdgeInsets.only(left: 16, top: 14),

                          border: InputBorder.none,
                          // fillColor: Colors.grey,
                          // filled: true,
                          // counterText: '',
                        ),
                        style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Container(
                      color: Colors.white,
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          child: Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.format_clear,
                                    color: Color.fromARGB(255, 139, 139, 139),
                                  ),
                                  Container(width: 8),
                                  Text('Clear URL',
                                      style: TextStyle(
                                          letterSpacing: 0.2, fontSize: 15)),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              clearVideoUrl();
                              // greyHover = !greyHover;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          _videoUrlController.text.length == 0
                              ? setState(() {
                                  selected = 0;
                                  //  clearVideoUrl();
                                  clearVideoUrl();
                                })
                              : print(selected);
                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.of(context).pop();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check,
                                color: Color.fromARGB(255, 139, 139, 139),
                              ),
                              Container(width: 8),
                              Text('Done',
                                  style: TextStyle(
                                      letterSpacing: 0.2, fontSize: 15)),
                            ],
                          ),
                        ),
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
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 139, 139, 139),
                  radius: 43.5,
                  child: FittedBox(
                    child: Icon(
                      Icons.ondemand_video,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ).then((value) => _videoUrlController.text.length == 0 || videoUrl == null
        ? setState(() {
            selected = 0;
          })
        : print('not null'));
  }

  _selectVideo(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              // height: MediaQuery.of(context).size.height * 0.43,
              height: 290,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              padding: EdgeInsets.fromLTRB(10, 45, 10, 0),
              child: Column(
                children: [
                  SimpleDialogOption(
                    padding: const EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 5),
                    child: Text("Upload Video",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.transparent,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(offset: Offset(0, -5), color: Colors.black)
                          ],
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                        )),
                    onPressed: () {},
                  ),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () async {
                          var file = await openCamera(
                            context: context,
                            cameraFileType: CameraFileType.video,
                            add: add,
                          );
                          print(file);
                          if (file != null) {
                            setState(() {
                              _file = (file as File).readAsBytesSync();
                              _videoFile = (file as File);
                              _isVideoFile = true;
                            });
                          }
                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.of(context).pop();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Color.fromARGB(255, 139, 139, 139),
                              ),
                              Container(width: 8),
                              Text('Open camera',
                                  style: TextStyle(
                                      letterSpacing: 0.2, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () async {
                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.of(context).pop();
                          });
                          File file = await pickVideo(
                            ImageSource.gallery,
                          );
                          setState(() {
                            _file = (file as File).readAsBytesSync();
                            _videoFile = (file as File);
                            _isVideoFile = true;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.collections,
                                color: Color.fromARGB(255, 139, 139, 139),
                              ),
                              Container(width: 8),
                              Text('Choose from gallery',
                                  style: TextStyle(
                                      letterSpacing: 0.2, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          _file == null
                              ? setState(() {
                                  selected = 0;
                                })
                              : null;

                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.of(context).pop();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.cancel,
                                color: Color.fromARGB(255, 139, 139, 139),
                              ),
                              Container(width: 8),
                              Text('Cancel',
                                  style: TextStyle(
                                      letterSpacing: 0.2, fontSize: 15)),
                            ],
                          ),
                        ),
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
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 139, 139, 139),
                  radius: 43.5,
                  child: FittedBox(
                    child: Icon(
                      Icons.video_library,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ).then((value) => _file == null
        ? setState(() {
            selected = 0;
          })
        : print('not null'));
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              // height: MediaQuery.of(context).size.height * 0.43,
              height: 290,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              padding: EdgeInsets.fromLTRB(10, 45, 10, 0),
              child: Column(
                children: [
                  SimpleDialogOption(
                    padding: const EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 5),
                    child: Text("Upload Image",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.transparent,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(offset: Offset(0, -5), color: Colors.black)
                          ],
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                        )),
                    onPressed: () {},
                  ),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () async {
                          Uint8List? file = await openCamera(
                            context: context,
                            cameraFileType: CameraFileType.image,
                            add: add,
                          );
                          // Uint8List file = await pickImage(
                          //   ImageSource.camera,
                          // );
                          // setState(() {
                          //   _file = file;
                          // });
                          // Uint8List? file = await openCamera(context: context);
                          // Uint8List file = await pickImage(
                          //   ImageSource.camera,
                          // );
                          print(file);
                          if (file != null) {
                            setState(() {
                              _file = file;
                              _isVideoFile = false;
                            });
                          }
                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.of(context).pop();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Color.fromARGB(255, 139, 139, 139),
                              ),
                              Container(width: 8),
                              Text('Open camera',
                                  style: TextStyle(
                                      letterSpacing: 0.2, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () async {
                          Uint8List file = await pickImage(
                            ImageSource.gallery,
                          );
                          setState(() {
                            _file = file;
                            _isVideoFile = false;
                          });
                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.of(context).pop();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.collections,
                                color: Color.fromARGB(255, 139, 139, 139),
                              ),
                              Container(width: 8),
                              Text('Choose from gallery',
                                  style: TextStyle(
                                      letterSpacing: 0.2, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 60,
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          print(selected);
                          _file == null
                              ? setState(() {
                                  selected = 0;
                                })
                              : null;
                          print(selected);
                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.of(context).pop();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.cancel,
                                color: Color.fromARGB(255, 139, 139, 139),
                              ),
                              Container(width: 8),
                              Text('Cancel',
                                  style: TextStyle(
                                      letterSpacing: 0.2, fontSize: 15)),
                            ],
                          ),
                        ),
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
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 139, 139, 139),
                  radius: 43.5,
                  child: FittedBox(
                    child: Icon(
                      Icons.collections,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ).then((value) => _file == null
        ? setState(() {
            selected = 0;
          })
        : print('not null'));
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  void clearVideoUrl() {
    setState(() {
      _videoUrlController.clear();
    });
  }

  Future<void> getValueG() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio3') != null) {
      setState(() {
        global = prefs.getString('selected_radio3')!;
      });
    }
  }

  Future<void> setValueG(String valueg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      global = valueg.toString();
      prefs.setString('selected_radio3', global);
    });
  }

  Future<void> getValueM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio4') != null) {
      setState(() {
        messages = prefs.getString('selected_radio4')!;
      });
    }

    setState(() {
      oneValue = prefs.getString('selected_radio') ?? '';

      var countryIndex = long.indexOf(oneValue);
      if (countryIndex >= 0) {
        // country = short[countryIndex];

        // country = user.country

        print('abc');
        print(country);

        prefs.setString('cont', country);
      }
    });
  }

  Future<void> setValueM(String valuem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      messages = valuem.toString();
      prefs.setString('selected_radio4', messages);
    });
  }

  //
  //MESSAGE
  //
  void postImage(
    String uid,
    String username,
    String profImage,
    String mCountry,
  ) async {
    try {
      if (selected == 3) {
        if (_videoUrlController.text.length == 0) {
          setState(() {
            selected = 0;
          });
        }
      }
      emptyTittle = _titleController.text.trim().isEmpty;
      setState(() {});
      // if (_titleController.text.length != 0) {
      //   setState(() {
      //     emptyTittle = false;
      //   });
      // setState(() {
      //   _isLoading = true;
      // });
      if (!emptyTittle) {
        String photoUrl = "";
        if (_file == null) {
          photoUrl = "";
        } else {
          photoUrl = await StorageMethods()
              .uploadImageToStorage('posts', _file!, true);
        }

        // String videoUrl = "";
        // if (_videoFile == null) {
        //   videoUrl = "";
        // } else {
        //   videoUrl = await StorageMethods()
        //       .uploadImageToStorage('posts', _file!, true);
        // }

        if (country == '') {
          country = user!.country;
        } else {}

        String res = await FirestoreMethods().uploadPost(
          uid,
          username,
          profImage,
          country,
          global,
          _titleController.text,
          _bodyController.text,
          videoUrl!,
          //proxyurl,
          photoUrl,
          selected,
        );
        if (res == "success") {
          setState(() {
            _isLoading = false;
          });
          showSnackBar('Posted!', context);
          // Navigator.of(context).pop();
          // clearImage();
        } else {
          // setState(() {
          //   _isLoading = true;
          // });
          showSnackBar(res, context);
        }
        // } else {
        //   setState(() {
        //     emptyTittle = true;
        //   });
        // }
        // Navigator.pop(context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

//
//POLL
//
  void postImagePoll(
      String uid, String username, String profImage, String mCountry) async {
    try {
      // Validates poll question text field
      emptyPollQuestion = _pollController.text.trim().isEmpty;

      // Validates Poll Option 1 and 2 text fields
      emptyOptionOne = _cont![0].text.trim().isEmpty;
      emptyOptionTwo = _cont![1].text.trim().isEmpty;

      setState(() {});

      // If Poll question and Poll option 1 and 2 are not empty the post poll
      if (!emptyPollQuestion && !emptyOptionOne && !emptyOptionTwo) {
        if (country == '') {
          country = user!.country;
        }

        String res = await FirestoreMethods().uploadPoll(
          uid,
          username,
          profImage,
          country,
          global,
          _pollController.text.trim(),
          _cont?[0].text.trim() ?? '',
          _cont?[1].text.trim() ?? '',
          _cont?[2].text.trim() ?? '',
          _cont?[3].text.trim() ?? '',
          _cont?[4].text.trim() ?? '',
          _cont?[5].text.trim() ?? '',
          _cont?[6].text.trim() ?? '',
          _cont?[7].text.trim() ?? '',
          _cont?[8].text.trim() ?? '',
          _cont?[9].text.trim() ?? '',
        );
        if (res == "success") {
          setState(() {
            _isLoading = false;
          });
          showSnackBar('Posted!', context);
          // Navigator.of(context).pop();
        } else {
          // setState(() {
          //   _isLoading = true;
          // });
          showSnackBar(res, context);
        }
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    controller.close();
    _titleController.dispose;
    _bodyController.dispose;
    _videoUrlController.dispose;
  }

  @override
  Widget build(BuildContext context) {
    const player = YoutubePlayerIFrame();
    user = Provider.of<UserProvider>(context).getUser;
    print(messages);

    // if (messages == 'true') {
    return WillPopScope(
      onWillPop: () async {
        print('ENTERED ON WILLPOP');
        if (textfield1selected == true || textfield1selected2 == true) {
          setState(() {
            textfield1selected = false;
            textfield1selected2 = false;
          });
        }
        return false;
      },
      child: YoutubePlayerControllerProvider(
        controller: controller,
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 245, 245, 245),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            toolbarHeight: 65,
            backgroundColor: Color.fromARGB(255, 245, 245, 245),
            actions: [
              Container(
                width: MediaQuery.of(context).size.width * 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: [
                          global == 'true'
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 1.0),
                                  child: Text(
                                    'Global',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                )
                              : Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 1.0),
                                      child: Text(
                                        'National',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 1.0),
                                      child: user != null
                                          ? Container(
                                              width: 24,
                                              height: 14,
                                              child: Image.asset(
                                                  'icons/flags/png/${user?.country}.png',
                                                  package: 'country_icons'),
                                            )
                                          : Container(),
                                    ),
                                  ],
                                ),
                          AnimatedToggleSwitch<String>.rollingByHeight(
                              height: 32,
                              current: global,
                              values: const [
                                'true',
                                'false',
                              ],
                              onChanged: (valueg) =>
                                  setValueG(valueg.toString()),
                              iconBuilder: rollingIconBuilderStringThree,
                              borderRadius: BorderRadius.circular(25.0),
                              borderWidth: 0,
                              indicatorSize: const Size.square(1.8),
                              innerColor: Color.fromARGB(255, 228, 228, 228),
                              indicatorColor:
                                  Color.fromARGB(255, 157, 157, 157),
                              borderColor: Color.fromARGB(255, 135, 135, 135),
                              iconOpacity: 1),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 1.0),
                            child: Text(
                              messages == 'true' ? 'Messages' : 'Polls',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          AnimatedToggleSwitch<String>.rollingByHeight(
                              height: 32,
                              current: messages,
                              values: const [
                                'true',
                                'false',
                              ],
                              onChanged: (valuem) =>
                                  setValueM(valuem.toString()),
                              iconBuilder: rollingIconBuilderStringTwo,
                              borderRadius: BorderRadius.circular(25.0),
                              borderWidth: 0,
                              indicatorSize: const Size.square(1.8),
                              innerColor: Color.fromARGB(255, 228, 228, 228),
                              indicatorColor:
                                  Color.fromARGB(255, 157, 157, 157),
                              borderColor: Color.fromARGB(255, 135, 135, 135),
                              iconOpacity: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: messages == 'true'
              ? SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _isLoading
                          ? const LinearProgressIndicator()
                          : const Padding(padding: EdgeInsets.only(top: 0)),
                      // const Divider(),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.92,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Color.fromARGB(255, 219, 219, 219),
                              width: 1.5),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Column(
                          children: [
                            emptyTittle == true
                                ? Column(
                                    children: [
                                      Container(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error,
                                              size: 16,
                                              color: Color.fromARGB(
                                                  255, 220, 105, 96)),
                                          Container(width: 4),
                                          Text('Message title cannot be blank.',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 220, 105, 96))),
                                        ],
                                      ),
                                      Container(height: 4),
                                    ],
                                  )
                                : Container(),
                            emptyTittle ? Container() : Container(height: 10),
                            // Card(
                            //   elevation: textfield1selected == false ? 3 : 0,
                            Stack(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  decoration: BoxDecoration(
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Color.fromARGB(255, 176, 176, 176),
                                    //     blurRadius: 2,
                                    //     offset: Offset(2, 4), // Shadow position
                                    //   ),
                                    // ],
                                    color: Color.fromARGB(255, 248, 248, 248),
                                    border: Border.all(
                                        color: textfield1selected == false
                                            ? Colors.grey
                                            : Colors.blueAccent,
                                        width: textfield1selected != false
                                            ? 1.5
                                            : 0.5),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  child: WillPopScope(
                                    onWillPop: () async {
                                      print('POP');
                                      return false;
                                    },
                                    child: TextField(
                                      minLines: 3,
                                      maxLength:
                                          _messageTitleTextfieldMaxLength,
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                      onEditingComplete: () {
                                        print('complete');
                                      },
                                      onTap: () {
                                        setState(() {
                                          textfield1selected = true;
                                          textfield1selected2 = false;
                                        });
                                      },
                                      onSubmitted: (t) {
                                        setState(() {
                                          textfield1selected = false;
                                          textfield1selected2 = false;
                                        });
                                      },
                                      controller: _titleController,
                                      decoration: InputDecoration(
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 15.0),
                                          child: Icon(Icons.create,
                                              color: textfield1selected == false
                                                  ? Colors.grey
                                                  : Colors.blueAccent),
                                        ),
                                        hintText: "Message title ...",
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            top: 10,
                                            right: 6,
                                            left: 10,
                                            bottom: 10),
                                        hintStyle: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                            fontSize: 15),
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        // fillColor: Colors.white,
                                        // filled: true,
                                        counterText: '',
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 6,
                                  child: Text(
                                    '${_titleController.text.length}/$_messageTitleTextfieldMaxLength',
                                    style: const TextStyle(
                                      // fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // ),
                            Container(height: 10),
                            // Card(
                            //   elevation: textfield1selected2 == false ? 3 : 0,
                            Stack(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 248, 248, 248),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    border: Border.all(
                                        color: textfield1selected2 == false
                                            ? Colors.grey
                                            : Colors.blueAccent,
                                        width: textfield1selected2 != false
                                            ? 1.5
                                            : 0.5),
                                  ),
                                  child: TextField(
                                    minLines: 3,
                                    onTap: () {
                                      setState(() {
                                        textfield1selected = false;
                                        textfield1selected2 = true;
                                      });
                                    },
                                    onSubmitted: (t) {
                                      setState(() {
                                        textfield1selected = false;
                                        textfield1selected2 = false;
                                      });
                                    },
                                    controller: _bodyController,
                                    decoration: InputDecoration(
                                      suffixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15.0),
                                        child: Icon(Icons.create,
                                            color: textfield1selected2 == false
                                                ? Colors.grey
                                                : Colors.blueAccent),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          top: 10.0,
                                          left: 10,
                                          right: 10,
                                          bottom: 10),
                                      hintText: "Additional text (optional)",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                          fontSize: 15),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      // fillColor: Colors.white,
                                      // filled: true,
                                      counterText: '',
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 3,
                                  child: Text(
                                    'unlimited',
                                    style: const TextStyle(
                                      // fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // ),
                            Container(height: 10),
                            Column(
                              children: [
                                // Container(
                                //   // width: MediaQuery.of(context).size.width * 0.8,
                                //   alignment: Alignment.center,
                                //   child: Text('Select one:',
                                //       style: TextStyle(
                                //         fontSize: 15,
                                //         letterSpacing: 0.6,
                                //       )),
                                // ),
                                // SizedBox(height: 4),
                                // Card(
                                //   elevation: 3,
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 248, 248, 248),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _icon(0, icon: Icons.do_not_disturb),
                                      _icon(1, icon: Icons.collections),
                                      _icon(2, icon: Icons.video_library),
                                      _icon(3, icon: Icons.ondemand_video),
                                    ],
                                  ),
                                ),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            _file != null
                                ? Column(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.85,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          _isVideoFile &&
                                                                  _videoFile !=
                                                                      null
                                                              ? PreviewPictureScreen(
                                                                  previewOnly:
                                                                      true,
                                                                  filePath:
                                                                      _videoFile!
                                                                          .path,
                                                                  cameraFileType:
                                                                      CameraFileType
                                                                          .video,
                                                                  add: add,
                                                                )
                                                              : FullImageScreenAdd(
                                                                  file: MemoryImage(
                                                                      _file!),
                                                                )),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 248, 248, 248),
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                ),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.35,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,

                                                // child: AspectRatio(
                                                //   aspectRatio: 487 / 451,

                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child:
                                                      _isVideoFile &&
                                                              _videoFile != null
                                                          ? FutureBuilder(
                                                              future:
                                                                  _getVideoThumbnail(
                                                                file:
                                                                    _videoFile!,
                                                              ),
                                                              builder: (BuildContext
                                                                      context,
                                                                  AsyncSnapshot<
                                                                          File>
                                                                      snapshot) {
                                                                switch (snapshot
                                                                    .connectionState) {
                                                                  case ConnectionState
                                                                      .none:
                                                                    print(
                                                                        'ConnectionState.none');
                                                                    break;
                                                                  case ConnectionState
                                                                      .waiting:
                                                                    return const Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    );
                                                                    break;
                                                                  case ConnectionState
                                                                      .active:
                                                                    print(
                                                                        'ConnectionState.active');
                                                                    break;
                                                                  case ConnectionState
                                                                      .done:
                                                                    print(
                                                                        'ConnectionState.done');
                                                                    break;
                                                                }

                                                                return snapshot
                                                                            .data !=
                                                                        null
                                                                    ? Stack(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        children: [
                                                                          Image.file(
                                                                              snapshot.data!),
                                                                          const Center(
                                                                            child:
                                                                                Icon(
                                                                              Icons.play_circle_outline,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : const Center(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                      );
                                                              },
                                                            )
                                                          : Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image:
                                                                      MemoryImage(
                                                                          _file!),
                                                                  fit: BoxFit
                                                                      .contain,
                                                                  // alignment: FractionalOffset.topCenter,
                                                                ),
                                                              ),
                                                            ),
                                                ),
                                                // ),
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    _isVideoFile
                                                        ? _selectVideo(context)
                                                        : _selectImage(context);
                                                  },
                                                  icon: const Icon(
                                                      Icons.change_circle,
                                                      color: Colors.grey),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    clearImage();
                                                    selected = 0;
                                                  },
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(height: 10),
                                    ],
                                  )
                                : _videoUrlController.text.isEmpty
                                    ? Container()
                                    : LayoutBuilder(
                                        builder: (context, constraints) {
                                          if (kIsWeb &&
                                              constraints.maxWidth > 800) {
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(child: player),
                                                const SizedBox(
                                                  width: 500,
                                                ),
                                              ],
                                            );
                                          }
                                          return Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Container(
                                                    width: 250,
                                                    child: Stack(
                                                      children: [
                                                        player,
                                                        Positioned.fill(
                                                          child:
                                                              YoutubeValueBuilder(
                                                            controller:
                                                                controller,
                                                            builder: (context,
                                                                value) {
                                                              return AnimatedCrossFade(
                                                                crossFadeState: value.isReady
                                                                    ? CrossFadeState
                                                                        .showSecond
                                                                    : CrossFadeState
                                                                        .showFirst,
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                secondChild: Container(
                                                                    child: const SizedBox
                                                                        .shrink()),
                                                                firstChild:
                                                                    Material(
                                                                  child:
                                                                      DecoratedBox(
                                                                    child:
                                                                        const Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            NetworkImage(
                                                                          YoutubePlayerController
                                                                              .getThumbnail(
                                                                            videoId:
                                                                                controller.initialVideoId,
                                                                            quality:
                                                                                ThumbnailQuality.medium,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        _selectYoutube(context);
                                                      },
                                                      icon: const Icon(
                                                          Icons.change_circle,
                                                          color: Colors.grey),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        clearVideoUrl();
                                                        setState(() {
                                                          selected = 0;
                                                        });
                                                      },
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                            _videoUrlController.text.isEmpty
                                ? Container(height: 0)
                                : Container(height: 10)
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            PhysicalModel(
                              color: _titleController.text.length != 0
                                  ? Colors.blueAccent
                                  : Colors.blueAccent.withOpacity(0.45),
                              shadowColor: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                              child: InkWell(
                                onTap: () async {
                                  performLoggedUserAction(
                                      context: context,
                                      action: () {
                                        postImage(
                                          user?.uid ?? '',
                                          user?.username ?? '',
                                          user?.photoUrl ?? '',
                                          user?.country ?? '',
                                        );
                                      });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  width: 260,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 14.0),
                                        child: Icon(
                                          Icons.send,
                                          color:
                                              _titleController.text.length != 0
                                                  ? Colors.white
                                                  : Color.fromARGB(
                                                      255, 245, 245, 245),
                                        ),
                                      ),
                                      global == 'true'
                                          ? SizedBox(
                                              width: 16,
                                            )
                                          : SizedBox(
                                              width: 8,
                                            ),
                                      global == 'true' &&
                                              _titleController.text.length != 0
                                          ? Expanded(
                                              child: const Text(
                                                'Send Message Globally',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.25,
                                                    letterSpacing: 1.2),
                                              ),
                                            )
                                          : global == 'false' &&
                                                  _titleController
                                                          .text.length !=
                                                      0
                                              ? Expanded(
                                                  child: const Text(
                                                    'Send Message Nationally',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                        letterSpacing: 1),
                                                  ),
                                                )
                                              : global == 'true'
                                                  ? Expanded(
                                                      child: const Text(
                                                        'Send Message Globally',
                                                        style: TextStyle(
                                                            color: Color
                                                                .fromARGB(
                                                                    255,
                                                                    245,
                                                                    245,
                                                                    245),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                            letterSpacing: 1),
                                                      ),
                                                    )
                                                  : Expanded(
                                                      child: const Text(
                                                        'Send Message Nationally',
                                                        style: TextStyle(
                                                            color: Color
                                                                .fromARGB(
                                                                    255,
                                                                    245,
                                                                    245,
                                                                    245),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15.25,
                                                            letterSpacing: 1.2),
                                                      ),
                                                    ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Container(
                    // minHeight: 500,
                    width: MediaQuery.of(context).size.width * 1,
                    child: Column(
                      children: [
                        _isLoading
                            ? const LinearProgressIndicator()
                            : const Padding(padding: EdgeInsets.only(top: 0)),
                        // const Divider(),
                        SizedBox(
                          height: 8,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.92,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Color.fromARGB(255, 219, 219, 219),
                                    width: 1.5),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  emptyPollQuestion == true
                                      ? Column(
                                          children: [
                                            Container(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.error,
                                                    size: 16,
                                                    color: Color.fromARGB(
                                                        255, 220, 105, 96)),
                                                Container(width: 4),
                                                Text(
                                                  'Poll question cannot be blank.',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 220, 105, 96),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  Padding(
                                    padding: emptyPollQuestion == true
                                        ? const EdgeInsets.only(
                                            bottom: 20.0, top: 8)
                                        : const EdgeInsets.only(
                                            bottom: 20.0, top: 20),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.81,
                                      // color: Colors.orange,

                                      child: WillPopScope(
                                        onWillPop: () async {
                                          print('POP');
                                          return false;
                                        },
                                        child: Stack(
                                          children: [
                                            TextField(
                                              //168 is really the max but 170 should be okay
                                              maxLength:
                                                  _pollQuestionTextfieldMaxLength,
                                              onChanged: (val) {
                                                // setState(() {});
                                                setState(() {
                                                  // emptyPollQuestion = false;
                                                });
                                              },
                                              controller: _pollController,

                                              decoration: InputDecoration(
                                                hintText: "Poll question ...",
                                                // border: InputBorder.none,
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blueAccent,
                                                      width: 2),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                    top: 0,
                                                    left: 4,
                                                    right: 45,
                                                    bottom: 8),
                                                isDense: true,

                                                hintStyle: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                                labelStyle: TextStyle(
                                                    color: Colors.black),
                                                // fillColor: Colors.white,
                                                // filled: true,
                                                counterText: '',
                                              ),
                                              maxLines: null,
                                            ),
                                            Positioned(
                                              bottom: 5,
                                              right: 0,
                                              child: Text(
                                                '${_pollController.text.length}/$_pollQuestionTextfieldMaxLength',
                                                style: const TextStyle(
                                                  // fontStyle: FontStyle.italic,
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      children: [
                                        emptyOptionOne || emptyOptionTwo
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.error,
                                                        size: 16,
                                                        color: Color.fromARGB(
                                                            255, 220, 105, 96)),
                                                    Container(width: 6),
                                                    Text(
                                                        'First two poll options cannot be blank.',
                                                        style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    220,
                                                                    105,
                                                                    96))),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: i,
                                            itemBuilder: (context, index) {
                                              _cont!
                                                  .add(TextEditingController());
                                              int ic = index + 1;
                                              return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    right: 10,
                                                    left: 10,
                                                    top: 6,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      TextField(
                                                        maxLength:
                                                            _optionTextfieldMaxLength,
                                                        onChanged: (val) {
                                                          setState(() {});
                                                          // setState(() {
                                                          //   emptyOptionOne ==
                                                          //           true
                                                          //       ? emptyOptionOne =
                                                          //           false
                                                          //       : null;
                                                          //   emptyOptionTwo ==
                                                          //           true
                                                          //       ? emptyOptionTwo =
                                                          //           false
                                                          //       : null;
                                                          // });
                                                        },
                                                        controller:
                                                            _cont![index],
                                                        decoration:
                                                            InputDecoration(
                                                          counter: Container(),
                                                          labelText: index ==
                                                                      0 ||
                                                                  index == 1
                                                              ? "Option #$ic"
                                                              : "Option #$ic (optional)",
                                                          labelStyle:
                                                              const TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                          ),
                                                          suffixIcon: i == 2
                                                              ? Icon(
                                                                  Icons.cancel,
                                                                  color: Colors
                                                                      .transparent)
                                                              : IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    print(
                                                                        index);
                                                                    print(i);

                                                                    if (i > 2) {
                                                                      setState(
                                                                          () {
                                                                        i = i -
                                                                            1;
                                                                        print(
                                                                            i);

                                                                        _cont![index]
                                                                            .clear();
                                                                      });

                                                                      if (index !=
                                                                          i) {
                                                                        print(
                                                                            'abc');
                                                                        print(_cont![i]
                                                                            .text);
                                                                        if (_cont![i -
                                                                                1]
                                                                            .text
                                                                            .isEmpty) {
                                                                          _cont![i - 1].text =
                                                                              _cont![i].text;
                                                                        }

                                                                        print(_cont![i -
                                                                                1]
                                                                            .text);
                                                                        _cont![i]
                                                                            .clear();
                                                                      }
                                                                    }
                                                                  },
                                                                  icon: Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0,
                                                                        bottom:
                                                                            14),
                                                                    child: Icon(
                                                                      Icons
                                                                          .delete,
                                                                      size: 20,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                          // hintText: "Option #$ic",
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .blueAccent,
                                                                width: 2.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          border:
                                                              InputBorder.none,
                                                          // fillColor: Colors.white,
                                                          // filled: true,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                      Positioned(
                                                        bottom: 12,
                                                        right: 6,
                                                        child: Text(
                                                          '${_cont![index].text.length}/$_optionTextfieldMaxLength',
                                                          style:
                                                              const TextStyle(
                                                            // fontStyle: FontStyle.italic,
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ));
                                            }),
                                      ],
                                    ),
                                  ),
                                  i == 10
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15, bottom: 19),
                                          child: Text('MAXIMUM OPTIONS REACHED',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 85, 85, 85),
                                                  fontSize: 13)),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0, bottom: 4),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      // i = i + 1;
                                                      print(i = i + 1);
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.add_circle_outline,
                                                    color: Colors.blueAccent,
                                                    size: 27,
                                                  )),
                                              TextButton(
                                                child: Text('ADD OPTION',
                                                    style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontSize: 15,
                                                    )),
                                                onPressed: () {
                                                  setState(() {
                                                    // i = i + 1;
                                                    print(i = i + 1);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                          child: PhysicalModel(
                            //ISSUE
                            color: _pollController.text.length != 0 &&
                                    _cont![0].text.length != 0 &&
                                    _cont![1].text.length != 0
                                ? Colors.blueAccent
                                : Colors.blueAccent.withOpacity(0.45),

                            borderRadius: BorderRadius.circular(30),
                            // color: Colors.blue,
                            child: InkWell(
                              onTap: () async {
                                performLoggedUserAction(
                                    context: context,
                                    action: () {
                                      postImagePoll(
                                        user?.uid ?? '',
                                        user?.username ?? '',
                                        user?.photoUrl ?? '',
                                        user?.country ?? '',
                                      );
                                    });
                              },
                              child: Container(
                                height: 40,
                                width: 215,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 14.0,
                                      ),
                                      child: Icon(Icons.send,
                                          color: _pollController.text.length !=
                                                      0 &&
                                                  _cont![0].text.length != 0 &&
                                                  _cont![1].text.length != 0
                                              ? Colors.white
                                              : Color.fromARGB(
                                                  255, 245, 245, 245)),
                                    ),
                                    Container(width: global == 'true' ? 14 : 8),
                                    global == 'true'
                                        ? Text(
                                            'Send Poll Globally',
                                            style: TextStyle(
                                                color: _pollController
                                                                .text.length !=
                                                            0 &&
                                                        _cont![0].text.length !=
                                                            0 &&
                                                        _cont![1].text.length !=
                                                            0
                                                    ? Colors.white
                                                    : Color.fromARGB(
                                                        255, 245, 245, 245),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                letterSpacing: 1),
                                          )
                                        : Text(
                                            'Send Poll Nationally',
                                            style: TextStyle(
                                                color: _pollController
                                                                .text.length !=
                                                            0 &&
                                                        _cont![0].text.length !=
                                                            0 &&
                                                        _cont![1].text.length !=
                                                            0
                                                    ? Colors.white
                                                    : Color.fromARGB(
                                                        255, 245, 245, 245),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                letterSpacing: 1),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _icon(int index, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected == index ? Colors.blueAccent : Colors.grey,
            ),
          ],
        ),
        onTap: () => setState(
          () {
            selected = index;
            print('this is the index:');
            print(index);
            index == 1 ? _selectImage(context) : null;
            index == 2 ? _selectVideo(context) : null;
            index == 3 ? _selectYoutube(context) : null;

            index == 0 || index == 2 || index == 3 ? clearImage() : null;
            index == 0 || index == 1 || index == 2 ? clearVideoUrl() : null;
          },
        ),
      ),
    );
  }

  Widget rollingIconBuilderStringTwo(
      String messages, Size iconSize, bool foreground) {
    IconData data = Icons.poll;
    if (messages == 'true') data = Icons.message;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }

  Widget rollingIconBuilderStringThree(
      String global, Size iconSize, bool foreground) {
    IconData data = Icons.flag;
    if (global == 'true') data = Icons.public;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }

  Future<File> _getVideoThumbnail({required File file}) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = '$tempPath/${DateTime.now().millisecondsSinceEpoch}.png';

    final thumbnail = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.PNG,
      quality: 100,
    );
    return File(filePath).writeAsBytes(thumbnail!);
  }
}
