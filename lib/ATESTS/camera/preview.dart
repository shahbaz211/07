import 'dart:io';

import 'package:aft/ATESTS/camera/video_preview.dart';
import 'package:flutter/material.dart';
import '../authentication/signup.dart';
import '../other/utils.dart.dart';

import 'camera_loader.dart';
import 'camera_screen.dart';

class PreviewPictureScreen extends StatefulWidget {
  final String filePath;
  final bool? previewOnly;
  final CameraFileType cameraFileType;
  final add;

  const PreviewPictureScreen(
      {Key? key,
      required this.filePath,
      this.previewOnly,
      required this.cameraFileType,
      required this.add})
      : super(key: key);

  @override
  State<PreviewPictureScreen> createState() => _PreviewPictureScreenState();
}

class _PreviewPictureScreenState extends State<PreviewPictureScreen> {
  bool _captureImage = true;

  @override
  void initState() {
    print('filePath: ${widget.filePath}');
    _captureImage = widget.cameraFileType == CameraFileType.image;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          // extendBodyBehindAppBar: widget.add == "true" ? false : true,
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromARGB(255, 231, 231, 231),
            actions: [
              Container(
                width: MediaQuery.of(context).size.width * 1,
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.keyboard_arrow_left, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'Preview',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              const CameraLoader(),
              Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    _captureImage
                        ? Image.file(
                            File(widget.filePath),
                          )
                        : VideoPreview(filePath: widget.filePath),
                    Positioned(
                      bottom: 20,
                      left: -1,
                      right: -1,
                      child: Offstage(
                        offstage: widget.previewOnly ?? false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularOutlinedIconButton(
                                borderColor: Colors.red,
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                  size: 36,
                                ),
                                onTap: () {
                                  Navigator.pop(context, false);
                                },
                              ),
                              SizedBox(
                                  width: getScreenSize(context: context).width *
                                      0.15),
                              CircularOutlinedIconButton(
                                borderColor: Colors.green,
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 36,
                                ),
                                onTap: () {
                                  widget.add == "true"
                                      ? Navigator.pop(context, true)
                                      : null;
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             widget.add != "one"
                                  //                 ? VerifyThree()
                                  //                 :
                                  //                 SignupScreen()),
                                  //   );
                                },
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
        ),
      ),
    );
  }
}
