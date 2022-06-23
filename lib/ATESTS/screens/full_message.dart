import 'dart:developer';
import 'package:aft/ATESTS/models/APost.dart';
import 'package:aft/ATESTS/models/AUser.dart';
import 'package:aft/ATESTS/provider/AUserProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../methods/AFirestoreMethods.dart';

import 'ALikeAnimation.dart';
import 'comment_card.dart';

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
  final String key;
  final String value;

  CommentFilter({
    required this.label,
    this.icon,
    required this.key,
    required this.value,
  });
}

class FullMessage extends StatefulWidget {
  final Post post;

  const FullMessage({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<FullMessage> createState() => _FullMessageState();
}

class _FullMessageState extends State<FullMessage> {
  late Post _post;

  final TextEditingController _commentController = TextEditingController();
  late YoutubePlayerController controller;
  bool isLikeAnimating = false;
  int commentLen = 0;
  String placement = '#338';
  bool filter = false;

  List<CommentSort> commentSorts = [
    CommentSort(label: 'Most Popular', key: 'likes', value: true),
    CommentSort(label: 'Most Recent', key: 'datePublished', value: true),
  ];

  List<CommentFilter> commentFilters = [
    CommentFilter(
      label: 'All',
      key: 'commentId',
      value: 'all',
    ),
    CommentFilter(
      label: 'Voted',
      icon: const Icon(
        Icons.add_circle,
        color: Colors.green,
        size: 15,
      ),
      key: 'plus',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Voted',
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

  @override
  void initState() {
    _post = widget.post;
    _selectedCommentSort = commentSorts.first;
    _selectedCommentFilter = commentFilters.first;

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
    if (user == null) {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.black,
      ));
    }

    print("_selectedCommentFilter.key: ${_selectedCommentFilter.key}");
    print("_post.toJson(): ${_post.toJson()}");
    print(
        "_post.toJson()[_selectedCommentFilter.key]: ${_post.toJson()[_selectedCommentFilter.key]}");

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 1.5,
          toolbarHeight: 50,
          actions: [
            Container(
              width: 360,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close, color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        child: Center(
                          child: Text('',
                              style: TextStyle(
                                  fontSize: 23,
                                  letterSpacing: 2.5,
                                  color: Colors.black)),
                        ),
                      ),
                      Container(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {},
                            icon:
                                const Icon(Icons.settings, color: Colors.black),
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
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            _post =
                snapshot.data != null ? Post.fromSnap(snapshot.data!) : _post;
            return SingleChildScrollView(
              child: Column(
                children: [
                  YoutubePlayerControllerProvider(
                    controller: controller,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          right: 10,
                          left: 10,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      _post.profImage,
                                    ),
                                    radius: 18,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: _post.username,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    letterSpacing: 1,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              DateFormat.yMMMd().format(
                                                  _post.datePublished.toDate()),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color.fromARGB(
                                                      255, 123, 122, 122)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: Container(
                                        // color: Colors.brown,
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                child: ListView(
                                                    padding: const EdgeInsets
                                                        .symmetric(
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
                                                                  .deletePost(_post
                                                                      .postId);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Container(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 12,
                                                                  horizontal:
                                                                      16),
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
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  // minHeight: 440.0,
                                  ),
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text('${_post.title}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                    _post.selected == 2
                                        ? LayoutBuilder(
                                            builder: (context, constraints) {
                                              if (kIsWeb &&
                                                  constraints.maxWidth > 800) {
                                                return Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Expanded(
                                                        child: player),
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
                                              );
                                            },
                                          )
                                        : _post.selected == 1
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 0.0),
                                                child: Material(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            Column(
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              width: 45,
                                                              alignment: Alignment
                                                                  .bottomLeft,
                                                              child: Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child:
                                                                    IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            ),
                                                            SimpleDialog(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                insetPadding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            8),
                                                                children: [
                                                                  InteractiveViewer(
                                                                    clipBehavior:
                                                                        Clip.none,
                                                                    minScale: 1,
                                                                    maxScale: 4,
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                          .black,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.87,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.9,
                                                                      child: Image
                                                                          .network(
                                                                        _post
                                                                            .postUrl,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 182,
                                                      width: 324,
                                                      color: Color.fromARGB(
                                                          255, 239, 238, 238),
                                                      child: FittedBox(
                                                        fit: BoxFit.contain,
                                                        child: Image.network(
                                                          _post.postUrl,
                                                          // fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                    _post.body != ""
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                              bottom: 14,
                                            ),
                                            child: Text('${_post.body}'),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 14.0),
                                            child: Container(),
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
                                                width: 1,
                                                color: Color.fromARGB(
                                                    255, 218, 216, 216)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    height: 60,
                                                    width: 59,
                                                    // color: Colors.orange,
                                                    child: IconButton(
                                                      iconSize: 25,
                                                      onPressed: () async {
                                                        await FirestoreMethods()
                                                            .plusMessage(
                                                          _post.postId,
                                                          user.uid,
                                                          _post.plus,
                                                        );
                                                      },
                                                      icon: _post.plus.contains(
                                                              user.uid)
                                                          ? const Icon(
                                                              Icons.add_circle,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : const Icon(
                                                              Icons.add_circle,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      206,
                                                                      204,
                                                                      204),
                                                            ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 42,
                                                    child: Container(
                                                      width: 59,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                          '${_post.plus.length}',
                                                          // '32.4k',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Stack(
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  height: 60,
                                                  width: 59,
                                                  child: IconButton(
                                                    iconSize: 25,
                                                    onPressed: () async {
                                                      await FirestoreMethods()
                                                          .minusMessage(
                                                        _post.postId,
                                                        user.uid,
                                                        _post.minus,
                                                      );
                                                    },
                                                    icon: _post.minus
                                                            .contains(user.uid)
                                                        ? Icon(
                                                            Icons
                                                                .do_not_disturb_on,
                                                            color: Colors.red,
                                                          )
                                                        : Icon(
                                                            Icons
                                                                .do_not_disturb_on,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    206,
                                                                    204,
                                                                    204),
                                                          ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 42,
                                                  child: Container(
                                                    width: 59,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        '${_post.minus.length}',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 12,
                    color: Color.fromARGB(255, 236, 234, 234),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8),
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 8,
                              left: 8,
                              top: 16,
                              bottom: 8,
                            ),
                            child: Container(
                              height: 30,
                              child: StreamBuilder(
                                stream: _selectedCommentFilter.value == 'all'
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
                                        // Sort
                                        .orderBy(_selectedCommentSort.key,
                                            descending:
                                                _selectedCommentSort.value)
                                        // Filter
                                        .where(_selectedCommentFilter.value,
                                            whereIn: (_post
                                                    .toJson()[
                                                        _selectedCommentFilter
                                                            .key]
                                                    .isNotEmpty
                                                ? _post.toJson()[
                                                    _selectedCommentFilter.key]
                                                : ['placeholder_uid']))
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
                          filter == false
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      filter = !filter;
                                    });
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    child: const Icon(Icons.filter_list,
                                        color: Colors.black),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                      left: 8,
                      bottom: 12,
                    ),
                    child: Container(
                      color: Colors.white,
                      child: PhysicalModel(
                        color: Color.fromARGB(255, 247, 245, 245),
                        elevation: 2,
                        // shadowColor: Colors.black,
                        borderRadius: BorderRadius.circular(0),
                        child: Row(
                          children: [
                            Container(
                              // color: Colors.orange,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    user.photoUrl,
                                  ),
                                  radius: 18,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 8.0),
                                child: Container(
                                  child: TextField(
                                    controller: _commentController,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintText: 'Write a comment...',
                                      // hintText: 'Comment as ${user.username}',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                await FirestoreMethods().postComment(
                                    _post.postId,
                                    _commentController.text,
                                    user.uid,
                                    user.username,
                                    user.photoUrl);
                                setState(() {
                                  _commentController.text = "";
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.send,
                                        color: Colors.blueAccent, size: 12),
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
                      ),
                    ),
                  ),
                  filter == false
                      ? Container()
                      : Container(
                          // decoration: BoxDecoration(
                          //   // color: Colors.blue,
                          //   border: Border(
                          //     top: BorderSide(
                          //         width: 1,
                          //         color: Color.fromARGB(255, 218, 216, 216)),
                          //   ),
                          // ),
                          height: 108,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                              left: 16,
                              top: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Sort:   ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          letterSpacing: 0.8),
                                    ),
                                    Row(
                                      children: [
                                        ...List.generate(commentSorts.length,
                                            (index) {
                                          CommentSort commentSort =
                                              commentSorts[index];
                                          return InkResponse(
                                            child: Row(
                                              children: [
                                                PhysicalModel(
                                                  color: _selectedCommentSort ==
                                                          commentSort
                                                      ? Color.fromARGB(
                                                          255, 111, 111, 111)
                                                      : Color.fromARGB(
                                                          255, 247, 245, 245),
                                                  elevation: 2,
                                                  // shadowColor: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8),
                                                    child: Text(
                                                        commentSort.label,
                                                        style: TextStyle(
                                                            color: _selectedCommentSort ==
                                                                    commentSort
                                                                ? Colors.white
                                                                : Color
                                                                    .fromARGB(
                                                                        255,
                                                                        111,
                                                                        111,
                                                                        111))),
                                                  ),
                                                ),
                                                Container(width: 10),
                                              ],
                                            ),
                                            onTap: () => setState(
                                              () {
                                                _selectedCommentSort =
                                                    commentSort;
                                              },
                                            ),
                                          );
                                        })
                                      ],
                                    ),
                                    Container(
                                      width: 22,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          filter = !filter;
                                        });
                                      },
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        // color: Colors.blue,
                                        child: Icon(
                                          Icons.close,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Text('Filter: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              letterSpacing: 0.8)),
                                      Container(
                                        height: 39,
                                        width: 286,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 2.0),
                                            child: Row(
                                              children: [
                                                ...List.generate(
                                                    commentFilters.length,
                                                    (index) {
                                                  CommentFilter commentFilter =
                                                      commentFilters[index];
                                                  return InkResponse(
                                                    child: Row(
                                                      children: [
                                                        PhysicalModel(
                                                          color: _selectedCommentFilter ==
                                                                  commentFilter
                                                              ? Color.fromARGB(
                                                                  255,
                                                                  111,
                                                                  111,
                                                                  111)
                                                              : Color.fromARGB(
                                                                  255,
                                                                  247,
                                                                  245,
                                                                  245),
                                                          elevation: 2,
                                                          // shadowColor: Colors.black,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        12.0,
                                                                    vertical:
                                                                        8),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  commentFilter
                                                                      .label,
                                                                  style: TextStyle(
                                                                      color: _selectedCommentFilter ==
                                                                              commentFilter
                                                                          ? Colors
                                                                              .white
                                                                          : Color.fromARGB(
                                                                              255,
                                                                              111,
                                                                              111,
                                                                              111)),
                                                                ),
                                                                commentFilter
                                                                        .icon ??
                                                                    Container(),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Container(width: 10),
                                                      ],
                                                    ),
                                                    onTap: () => setState(
                                                      () {
                                                        _selectedCommentFilter =
                                                            commentFilter;
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
                  StreamBuilder(
                    stream: _selectedCommentFilter.value == 'all'
                        ? FirebaseFirestore.instance
                            .collection('posts')
                            .doc(_post.postId)
                            .collection('comments')

                            // Sort
                            .orderBy(_selectedCommentSort.key,
                                descending: _selectedCommentSort.value)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('posts')
                            .doc(_post.postId)
                            .collection('comments')

                            // Filter
                            .where(_selectedCommentFilter.value,
                                whereIn: (_post
                                        .toJson()[_selectedCommentFilter.key]
                                        .isNotEmpty
                                    ? _post.toJson()[_selectedCommentFilter.key]
                                    : ['placeholder_uid']))

                            // Sort
                            .orderBy(_selectedCommentSort.key,
                                descending: _selectedCommentSort.value)
                            .snapshots(),
                    builder: (content, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return widget.post.comments == null
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : CommentList(
                                commentSnaps:
                                    (widget.post.comments as dynamic)?.docs ??
                                        [],
                                post: widget.post,
                                parentSetState: () {
                                  setState(() {});
                                },
                              );
                      }
                      widget.post.comments = (snapshot.data as dynamic);

                      return CommentList(
                        commentSnaps: (snapshot.data as dynamic)?.docs ?? [],
                        post: _post,
                        parentSetState: () {
                          setState(() {});
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
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
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text('No comments yet'),
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
                plus: post.plus.contains(commentSnap['uid']),
                parentSetState: parentSetState,
              );
            },
          );
  }
}
