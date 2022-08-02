import 'dart:developer';
import 'package:aft/ATESTS/screens/report_user_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../feeds/comment_card.dart';
import '../methods/firestore_methods.dart';

import '../models/post.dart';

import '../models/user.dart';
import '../other/utils.dart.dart';
import '../provider/user_provider.dart';

import 'full_image_screen.dart';
import 'home_screen.dart';
import 'like_animation.dart';

String? currentReplyCommentId;

class CommentSort {
  final String label;
  final String key;
  final bool value;

  CommentSort({
    required this.label,
    required this.key,
    required this.value,
  });
}

class CommentFilter {
  final String label;
  Icon? icon;
  RotatedBox? rotatedBox;

  final String key;
  final String value;

  CommentFilter({
    required this.label,
    this.icon,
    this.rotatedBox,
    required this.key,
    required this.value,
  });
}

class FullMessage extends StatefulWidget {
  final Post post;
  final indexPlacement;

  const FullMessage(
      {Key? key, required this.post, required this.indexPlacement})
      : super(key: key);

  @override
  State<FullMessage> createState() => _FullMessageState();
}

class _FullMessageState extends State<FullMessage> {
  late Post _post;

  final TextEditingController _commentController = TextEditingController();
  late YoutubePlayerController controller;
  bool isLikeAnimating = false;
  int commentLen = 0;
  String placement = '';
  bool filter = false;

  List<CommentSort> commentSorts = [
    CommentSort(label: 'Most Popular', key: 'likeCount', value: true),
    CommentSort(label: 'Most Recent', key: 'datePublished', value: true),
  ];

  List<CommentFilter> commentFilters = [
    CommentFilter(
      label: 'All',
      key: 'commentId',
      value: 'all',
    ),
    CommentFilter(
      label: 'Voted ',
      icon: const Icon(
        Icons.add_circle,
        color: Colors.green,
        size: 15,
      ),
      key: 'plus',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Voted ',
      rotatedBox: RotatedBox(
        quarterTurns: 1,
        child: const Icon(
          Icons.pause_circle_filled,
          color: Color.fromARGB(255, 104, 104, 104),
          size: 15,
        ),
      ),
      key: 'neutral',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Voted ',
      icon: const Icon(
        Icons.do_not_disturb_on,
        color: Colors.red,
        size: 15,
      ),
      key: 'minus',
      value: 'uid',
    ),
  ];

  late CommentSort _selectedCommentSort;
  late CommentFilter _selectedCommentFilter;

