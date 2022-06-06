import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/AUser.dart';
import '../provider/AUserProvider.dart';
import '../methods/AFirestoreMethods.dart';
import '../other/AUtils.dart';
import 'ALikeAnimation.dart';

class PostCardTest extends StatefulWidget {
  final snap;
  const PostCardTest({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCardTest> createState() => _PostCardTestState();
}

class _PostCardTestState extends State<PostCardTest> {
  late YoutubePlayerController controller;
  bool isLikeAnimating = false;
  int commentLen = 0;
  String placement = '26';
  var testt = 21100;

  @override
  void initState() {
    super.initState();
    var url = widget.snap['videoUrl'];
    controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(url)!,
      flags: const YoutubePlayerFlags(
        mute: false,
        loop: false,
        autoPlay: false,
      ),
    );
  }

  @override
  void deactivate() {
    controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    if (user == null) {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.black,
      ));
    }
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: controller,
      ),
      builder: (context, player) => Padding(
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
          padding: const EdgeInsets.only(left: 10),
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
                        backgroundImage: NetworkImage(widget.snap['profImage']),
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

                                child: widget.snap['global'] == 'true'
                                    ? Text(
                                        widget.snap['username'],
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    : null,
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat.yMMMd().format(
                                  widget.snap['datePublished'].toDate(),
                                ),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // SizedBox(width: 130),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          // color: Colors.purple,
                          child: Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: placement.length == 1
                                  ? Text(
                                      placement,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 63,
                                      ),
                                    )
                                  : placement.length == 2
                                      ? Text(
                                          placement,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                            fontSize: 44,
                                          ),
                                        )
                                      : placement.length == 3
                                          ? Text(
                                              placement,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 30,
                                              ),
                                            )
                                          : placement.length == 4
                                              ? Text(
                                                  placement,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 23,
                                                  ),
                                                )
                                              : placement.length == 5
                                                  ? Text(
                                                      placement,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 17,
                                                      ),
                                                    )
                                                  : placement.length == 6
                                                      ? Text(
                                                          placement,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      : placement.length == 7
                                                          ? Text(
                                                              placement,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontSize: 13,
                                                              ),
                                                            )
                                                          : placement.length ==
                                                                  8
                                                              ? Text(
                                                                  placement,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    fontSize:
                                                                        11,
                                                                  ),
                                                                )
                                                              : null),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                            width: 1,
                            color: Color.fromARGB(255, 218, 216, 216)),
                      ),
                    ),
                    height: 314,
                    width: 273,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${widget.snap['title']}',
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
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
                                          color: Colors.black,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.9,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: Image.network(
                                            widget.snap['postUrl'],
                                          ),
                                        ),
                                      ),
                                    ]),
                              );
                            },
                            child: Container(
                              // height: 150,
                              height: 150,
                              width: 265,
                              // color: Color.fromARGB(255, 239, 238, 238),

                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Image.network(
                                  widget.snap['postUrl'],
                                  // fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // color: Colors.yellow,
                    height: 300,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          child: Text('Score',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              )),
                        ),
                        SizedBox(height: 10),
                        Text(
                            '${widget.snap['plus'].length - widget.snap['minus'].length}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                            )),
                        SizedBox(height: 20),
                        Container(
                          child: LikeAnimation(
                            isAnimating: widget.snap['plus'].contains(user.uid),
                            // smallLike: true,
                            child: IconButton(
                              onPressed: () async {
                                await FirestoreMethods().plusMessage(
                                  widget.snap['postId'],
                                  user.uid,
                                  widget.snap['plus'],
                                );
                              },
                              icon: widget.snap['plus'].contains(user.uid)
                                  ? const Icon(
                                      Icons.add_circle,
                                      color: Colors.green,
                                    )
                                  : const Icon(
                                      Icons.add_circle,
                                      color: Color.fromARGB(255, 206, 204, 204),
                                    ),
                            ),
                          ),
                        ),
                        Text(
                          '${widget.snap['plus'].length}',
                        ),
                        SizedBox(height: 20),
                        LikeAnimation(
                          isAnimating: widget.snap['minus'].contains(user.uid),
                          child: IconButton(
                            onPressed: () async {
                              await FirestoreMethods().minusMessage(
                                widget.snap['postId'],
                                user.uid,
                                widget.snap['minus'],
                              );
                            },
                            icon: widget.snap['minus'].contains(user.uid)
                                ? const Icon(
                                    Icons.do_not_disturb_on,
                                    color: Colors.red,
                                  )
                                : const Icon(
                                    Icons.do_not_disturb_on,
                                    color: Color.fromARGB(255, 206, 204, 204),
                                  ),
                          ),
                        ),
                        Text(
                          '${widget.snap['minus'].length}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
