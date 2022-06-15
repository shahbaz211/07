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

import '../models/AUser.dart';
import '../provider/AUserProvider.dart';
import '../methods/AFirestoreMethods.dart';
import '../other/AUtils.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  late YoutubePlayerController controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  bool _isLoading = false;
  var messages = 'true';
  var global = 'true';
  Uint8List? _file;
  var selected = 0;
  String? videoUrl = '';
  bool textfield1selected = false;
  bool textfield1selected2 = false;
  int i = 1;
  String proxyurl = 'abc';
  bool emptyTittle = false;

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

  _selectvideo(BuildContext context) async {
    return showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text("Paste The Video Url Here"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        onChanged: (t) {
                          videoUrl = ytplayer.YoutubePlayer.convertUrlToId(
                              _videoUrlController.text);
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
                          hintText: "Paste video url here",

                          border: InputBorder.none,
                          fillColor: Colors.white,
                          filled: true,
                          // counterText: '',
                          contentPadding: EdgeInsets.only(
                            left: 10,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  SimpleDialogOption(
                    padding: const EdgeInsets.all(20),
                    child: const Text('Cancel'),
                    onPressed: () {
                      print(selected);
                      setState(() {
                        selected = 0;
                      });
                      print(selected);
                      Navigator.of(context).pop();
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

    /* return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextField(
        controller: _videoUrlController,
        maxLines: 1,
        decoration: const InputDecoration(
          hintText: "Paste video url here",
          border: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
          // counterText: '',
          contentPadding: EdgeInsets.only(
            left: 10,
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
    */
  }

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Upload"),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Open Camera'),
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
                child: const Text('Choose from gallery'),
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
                child: const Text('Cancel'),
                onPressed: () {
                  print(selected);
                  setState(() {
                    selected = 0;
                  });
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
  }

  Future<void> setValueM(String valuem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      messages = valuem.toString();
      prefs.setString('selected_radio4', messages);
    });
  }

  void postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    try {
      if (selected == 2) {
        if (_videoUrlController.text.length == 0) {
          setState(() {
            selected = 0;
          });
        }
      }

      print('THIS IS SELECTED IN POST IMAGE');
      print(selected);

      if (_titleController.text.length != 0) {
        setState(() {
          emptyTittle = false;
        });

        setState(() {
          _isLoading = true;
        });

        print('Entered this');

        if (selected == 0) {
          try {
            String res = await FirestoreMethods().uploadPostjusttext(
              uid,
              username,
              profImage,
              global,
              _titleController.text,
              _bodyController.text,
              //videoUrl!,

              selected,
            );

            if (res == "success") {
              setState(() {
                _isLoading = true;
              });
              showSnackBar('Posted!', context);
              // clearImage();
            } else {
              setState(() {
                _isLoading = true;
              });
              showSnackBar(res, context);
            }
          } catch (e) {
            showSnackBar(e.toString(), context);
          }
        }

        if (selected == 1) {
          try {
            String res = await FirestoreMethods().uploadPostjustImage(
              uid,
              username,
              profImage,
              global,
              _titleController.text,
              _bodyController.text,
              //videoUrl!,
              _file!,

              selected,
            );

            if (res == "success") {
              setState(() {
                _isLoading = true;
              });
              showSnackBar('Posted!', context);
              // clearImage();
            } else {
              setState(() {
                _isLoading = true;
              });
              showSnackBar(res, context);
            }
          } catch (e) {
            showSnackBar(e.toString(), context);
          }
        }

        if (selected == 2) {
          try {
            String res = await FirestoreMethods().uploadPostJustUrl(
              uid,
              username,
              profImage,
              global,
              _titleController.text,
              _bodyController.text,
              videoUrl!,
              //_file!,

              selected,
            );

            if (res == "success") {
              setState(() {
                _isLoading = true;
              });
              showSnackBar('Posted!', context);
              // clearImage();
            } else {
              setState(() {
                _isLoading = true;
              });
              showSnackBar(res, context);
            }
          } catch (e) {
            showSnackBar(e.toString(), context);
          }
        }
      } else {
        setState(() {
          emptyTittle = true;
        });
      }

      /*
      String res = await FirestoreMethods().uploadPost(
        uid,
        username,
        profImage,
        global,
        _titleController.text,
        _bodyController.text,
        //videoUrl!,
        proxyurl,
        _file,
        selected,
      );
      if (res == "success") {
        setState(() {
          _isLoading = true;
        });
        showSnackBar('Posted!', context);
        // clearImage();
      } else {
        setState(() {
          _isLoading = true;
        });
        showSnackBar(res, context);
      }
      */

    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    const player = YoutubePlayerIFrame();
    final User? user = Provider.of<UserProvider>(context).getUser;
    if (user == null) {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.black,
      ));
    }
    print(messages);

    if (messages == 'true') {
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
                          Text(
                            global == 'true' ? 'Global' : 'National',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              letterSpacing: 1,
                            ),
                          ),
                          AnimatedToggleSwitch<String>.rollingByHeight(
                              height: 34,
                              current: global,
                              values: const [
                                'true',
                                'false',
                              ],
                              onChanged: (valueg) =>
                                  setValueG(valueg.toString()),
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
                            messages == 'true' ? 'Option#1' : 'Option#2',
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
                              onChanged: (valuem) =>
                                  setValueM(valuem.toString()),
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
            body: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  _isLoading
                      ? const LinearProgressIndicator()
                      : const Padding(padding: EdgeInsets.only(top: 0)),
                  // const Divider(),
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: textfield1selected == false
                                ? Colors.white
                                : Colors.red,
                          ),
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
                                      ? Color.fromARGB(255, 190, 190, 190)
                                      : Colors.red),
                              hintText: "Write a title...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14),
                              hintStyle: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                              labelStyle: TextStyle(color: Colors.black),
                              // fillColor: Colors.white,
                              // filled: true,
                              // counterText: '',
                            ),
                            maxLines: null,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      emptyTittle == true
                          ? Text('Error: The tittle cannot be blank')
                          : Container(),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                          border: Border.all(
                            color: textfield1selected2 == false
                                ? Colors.white
                                : Colors.red,
                          ),
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
                                    ? Color.fromARGB(255, 190, 190, 190)
                                    : Colors.red),
                            contentPadding: EdgeInsets.only(top: 14.0),
                            hintText: "Additional text (optional)",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey),
                            labelStyle: TextStyle(color: Colors.black),
                            // fillColor: Colors.white,
                            // filled: true,
                            counterText: 'unlimited',
                          ),
                          maxLines: null,
                        ),
                      ),
                      PhysicalModel(
                        color: Colors.blueAccent,
                        elevation: 8,
                        shadowColor: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          onTap: () => postImage(
                            user.uid,
                            user.username,
                            user.photoUrl,
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 265,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: Icon(Icons.send, color: Colors.white),
                                ),
                                global == 'true'
                                    ? SizedBox(
                                        width: 14,
                                      )
                                    : SizedBox(
                                        width: 7,
                                      ),
                                global == 'true'
                                    ? Expanded(
                                        child: const Text(
                                          'Send Message Globally',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              letterSpacing: 1.5),
                                        ),
                                      )
                                    : Expanded(
                                        child: const Text(
                                          'Send Message Nationally',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              letterSpacing: 1.5),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      //
      //
      //
      //
      //
      //
      //
    } else {
      print('ENTERED ALT SCAFFOLD');
      return Scaffold(
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
                      Text(
                        global == 'true' ? 'Global' : 'National',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          letterSpacing: 1,
                        ),
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
                        messages == 'true' ? 'Option#1' : 'Option#2',
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
        body: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: [
              _isLoading
                  ? const LinearProgressIndicator()
                  : const Padding(padding: EdgeInsets.only(top: 0)),
              // const Divider(),
              SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(5),
                    //   color: Colors.white,
                    // ),
                    child: TextField(
                      //168 is really the max but 170 should be okay
                      maxLength: 50,
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: "Option #1",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        border: InputBorder.none,
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.only(
                          left: 10,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: null,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    // decoration: BoxDecoration(
                    //   border: Border.all(width: 2, color: Colors.blueAccent),
                    //   borderRadius: BorderRadius.circular(5),
                    //   color: Colors.white,
                    // ),
                    child: TextFormField(
                      controller: _bodyController,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Option #2",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          left: 10,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: null,
                    ),
                  ),
                  // const Divider(),
                  TextButton(
                    child: Text('add'),
                    onPressed: () {},
                  ),
                ],
              ),
              PhysicalModel(
                color: Colors.blueAccent,
                elevation: 8,
                shadowColor: Colors.black,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () => postImage(
                    user.uid,
                    user.username,
                    user.photoUrl,
                  ),
                  child: Container(
                    height: 40,
                    width: 260,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: Icon(Icons.send, color: Colors.white),
                        ),
                        global == 'true'
                            ? const Text(
                                'Send Message Globally',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 1),
                              )
                            : const Text(
                                'Send Message Nationally',
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
            ],
          ),
        ),
      );
    }
  }

  Widget _textFields(int index, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
            index == 1 ? _selectImage(context) : null;
            index == 2 ? _selectvideo(context) : null;
            index == 0 || index == 2 ? clearImage() : null;
          },
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
    IconData data = Icons.circle;
    if (messages == 'true') data = Icons.message;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }

  Widget rollingIconBuilderStringThree(
      String global, Size iconSize, bool foreground) {
    IconData data = Icons.flag;
    if (global == 'true') data = Icons.circle;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();
    controller.close();
    _titleController.dispose;
    _bodyController.dispose;
    _videoUrlController.dispose;
  }
}
