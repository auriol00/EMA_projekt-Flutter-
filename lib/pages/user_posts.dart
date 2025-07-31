import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/post_box.dart';
import 'package:moonflow/models/post_model.dart';

class UserPostsPage extends StatefulWidget {
  const UserPostsPage({super.key});

  @override
  State<UserPostsPage> createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  late final String userEmail = currentUser.email!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$userEmail\'s Posts')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .where('UserEmail', isEqualTo: userEmail) // <-- FIXED FIELD NAME
            .orderBy('TimeStamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Text("No posts found."),
              ),
            );
          }

          final postDocs = snapshot.data!.docs;
          List<PostModel> posts = postDocs.map((doc) {
            return PostModel.fromMap(doc.id, doc.data());
          }).toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) => PostBox(post: posts[index]),
          );
        },
      ),
    );
  }
}
