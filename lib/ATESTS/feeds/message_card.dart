import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../methods/firestore_methods.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../other/utils.dart.dart';
import '../provider/user_provider.dart';
import '../screens/full_image_screen.dart';
import '../screens/full_message.dart';
import '../screens/profile_screen.dart';
import '../screens/report_user_screen.dart';
import '../screens/like_animation.dart';

class PostCardTest extends StatefulWidget {
  final Post post;
  final indexPlacement;
  const PostCardTest({
    Key? key,
    required this.post,
    required this.indexPlacement,
  }) : super(key: key);

  @override
  State<PostCardTest> createState() => _PostCardTestState();
}

class _PostCardTestState extends State<PostCardTest> {
  late Post _post;
  late YoutubePlayerController controller;
  bool isLikeAnimating = false;
  int commentLen = 0;
  String placement = '';
  var testt = 21100;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    placement = '#${(widget.indexPlacement + 1).toString()}';
    controller = YoutubePlayerController(
      // initialVideoId: '${widget.snap['videoUrl']}',
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
          // .doc(widget.snap['postId'])
          .doc(_post.postId)
          .collection('comments')
          .get();

      commentLen = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    // setState(() {});
  }

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
              // SimpleDialogOption(
              //   padding: const EdgeInsets.all(20),
              //   child: Row(
              //     children: [
              //       Icon(Icons.clear),
              //       Container(width: 10),
              //       const Text('Close',
              //           style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
              //     ],
              //   ),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     InkWell(
              //       onTap: () {
              //         Navigator.of(context).pop();
              //       },
              //       child: Text(
              //         'Close',
              //         style: TextStyle(
              //             letterSpacing: 0.2,
              //             fontSize: 15,
              //             color: Colors.blueAccent),
              //       ),
              //     ),
              //     Container(height: 8),
              //   ],
              // ),
              // SimpleDialogOption(
              //   padding: const EdgeInsets.all(20),
              //   child: Row(
              //     children: [
              //       Icon(Icons.clear),
              //       Container(width: 10),
              //       const Text('Close',
              //           style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
              //     ],
              //   ),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
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
              // SimpleDialogOption(
              //   padding: const EdgeInsets.all(20),
              //   child: Row(
              //     children: [
              //       Icon(Icons.clear),
              //       Container(width: 10),
              //       const Text('Close',
              //           style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
              //     ],
              //   ),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     InkWell(
              //       onTap: () {
              //         Navigator.of(context).pop();
              //       },
              //       child: Text(
              //         'Close',
              //         style: TextStyle(
              //             letterSpacing: 0.2,
              //             fontSize: 15,
              //             color: Colors.blueAccent),
              //       ),
              //     ),
              //     Container(height: 8),
              //   ],
              // ),
            ],
          );
        });
  }
  // showDialog(
  //   context: context,
  //   builder: (context) => Dialog(
  //     child: ListView(
  //         padding: const EdgeInsets.symmetric(
  //           vertical: 16,
  //         ),
  //         shrinkWrap: true,
  //         children: ['Delete']
  //             .map(
  //               (e) => InkWell(
  //                 onTap: () async {
  //                   FirestoreMethods().deletePost(_post.postId);
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Container(
  //                   padding: const EdgeInsets.symmetric(
  //                       vertical: 12, horizontal: 16),
  //                   child: Text(e),
  //                 ),
  //               ),
  //             )
  //             .toList()),
  //   ),

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
    // if (user == null) {
    //   return const Center(
    //       child: CircularProgressIndicator(
    //     color: Colors.black,
    //   ));
    // }
    print('_post.username: ${_post.username}');
    print(' _post.global == true: ${_post.global == 'true'}');
    return YoutubePlayerControllerProvider(
      controller: controller,
      child: Padding(
        padding: widget.indexPlacement == 0
            ? EdgeInsets.only(
                bottom: 8,
                right: 8,
                left: 8,
                top: 8,
              )
            : EdgeInsets.only(
                bottom: 8,
                right: 8,
                left: 8,
              ),
        child: Container(
          decoration: BoxDecoration(
            // border: Border.all(width: 2, color: Colors.black),
            border:
                Border.all(width: 0, color: Color.fromARGB(255, 167, 167, 167)),
            borderRadius: BorderRadius.circular(8),
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
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Profile(
                                        post: _post,
                                      )),
                            );
                          },
                          child: CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  Color.fromARGB(255, 227, 227, 227),
                              // backgroundImage: NetworkImage(widget.snap['profImage']),
                              backgroundImage: NetworkImage(_post.profImage))),
                      //       backgroundImage: _post.profImage != ""
                      //           ? NetworkImage(_post.profImage)
                      //           :
                      //           NetworkImage(
                      //               'https://images.nightcafe.studio//assets/profile.png?tr=w-1600,c-at_max')),
                      // ),
                      SizedBox(width: 10),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          // color: Colors.green,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  // color: Colors.grey,

                                  child: Text(
                                _post.username,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 0.5),
                              )),
                              SizedBox(height: 2),
                              Text(
                                DateFormat.yMMMd().format(
                                  _post.datePublished.toDate(),
                                ),
                                style: const TextStyle(
                                    fontSize: 12.5, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          // color: Colors.brown,
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: _post.uid == user?.uid
                                ? () => _deletePost(context)
                                : () => _otherUsers(context),
                            // showDialog(
                            //   context: context,
                            //   builder: (context) => Dialog(
                            //     child: ListView(
                            //         padding: const EdgeInsets.symmetric(
                            //           vertical: 16,
                            //         ),
                            //         shrinkWrap: true,
                            //         children: ['Delete', 'Hi']
                            //             .map(
                            //               (e) => InkWell(
                            //                 onTap: () async {
                            //                   FirestoreMethods()
                            //                       .deletePost(_post.postId);
                            //                   Navigator.of(context).pop();
                            //                 },
                            //                 child: Container(
                            //                   padding: const EdgeInsets
                            //                           .symmetric(
                            //                       vertical: 12,
                            //                       horizontal: 16),
                            //                   child: Text(e),
                            //                 ),
                            //               ),
                            //             )
                            //             .toList()),
                            //   ),
                            // );

                            icon: const Icon(Icons.more_vert),
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
                            builder: (context) => FullMessage(
                                post: _post,
                                indexPlacement: widget.indexPlacement)),
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
                            padding: EdgeInsets.only(
                                top: 8, bottom: _post.selected != 0 ? 4 : 0),
                            child: Container(
                              // width: 300,

                              width: MediaQuery.of(context).size.width * 0.88,

                              child: Text(
                                '${_post.title}', textAlign: TextAlign.center,
                                // maxLines: 8,
                                // overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          // Padding(
                          //   padding: const EdgeInsets.only(right: 5.0),
                          //   child:
                          //   Container(player),
                          //   Text(
                          //     '${widget.snap['body']}',
                          //     maxLines: 11,
                          //     overflow: TextOverflow.ellipsis,
                          //     style: TextStyle(),
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(right: 8.0),
                          //   child: player,
                          // ),
                          _post.selected == 1
                              ? InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FullImageScreen(
                                                post: _post,
                                              )),
                                    );
                                  },
                                  child: Container(
                                    // height: 150,
                                    height: MediaQuery.of(context).size.width *
                                        0.445,
                                    width: MediaQuery.of(context).size.width *
                                        0.89,
                                    color: Color.fromARGB(255, 245, 245, 245),

                                    child: Image.network(
                                      _post.postUrl,
                                      // fit: BoxFit.fill,
                                    ),
                                  ),
                                )
                              : _post.selected == 3
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
                  top: 8,
                ),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    // color: Colors.orange,
                    border: Border(
                      top: BorderSide(
                          width: 1, color: Color.fromARGB(255, 218, 216, 216)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        // color: Colors.blue,
                        height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                width: 90,
                                height: 39,
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 12.0),
                                        child: Text(placement,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                            )),
                                      )
                                    ])),
                            Container(
                              // color: Colors.green,
                              width: 88,
                              height: 19.3,
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Score:',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                          letterSpacing: 0.8)),
                                  Text(
                                    // testt > 10000
                                    //     ? testt.toString().replaceRange(
                                    //         3, testt.toString().length, 'k')
                                    //     : testt.toString(),
                                    // ' ${widget.snap['plus'].length - widget.snap['minus'].length}',
                                    ' ${_post.plus.length - _post.minus.length}',
                                    // ' 32.4k',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
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
                              width: 59,
                              // color: Colors.orange,
                              child: LikeAnimation(
                                isAnimating: _post.plus.contains(user?.uid),
                                child: IconButton(
                                  iconSize: 25,
                                  onPressed: () {
                                    performLoggedUserAction(
                                        context: context,
                                        action: () async {
                                          await FirestoreMethods().plusMessage(
                                            _post.postId,
                                            user?.uid ?? '',
                                            _post.plus,
                                          );
                                          FirestoreMethods().scoreMessage(
                                              _post.postId,
                                              user?.uid ?? "",
                                              _post.plus.length -
                                                  _post.minus.length);
                                        });
                                  },
                                  icon: _post.plus.contains(user?.uid)
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
                            // color: Colors.blue,
                            child: LikeAnimation(
                              isAnimating: _post.neutral.contains(user?.uid),
                              child: IconButton(
                                iconSize: 25,
                                onPressed: () {
                                  performLoggedUserAction(
                                      context: context,
                                      action: () async {
                                        await FirestoreMethods().neutralMessage(
                                          _post.postId,
                                          user?.uid ?? '',
                                          _post.neutral,
                                        );
                                        FirestoreMethods().scoreMessage(
                                            _post.postId,
                                            user?.uid ?? '',
                                            _post.plus.length -
                                                _post.minus.length);
                                      });
                                },
                                icon: _post.neutral.contains(user?.uid)
                                    ? RotatedBox(
                                        quarterTurns: 1,
                                        child: Icon(
                                          Icons.pause_circle_filled,
                                          color: Color.fromARGB(
                                              255, 111, 111, 111),
                                        ),
                                      )
                                    : RotatedBox(
                                        quarterTurns: 1,
                                        child: Icon(
                                          Icons.pause_circle_filled,
                                          color: Color.fromARGB(
                                              255, 206, 204, 204),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 42,
                            // right: 24,
                            child: Container(
                              width: 59,
                              // color: Colors.yellow,
                              alignment: Alignment.center,
                              child: Text('${_post.neutral.length}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.topCenter,
                            height: 60,
                            width: 59,
                            child: LikeAnimation(
                              isAnimating: _post.minus.contains(user?.uid),
                              child: Container(
                                child: IconButton(
                                  iconSize: 25,
                                  onPressed: () {
                                    performLoggedUserAction(
                                        context: context,
                                        action: () async {
                                          await FirestoreMethods().minusMessage(
                                            _post.postId,
                                            user?.uid ?? '',
                                            _post.minus,
                                          );
                                          FirestoreMethods().scoreMessage(
                                              _post.postId,
                                              user?.uid ?? '',
                                              _post.plus.length -
                                                  _post.minus.length);
                                        });
                                  },
                                  icon: _post.minus.contains(user?.uid)
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
                  top: 8,
                ),
                child: Container(
                  width: 360,
                  // decoration: BoxDecoration(
                  //   border: Border(
                  //     top: BorderSide(
                  //         width: 1, color: Color.fromARGB(255, 218, 216, 216)),
                  //   ),
                  // ),
                  // color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullMessage(
                              post: _post,
                              indexPlacement: widget.indexPlacement),
                        ),
                      ),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.comment_outlined,
                              size: 15,
                              color: Color.fromARGB(255, 132, 132, 132),
                            ),
                            Container(width: 8),
                            Container(
                              child: Center(
                                // child: Text(
                                //   '$commentLen Comments',
                                //   style: const TextStyle(
                                //       fontSize: 13,
                                //       color:
                                //           Color.fromARGB(255, 132, 132, 132),
                                //       letterSpacing: 0.8),
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
