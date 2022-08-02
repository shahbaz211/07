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
import '../feeds/comment_card_poll.dart';
import '../methods/firestore_methods.dart';
import '../models/poll.dart';
import '../models/user.dart';
import '../other/utils.dart.dart';
import '../poll/poll_view.dart.dart';
import '../provider/user_provider.dart';
import 'full_image_screen.dart';
import 'home_screen.dart';

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

class FullMessagePoll extends StatefulWidget {
  final Poll poll;
  final indexPlacement;

  const FullMessagePoll({
    Key? key,
    required this.poll,
    required this.indexPlacement,
  }) : super(key: key);

  @override
  State<FullMessagePoll> createState() => _FullMessagePollState();
}

class _FullMessagePollState extends State<FullMessagePoll> {
  late Poll _poll;

  final TextEditingController _commentController = TextEditingController();
  final TextStyle _pollOptionTextStyle = const TextStyle(
    fontSize: 16,
  );
  bool isLikeAnimating = false;
  int commentLen = 0;
  String placement = '';
  bool filter = false;
  bool _isPollEnded = false;
  String option1 = '';
  String option2 = '';
  String option3 = '';
  String option4 = '';
  String option5 = '';
  String option6 = '';
  String option7 = '';
  String option8 = '';
  String option9 = '';
  String option10 = '';

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
      label: 'Option 1',
      key: 'plus',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Option 2',
      key: 'neutral',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Option 3',
      key: 'minus',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Option 4',
      key: 'minus',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Option 5',
      key: 'minus',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Option 6',
      key: 'minus',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Option 7',
      key: 'minus',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Option 8',
      key: 'minus',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Option 9',
      key: 'minus',
      value: 'uid',
    ),
    CommentFilter(
      label: 'Option 10',
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
                    const Text('Delete Poll',
                        style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                  ],
                ),
                onPressed: () async {
                  FirestoreMethods().deletePost(_poll.pollId);
                  Navigator.of(context).pop();
                  showSnackBar('Poll Deleted', context);
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

  @override
  void initState() {
    _poll = widget.poll;
    _selectedCommentSort = commentSorts.first;
    _selectedCommentFilter = commentFilters.first;
    placement = '#${(widget.indexPlacement + 1).toString()}';
    option1 = '_poll.option1';

    currentReplyCommentId = null;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    _poll = widget.poll;

    print('INSIDE FULL MESSAGE BUILD');
    print('_post.toJson(): ${_poll.toJson()}');

    final User? user = Provider.of<UserProvider>(context).getUser;
    _isPollEnded = (_poll.endDate as Timestamp)
        .toDate()
        .difference(
          DateTime.now(),
        )
        .isNegative;

    print("_selectedCommentFilter.key: ${_selectedCommentFilter.key}");
    print("_post.toJson(): ${_poll.toJson()}");
    print(
        "_post.toJson()[_selectedCommentFilter.key]: ${_poll.toJson()[_selectedCommentFilter.key]}");

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('polls')
            .doc(_poll.pollId)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          _poll = snapshot.data != null ? Poll.fromSnap(snapshot.data!) : _poll;
          return Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Color.fromARGB(255, 245, 245, 245),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  // toolbarHeight: 68,
                  actions: [
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 70,
                            // color: Colors.orange,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8,
                                  ),
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
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              // color: Colors.blue,

                              padding: EdgeInsets.only(right: 10),
                              // color: Colors.blue,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    // color: Colors.red,
                                    child: Text(
                                      placement,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          fontSize: placement.length < 4
                                              ? 24
                                              : placement.length < 5
                                                  ? 22
                                                  : placement.length >= 5
                                                      ? 20
                                                      : 20,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    '•',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text('${_poll.totalVotes} Votes',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 10),
                                  const Text(
                                    '•',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(_pollTimeLeftLabel(poll: _poll),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                body: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('polls')
                      .doc(_poll.pollId)
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                    _poll = snapshot.data != null
                        ? Poll.fromSnap(snapshot.data!)
                        : _poll;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 8, left: 8, top: 8, bottom: 0),
                            child: Container(
                              decoration: BoxDecoration(
                                  // color: Colors.white,
                                  ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                            top: 6.0,
                                            // right: 10,
                                            left: 10,
                                          ),
                                          child: Container(
                                            // color: Colors.orange,
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 227, 227, 227),
                                                  backgroundImage: NetworkImage(
                                                    _poll.profImage,
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
                                                                text: _poll
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
                                                                .format(_poll
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
                                                        onPressed: _poll.uid ==
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
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8.0, bottom: 0),
                                          child: Text('${_poll.pollTitle}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              right: 8, left: 8, bottom: 6),
                                          child: Stack(
                                            children: [
                                              PollView(
                                                pollId: _poll.pollId,
                                                pollEnded: _isPollEnded,
                                                hasVoted: _poll.allVotesUIDs
                                                    .contains(user?.uid),
                                                userVotedOptionId:
                                                    _getUserPollOptionId(
                                                        user?.uid ?? ''),
                                                onVoted: (PollOption pollOption,
                                                    int newTotalVotes) async {
                                                  if (!_isPollEnded) {
                                                    performLoggedUserAction(
                                                        context: context,
                                                        action: () async {
                                                          await FirestoreMethods()
                                                              .poll(
                                                            poll: _poll,
                                                            uid:
                                                                user?.uid ?? '',
                                                            optionIndex:
                                                                pollOption.id!,
                                                          );
                                                        });
                                                  }

                                                  print(
                                                      'newTotalVotes: ${newTotalVotes}');
                                                  print(
                                                      'Voted: ${pollOption.id}');
                                                },
                                                leadingVotedProgessColor:
                                                    Colors.blue.shade200,
                                                pollOptionsSplashColor:
                                                    Colors.white,
                                                votedProgressColor: Colors
                                                    .blueGrey
                                                    .withOpacity(0.3),
                                                votedBackgroundColor: Colors
                                                    .grey
                                                    .withOpacity(0.2),
                                                votedCheckmark: const Icon(
                                                  Icons.check_circle_outline,
                                                  color: Color.fromARGB(
                                                      255, 17, 125, 21),
                                                  size: 18,
                                                ),
                                                // pollTitle: Align(
                                                //   alignment: Alignment.center,
                                                //   child: Text(
                                                //     _poll.pollTitle,
                                                //     textAlign: TextAlign.center,
                                                //     style: const TextStyle(
                                                //       fontSize: 16,
                                                //       fontWeight: FontWeight.w500,
                                                //     ),
                                                //   ),
                                                // ),
                                                pollOptions: [
                                                  PollOption(
                                                    id: 1,
                                                    title: Text(
                                                      _poll.option1,
                                                      style:
                                                          _pollOptionTextStyle,
                                                    ),
                                                    votes: _poll.vote1.length,
                                                  ),
                                                  PollOption(
                                                    id: 2,
                                                    title: Text(
                                                      _poll.option2,
                                                      style:
                                                          _pollOptionTextStyle,
                                                    ),
                                                    votes: _poll.vote2.length,
                                                  ),
                                                  if (_poll.option3 != '')
                                                    PollOption(
                                                      id: 3,
                                                      title: Text(
                                                        _poll.option3,
                                                        style:
                                                            _pollOptionTextStyle,
                                                      ),
                                                      votes: _poll.vote3.length,
                                                    ),
                                                  if (_poll.option4 != '')
                                                    PollOption(
                                                      id: 4,
                                                      title: Text(
                                                        _poll.option4,
                                                        style:
                                                            _pollOptionTextStyle,
                                                      ),
                                                      votes: _poll.vote4.length,
                                                    ),
                                                  if (_poll.option5 != '')
                                                    PollOption(
                                                      id: 5,
                                                      title: Text(
                                                        _poll.option5,
                                                        style:
                                                            _pollOptionTextStyle,
                                                      ),
                                                      votes: _poll.vote5.length,
                                                    ),
                                                  if (_poll.option6 != '')
                                                    PollOption(
                                                      id: 6,
                                                      title: Text(
                                                        _poll.option6,
                                                        style:
                                                            _pollOptionTextStyle,
                                                      ),
                                                      votes: _poll.vote6.length,
                                                    ),
                                                  if (_poll.option7 != '')
                                                    PollOption(
                                                      id: 7,
                                                      title: Text(
                                                        _poll.option7,
                                                        style:
                                                            _pollOptionTextStyle,
                                                      ),
                                                      votes: _poll.vote7.length,
                                                    ),
                                                  if (_poll.option8 != '')
                                                    PollOption(
                                                      id: 8,
                                                      title: Text(
                                                        _poll.option8,
                                                        style:
                                                            _pollOptionTextStyle,
                                                      ),
                                                      votes: _poll.vote8.length,
                                                    ),
                                                  if (_poll.option9 != '')
                                                    PollOption(
                                                      id: 9,
                                                      title: Text(
                                                        _poll.option9,
                                                        style:
                                                            _pollOptionTextStyle,
                                                      ),
                                                      votes: _poll.vote9.length,
                                                    ),
                                                  if (_poll.option10 != '')
                                                    PollOption(
                                                      id: 10,
                                                      title: Text(
                                                        _poll.option10,
                                                        style:
                                                            _pollOptionTextStyle,
                                                      ),
                                                      votes:
                                                          _poll.vote10.length,
                                                    ),
                                                ],
                                                metaWidget: Row(
                                                  children: [],
                                                ),
                                              ),
                                              Positioned.fill(
                                                  child: Visibility(
                                                visible: _isPollEnded,
                                                child: Container(
                                                  color: Colors.cyanAccent
                                                      .withOpacity(0.0),
                                                ),
                                              )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 14,
                                                  top: 16,
                                                  bottom: 4,
                                                ),
                                                child: StreamBuilder(
                                                  stream: _selectedCommentFilter
                                                              .value ==
                                                          'all'
                                                      ? FirebaseFirestore
                                                          .instance
                                                          .collection('polls')
                                                          .doc(_poll.pollId)
                                                          .collection(
                                                              'comments')

                                                          // Sort
                                                          .orderBy(
                                                              _selectedCommentSort
                                                                  .key,
                                                              descending:
                                                                  _selectedCommentSort
                                                                      .value)
                                                          .snapshots()
                                                      : FirebaseFirestore
                                                          .instance
                                                          .collection('polls')
                                                          .doc(_poll.pollId)
                                                          .collection(
                                                              'comments')
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
                                                              whereIn: (_poll
                                                                      .toJson()[
                                                                          _selectedCommentFilter
                                                                              .key]
                                                                      .isNotEmpty
                                                                  ? _poll.toJson()[
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          letterSpacing: 0.8),
                                                    );
                                                  },
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    filter = !filter;
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                                  : Icons
                                                                      .arrow_drop_up,
                                                              color:
                                                                  Colors.black),
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    224,
                                                                    224,
                                                                    224)),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: Color.fromARGB(
                                                            255, 245, 245, 245),
                                                      ),
                                                      // height: 108,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
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
                                                                        fontSize:
                                                                            15,
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
                                                                            commentSorts[index];
                                                                        return InkResponse(
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              PhysicalModel(
                                                                                color: _selectedCommentSort == commentSort ? Colors.grey : Color.fromARGB(255, 247, 245, 245),
                                                                                elevation: 2,
                                                                                // shadowColor: Colors.black,
                                                                                borderRadius: BorderRadius.circular(25),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                                                                                  child: Text(commentSort.label, style: TextStyle(color: _selectedCommentSort == commentSort ? Colors.white : Color.fromARGB(255, 111, 111, 111))),
                                                                                ),
                                                                              ),
                                                                              Container(width: 10),
                                                                            ],
                                                                          ),
                                                                          onTap: () =>
                                                                              setState(
                                                                            () {
                                                                              _selectedCommentSort = commentSort;
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
                                                              Container(
                                                                  height: 10),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            0.0),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                        'Filter: ',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                                15,
                                                                            letterSpacing:
                                                                                0.8)),
                                                                    Container(
                                                                      height:
                                                                          39,
                                                                      // width: 286,
                                                                      width: MediaQuery.of(context).size.width *
                                                                              1 -
                                                                          105,
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        scrollDirection:
                                                                            Axis.horizontal,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(left: 2.0),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              ...List.generate(commentFilters.length, (index) {
                                                                                CommentFilter commentFilter = commentFilters[index];
                                                                                return InkResponse(
                                                                                  child: Row(
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
                                                                                                '${commentFilter.label}',
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
                                                                                  onTap: () => setState(
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
                                                      padding:
                                                          const EdgeInsets.only(
                                                        left: 16.0,
                                                        top: 14,
                                                      ),
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                227, 227, 227),
                                                        backgroundImage:
                                                            NetworkImage(
                                                          user?.photoUrl ?? '',
                                                        ),
                                                        radius: 18,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 14,
                                                              right: 14.0),
                                                      child: Container(
                                                        // height: 40,
                                                        // color: Colors.grey,
                                                        child: TextField(
                                                          controller:
                                                              _commentController,
                                                          maxLines: null,
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'Write a comment...',
                                                            // hintText: 'Comment as ${user.username}',
                                                            // border: InputBorder.none,
                                                            hintStyle: TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                color: Colors
                                                                    .grey),
                                                            labelStyle:
                                                                TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    top: 8),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  performLoggedUserAction(
                                                      context: context,
                                                      action: () async {
                                                        await FirestoreMethods()
                                                            .pollComment(
                                                                _poll.pollId,
                                                                _commentController
                                                                    .text,
                                                                user?.uid ?? '',
                                                                user?.username ??
                                                                    '',
                                                                user?.photoUrl ??
                                                                    '');
                                                        setState(() {
                                                          _commentController
                                                              .text = "";
                                                        });
                                                      });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 16.0,
                                                          bottom: 12),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.send,
                                                          color:
                                                              Colors.blueAccent,
                                                          size: 12),
                                                      Container(width: 3),
                                                      Text(
                                                        'SEND',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blueAccent,
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
                                            stream: _selectedCommentFilter
                                                        .value ==
                                                    'all'
                                                ? FirebaseFirestore.instance
                                                    .collection('polls')
                                                    .doc(_poll.pollId)
                                                    .collection('comments')

                                                    // Sort
                                                    .orderBy(_selectedCommentSort.key,
                                                        descending:
                                                            _selectedCommentSort
                                                                .value)
                                                    .snapshots()
                                                : FirebaseFirestore.instance
                                                    .collection('polls')
                                                    .doc(_poll.pollId)
                                                    .collection('comments')

                                                    // Filter
                                                    .where(
                                                        _selectedCommentFilter
                                                            .value,
                                                        whereIn: (_poll
                                                                .toJson()[
                                                                    _selectedCommentFilter
                                                                        .key]
                                                                .isNotEmpty
                                                            ? _poll.toJson()[
                                                                _selectedCommentFilter
                                                                    .key]
                                                            : [
                                                                'placeholder_uid'
                                                              ]))

                                                    // Sort
                                                    .orderBy(
                                                        _selectedCommentSort
                                                            .key,
                                                        descending:
                                                            _selectedCommentSort
                                                                .value)
                                                    .snapshots(),
                                            builder: (content, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return widget.poll.comments ==
                                                        null
                                                    ? const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      )
                                                    : CommentList(
                                                        commentSnaps: (widget
                                                                        .poll
                                                                        .comments
                                                                    as dynamic)
                                                                ?.docs ??
                                                            [],
                                                        poll: widget.poll,
                                                        parentSetState: () {
                                                          setState(() {});
                                                        },
                                                      );
                                              }
                                              widget.poll.comments =
                                                  (snapshot.data as dynamic);

                                              return CommentList(
                                                commentSnaps:
                                                    (snapshot.data as dynamic)
                                                            ?.docs ??
                                                        [],
                                                poll: _poll,
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

  String _pollTimeLeftLabel({required Poll poll}) {
    if (_isPollEnded) {
      return 'Poll Closed';

      // 'Poll ended on ${DateFormat.yMMMd().format(
      //   _poll.endDate.toDate(),
      // )}';
    }

    Duration timeLeft = (_poll.endDate as Timestamp).toDate().difference(
          DateTime.now(),
        );

    return timeLeft.inHours >= 48
        ? "${timeLeft.inDays} days left"
        : timeLeft.inHours >= 24
            ? "${timeLeft.inDays} day left"
            : timeLeft.inHours >= 2
                ? "${timeLeft.inHours} hours left"
                : timeLeft.inHours >= 1
                    ? "${timeLeft.inHours} hour left"
                    : timeLeft.inMinutes != 1
                        ? "${timeLeft.inMinutes} minutes left"
                        : "${timeLeft.inMinutes} minute left";
  }

  int? _getUserPollOptionId(String uid) {
    print("uid: $uid");
    int? optionId;
    for (int i = 1; i <= 10; i++) {
      switch (i) {
        case 1:
          if (_poll.vote1.contains(uid)) {
            optionId = i;
          }
          break;
        case 2:
          if (_poll.vote2.contains(uid)) {
            optionId = i;
          }
          break;
        case 3:
          if (_poll.vote3.contains(uid)) {
            optionId = i;
          }
          break;
        case 4:
          if (_poll.vote4.contains(uid)) {
            optionId = i;
          }
          break;
        case 5:
          if (_poll.vote5.contains(uid)) {
            optionId = i;
          }
          break;
        case 6:
          if (_poll.vote6.contains(uid)) {
            optionId = i;
          }
          break;
        case 7:
          if (_poll.vote7.contains(uid)) {
            optionId = i;
          }
          break;
        case 8:
          if (_poll.vote8.contains(uid)) {
            optionId = i;
          }
          break;
        case 9:
          if (_poll.vote9.contains(uid)) {
            optionId = i;
          }
          break;
        case 10:
          if (_poll.vote10.contains(uid)) {
            optionId = i;
          }
          break;
      }
    }
    print("POLLED optionId: $optionId");
    return optionId;
  }
}

class CommentList extends StatelessWidget {
  final commentSnaps;
  final Poll poll;
  final Function parentSetState;

  const CommentList({
    super.key,
    required this.commentSnaps,
    required this.poll,
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

              return CommentCardPoll(
                snap: commentSnap,
                parentPost: poll,
                pollId: poll.pollId,
                option1: poll.option1,
                option2: poll.option2,
                option3: poll.option3,
                option4: poll.option4,
                option5: poll.option5,
                option6: poll.option6,
                option7: poll.option7,
                option8: poll.option8,
                option9: poll.option9,
                option10: poll.option10,
                vote1: poll.vote1.contains(commentSnap['uid']),
                vote2: poll.vote2.contains(commentSnap['uid']),
                vote3: poll.vote3.contains(commentSnap['uid']),
                vote4: poll.vote4.contains(commentSnap['uid']),
                vote5: poll.vote5.contains(commentSnap['uid']),
                vote6: poll.vote6.contains(commentSnap['uid']),
                vote7: poll.vote7.contains(commentSnap['uid']),
                vote8: poll.vote8.contains(commentSnap['uid']),
                vote9: poll.vote9.contains(commentSnap['uid']),
                vote10: poll.vote10.contains(commentSnap['uid']),
                parentSetState: parentSetState,
              );
            },
          );
  }
}
