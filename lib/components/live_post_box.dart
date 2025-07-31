/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/comment_button.dart';
import 'package:moonflow/components/delete_button.dart';
import 'package:moonflow/components/like_button.dart';
import 'package:moonflow/components/user_avatar.dart';
import 'package:moonflow/helper/timeformat.dart';
import 'package:moonflow/models/post_model.dart';
import 'package:moonflow/services/chat/forum_sevices.dart';

class LivePostBox extends StatefulWidget {
  final PostModel postModel;

  const LivePostBox({super.key, required this.postModel});

  @override
  State<LivePostBox> createState() => _LivePostBoxState();
}

class _LivePostBoxState extends State<LivePostBox> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Posts')
              .doc(widget.postModel.id)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Post not found or error occurred'),
          );
        }

        // Convert Firestore data to PostModel
        final postData = snapshot.data!.data() as Map<String, dynamic>;
        final post = PostModel.fromMap(snapshot.data!.id, postData);

        final currentUser = FirebaseAuth.instance.currentUser!;
        final isliked = post.likes.contains(currentUser.email);

        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
          child: Container(
            decoration: BoxDecoration(
              //color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  //color: Colors.grey, // Choose your color
                  width: 1.0, // Set thickness
                ),
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User + Delete button (if owner)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UserAvatar(
                      userId: widget.postModel.userId,
                      radius: 20,
                      // fallbackAsset: 'assets/avatar2.png',
                    ),

                    if (post.user == currentUser.email)
                      DeleteButton(
                        onTap:
                            () async => await PostService.deleteContent(
                              context: context,
                              postId: post.id,
                            ),
                      ),
                  ],
                ),

                // Username
                Row(
                  children: [
                    Text(
                      post.userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5),
                    //time
                    Text(
                      formatData(post.time),
                      style: TextStyle(
                        fontSize: 12,
                        // color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Scrollable message

                // Message with tap-to-expand
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.message,
                      maxLines: isExpanded ? null : 4,
                      overflow:
                          isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (post.message.length > 100)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded ? 'Show less' : 'Show more',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                    SizedBox(height: 5),

                Row(
                  children: [
                    LikeButton(
                      isLiked: isliked,
                      onTap: () async {
                        await PostService.toggleLikePost(post: post);
                      },
                    ),
                    SizedBox(width: 5),
                    // like count
                    Text(post.likes.length.toString()),
                    SizedBox(width: 10),
                    // comment button
                    CommentButton(),
                    SizedBox(width: 5),

                    //comment count
                    Text(post.commentCount.toString()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/comment_button.dart';
import 'package:moonflow/components/delete_button.dart';
import 'package:moonflow/components/like_button.dart';
import 'package:moonflow/components/user_avatar.dart';
import 'package:moonflow/helper/timeformat.dart';
import 'package:moonflow/models/post_model.dart';
import 'package:moonflow/services/chat/forum_sevices.dart';

class LivePostBox extends StatefulWidget {
  final PostModel postModel;

  const LivePostBox({super.key, required this.postModel});

  @override
  State<LivePostBox> createState() => _LivePostBoxState();
}

class _LivePostBoxState extends State<LivePostBox> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.postModel.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Post not found or error occurred',
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        // Convert Firestore data to PostModel
        final postData = snapshot.data!.data() as Map<String, dynamic>;
        final post = PostModel.fromMap(snapshot.data!.id, postData);

        final currentUser = FirebaseAuth.instance.currentUser!;
        final isliked = post.likes.contains(currentUser.email);

        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1.0,
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User + Delete button (if owner)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UserAvatar(
                      userId: widget.postModel.userId,
                      radius: 20,
                    ),
                    if (post.user == currentUser.email)
                      DeleteButton(
                        onTap: () async => await PostService.deleteContent(
                          context: context,
                          postId: post.id,
                        ),
                      ),
                  ],
                ),

                // Username and timestamp
                Row(
                  children: [
                    Text(
                      post.userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatData(post.time),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Message with tap-to-expand
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.postModel.message,
                    maxLines: isExpanded ? null : 4,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                  if (widget.postModel.message.length > 100)
                    Text(
                      isExpanded ? 'Show less' : 'Show more',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),

                const SizedBox(height: 5),

                // Like and comment buttons
                Row(
                  children: [
                    LikeButton(
                      isLiked: isliked,
                      onTap: () async {
                        await PostService.toggleLikePost(post: post);
                      },
                    ),
                    const SizedBox(width: 5),
                    Text(
                      post.likes.length.toString(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 10),
                    const CommentButton(),
                    const SizedBox(width: 5),
                    Text(
                      post.commentCount.toString(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}