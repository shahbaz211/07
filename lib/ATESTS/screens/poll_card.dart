import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
// import 'package:polls/polls.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../methods/AFirestoreMethods.dart';
import '../models/AUser.dart';
import '../provider/AUserProvider.dart';
import 'like_animation.dart';
import '../models/poll.dart';

class PollCard extends StatefulWidget {
  final Poll poll;

  const PollCard({
    Key? key,
    required this.poll,
  }) : super(key: key);

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  late Poll _poll;
  bool isLikeAnimating = false;
  int commentLen = 0;
  String placement = '';
  var testt = 21100;

  @override
  void initState() {
    super.initState();
    _poll = widget.poll;
    // placement = '#${(widget.indexPlacement + 1).toString()}';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    _poll = widget.poll;
    final User? user = Provider.of<UserProvider>(context).getUser;

    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 8,
        left: 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 6,
                  // bottom: 6,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(_poll.profImage),
                    ),
                    SizedBox(width: 8),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                child: Text(
                              _poll.username,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 1),
                            )),
                            SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMd().format(
                                _poll.datePublished.toDate(),
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
                                                    .deletePost(_poll.pollId);
                                                Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('${_poll.pollTitle}'),
                        Container(height: 4),
                        Text('${_poll.option1}'),
                        Text('${_poll.option2}'),
                        _poll.option3 == ''
                            ? Container()
                            : Text('${_poll.option3}'),
                        _poll.option4 == ''
                            ? Container()
                            : Text('${_poll.option4}'),
                        _poll.option5 == ''
                            ? Container()
                            : Text('${_poll.option5}'),
                        _poll.option6 == ''
                            ? Container()
                            : Text('${_poll.option6}'),
                        _poll.option7 == ''
                            ? Container()
                            : Text('${_poll.option7}'),
                        _poll.option8 == ''
                            ? Container()
                            : Text('${_poll.option8}'),
                        _poll.option9 == ''
                            ? Container()
                            : Text('${_poll.option9}'),
                        _poll.option10 == ''
                            ? Container()
                            : Text('${_poll.option10}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
