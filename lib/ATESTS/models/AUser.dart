import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String country;

  const User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.country,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "country": country,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      photoUrl: snapshot['photoUrl'],
      email: snapshot['email'],
      country: snapshot['country'],
    );
  }
}
