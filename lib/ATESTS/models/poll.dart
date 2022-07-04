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

  final List<String> vote1;
  final List<String> vote2;
  final List<String> vote3;
  final List<String> vote4;
  final List<String> vote5;
  final List<String> vote6;
  final List<String> vote7;
  final List<String> vote8;
  final List<String> vote9;
  final List<String> vote10;
  final int totalVotes;

  final datePublished;
  dynamic comments;

  Poll({
    required this.pollId,
    required this.uid,
    required this.username,
    required this.profImage,
    required this.country,
    required this.datePublished,
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
  });

  Map<String, dynamic> toJson() => {
        "postId": pollId,
        "uid": uid,
        "username": username,
        "profImage": profImage,
        "country": country,
        "datePublished": datePublished,
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
      };

  static Poll fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

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
      totalVotes: snapshot['totalVotes'],
    );
  }
}
