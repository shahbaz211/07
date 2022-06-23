import 'dart:developer';
import 'package:aft/ATESTS/models/APost.dart';
import 'package:aft/ATESTS/screens/full_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/AUser.dart';
import '../provider/AUserProvider.dart';
import '../methods/AFirestoreMethods.dart';
import '../other/AUtils.dart';
import 'ALikeAnimation.dart';

class PostCardTest extends StatefulWidget {
  final Post post;

  const PostCardTest({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<PostCardTest> createState() => _PostCardTestState();
}

class _PostCardTestState extends State<PostCardTest> {
  late Post _post;
  late YoutubePlayerController controller;
  bool isLikeAnimating = false;
  int commentLen = 0;
  String placement = '#86';
  var testt = 21100;

  @override
  void initState() {
    print('POST CARD TEST INIT CALLED');
    _post = widget.post;
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
    getComments();
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(_post.postId)
          .collection('comments')
          .get();

      commentLen = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  // @override
  // void deactivate() {
  //   controller.pause();
  //   super.deactivate();
  // }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    _post = widget.post;
    const player = YoutubePlayerIFrame(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
    );
    final User? user = Provider.of<UserProvider>(context).getUser;
    if (user == null) {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.black,
      ));
    }

    print('_post.username: ${_post.username}');
    print(' _post.global == true: ${_post.global == 'true'}');

    return YoutubePlayerControllerProvider(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          right: 8,
          left: 8,
        ),
        child: Container(
          decoration: BoxDecoration(
            // border: Border.all(width: 2, color: Colors.black),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Container(
                // color: Colors.orange,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 6,
                    // bottom: 6,
                  ),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(_post.profImage),
                      ),
                      SizedBox(width: 8),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          // color: Colors.green,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // color: Colors.grey,
                                child:
                                    // _post.global == 'true' ?
                                    Text(
                                  _post.username,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      letterSpacing: 1),
                                )
                                // : null
                                ,
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat.yMMMd().format(
                                  _post.datePublished.toDate(),
                                ),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Container(
                            // color: Colors.brown,
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: ListView(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shrinkWrap: true,
                                        children: [
                                          'Delete',
                                        ]
                                            .map(
                                              (e) => InkWell(
                                                onTap: () async {
                                                  FirestoreMethods()
                                                      .deletePost(_post.postId);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                                  child: Text(e),
                                                ),
                                              ),
                                            )
                                            .toList()),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.more_vert),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // GestureDetector(
              //   onDoubleTap: () async {
              //     await FirestoreMethods().likePost(
              //       widget.snap['postId'],
              //       user.uid,
              //       widget.snap['likes'],
              //     );
              //     setState(() {
              //       isLikeAnimating = true;
              //     });
              //   },
              // child:
              // Stack(
              //   alignment: Alignment.center,
              //   children: [
              //     SizedBox(
              //       height: MediaQuery.of(context).size.height * 0.35,
              //       width: double.infinity,
              //       child: Image.network(
              //         widget.snap['postUrl'],
              //         fit: BoxFit.cover,
              //       ),
              //     ),
              //   ],
              // ),
              //       AnimatedOpacity(
              //         duration: const Duration(milliseconds: 200),
              //         opacity: isLikeAnimating ? 1 : 0,
              //         child: LikeAnimation(
              //           child: const Icon(Icons.favorite,
              //               color: Colors.redAccent, size: 120),
              //           isAnimating: isLikeAnimating,
              //           duration: const Duration(
              //             milliseconds: 400,
              //           ),
              //           onEnd: () {
              //             setState(() {
              //               isLikeAnimating = false;
              //             });
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullMessage(post: _post)),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,

                      // height: 314,
                      // width: 273,
                      // constraints:
                      //     BoxConstraints(minHeight: 314, minWidth: 273),
                      // color: Colors.blue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              alignment: Alignment.center,
                              width: 300,
                              child: Text(
                                '${_post.title}',
                                // maxLines: 8,
                                // overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          _post.selected == 1
                              ? InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.white,
                                            ),
                                            width: 45,
                                            alignment: Alignment.bottomLeft,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: IconButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                icon: const Icon(Icons.close,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                          SimpleDialog(
                                              contentPadding: EdgeInsets.zero,
                                              insetPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8),
                                              children: [
                                                InteractiveViewer(
                                                  clipBehavior: Clip.none,
                                                  minScale: 1,
                                                  maxScale: 4,
                                                  child: Container(
                                                    color: Colors.white,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.87,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.9,
                                                    child: Image.network(
                                                      _post.postUrl,
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    // height: 150,
                                    height: 182,
                                    width: 324,
                                    color: Color.fromARGB(255, 239, 238, 238),

                                    child: FittedBox(
                                      alignment: Alignment.center,
                                      fit: BoxFit.contain,
                                      child: Image.network(
                                        _post.postUrl,
                                        // fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                )
                              : _post.selected == 2
                                  ? LayoutBuilder(
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
                                        width: 324,
                                        child: Stack(
                                          children: [
                                            player,
                                            Positioned.fill(
                                              child: YoutubeValueBuilder(
                                                controller: controller,
                                                builder: (context, value) {
                                                  return AnimatedCrossFade(
                                                    crossFadeState:
                                                        value.isReady
                                                            ? CrossFadeState
                                                                .showSecond
                                                            : CrossFadeState
                                                                .showFirst,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    secondChild: Container(
                                                        child: const SizedBox
                                                            .shrink()),
                                                    firstChild: Material(
                                                      child: DecoratedBox(
                                                        child: const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
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
                                      );
                                    })
                                  : Container()
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          width: 1, color: Color.fromARGB(255, 218, 216, 216)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        child: Stack(
                          children: [
                            Container(
                              alignment: Alignment.topCenter,
                              height: 60,
                              width: 59,
                              // color: Colors.orange,
                              child: LikeAnimation(
                                isAnimating: _post.plus.contains(user.uid),
                                child: IconButton(
                                  iconSize: 25,
                                  onPressed: () async {
                                    await FirestoreMethods().plusMessage(
                                      _post.postId,
                                      user.uid,
                                      _post.plus,
                                    );
                                  },
                                  icon: _post.plus.contains(user.uid)
                                      ? Icon(
                                          Icons.add_circle,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          Icons.add_circle,
                                          color: Color.fromARGB(
                                              255, 206, 204, 204),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 42,
                              child: Container(
                                width: 59,
                                alignment: Alignment.center,
                                child: Text('${_post.plus.length}',
                                    // '32.4k',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
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
                            width: 59,
                            child: LikeAnimation(
                              isAnimating: _post.minus.contains(user.uid),
                              child: IconButton(
                                iconSize: 25,
                                onPressed: () async {
                                  await FirestoreMethods().minusMessage(
                                    _post.postId,
                                    user.uid,
                                    _post.minus,
                                  );
                                },
                                icon: _post.minus.contains(user.uid)
                                    ? Icon(
                                        Icons.do_not_disturb_on,
                                        color: Colors.red,
                                      )
                                    : Icon(
                                        Icons.do_not_disturb_on,
                                        color:
                                            Color.fromARGB(255, 206, 204, 204),
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 42,
                            child: Container(
                              width: 59,
                              alignment: Alignment.center,
                              child: Text('${_post.minus.length}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                  top: 10,
                ),
                child: Container(
                  width: 360,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          width: 1, color: Color.fromARGB(255, 218, 216, 216)),
                    ),
                  ),
                  // color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullMessage(
                            post: _post,
                          ),
                        ),
                      ),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FullMessage(
                                    post: _post,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.comment_outlined,
                                size: 15,
                                color: Color.fromARGB(255, 132, 132, 132),
                              ),
                            ),
                            Container(width: 8),
                            InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FullMessage(
                                    post: _post,
                                  ),
                                ),
                              ),
                              child: Container(
                                child: Center(
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(_post.postId)
                                        .collection('comments')
                                        .snapshots(),
                                    builder: (content, snapshot) {
                                      print(
                                          'BEFORE SNAPSHOT _post.comments: ${widget.post.comments}');

                                      return Text(
                                        '${(snapshot.data as dynamic)?.docs.length ?? 0} Comments',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color.fromARGB(
                                                255, 132, 132, 132),
                                            letterSpacing: 0.8),
                                      );
                                    },
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
