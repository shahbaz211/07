import 'dart:developer';
import 'dart:typed_data';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  var videoUrl = 'DavckVZylkg';

  @override
  void initState() {
    super.initState();
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
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.camera,
                  );
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.gallery,
                  );
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
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
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
        uid,
        username,
        profImage,
        global,
        _titleController.text,
        _bodyController.text,
        videoUrl,
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
    if (messages == 'true') {
      return YoutubePlayerControllerProvider(
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      child: TextField(
                        //168 is really the max but 170 should be okay
                        maxLength: 700,

                        controller: _titleController,

                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.create,
                              color: Color.fromARGB(255, 190, 190, 190)),
                          hintText: "Write a title...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(top: 14),
                          hintStyle: TextStyle(
                              fontStyle: FontStyle.italic, color: Colors.grey),
                          labelStyle: TextStyle(color: Colors.black),
                          // fillColor: Colors.white,
                          // filled: true,
                          // counterText: '',
                        ),
                        maxLines: null,
                      ),
                    ),
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
                      ),
                      child: TextField(
                        controller: _bodyController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.create,
                              color: Color.fromARGB(255, 190, 190, 190)),
                          contentPadding: EdgeInsets.only(top: 14.0),
                          hintText: "Additional text (optional)",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              fontStyle: FontStyle.italic, color: Colors.grey),
                          labelStyle: TextStyle(color: Colors.black),
                          // fillColor: Colors.white,
                          // filled: true,
                          counterText: 'unlimited',
                        ),
                        maxLines: null,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      alignment: Alignment.centerLeft,
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.all(
                      //     Radius.circular(100.0),
                      //   ),
                      // ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          children: [
                            Container(
                              // width: MediaQuery.of(context).size.width * 0.8,
                              alignment: Alignment.centerLeft,
                              child: Text('Select one:',
                                  style: TextStyle(
                                      fontSize: 14, letterSpacing: 1)),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    selected == 2
                        ? Container(
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
                          )
                        : Container(),
                    _file != null
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                        contentPadding: EdgeInsets.zero,
                                        insetPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        children: [
                                          InteractiveViewer(
                                            clipBehavior: Clip.none,
                                            minScale: 1,
                                            maxScale: 4,
                                            child: Container(
                                              // color: Colors.black,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.9,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                image: DecorationImage(
                                                  image: MemoryImage(_file!),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 150,
                                    width: 265,
                                    color: Colors.black,
                                    // child: AspectRatio(
                                    //   aspectRatio: 487 / 451,

                                    child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image: MemoryImage(_file!),
                                        fit: BoxFit.contain,
                                        // alignment: FractionalOffset.topCenter,
                                      )),
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
                                      icon: const Icon(Icons.change_circle,
                                          color: Colors.grey),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        clearImage();
                                        selected -= 1;
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    // _videoUrlController.text.isEmpty
                    //     ? Container()
                    //     :
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (kIsWeb && constraints.maxWidth > 800) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(child: player),
                              const SizedBox(
                                width: 500,
                              ),
                            ],
                          );
                        }
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: 265,
                                child: Stack(
                                  children: [
                                    player,
                                    Positioned.fill(
                                      child: YoutubeValueBuilder(
                                        controller: controller,
                                        builder: (context, value) {
                                          return AnimatedCrossFade(
                                            crossFadeState: value.isReady
                                                ? CrossFadeState.showSecond
                                                : CrossFadeState.showFirst,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            secondChild: Container(
                                                child: const SizedBox.shrink()),
                                            firstChild: Material(
                                              child: DecoratedBox(
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      YoutubePlayerController
                                                          .getThumbnail(
                                                        videoId: controller
                                                            .initialVideoId,
                                                        quality:
                                                            ThumbnailQuality
                                                                .medium,
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
                                      _selectImage(context);
                                    },
                                    icon: const Icon(Icons.change_circle,
                                        color: Colors.grey),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      clearImage();
                                      selected -= 1;
                                    },
                                    icon: const Icon(Icons.delete,
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
            index == 1 ? _selectImage(context) : null;
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
