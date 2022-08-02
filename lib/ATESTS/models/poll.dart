import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  final String pollId;
  final String uid;
  final String username;
  final String profImage;
  final String country;
  final String global;
  final String pollTitle;

  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final String option5;
  final String option6;
  final String option7;
  final String option8;
  final String option9;
  final String option10;

  List<String> vote1;
  List<String> vote2;
  List<String> vote3;
  List<String> vote4;
  List<String> vote5;
  List<String> vote6;
  List<String> vote7;
  List<String> vote8;
  List<String> vote9;
  List<String> vote10;
  int totalVotes;
  final List<String> allVotesUIDs;
  StreamController<Poll>? updatingStreamPoll;
  final endDate;
  final datePublished;
  dynamic comments;

  Poll(
      {required this.pollId,
      required this.uid,
      required this.username,
      required this.profImage,
      required this.country,
      required this.datePublished,
      required this.endDate,
      required this.global,
      required this.pollTitle,
      required this.option1,
      required this.option2,
      required this.option3,
      required this.option4,
      required this.option5,
      required this.option6,
      required this.option7,
      required this.option8,
      required this.option9,
      required this.option10,
      required this.vote1,
      required this.vote2,
      required this.vote3,
      required this.vote4,
      required this.vote5,
      required this.vote6,
      required this.vote7,
      required this.vote8,
      required this.vote9,
      required this.vote10,
      required this.totalVotes,
      required this.allVotesUIDs,
      this.updatingStreamPoll}) {
    if (updatingStreamPoll != null) {
      updatingStreamPoll!.stream
          .where((event) => event.pollId == pollId)
          .listen((event) {
        totalVotes = event.totalVotes;
        vote1 = event.vote1;
        vote2 = event.vote2;
        vote3 = event.vote3;
        vote4 = event.vote4;
        vote5 = event.vote5;
        vote6 = event.vote6;
        vote7 = event.vote7;
        vote8 = event.vote8;
        vote9 = event.vote9;
        vote10 = event.vote10;
      });
    }
  }

  Map<String, dynamic> toJson() => {
        "pollId": pollId,
        "uid": uid,
        "username": username,
        "profImage": profImage,
        "country": country,
        "datePublished": datePublished,
        "endDate": endDate,
        "global": global,
        "pollTitle": pollTitle,
        "option1": option1,
        "option2": option2,
        "option3": option3,
        "option4": option4,
        "option5": option5,
        "option6": option6,
        "option7": option7,
        "option8": option8,
        "option9": option9,
        "option10": option10,
        "vote1": vote1,
        "vote2": vote2,
        "vote3": vote3,
        "vote4": vote4,
        "vote5": vote5,
        "vote6": vote6,
        "vote7": vote7,
        "vote8": vote8,
        "vote9": vote9,
        "vote10": vote10,
        "totalVotes": totalVotes,
        "allVotesUIDs": allVotesUIDs,
      };

  static Poll fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return fromMap(snapshot);

    // return Poll(
    //   pollId: snapshot['pollId'] ?? "",
    //   uid: snapshot['uid'] ?? "",
    //   username: snapshot['username'] ?? "",
    //   profImage: snapshot['profImage'] ?? "",
    //   country: snapshot['country'] ?? "",
    //   global: snapshot['global'] ?? "",
    //   pollTitle: snapshot['pollTitle'] ?? "",
    //   option1: snapshot['option1'] ?? "",
    //   option2: snapshot['option2'] ?? "",
    //   option3: snapshot['option3'] ?? "",
    //   option4: snapshot['option4'] ?? "",
    //   option5: snapshot['option5'] ?? "",
    //   option6: snapshot['option6'] ?? "",
    //   option7: snapshot['option7'] ?? "",
    //   option8: snapshot['option8'] ?? "",
    //   option9: snapshot['option9'] ?? "",
    //   option10: snapshot['option10'] ?? "",
    //   vote1: (snapshot['vote1'] ?? []).cast<String>(),
    //   vote2: (snapshot['vote2'] ?? []).cast<String>(),
    //   vote3: (snapshot['vote3'] ?? []).cast<String>(),
    //   vote4: (snapshot['vote4'] ?? []).cast<String>(),
    //   vote5: (snapshot['vote5'] ?? []).cast<String>(),
    //   vote6: (snapshot['vote6'] ?? []).cast<String>(),
    //   vote7: (snapshot['vote7'] ?? []).cast<String>(),
    //   vote8: (snapshot['vote8'] ?? []).cast<String>(),
    //   vote9: (snapshot['vote9'] ?? []).cast<String>(),
    //   vote10: (snapshot['vote10'] ?? []).cast<String>(),
    //   datePublished: snapshot['datePublished'],
    //   endDate: snapshot['endDate'],
    //   totalVotes: snapshot['totalVotes'],
    //   allVotesUIDs: (snapshot['allVotesUIDs'] ?? []).cast<String>(),
    // );
  }

  static Poll fromMap(Map<String, dynamic> snapshot) {
    return Poll(
        pollId: snapshot['pollId'] ?? "",
        uid: snapshot['uid'] ?? "",
        username: snapshot['username'] ?? "",
        profImage: snapshot['profImage'] ?? "",
        country: snapshot['country'] ?? "",
        global: snapshot['global'] ?? "",
        pollTitle: snapshot['pollTitle'] ?? "",
        option1: snapshot['option1'] ?? "",
        option2: snapshot['option2'] ?? "",
        option3: snapshot['option3'] ?? "",
        option4: snapshot['option4'] ?? "",
        option5: snapshot['option5'] ?? "",
        option6: snapshot['option6'] ?? "",
        option7: snapshot['option7'] ?? "",
        option8: snapshot['option8'] ?? "",
        option9: snapshot['option9'] ?? "",
        option10: snapshot['option10'] ?? "",
        vote1: (snapshot['vote1'] ?? []).cast<String>(),
        vote2: (snapshot['vote2'] ?? []).cast<String>(),
        vote3: (snapshot['vote3'] ?? []).cast<String>(),
        vote4: (snapshot['vote4'] ?? []).cast<String>(),
        vote5: (snapshot['vote5'] ?? []).cast<String>(),
        vote6: (snapshot['vote6'] ?? []).cast<String>(),
        vote7: (snapshot['vote7'] ?? []).cast<String>(),
        vote8: (snapshot['vote8'] ?? []).cast<String>(),
        vote9: (snapshot['vote9'] ?? []).cast<String>(),
        vote10: (snapshot['vote10'] ?? []).cast<String>(),
        datePublished: snapshot['datePublished'],
        endDate: snapshot['endDate'],
        totalVotes: snapshot['totalVotes'],
        allVotesUIDs: (snapshot['allVotesUIDs'] ?? []).cast<String>(),
        updatingStreamPoll: snapshot['updatingStreamPoll']);
  }
}
