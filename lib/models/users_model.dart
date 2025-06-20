import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}
