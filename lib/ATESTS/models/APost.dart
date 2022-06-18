import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String uid;
  final String username;
  final String profImage;
  final String global;
  final String title;
  final String body;
  final String videoUrl;
  final String postUrl;
  final List<String> plus;
  final List<String> neutral;
  final List<String> minus;
  final int? selected;
  final datePublished;
  dynamic comments;

  Post({
    required this.postId,
    required this.uid,
    required this.username,
    required this.profImage,
    required this.datePublished,
    required this.global,
    required this.title,
    required this.body,
    required this.videoUrl,
    required this.postUrl,
    required this.selected,
    required this.plus,
    required this.neutral,
    required this.minus,
  });

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "uid": uid,
        "username": username,
        "profImage": profImage,
        "datePublished": datePublished,
        "global": global,
        "title": title,
        "body": body,
        "videoUrl": videoUrl,
        "postUrl": postUrl,
        "selected": selected,
        "plus": plus,
        "neutral": neutral,
        "minus": minus,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      postId: snapshot['postId'] ?? "",
      uid: snapshot['uid'] ?? "",
      username: snapshot['username'] ?? "",
      profImage: snapshot['profImage'] ?? "",
      global: snapshot['global'] ?? "",
      title: snapshot['title'] ?? "",
      body: snapshot['body'] ?? "",
      videoUrl: snapshot['videoUrl'] ?? "",
      postUrl: snapshot['postUrl'] ?? "",
      plus: (snapshot['plus'] ?? []).cast<String>(),
      neutral: (snapshot['neutral'] ?? []).cast<String>(),
      minus: (snapshot['minus'] ?? []).cast<String>(),
      selected: snapshot['selected'],
      datePublished: snapshot['datePublished'],
    );
  }
}
