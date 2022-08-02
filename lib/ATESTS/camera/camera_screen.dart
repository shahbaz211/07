import 'dart:async';
import 'dart:io';

import 'package:aft/ATESTS/camera/preview.dart';
import 'package:camera/camera.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../other/utils.dart.dart';
import 'camera_loader.dart';

enum CameraFileType { image, video }

class CameraScreen extends StatefulWidget {
  final add;
  const CameraScreen(
      {Key? key,
      required this.camera,
      required this.secondaryCamera,
      required this.cameraFileType,
      required this.add})
      : super(key: key);

  final CameraDescription camera;
  final CameraDescription? secondaryCamera;
  final CameraFileType cameraFileType;

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  // Controllers
  late CameraDescription selectedCamera;
  final StreamController<bool> _isCapturingStreamController =
      StreamController<bool>.broadcast();
  late CameraController controller;
  late Future<void> _initializeControllerFuture;
  bool _captureImage = true;

  @override
  void initState() {
    super.initState();
    selectedCamera =
        widget.add == "two" ? widget.secondaryCamera! : widget.camera;
    _captureImage = widget.cameraFileType == CameraFileType.image;
    _setDefaults();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: widget.add == "one" ? false : false,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: widget.add != "true"
                ? Color.fromARGB(255, 231, 231, 231)
                : Color.fromARGB(255, 231, 231, 231),
            automaticallyImplyLeading: false,
            actions: [
              Container(
                width: MediaQuery.of(context).size.width * 1,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_left,
                          color: widget.add == "true"
                              ? Colors.black
                              : Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      _captureImage == true && widget.add == "true"
                          ? 'Take a picture'
                          : "Record a video",
                      style: TextStyle(
                          color: widget.add == "true"
                              ? Colors.black
                              : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Expanded(
                      child: Container(
                          color: Color.fromARGB(255, 231, 231, 231),
                          width: getScreenSize(context: context).width,
                          height: getScreenSize(context: context).height),
                    ),
                    CameraPreview(
                      controller,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: StreamBuilder<bool>(
                              initialData: false,
                              stream: _isCapturingStreamController.stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<bool> snapshot) {
                                return Visibility(
                                  visible: controller.value.isRecordingVideo,
                                  child: Container(
                                    child: Container(),
                                    decoration: BoxDecoration(
                                      // color: Colors.white.withOpacity(0),
                                      border: Border.all(
                                        color: Colors.redAccent,
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: widget.add == "true" ? 20 : 10,
                            left: -1,
                            right: -1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(child: Container()),
                                Align(
                                  alignment: Alignment.center,
                                  child: StreamBuilder<bool>(
                                    initialData: false,
                                    stream: _isCapturingStreamController.stream,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<bool> snapshot) {
                                      bool _isCapturing =
                                          snapshot.data ?? false;
                                      return _captureImage
                                          ? Center(
                                              child: Container(
                                                // width: 100,
                                                // color: Colors.blue,
                                                child: Center(
                                                  child:
                                                      CircularOutlinedIconButton(
                                                    icon: const Icon(
                                                      Icons.camera_alt_outlined,
                                                      color: Colors.white,
                                                      size: 36,
                                                    ),
                                                    onTap: _isCapturing
                                                        ? () {}
                                                        : () async {
                                                            _onImageCapture(
                                                                context:
                                                                    context);
                                                          },
                                                  ),
                                                ),
                                              ),
                                            )
                                          : CircularOutlinedIconButton(
                                              icon: Icon(
                                                controller
                                                        .value.isRecordingVideo
                                                    ? Icons.stop
                                                    : Icons.videocam_outlined,
                                                color: Colors.white,
                                                size: 36,
                                              ),
                                              onTap: _isCapturing
                                                  ? () {}
                                                  : () async {
                                                      if (controller.value
                                                          .isRecordingVideo) {
                                                        stopVideoRecording();
                                                      } else {
                                                        startVideoRecording();
                                                      }
                                                    },
                                            );
                                    },
                                  ),
                                ),
                                widget.add == "true"
                                    ? Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Visibility(
                                              visible: widget.secondaryCamera !=
                                                  null,
                                              child: CircularOutlinedIconButton(
                                                icon: const Icon(
                                                  Icons.cameraswitch_outlined,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                onTap: () {
                                                  selectedCamera =
                                                      selectedCamera ==
                                                              widget.camera
                                                          ? widget
                                                              .secondaryCamera!
                                                          : widget.camera;
                                                  _setDefaults();
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Expanded(child: Container())
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return const CameraLoader();
              }
            },
          ),
        ),
      ),
    );
  }

  // Methods

  // Set defaults
  void _setDefaults() {
    controller = CameraController(
      selectedCamera,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = controller.initialize();
    _isCapturingStreamController.sink.add(false);
  }

  // Disposes controllers
  void _dispose() {
    controller.dispose();
    _isCapturingStreamController.close();
  }

  // On capture
  void _onImageCapture({required BuildContext context}) async {
    _isCapturingStreamController.sink.add(true);
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Attempt to take a picture and get the file `image`
      // where it was saved.
      final image = await controller.takePicture();

      _isCapturingStreamController.sink.add(false);

      // If the picture was taken, display it on a new screen.
      bool? selected = await Navigator.of(
        context,
      ).push<bool>(
        CupertinoPageRoute(builder: (BuildContext context) {
          return PreviewPictureScreen(
            filePath: image.path,
            cameraFileType: CameraFileType.image,
            add: widget.add,
          );
        }),
      );

      // If photo is selected return it
      if (selected ?? false) {
        Navigator.pop(context, [File(image.path)]);
      }
    } catch (e) {
      // If an error occurs, log the error to the console.
      // showAlert(
      //   context: context,
      //   titleText: Localization.of(context).trans(LocalizationValues.error),
      //   message: '$e',
      //   actionCallbacks: {
      //     Localization.of(context).trans(LocalizationValues.ok): () {}
      //   },
      // );
      _isCapturingStreamController.sink.add(false);
    }
  }

  void startVideoRecording() async {
    _isCapturingStreamController.sink.add(true);
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Attempt to start recording a video
      // where it was saved.
      await controller.startVideoRecording();
      _isCapturingStreamController.sink.add(false);
    } catch (e) {
      // If an error occurs, log the error to the console.
      // showAlert(
      //   context: context,
      //   titleText: Localization.of(context).trans(LocalizationValues.error),
      //   message: '$e',
      //   actionCallbacks: {
      //     Localization.of(context).trans(LocalizationValues.ok): () {}
      //   },
      // );
      _isCapturingStreamController.sink.add(false);
    }
  }

  void stopVideoRecording() async {
    _isCapturingStreamController.sink.add(true);
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Attempt to start recording a video
      // where it was saved.
      final video = await controller.stopVideoRecording();
      _isCapturingStreamController.sink.add(false);

      // If the picture was taken, display it on a new screen.
      bool? selected = await Navigator.of(
        context,
      ).push<bool>(CupertinoPageRoute(builder: (BuildContext context) {
        return PreviewPictureScreen(
          filePath: video.path,
          cameraFileType: CameraFileType.video,
          add: widget.add,
        );
      }));

      // If photo is  selected return it
      if (selected ?? false) {
        Navigator.pop(context, [File(video.path)]);
      }
    } catch (e) {
      // If an error occurs, log the error to the console.
      // showAlert(
      //   context: context,
      //   titleText: Localization.of(context).trans(LocalizationValues.error),
      //   message: '$e',
      //   actionCallbacks: {
      //     Localization.of(context).trans(LocalizationValues.ok): () {}
      //   },
      // );
      _isCapturingStreamController.sink.add(false);
    }
  }
}

class CircularOutlinedIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final String? label;
  final Color? borderColor;

  const CircularOutlinedIconButton({
    Key? key,
    required this.onTap,
    required this.icon,
    this.label,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          shape: CircleBorder(
            side: BorderSide(
              color: borderColor ?? Colors.white,
              width: 2.0,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: icon,
            ),
          ),
        ),
        Visibility(
          visible: label != null,
          child: Text(label ?? ''),
        ),
      ],
    );
  }
}
