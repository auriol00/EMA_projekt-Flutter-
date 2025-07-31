import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String message;
  final String user;
  final String userId; 
  final String userName;
  final String postId;
  final Timestamp time;
  final List<String> commentLikes;

  CommentModel({
    required this.id,
    required this.message,
    required this.user,
    required this.userId,
    required this.userName,
    required this.postId,
    required this.time,
    required this.commentLikes,
  });

  // Factory constructor to create from Firestore data
  factory CommentModel.fromMap(String id, {
    required String postId,
    required Map<String, dynamic> data,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      message: data['CommentText'] ?? '',
      user: data['CommentedBy'] ?? '',
      userId: data['CommentedByUid'] ?? '',
      userName: data['CommentedByName'] ?? '',
      time: data['CommentTime'],
      commentLikes: List<String>.from(data['CommentLikes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'CommentText': message,
      'CommentedBy': user,
      'CommentedByName':userName,
      'CommentedByUid':userId,
      'CommentTime': time, // ideally this should be a Timestamp if you're sending it back
      'CommentLikes': commentLikes,
    };
  }
}

  

