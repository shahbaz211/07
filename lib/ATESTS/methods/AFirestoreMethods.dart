import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/APost.dart';
import '../models/poll.dart';
import '../other/AUtils.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPoll(
    String uid,
    String username,
    String profImage,
    String country,
    String global,
    String pollTitle,
    String option1,
    String option2,
    String option3,
    String option4,
    String option5,
    String option6,
    String option7,
    String option8,
    String option9,
    String option10,
  ) async {
    String res = "some error occurred";
    try {
      String pollId = const Uuid().v1();

      Poll poll = Poll(
        pollId: pollId,
        uid: uid,
        username: username,
        profImage: profImage,
        country: country,
        datePublished: DateTime.now(),
        global: global,
        pollTitle: pollTitle,
        option1: option1,
        option2: option2,
        option3: option3,
        option4: option4,
        option5: option5,
        option6: option6,
        option7: option7,
        option8: option8,
        option9: option9,
        option10: option10,
        vote1: [],
        vote2: [],
        vote3: [],
        vote4: [],
        vote5: [],
        vote6: [],
        vote7: [],
        vote8: [],
        vote9: [],
        vote10: [],
        totalVotes: 0,
      );

      _firestore.collection('polls').doc(pollId).set(
            poll.toJson(),
          );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //upload post
  Future<String> uploadPost(
    String uid,
    String username,
    String profImage,
    String country,
    String global,
    String title,
    String body,
    String videoUrl,
    // Uint8List file,
    String photoUrl,
    int selected,
  ) async {
    String res = "some error occurred";
    try {
      // String photoUrl =
      //     await StorageMethods().uploadImageToStorage('posts', file, true);
      String trimmedText = trimText(text: title);
      String postId = const Uuid().v1();

      Post post = Post(
        postId: postId,
        uid: uid,
        username: username,
        profImage: profImage,
        country: country,
        datePublished: DateTime.now(),
        global: global,
        title: trimmedText,
        body: body,
        videoUrl: videoUrl,
        postUrl: photoUrl,
        selected: selected,
        plus: [],
        neutral: [],
        minus: [],
        score: 0,
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

  Future<void> scoreMessage(String postId, String uid, int score) async {
    try {
      await _firestore.collection('posts').doc(postId).update(
        {'score': score},
      );
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> totalVotesPoll(String pollId, String uid, int totalVotes) async {
    try {
      await _firestore.collection('posts').doc(pollId).update(
        {'totalVotes': totalVotes},
      );
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  // Future<void> plusMessage(String postId, String uid, List plus) async {
  //   try {
  //     if (plus.contains(uid)) {
  //       await _firestore.collection('posts').doc(postId).update({
  //         'plus': FieldValue.arrayRemove([uid]),
  //       });
  //     } else {
  //       await _firestore.collection('posts').doc(postId).update({
  //         'plus': FieldValue.arrayUnion([uid]),
  //         'neutral': FieldValue.arrayRemove([uid]),
  //         'minus': FieldValue.arrayRemove([uid]),
  //       });
  //     }
  //   } catch (e) {
  //     print(
  //       e.toString(),
  //     );
  //   }
  // }
  Future<void> plusMessage(
    String postId,
    String uid,
    List plus,
  ) async {
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

  Future<void> minusMessage(
    String postId,
    String uid,
    List minus,
  ) async {
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

  // Future<void> minusMessage(String postId, String uid, List minus) async {
  //   try {
  //     if (minus.contains(uid)) {
  //       await _firestore.collection('posts').doc(postId).update({
  //         'minus': FieldValue.arrayRemove([uid]),
  //       });
  //     } else {
  //       await _firestore.collection('posts').doc(postId).update({
  //         'minus': FieldValue.arrayUnion([uid]),
  //         'plus': FieldValue.arrayRemove([uid]),
  //         'neutral': FieldValue.arrayRemove([uid]),
  //       });
  //     }
  //   } catch (e) {
  //     print(
  //       e.toString(),
  //     );
  //   }
  // }

  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic) async {
    try {
      if (text.isNotEmpty) {
        String trimmedText = trimText(text: text);
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
          'text': trimmedText,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          'likes': [],
          'likeCount': 0,
          'dislikes': [],
          'dislikeCount': 0,
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

  Future<void> postReply(String postId, String commentId, String text,
      String uid, String name, String profilePic) async {
    try {
      if (text.isNotEmpty) {
        String trimmedText = trimText(text: text);
        String replyId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': trimmedText,
          'replyId': replyId,
          'datePublished': DateTime.now(),
          'likes': [],
          'likeCount': 0,
          'dislikes': [],
          'dislikeCount': 0,
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

  // Future<void> likeComment(
  //     String postId, String commentId, String uid, List likes) async {
  //   try {
  //     if (likes.contains(uid)) {
  //       await _firestore
  //           .collection('posts')
  //           .doc(postId)
  //           .collection('comments')
  //           .doc(commentId)
  //           .update({
  //         'likes': FieldValue.arrayRemove([uid]),
  //       });
  //     } else {
  //       await _firestore
  //           .collection('posts')
  //           .doc(postId)
  //           .collection('comments')
  //           .doc(commentId)
  //           .update({
  //         'likes': FieldValue.arrayUnion([uid]),
  //         'dislikes': FieldValue.arrayRemove([uid]),
  //       });
  //     }
  //   } catch (e) {
  //     print(
  //       e.toString(),
  //     );
  //   }
  // }

  // Future<void> dislikeComment(
  //     String postId, String commentId, String uid, List dislikes) async {
  //   try {
  //     if (dislikes.contains(uid)) {
  //       await _firestore
  //           .collection('posts')
  //           .doc(postId)
  //           .collection('comments')
  //           .doc(commentId)
  //           .update({
  //         'dislikes': FieldValue.arrayRemove([uid]),
  //       });
  //     } else {
  //       await _firestore
  //           .collection('posts')
  //           .doc(postId)
  //           .collection('comments')
  //           .doc(commentId)
  //           .update({
  //         'dislikes': FieldValue.arrayUnion([uid]),
  //         'likes': FieldValue.arrayRemove([uid]),
  //       });
  //     }
  //   } catch (e) {
  //     print(
  //       e.toString(),
  //     );
  //   }
  // }

  //deleting post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  //deleting comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> deleteReply(
    String postId,
    String commentId,
    String replyId,
  ) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> likeComment(
    String postId,
    String commentId,
    String uid,
    List likes,
    List dislikes,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        var updateMap = {
          'likes': FieldValue.arrayUnion([uid]),
          'likeCount': FieldValue.increment(1),
          'dislikes': FieldValue.arrayRemove([uid]),
        };

        if (dislikes.contains(uid)) {
          updateMap['dislikeCount'] = FieldValue.increment(-1);
        }
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update(updateMap);
        //     .update({
        //   'likes': FieldValue.arrayUnion([uid]),

        //   'dislikes': FieldValue.arrayRemove([uid]),
        // });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> dislikeComment(String postId, String commentId, String uid,
      List likes, List dislikes) async {
    try {
      if (dislikes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'dislikes': FieldValue.arrayRemove([uid]),
          'dislikeCount': FieldValue.increment(-1),
        });
      } else {
        var updateMap = {
          'dislikes': FieldValue.arrayUnion([uid]),
          'dislikeCount': FieldValue.increment(1),
          'likes': FieldValue.arrayRemove([uid]),
        };

        if (likes.contains(uid)) {
          updateMap['likeCount'] = FieldValue.increment(-1);
        }

        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update(updateMap);
        //     .update({
        //   'dislikes': FieldValue.arrayUnion([uid]),
        //   'likes': FieldValue.arrayRemove([uid]),
        // });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> likeReply(
    String postId,
    String commentId,
    String uid,
    List likes,
    List dislikes,
    String replyId,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        var updateMap = {
          'likes': FieldValue.arrayUnion([uid]),
          'likeCount': FieldValue.increment(1),
          'dislikes': FieldValue.arrayRemove([uid]),
        };

        if (dislikes.contains(uid)) {
          updateMap['dislikeCount'] = FieldValue.increment(-1);
        }
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update(updateMap);
        //     .update({
        //   'likes': FieldValue.arrayUnion([uid]),
        //   'dislikes': FieldValue.arrayRemove([uid]),
        // });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<void> dislikeReply(
    String postId,
    String commentId,
    String uid,
    List likes,
    List dislikes,
    String replyId,
  ) async {
    try {
      if (dislikes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update({
          'dislikes': FieldValue.arrayRemove([uid]),
          'dislikeCount': FieldValue.increment(-1),
        });
      } else {
        var updateMap = {
          'dislikes': FieldValue.arrayUnion([uid]),
          'dislikeCount': FieldValue.increment(1),
          'likes': FieldValue.arrayRemove([uid]),
        };

        if (likes.contains(uid)) {
          updateMap['likeCount'] = FieldValue.increment(-1);
        }
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .update(updateMap);
        //     .update({
        //   'dislikes': FieldValue.arrayUnion([uid]),
        //   'likes': FieldValue.arrayRemove([uid]),
        // });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }
}
