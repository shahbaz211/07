import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AStorageMethods.dart';
import 'package:uuid/uuid.dart';

import '../models/APost.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future<String> uploadPost(
    String uid,
    String username,
    String profImage,
    String global,
    String title,
    String body,
    String videoUrl,
    Uint8List file,
    int selected,
  ) async {
    String res = "some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      String postId = const Uuid().v1();

      Post post = Post(
        postId: postId,
        uid: uid,
        username: username,
        profImage: profImage,
        datePublished: DateTime.now(),
        global: global,
        title: title,
        body: body,
        videoUrl: videoUrl,
        postUrl: photoUrl,
        selected: selected,
        plus: [],
        neutral: [],
        minus: [],
      );

      _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> plusMessage(String postId, String uid, List plus) async {
    try {
      if (plus.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'plus': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'plus': FieldValue.arrayUnion([uid]),
          'neutral': FieldValue.arrayRemove([uid]),
          'minus': FieldValue.arrayRemove([uid]),
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> neutralMessage(String postId, String uid, List neutral) async {
    try {
      if (neutral.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'neutral': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'neutral': FieldValue.arrayUnion([uid]),
          'plus': FieldValue.arrayRemove([uid]),
          'minus': FieldValue.arrayRemove([uid]),
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> minusMessage(String postId, String uid, List minus) async {
    try {
      if (minus.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'minus': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'minus': FieldValue.arrayUnion([uid]),
          'plus': FieldValue.arrayRemove([uid]),
          'neutral': FieldValue.arrayRemove([uid]),
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  //deleting post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }
}
