import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String user;
  final String userId;
  final String userName;
  final String message;
  final Timestamp time;
  final List<String> likes;
  final int commentCount;

  PostModel({
    required this.id,
    required this.user,
    required this.userId,
    required this.userName,
    required this.message,
    required this.time,
    required this.likes,
    required this.commentCount,
  });

  factory PostModel.fromMap(String id, Map<String, dynamic> data) {
    return PostModel(
      id: id,
      user: data['UserEmail'] ?? '',
      userName: data['UserName'] ?? '',
      userId: data['UserId'] ?? '',
      message: data['PostMessage'] ?? '',
      time: data['TimeStamp'],
      likes: List<String>.from(data['Likes'] ?? []),
      commentCount: data['CommentCount'] ?? 0,
    );
  }
}
