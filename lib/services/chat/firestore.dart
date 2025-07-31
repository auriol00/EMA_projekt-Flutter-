/*
Database stores posts that users have published in the App
It stores in a collection called 'Posts' in Firebase

Each Post contains
- A message
- email of user
- timestamp

*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {
  // current logged in user
  User? user = FirebaseAuth.instance.currentUser;

  // Post a message
  final CollectionReference posts = FirebaseFirestore.instance.collection(
    'Posts',
  );
  final CollectionReference avatar = FirebaseFirestore.instance.collection(
    'Avatar',
  );

  


  // Read Post from Firebase
  Future<Future<DocumentReference<Object?>>> addPost(String message) async {
    // Get username from Firestore
    final userDoc =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user?.uid)
            .get();

    final username = userDoc.data()?['username'] ?? 'Unknown';

    // Add post with username
    return posts.add({
      'UserEmail': user?.email,
      'UserId': user!.uid,
      'UserName': username,
      'PostMessage': message,
      'Likes': [],
      'CommentCount': 0,
      'TimeStamp': Timestamp.now(),
    });
  }

  /*Future<void> addPost(String message) {
    return posts.add({
      'UserEmail': user!.email,
      'username': user!.,
      'PostMessage': message,
      'Likes': [],
      'CommentCount': 0,
      'TimeStamp': Timestamp.now(),
    });
  }*/

  // read Post from database
  Stream<QuerySnapshot> getPostsStream() {
    final postsStream =
        FirebaseFirestore.instance
            .collection('Posts')
            .orderBy('TimeStamp', descending: true)
            .snapshots();
    return postsStream;
  }

  // add comments
  Future<void> addComment({
    required String postId,
    required String commentText,
  }) async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .get();
    final username = userDoc.data()?['username'] ?? 'Unknown';

    // write the comment to firestore under the comments collection for this post
    FirebaseFirestore.instance
        .collection("Posts")
        .doc(postId)
        .collection("Comments")
        .add({
          "CommentText": commentText,
          "CommentedBy": user?.email,
          'CommentedByUid': user?.uid,
          "CommentedByName": username,
          "CommentTime": Timestamp.now(),
          "CommentLikes": [],
        });
  }

  // collection of all comments
  Future<void> addAllComments({
    required String postId,
    required String commentText,
    required String commentedBy,
  }) async {
    final commentData = {
      'commentText': commentText,
      'postId': postId,
      'commentedBy': commentedBy,
      'timestamp': Timestamp.now(),
      'likes': [],
      'likesCount': 0,
    };

    final commentRef =
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc();

    await commentRef.set(commentData);

    // Also mirror to top-level collection
    await FirebaseFirestore.instance
        .collection('AllComments')
        .doc(commentRef.id)
        .set(commentData);
  }
}