  _otherUsers(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.block),
                    Container(width: 10),
                    const Text('Block User',
                        style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                  ],
                ),
                onPressed: () {
                  performLoggedUserAction(
                    context: context,
                    action: () {},
                  );
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.report),
                    Container(width: 10),
                    const Text('Report User',
                        style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                  ],
                ),
                onPressed: () {
                  performLoggedUserAction(
                    context: context,
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReportUserScreen()),
                      );
                    },
                  );
                },
              ),
            ],
          );
        });
  }

  _deletePost(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    Container(width: 10),
                    const Text('Delete Message',
                        style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                  ],
                ),
                onPressed: () async {
                  FirestoreMethods().deletePost(_post.postId);
                  Navigator.of(context).pop();
                  showSnackBar('Message Deleted', context);
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    _post = widget.post;
    _selectedCommentSort = commentSorts.first;
    _selectedCommentFilter = commentFilters.first;
    placement = '#${(widget.indexPlacement + 1).toString()}';

    currentReplyCommentId = null;
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId: _post.videoUrl,
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

  @override
  void dispose() {
    controller.close();
    super.dispose();
    _commentController.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    _post = widget.post;

    print('INSIDE FULL MESSAGE BUILD');
    print('_post.toJson(): ${_post.toJson()}');

    const player = YoutubePlayerIFrame(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
    );
    final User? user = Provider.of<UserProvider>(context).getUser;
    // if (user == null) {
    //   return const Center(
    //       child: CircularProgressIndicator(
    //     color: Colors.black,
    //   ));
    // }

    print("_selectedCommentFilter.key: ${_selectedCommentFilter.key}");
    print("_post.toJson(): ${_post.toJson()}");
    print(
        "_post.toJson()[_selectedCommentFilter.key]: ${_post.toJson()[_selectedCommentFilter.key]}");

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(_post.postId)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          _post = snapshot.data != null ? Post.fromSnap(snapshot.data!) : _post;
          return Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Color.fromARGB(255, 245, 245, 245),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  toolbarHeight: 67,
                  actions: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 70,
                                // color: Colors.blue,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0.0, top: 4),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.arrow_back,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 20.0, left: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 11.25, right: 8, left: 0),
                                        child: Column(
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                // color: Colors.red,
                                                // width: 80,
                                                // height: 39,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: placement.length < 4
                                                          ? 0
                                                          : placement.length < 5
                                                              ? 2
                                                              : placement.length >=
                                                                      5
                                                                  ? 3
                                                                  : 3),
                                                  child: Text(
                                                    placement,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: placement
                                                                    .length <
                                                                4
                                                            ? 24
                                                            : placement.length <
                                                                    5
                                                                ? 22
                                                                : placement.length >=
                                                                        5
                                                                    ? 20
                                                                    : 20,
                                                        color: Colors.black),
                                                  ),
                                                )),
                                            Container(
                                                height: placement.length >= 5
                                                    ? 2
                                                    : 0.5),
                                            Container(
                                              // color: Colors.green,
                                              // width: 90,
                                              // height: 19.3,

                                              child: Row(
                                                children: [
                                                  Text('Score:',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 13,
                                                          letterSpacing: 0.5)),
                                                  Text(
                                                    // testt > 10000
                                                    //     ? testt.toString().replaceRange(
                                                    //         3, testt.toString().length, 'k')
                                                    //     : testt.toString(),
                                                    ' ${_post.plus.length - _post.minus.length}',
                                                    // ' 32.4k',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        // color: Colors.purple,
                                        child: Stack(
                                          children: [
                                            Container(
                                              alignment: Alignment.topCenter,
                                              height: 60,
                                              // color: Colors.red,
                                              // width: 60,
                                              // color: Colors.orange,
                                              child: LikeAnimation(
                                                isAnimating: _post.plus
                                                    .contains(user?.uid),
                                                child: IconButton(
                                                  iconSize: 25,
                                                  onPressed: () {
                                                    performLoggedUserAction(
                                                        context: context,
                                                        action: () async {
                                                          await FirestoreMethods()
                                                              .plusMessage(
                                                            _post.postId,
                                                            user?.uid ?? '',
                                                            _post.plus,
                                                          );
                                                          FirestoreMethods()
                                                              .scoreMessage(
                                                                  _post.postId,
                                                                  user?.uid ??
                                                                      "",
                                                                  _post.plus
                                                                          .length -
                                                                      _post
                                                                          .minus
                                                                          .length);
                                                        });
                                                  },
                                                  icon: _post.plus
                                                          .contains(user?.uid)
                                                      ? Icon(
                                                          Icons.add_circle,
                                                          color: Colors.green,
                                                        )
                                                      : Icon(
                                                          Icons.add_circle,
                                                          color: Color.fromARGB(
                                                              255,
                                                              206,
                                                              204,
                                                              204),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 42,
                                              left: 20,
                                              child: Container(
                                                // width: 60,
                                                // color: Colors.orange,
                                                alignment: Alignment.center,
                                                child: Text(
                                                    '${_post.plus.length}',
                                                    // '32.4k',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Stack(
                                        children: [
                                          Container(
                                            alignment: Alignment.topCenter,
                                            height: 60,
                                            // width: 60,
                                            child: LikeAnimation(
                                              isAnimating: _post.neutral
                                                  .contains(user?.uid),
                                              child: IconButton(
                                                iconSize: 25,
                                                onPressed: () {
                                                  performLoggedUserAction(
                                                      context: context,
                                                      action: () async {
                                                        await FirestoreMethods()
                                                            .neutralMessage(
                                                          _post.postId,
                                                          user?.uid ?? '',
                                                          _post.neutral,
                                                        );
                                                        FirestoreMethods()
                                                            .scoreMessage(
                                                                _post.postId,
                                                                user?.uid ?? "",
                                                                _post.plus
                                                                        .length -
                                                                    _post.minus
                                                                        .length);
                                                      });
                                                },
                                                icon: _post.neutral
                                                        .contains(user?.uid)
                                                    ? RotatedBox(
                                                        quarterTurns: 1,
                                                        child: Icon(
                                                          Icons
                                                              .pause_circle_filled,
                                                          color: Color.fromARGB(
                                                              255,
                                                              111,
                                                              111,
                                                              111),
                                                        ),
                                                      )
                                                    : RotatedBox(
                                                        quarterTurns: 1,
                                                        child: Icon(
                                                          Icons
                                                              .pause_circle_filled,
                                                          color: Color.fromARGB(
                                                              255,
                                                              206,
                                                              204,
                                                              204),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 42,
                                            left: 20,
                                            // right: 24,
                                            child: Container(
                                              // width: 60,
                                              // color: Colors.yellow,
                                              alignment: Alignment.center,
                                              child: Text(
                                                  '${_post.neutral.length}',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Stack(
                                        children: [
                                          Container(
                                            alignment: Alignment.topCenter,
                                            height: 60,
                                            // width: 60,
                                            child: LikeAnimation(
                                              isAnimating: _post.minus
                                                  .contains(user?.uid),
                                              child: IconButton(
                                                iconSize: 25,
                                                onPressed: () {
                                                  performLoggedUserAction(
                                                      context: context,
                                                      action: () async {
                                                        await FirestoreMethods()
                                                            .minusMessage(
                                                          _post.postId,
                                                          user?.uid ?? '',
                                                          _post.minus,
                                                        );
                                                        FirestoreMethods()
                                                            .scoreMessage(
                                                                _post.postId,
                                                                user?.uid ?? "",
                                                                _post.plus
                                                                        .length -
                                                                    _post.minus
                                                                        .length);
                                                      });
                                                },
                                                icon: _post.minus
                                                        .contains(user?.uid)
                                                    ? Icon(
                                                        Icons.do_not_disturb_on,
                                                        color: Colors.red,
                                                      )
                                                    : Icon(
                                                        Icons.do_not_disturb_on,
                                                        color: Color.fromARGB(
                                                            255, 206, 204, 204),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 42,
                                            left: 20,
                                            child: Container(
                                              // width: 60,
                                              alignment: Alignment.center,
                                              child: Text(
                                                  '${_post.minus.length}',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                body: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(_post.postId)
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                    _post = snapshot.data != null
                        ? Post.fromSnap(snapshot.data!)
                        : _post;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          YoutubePlayerControllerProvider(
                            controller: controller,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 8, left: 8, top: 8, bottom: 0),
                              child: Container(
                                decoration: BoxDecoration(
                                    // color: Colors.white,
                                    ),
                                child: Column(
                                  children: [
                                    // Container(
                                    //   height: 4,
                                    //   color: Color.fromARGB(255, 235, 235, 235),
                                    // ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                              top: 6.0,
                                              // right: 10,
                                              left: 10,
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 227, 227, 227),
                                                  backgroundImage: NetworkImage(
                                                    _post.profImage,
                                                  ),
                                                  radius: 18,
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 16,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: _post
                                                                    .username,
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                  letterSpacing:
                                                                      0.5,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 2),
                                                          child: Text(
                                                            DateFormat.yMMMd()
                                                                .format(_post
                                                                    .datePublished
                                                                    .toDate()),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12.5,
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 4.0),
                                                    child: Container(
                                                      // color: Colors.brown,
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: IconButton(
                                                        onPressed: _post.uid ==
                                                                user?.uid
                                                            ? () => _deletePost(
                                                                context)
                                                            : () => _otherUsers(
                                                                context),
                                                        icon: const Icon(
                                                            Icons.more_vert),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.94,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: _post.selected == 0
                                                        ? 0.0
                                                        : 8,
                                                  ),
                                                  child: Text('${_post.title}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                                _post.selected == 2
                                                    ? LayoutBuilder(
                                                        builder: (context,
                                                            constraints) {
                                                          if (kIsWeb &&
                                                              constraints
                                                                      .maxWidth >
                                                                  800) {
                                                            return Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Expanded(
                                                                    child:
                                                                        player),
                                                                const SizedBox(
                                                                  width: 500,
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                          return Container(
                                                            width: 324,
                                                            child: Stack(
                                                              children: [
                                                                player,
                                                                Positioned.fill(
                                                                  child:
                                                                      YoutubeValueBuilder(
                                                                    controller:
                                                                        controller,
                                                                    builder:
                                                                        (context,
                                                                            value) {
                                                                      return AnimatedCrossFade(
                                                                        crossFadeState: value.isReady
                                                                            ? CrossFadeState.showSecond
                                                                            : CrossFadeState.showFirst,
                                                                        duration:
                                                                            const Duration(milliseconds: 300),
                                                                        secondChild:
                                                                            Container(child: const SizedBox.shrink()),
                                                                        firstChild:
                                                                            Material(
                                                                          child:
                                                                              DecoratedBox(
                                                                            child:
                                                                                const Center(
                                                                              child: CircularProgressIndicator(),
                                                                            ),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              image: DecorationImage(
                                                                                image: NetworkImage(
                                                                                  YoutubePlayerController.getThumbnail(
                                                                                    videoId: controller.initialVideoId,
                                                                                    quality: ThumbnailQuality.medium,
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
                                                          );
                                                        },
                                                      )
                                                    : _post.selected == 1
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            FullImageScreen(
                                                                              post: _post,
                                                                            )),
                                                              );
                                                            },
                                                            child: Container(
                                                              // height: 150,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.445,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.89,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      245,
                                                                      245,
                                                                      245),

                                                              child: FittedBox(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                fit: BoxFit
                                                                    .contain,
                                                                child: Image
                                                                    .network(
                                                                  _post.postUrl,
                                                                  // fit: BoxFit.fill,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                _post.body != ""
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 8,
                                                          bottom: 14,
                                                        ),
                                                        child: Text(
                                                            '${_post.body}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                            )),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 14.0),
                                                        child: Container(),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Container(
                          //   height: 4,
                          //   color: Color.fromARGB(255, 236, 234, 234),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 8.0, left: 8, top: 8, bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          // right: 8,
                                          left: 14,
                                          top: 16,
                                          bottom: 4,
                                        ),
                                        child: Container(
                                          // height: 30,
                                          child: StreamBuilder(
                                            stream: _selectedCommentFilter
                                                        .value ==
                                                    'all'
                                                ? FirebaseFirestore.instance
                                                    .collection('posts')
                                                    .doc(_post.postId)
                                                    .collection('comments')

                                                    // Sort
                                                    .orderBy(
                                                        _selectedCommentSort
                                                            .key,
                                                        descending:
                                                            _selectedCommentSort
                                                                .value)
                                                    .snapshots()
                                                : FirebaseFirestore.instance
                                                    .collection('posts')
                                                    .doc(_post.postId)
                                                    .collection('comments')
                                                    .orderBy(
                                                        _selectedCommentSort
                                                            .key,
                                                        descending:
                                                            _selectedCommentSort
                                                                .value)
                                                    // Filter
                                                    .where(
                                                        _selectedCommentFilter
                                                            .value,
                                                        whereIn: (_post
                                                                .toJson()[
                                                                    _selectedCommentFilter
                                                                        .key]
                                                                .isNotEmpty
                                                            ? _post.toJson()[
                                                                _selectedCommentFilter
                                                                    .key]
                                                            : [
                                                                'placeholder_uid'
                                                              ]))

                                                    // Sort
                                                    // .orderBy(_selectedCommentSort.key,
                                                    //     descending:
                                                    //         _selectedCommentSort
                                                    //             .value)
                                                    .snapshots(),
                                            builder: (content, snapshot) {
                                              return Text(
                                                'Comments (${(snapshot.data as dynamic)?.docs.length ?? 0})',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    letterSpacing: 0.8),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            filter = !filter;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10,
                                            top: 10,
                                          ),
                                          child: Container(
                                            width: 40,
                                            // color: Colors.brown,
                                            child: Stack(
                                              children: [
                                                const Icon(
                                                  Icons.filter_list,
                                                  color: Colors.black,
                                                ),
                                                Positioned(
                                                  right: -3,
                                                  child: Icon(
                                                      filter == false
                                                          ? Icons
                                                              .arrow_drop_down
                                                          : Icons.arrow_drop_up,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  filter == false
                                      ? Container()
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              left: 14.0,
                                              right: 14,
                                              top: 10,
                                              bottom: 1),
                                          child: Container(
                                            color: Colors.white,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 0,
                                                    color: Color.fromARGB(
                                                        255, 224, 224, 224)),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color.fromARGB(
                                                    255, 245, 245, 245),
                                              ),
                                              // height: 108,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 10,
                                                  top: 10,
                                                  bottom: 10,
                                                ),
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Sort:   ',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                                letterSpacing:
                                                                    0.8),
                                                          ),
                                                          Row(
                                                            children: [
                                                              ...List.generate(
                                                                  commentSorts
                                                                      .length,
                                                                  (index) {
                                                                CommentSort
                                                                    commentSort =
                                                                    commentSorts[
                                                                        index];
                                                                return InkResponse(
                                                                  child: Row(
                                                                    children: [
                                                                      PhysicalModel(
                                                                        color: _selectedCommentSort ==
                                                                                commentSort
                                                                            ? Colors
                                                                                .grey
                                                                            : Color.fromARGB(
                                                                                255,
                                                                                247,
                                                                                245,
                                                                                245),
                                                                        elevation:
                                                                            2,
                                                                        // shadowColor: Colors.black,
                                                                        borderRadius:
                                                                            BorderRadius.circular(25),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              horizontal: 12.0,
                                                                              vertical: 8),
                                                                          child: Text(
                                                                              commentSort.label,
                                                                              style: TextStyle(color: _selectedCommentSort == commentSort ? Colors.white : Color.fromARGB(255, 111, 111, 111))),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                          width:
                                                                              10),
                                                                    ],
                                                                  ),
                                                                  onTap: () =>
                                                                      setState(
                                                                    () {
                                                                      _selectedCommentSort =
                                                                          commentSort;
                                                                    },
                                                                  ),
                                                                );
                                                              })
                                                            ],
                                                          ),
                                                          // Expanded(
                                                          //   child:
                                                          //       Padding(
                                                          //     padding: const EdgeInsets
                                                          //             .only(
                                                          //         right:
                                                          //             12.0),
                                                          //     child:
                                                          //         Align(
                                                          //       alignment:
                                                          //           Alignment.centerRight,
                                                          //       child:
                                                          //           InkWell(
                                                          //         onTap:
                                                          //             () {
                                                          //           setState(() {
                                                          //             filter = !filter;
                                                          //           });
                                                          //         },
                                                          //         child:
                                                          //             Container(
                                                          //           height:
                                                          //               30,
                                                          //           child:
                                                          //               Icon(
                                                          //             Icons.close,
                                                          //           ),
                                                          //         ),
                                                          //       ),
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                      Container(height: 10),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 0.0),
                                                        child: Row(
                                                          children: [
                                                            Text('Filter: ',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15,
                                                                    letterSpacing:
                                                                        0.8)),
                                                            Container(
                                                              height: 39,
                                                              // width: 286,
                                                              width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      1 -
                                                                  105,
                                                              child:
                                                                  SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          2.0),
                                                                  child: Row(
                                                                    children: [
                                                                      ...List.generate(
                                                                          commentFilters
                                                                              .length,
                                                                          (index) {
                                                                        CommentFilter
                                                                            commentFilter =
                                                                            commentFilters[index];
                                                                        return InkResponse(
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              PhysicalModel(
                                                                                color: _selectedCommentFilter == commentFilter ? Colors.grey : Color.fromARGB(255, 247, 245, 245),
                                                                                elevation: 2,
                                                                                // shadowColor: Colors.black,
                                                                                borderRadius: BorderRadius.circular(25),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Text(
                                                                                        commentFilter.label,
                                                                                        style: TextStyle(color: _selectedCommentFilter == commentFilter ? Colors.white : Color.fromARGB(255, 111, 111, 111)),
                                                                                      ),
                                                                                      commentFilter.icon ??
                                                                                          // Container(),
                                                                                          commentFilter.rotatedBox ??
                                                                                          Row(),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Container(width: 10),
                                                                            ],
                                                                          ),
                                                                          onTap: () =>
                                                                              setState(
                                                                            () {
                                                                              _selectedCommentFilter = commentFilter;
                                                                            },
                                                                          ),
                                                                        );
                                                                      })
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
                                            ),
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      // right: 8.0,
                                      // left: 8,
                                      bottom: 8,
                                    ),
                                    child: Container(
                                      color: Colors.white,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            // color: Colors.orange,
                                            child: Padding(
                                              // padding: const EdgeInsets.only(left: 8.0),
                                              padding: const EdgeInsets.only(
                                                left: 16.0,
                                                top: 14,
                                              ),
                                              child: CircleAvatar(
                                                backgroundColor: Color.fromARGB(
                                                    255, 227, 227, 227),
                                                backgroundImage: NetworkImage(
                                                  user?.photoUrl ?? '',
                                                ),
                                                radius: 18,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 14, right: 14.0),
                                              child: Container(
                                                // height: 40,
                                                // color: Colors.grey,
                                                child: TextField(
                                                  controller:
                                                      _commentController,
                                                  maxLines: null,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Write a comment...',
                                                    // hintText: 'Comment as ${user.username}',
                                                    // border: InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: Colors.grey),
                                                    labelStyle: TextStyle(
                                                        color: Colors.black),
                                                    contentPadding:
                                                        EdgeInsets.only(top: 8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          performLoggedUserAction(
                                              context: context,
                                              action: () async {
                                                await FirestoreMethods()
                                                    .postComment(
                                                        _post.postId,
                                                        _commentController.text,
                                                        user?.uid ?? '',
                                                        user?.username ?? '',
                                                        user?.photoUrl ?? '');
                                                setState(() {
                                                  _commentController.text = "";
                                                });
                                              });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0, bottom: 12),
                                          child: Row(
                                            children: [
                                              Icon(Icons.send,
                                                  color: Colors.blueAccent,
                                                  size: 12),
                                              Container(width: 3),
                                              Text(
                                                'SEND',
                                                style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  StreamBuilder(
                                    stream: _selectedCommentFilter.value ==
                                            'all'
                                        ? FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(_post.postId)
                                            .collection('comments')

                                            // Sort
                                            .orderBy(_selectedCommentSort.key,
                                                descending:
                                                    _selectedCommentSort.value)
                                            .snapshots()
                                        : FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(_post.postId)
                                            .collection('comments')

                                            // Filter
                                            .where(_selectedCommentFilter.value,
                                                whereIn: (_post
                                                        .toJson()[
                                                            _selectedCommentFilter
                                                                .key]
                                                        .isNotEmpty
                                                    ? _post.toJson()[
                                                        _selectedCommentFilter
                                                            .key]
                                                    : ['placeholder_uid']))

                                            // Sort
                                            .orderBy(_selectedCommentSort.key,
                                                descending:
                                                    _selectedCommentSort.value)
                                            .snapshots(),
                                    builder: (content, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return widget.post.comments == null
                                            ? const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )
                                            : CommentList(
                                                commentSnaps:
                                                    (widget.post.comments
                                                                as dynamic)
                                                            ?.docs ??
                                                        [],
                                                post: widget.post,
                                                parentSetState: () {
                                                  setState(() {});
                                                },
                                              );
                                      }
                                      widget.post.comments =
                                          (snapshot.data as dynamic);

                                      return CommentList(
                                        commentSnaps:
                                            (snapshot.data as dynamic)?.docs ??
                                                [],
                                        post: _post,
                                        parentSetState: () {
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        });
  }
}

class CommentList extends StatelessWidget {
  final commentSnaps;
  final Post post;
  final Function parentSetState;

  const CommentList({
    super.key,
    required this.commentSnaps,
    required this.post,
    required this.parentSetState,
  });

  @override
  Widget build(BuildContext context) {
    return commentSnaps.isEmpty
        ? const Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 40),
            child: Center(
              child: Text('No comments yet.',
                  style: TextStyle(
                      fontSize: 20,

                      // fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 95, 95, 95))),
            ),
          )
        : ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: commentSnaps.length,
            itemBuilder: (context, index) {
              var commentSnap = commentSnaps[index].data();

              return CommentCard(
                snap: commentSnap,
                parentPost: post,
                postId: post.postId,
                minus: post.minus.contains(commentSnap['uid']),
                neutral: post.neutral.contains(commentSnap['uid']),
                plus: post.plus.contains(commentSnap['uid']),
                parentSetState: parentSetState,
              );
            },
          );
  }
}
