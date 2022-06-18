import 'package:aft/ATESTS/screens/full_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../methods/AFirestoreMethods.dart';
import '../models/AUser.dart';
import '../provider/AUserProvider.dart';
import 'ALikeAnimation.dart';

class CommentCard extends StatefulWidget {
  final postId;
  final snap;
  final bool plus;
  final bool minus;
  final Function parentSetState;

  const CommentCard({
    Key? key,
    required this.postId,
    required this.snap,
    required this.plus,
    required this.minus,
    required this.parentSetState,
  }) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final TextEditingController _replyController = TextEditingController();
  bool isReadmore = false;
  bool showMoreButton = true;

  @override
  void dispose() {
    super.dispose();
    _replyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;

    print('widget.snap: ${widget.snap}');

    if (user == null) {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.black,
      ));
    }
    return Column(
      children: [
        Container(
          color: Color.fromARGB(255, 236, 234, 234),
        ),
        Padding(
          padding:
              const EdgeInsets.only(right: 16.0, left: 16, top: 16, bottom: 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.snap['profilePic'],
                ),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            // width: 270,
                            // color: Colors.brown,
                            child: Text(
                              widget.snap['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(width: 8),
                          Visibility(
                            visible: widget.minus,
                            child: Icon(
                              Icons.do_not_disturb_on,
                              color: Colors.red,
                              size: 15,
                            ),
                          ),
                          Visibility(
                            visible: widget.plus,
                            child: Icon(
                              Icons.add_circle,
                              color: Colors.green,
                              size: 15,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              // color: Colors.brown,
                              alignment: Alignment.centerRight,
                              child: Visibility(
                                visible: widget.snap['uid'] == user.uid,
                                child: InkWell(
                                  onTap: () {
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
                                                          .deleteComment(
                                                        widget.postId,
                                                        widget
                                                            .snap['commentId'],
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
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
                                  child: const Icon(Icons.more_vert, size: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat.yMMMd()
                              .format(widget.snap['datePublished'].toDate()),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 68, right: 16),
          child: buildText('${widget.snap['text']}'),
        ),
        Container(height: 4),
        '${widget.snap['text']}'.length > 100
            ? Padding(
                padding: const EdgeInsets.only(left: 68, right: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isReadmore = !isReadmore;
                    });
                  },
                  child: Text(isReadmore ? 'Show Less' : 'Show More',
                      style: TextStyle(color: Colors.blueAccent)),
                ),
              )
            : Container(),
        Container(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 16),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 68.0),
                      child: Container(
                        child: LikeAnimation(
                          isAnimating: widget.snap['likes'].contains(user.uid),
                          child: InkWell(
                              onTap: () async {
                                await FirestoreMethods().likeComment(
                                  widget.postId,
                                  widget.snap['commentId'],
                                  user.uid,
                                  widget.snap['likes'],
                                );
                              },
                              child: widget.snap['likes'].contains(user.uid)
                                  ? Icon(
                                      Icons.thumb_up,
                                      color: Colors.blueAccent,
                                      size: 16.0,
                                    )
                                  : Icon(
                                      Icons.thumb_up,
                                      color: Color.fromARGB(255, 206, 204, 204),
                                      size: 16.0,
                                    )),
                        ),
                      ),
                    ),
                    Container(width: 6),
                    Text('${widget.snap['likes'].length}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        )),
                    Container(width: 30),
                    LikeAnimation(
                      isAnimating: widget.snap['dislikes'].contains(user.uid),
                      child: InkWell(
                          onTap: () async {
                            await FirestoreMethods().dislikeComment(
                              widget.postId,
                              widget.snap['commentId'],
                              user.uid,
                              widget.snap['dislikes'],
                            );
                          },
                          child: widget.snap['dislikes'].contains(user.uid)
                              ? Icon(
                                  Icons.thumb_down,
                                  color: Colors.blueAccent,
                                  size: 16.0,
                                )
                              : Icon(
                                  Icons.thumb_down,
                                  color: Color.fromARGB(255, 206, 204, 204),
                                  size: 16.0,
                                )),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  currentReplyCommentId = widget.snap['commentId'];
                  widget.parentSetState();
                },
                child: Container(
                  decoration: BoxDecoration(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply,
                        size: 16,
                        color: Colors.blueAccent,
                      ),
                      Container(width: 3),
                      Text("REPLY",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 64.0, bottom: 16),
          child: Container(
            decoration: BoxDecoration(),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: Colors.blueAccent,
                ),
                Container(width: 2),
                Text("Replies (63)",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    )),
              ],
            ),
          ),
        ),
        Visibility(
          visible: widget.snap['commentId'] == currentReplyCommentId,
          child: Padding(
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
                        padding: const EdgeInsets.only(left: 16, right: 8.0),
                        child: Container(
                          child: TextField(
                            controller: _replyController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Write a reply...',
                              // hintText: 'Comment as ${user.username}',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await FirestoreMethods().postReply(
                            widget.postId,
                            widget.snap['commentId'],
                            _replyController.text,
                            user.uid,
                            user.username,
                            user.photoUrl);
                        setState(() {
                          _replyController.text = "";
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
        ),
        // StreamBuilder(
        //   stream: FirebaseFirestore.instance
        //       .collection('posts')
        //       .doc(widget.snap['postId'])
        //       .collection('comments')
        //       .doc(widget.snap['commentId'])
        //       .collection('replies')
        //       .orderBy('datePublished', descending: true)
        //       .snapshots(),
        //   builder: (content, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     }
        //     return ListView.builder(
        //       scrollDirection: Axis.vertical,
        //       shrinkWrap: true,
        //       physics: ScrollPhysics(),
        //       itemCount: (snapshot.data! as dynamic).docs.length,
        //       itemBuilder: (context, index) => CommentCard(
        //         snap: (snapshot.data! as dynamic).docs[index].data(),
        //         minus: ,
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }

  Widget buildText(String text) {
    final lines = isReadmore ? null : 2;
    Text t = Text(
      text,
      style: TextStyle(fontSize: 15),
      maxLines: lines,
      overflow: isReadmore ? TextOverflow.visible : TextOverflow.ellipsis,
    );
    return t;
  }
}
