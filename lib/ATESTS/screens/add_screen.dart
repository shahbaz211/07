import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as ytplayer;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:core';

import '../methods/AFirestoreMethods.dart';
import '../methods/AStorageMethods.dart';
import '../models/AUser.dart';
import '../other/AUtils.dart';
import '../provider/AUserProvider.dart';
import 'ACountriesValues.dart';
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
  bool emptyPollQuestion = false;
  // bool emptyOptionTwo = false;
  // bool emptyOptionFour = false;
  String country = '';
  String oneValue = '';
  User? user;

  late final KeyboardVisibilityController _keyboardVisibilityController;
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
    print('entered add post');

/*
      KeyboardVisibilityNotification().addNewListener(
        onHide: (){
          print("BACK BUTTON!");
          if(textfield1selected==true||textfield1selected2==true)
          {
            setState(() {
              textfield1selected = false;
              textfield1selected2 = false;
            });
          }
        }
      );
*/

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

  _selectvideo(BuildContext context) async {
    return showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                // contentPadding: EdgeInsets.zero,
                // insetPadding:
                //     EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                title: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: const Text("Upload YouTube Video",
                      style: TextStyle(
                        fontSize: 20,
                        // letterSpacing: 0.3,
                        color: Colors.transparent, // Step 2 SEE HERE
                        shadows: [
                          Shadow(offset: Offset(0, -5), color: Colors.black)
                        ],
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.black,
                      )),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 12.0, left: 12, top: 6, bottom: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 248, 248, 248),
                        // color: Color.fromARGB(255, 241, 239, 239),
                        border: Border.all(
                          width: 0.5,
                          color: Color.fromARGB(255, 149, 149, 149),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
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
                          hintText: "Paste YouTube video url ...",
                          prefixIcon:
                              Icon(Icons.link, size: 15, color: Colors.black),
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
                  SimpleDialogOption(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Icon(Icons.clear, size: 16),
                        // Container(
                        //   width: 4,
                        // ),
                        const Text('Clear',
                            style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        clearVideoUrl();
                      });
                    },
                  ),
                  SimpleDialogOption(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Icon(Icons.check, size: 16),
                        // Container(
                        //   width: 4,
                        // ),
                        const Text('Done',
                            style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                        // Container(
                        //   width: 10,
                        // ),
                        // Icon(Icons.check, size: 16)
                      ],
                    ),
                    onPressed: () {
                      _videoUrlController.text.length == 0
                          ? setState(() {
                              selected = 0;
                              clearVideoUrl();
                            })
                          : print(selected);
                      Navigator.of(context).pop();

                      // setState(() {
                      //   selected = 0;
                      // });
                      // print(selected);
                      // Navigator.of(context).pop();
                      // clearVideoUrl();
                    },
                  ),
                ],
              );
            })
        .then(
            (value) => _videoUrlController.text.length == 0 || videoUrl == null
                ? setState(() {
                    selected = 0;
                  })
                : print('not null'));
  }

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: const Text("Upload From Phone",
                  style: TextStyle(
                    fontSize: 20,
                    // letterSpacing: 0.3,
                    color: Colors.transparent, // Step 2 SEE HERE
                    shadows: [
                      Shadow(offset: Offset(0, -5), color: Colors.black)
                    ],
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black,
                  )),
            ),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Open Camera',
                    style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                onPressed: () async {
                  Uint8List file = await pickImage(
                    ImageSource.camera,
                  );
                  setState(() {
                    _file = file;
                  });
                  Navigator.of(context).pop();
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from gallery',
                    style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                onPressed: () async {
                  Uint8List file = await pickImage(
                    ImageSource.gallery,
                  );
                  setState(() {
                    _file = file;
                  });
                  Navigator.of(context).pop();
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancel',
                    style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                onPressed: () {
                  print(selected);
                  _file == null
                      ? setState(() {
                          selected = 0;
                        })
                      : null;
                  print(selected);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }).then((value) => _file == null
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
        country = short[countryIndex];

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
      if (selected == 2) {
        if (_videoUrlController.text.length == 0) {
          setState(() {
            selected = 0;
          });
        }
      }

      if (_titleController.text.length != 0) {
        setState(() {
          emptyTittle = false;
        });

        setState(() {
          _isLoading = true;
        });

        String photoUrl = "";
        if (_file == null) {
          photoUrl = "";
        } else {
          photoUrl = await StorageMethods()
              .uploadImageToStorage('posts', _file!, true);
        }

        print(">>>>>>>>>>>$country");
        if (country == '') {
          country = mCountry;
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
            _isLoading = true;
          });
          showSnackBar('Posted!', context);
          Navigator.of(context).pop();
          // clearImage();
        } else {
          setState(() {
            _isLoading = true;
          });
          showSnackBar(res, context);
        }
      } else {
        setState(() {
          emptyTittle = true;
        });
      }
      // Navigator.pop(context);
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
      if (_pollController.text.length != 0) {
        setState(() {
          // _isLoading = true;
          emptyPollQuestion = false;
        });

        if (_cont![0].text.length != 0 && _cont![1].text.length != 0) {
          setState(() {
            // _isLoading = true;
            emptyOptionOne = false;
          });

          if (_cont![0].text.length != 0 &&
              _cont![1].text.length != 0 &&
              _pollController.text.length != 0) {
            setState(() {
              // _isLoading = true;
              emptyOptionOne = false;
              emptyPollQuestion = false;
            });

            if (country == '') {
              country = mCountry;
            } else {}

            String res = await FirestoreMethods().uploadPoll(
              uid,
              username,
              profImage,
              country,
              global,
              _pollController.text,
              _cont![0].text,
              _cont![1].text,
              _cont![2].text,
              _cont![3].text,
              _cont![4].text,
              _cont![5].text,
              _cont![6].text,
              _cont![7].text,
              _cont![8].text,
              _cont![9].text,
            );
            if (res == "success") {
              setState(() {
                _isLoading = true;
              });
              showSnackBar('Posted!', context);
              Navigator.of(context).pop();
            } else {
              setState(() {
                _isLoading = true;
              });
              showSnackBar(res, context);
            }
          } else {
            setState(() {
              emptyPollQuestion = true;
              emptyOptionOne = true;
            });
          }
        } else {
          setState(() {
            emptyOptionOne = true;
          });
        }
      } else {
        setState(() {
          emptyPollQuestion = true;
          emptyOptionOne = true;
        });
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
    // i >= 2 ? _cont![0].dispose : null;
    // i >= 2 ? _cont![1].dispose : null;
    // i >= 3 ? _cont![2].dispose : null;
    // i >= 4 ? _cont![3].dispose : null;
    // i >= 5 ? _cont![4].dispose : null;
    // i >= 6 ? _cont![5].dispose : null;
    // i >= 7 ? _cont![6].dispose : null;
    // i >= 8 ? _cont![7].dispose : null;
    // i >= 9 ? _cont![8].dispose : null;
    // i >= 10 ? _cont![9].dispose : null;
  }

  @override
  Widget build(BuildContext context) {
    const player = YoutubePlayerIFrame();
    user = Provider.of<UserProvider>(context).getUser;
    // if (user == null) {
    //   return const Center(
    //       child: CircularProgressIndicator(
    //     color: Colors.black,
    //   ));
    // }
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
          backgroundColor: Color.fromARGB(255, 241, 239, 239),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            toolbarHeight: 65,
            backgroundColor: Color.fromARGB(255, 241, 239, 239),
            actions: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      children: [
                        global == 'true'
                            ? Text(
                                'Global',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  letterSpacing: 1,
                                ),
                              )
                            : Row(
                                children: [
                                  Text(
                                    'National',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 24,
                                    height: 14,
                                    child: Image.asset(
                                        'icons/flags/png/${user?.country}.png',
                                        package: 'country_icons'),
                                  ),
                                ],
                              ),
                        AnimatedToggleSwitch<String>.rollingByHeight(
                            height: 34,
                            current: global,
                            values: const [
                              'true',
                              'false',
                            ],
                            onChanged: (valueg) => setValueG(valueg.toString()),
                            iconBuilder: rollingIconBuilderStringThree,
                            borderRadius: BorderRadius.circular(75.0),
                            indicatorSize: const Size.square(1.8),
                            innerColor: Color.fromARGB(255, 203, 203, 203),
                            indicatorColor: Colors.black,
                            borderColor: Color.fromARGB(255, 234, 232, 232),
                            iconOpacity: 1),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      children: [
                        Text(
                          messages == 'true' ? 'Messages' : 'Polls',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        AnimatedToggleSwitch<String>.rollingByHeight(
                            height: 34,
                            current: messages,
                            values: const [
                              'true',
                              'false',
                            ],
                            onChanged: (valuem) => setValueM(valuem.toString()),
                            iconBuilder: rollingIconBuilderStringTwo,
                            borderRadius: BorderRadius.circular(75.0),
                            indicatorSize: const Size.square(1.8),
                            innerColor: Color.fromARGB(255, 203, 203, 203),
                            indicatorColor: Colors.black,
                            borderColor: Color.fromARGB(255, 234, 232, 232),
                            iconOpacity: 1),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline, color: Colors.black),
                  ),
                ],
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
                                                'Message title cannot be blank.',
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 220, 105, 96))),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Container(),
                              emptyTittle ? Container() : Container(height: 10),
                              Card(
                                elevation: textfield1selected == false ? 3 : 0,
                                child: Container(
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
                                            ? Color.fromARGB(255, 248, 248, 248)
                                            : Colors.blueAccent,
                                        width: 1.5),
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
                                      //168 is really the max but 170 should be okay
                                      maxLength: 700,
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
                                        prefixIcon: Icon(Icons.create,
                                            color: textfield1selected == false
                                                ? Color.fromARGB(
                                                    255, 190, 190, 190)
                                                : Colors.blueAccent),
                                        hintText: "Message title...",
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(top: 14),
                                        hintStyle: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey),
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        // fillColor: Colors.white,
                                        // filled: true,
                                        // counterText: '',
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ),
                              ),
                              Container(height: 10),
                              Card(
                                elevation: textfield1selected2 == false ? 3 : 0,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 248, 248, 248),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    border: Border.all(
                                        color: textfield1selected2 == false
                                            ? Color.fromARGB(255, 248, 248, 248)
                                            : Colors.blueAccent,
                                        width: 1.5),
                                  ),
                                  child: TextField(
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
                                      prefixIcon: Icon(Icons.create,
                                          color: textfield1selected2 == false
                                              ? Color.fromARGB(
                                                  255, 190, 190, 190)
                                              : Colors.blueAccent),
                                      contentPadding:
                                          EdgeInsets.only(top: 14.0),
                                      hintText: "Additional text (optional)",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      // fillColor: Colors.white,
                                      // filled: true,
                                      counterText: 'unlimited',
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                              ),
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
                                  Card(
                                    elevation: 3,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 248, 248, 248),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _icon(0, icon: Icons.do_not_disturb),
                                          _icon(1, icon: Icons.collections),
                                          _icon(2, icon: Icons.ondemand_video),
                                          _icon(3, icon: Icons.video_library),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              _file != null
                                  ? Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                                            FullImageScreenAdd(
                                                              image:
                                                                  MemoryImage(
                                                                      _file!),
                                                            )),
                                                  );
                                                },
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.35,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.7,
                                                  color: Colors.black,
                                                  // child: AspectRatio(
                                                  //   aspectRatio: 487 / 451,

                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image:
                                                            MemoryImage(_file!),
                                                        fit: BoxFit.contain,
                                                        // alignment: FractionalOffset.topCenter,
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
                                                      _selectImage(context);
                                                    },
                                                    icon: const Icon(
                                                        Icons.change_circle,
                                                        color: Colors.grey),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      clearImage();
                                                      selected -= 1;
                                                    },
                                                    icon: const Icon(
                                                        Icons.delete,
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
                                  : Container(),
                              _videoUrlController.text.isEmpty
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
                                              Container(
                                                width: 265,
                                                child: Stack(
                                                  children: [
                                                    player,
                                                    Positioned.fill(
                                                      child:
                                                          YoutubeValueBuilder(
                                                        controller: controller,
                                                        builder:
                                                            (context, value) {
                                                          return AnimatedCrossFade(
                                                            crossFadeState: value
                                                                    .isReady
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
                                              Column(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      _selectvideo(context);
                                                    },
                                                    icon: const Icon(
                                                        Icons.change_circle,
                                                        color: Colors.grey),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      clearVideoUrl();
                                                      selected -= 2;
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
                                    : Colors.blueAccent.withOpacity(0.6),
                                shadowColor: Colors.black,
                                borderRadius: BorderRadius.circular(30),
                                child: InkWell(
                                  onTap: () => postImage(
                                    user?.uid ?? '',
                                    user?.username ?? '',
                                    user?.photoUrl ?? '',
                                    user?.country ?? '',
                                  ),
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
                                                _titleController.text.length !=
                                                        0
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
                                                _titleController.text.length !=
                                                    0
                                            ? Expanded(
                                                child: const Text(
                                                  'Send Message Globally',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                                  FontWeight
                                                                      .bold,
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
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15.25,
                                                              letterSpacing:
                                                                  1.2),
                                                        ),
                                                      ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ]))
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
                                                            255,
                                                            220,
                                                            105,
                                                            96))),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  Padding(
                                    padding: emptyOptionOne == true
                                        ? const EdgeInsets.only(
                                            bottom: 14.0, top: 0)
                                        : const EdgeInsets.only(
                                            bottom: 14.0, top: 8),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.81,
                                      // color: Colors.orange,
                                      height: 42,
                                      child: WillPopScope(
                                        onWillPop: () async {
                                          print('POP');
                                          return false;
                                        },
                                        child: TextField(
                                          //168 is really the max but 170 should be okay
                                          maxLength: 700,

                                          controller: _pollController,

                                          decoration: InputDecoration(
                                            // prefixIcon: Icon(
                                            //   Icons.create,
                                            //   color: Color.fromARGB(
                                            //       255, 190, 190, 190),
                                            // ),

                                            hintText: "Poll question ...",
                                            // border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                                top: 0, left: 4),
                                            hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey,
                                              fontSize: 17,
                                            ),
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
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: i,
                                        itemBuilder: (context, index) {
                                          _cont!.add(TextEditingController());

                                          int ic = index + 1;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 16,
                                              right: 10,
                                              left: 10,
                                            ),
                                            child: Column(
                                              children: [
                                                emptyOptionOne && index == 0
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(Icons.error,
                                                                size: 16,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        220,
                                                                        105,
                                                                        96)),
                                                            Container(width: 6),
                                                            Text(
                                                                'First two poll options cannot be blank.',
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            220,
                                                                            105,
                                                                            96))),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                                Container(
                                                  // height: 50,
                                                  // decoration: BoxDecoration(
                                                  //   border: Border.all(
                                                  //       width: 1,
                                                  //       color: Color.fromARGB(
                                                  //           255, 102, 102, 102)),
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(10),
                                                  // ),
                                                  child: TextField(
                                                    maxLength: 50,

                                                    //controller: _titleController,
                                                    onTap: () {
                                                      print(i);
                                                    },
                                                    controller: _cont![index],
                                                    decoration: InputDecoration(
                                                      // counterText: '',
                                                      labelText: index == 0 ||
                                                              index == 1
                                                          ? "Option #$ic"
                                                          : "Option #$ic (optional)",
                                                      labelStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 15,
                                                        color: Colors.grey,
                                                      ),
                                                      suffixIcon: i == 2
                                                          ? Icon(Icons.cancel,
                                                              color: Colors
                                                                  .transparent)
                                                          : IconButton(
                                                              onPressed: () {
                                                                print(index);
                                                                print(i);

                                                                if (i > 2) {
                                                                  setState(() {
                                                                    i = i - 1;
                                                                    print(i);

                                                                    _cont![index]
                                                                        .clear();
                                                                  });

                                                                  if (index !=
                                                                      i) {
                                                                    print(
                                                                        'abc');
                                                                    print(_cont![
                                                                            i]
                                                                        .text);

                                                                    if (_cont![
                                                                            i - 1]
                                                                        .text
                                                                        .isEmpty) {
                                                                      _cont![i -
                                                                              1]
                                                                          .text = _cont![
                                                                              i]
                                                                          .text;
                                                                    }

                                                                    print(_cont![
                                                                            i - 1]
                                                                        .text);
                                                                    _cont![i]
                                                                        .clear();
                                                                  }
                                                                }
                                                              },
                                                              icon: Icon(
                                                                Icons.delete,
                                                                size: 20,
                                                                color:
                                                                    Colors.grey,
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
                                                                color:
                                                                    Colors.grey,
                                                                width: 1.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .blueAccent,
                                                            width: 2.0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      border: InputBorder.none,
                                                      // fillColor: Colors.white,
                                                      // filled: true,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                  i == 10
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 17, bottom: 17),
                                          child: Text('MAXIMUM OPTIONS REACHED',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 85, 85, 85),
                                                  fontSize: 12)),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4.0, bottom: 2),
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
                                : Colors.blueAccent.withOpacity(0.6),

                            borderRadius: BorderRadius.circular(30),
                            // color: Colors.blue,
                            child: InkWell(
                              onTap: () => postImagePoll(
                                user?.uid ?? '',
                                user?.username ?? '',
                                user?.photoUrl ?? '',
                                user?.country ?? '',
                              ),
                              child: Container(
                                height: 40,
                                width: 215,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 14.0,
                                      ),
                                      child:
                                          Icon(Icons.send, color: Colors.white),
                                    ),
                                    Container(width: global == 'true' ? 14 : 8),
                                    global == 'true'
                                        ? const Text(
                                            'Send Poll Globally',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                letterSpacing: 1),
                                          )
                                        : const Text(
                                            'Send Poll Nationally',
                                            style: TextStyle(
                                                color: Colors.white,
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
            index == 2 ? _selectvideo(context) : null;
            index == 0 || index == 2 ? clearImage() : null;
            index == 0 || index == 1 ? clearVideoUrl() : null;
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
}
