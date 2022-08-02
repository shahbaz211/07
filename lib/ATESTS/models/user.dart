import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String? photoUrl;
  final String username;
  final String country;
  final String isFT;
  final String bio;
  final dateCreated;
  final profileFlag;

  // final List followers;
  // final List following;

  const User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.country,
    required this.isFT,
    required this.bio,
    required this.dateCreated,
    required this.profileFlag,

    // required this.followers,
    // required this.following,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        // "bio": bio,
        // "followers": followers,
        // "following": following,
        "photoUrl": photoUrl,
        "country": country,
        "isFT": isFT,
        "bio": bio,
        "dateCreated": dateCreated,
        "profileFlag": profileFlag,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      photoUrl: snapshot['photoUrl'],
      email: snapshot['email'],
      country: snapshot['country'],
      isFT: snapshot['isFT'],
      bio: snapshot['bio'],
      dateCreated: snapshot['dateCreated'],
      profileFlag: snapshot['profileFlag'],
      // followers: snapshot['followers'],
      // following: snapshot['following'],
    );
  }
}
