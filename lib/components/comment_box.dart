import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/delete_button.dart';
import 'package:moonflow/components/like_button.dart';
import 'package:moonflow/components/user_avatar.dart';
import 'package:moonflow/helper/timeformat.dart';
import 'package:moonflow/models/comment_model.dart';
import 'package:moonflow/services/chat/forum_sevices.dart';
import 'package:moonflow/utilities/app_localizations.dart';

class CommentBox extends StatefulWidget {
  final CommentModel commentModel;

  const CommentBox({super.key, required this.commentModel});

  @override
  State<CommentBox> createState() => _CommentBox();
}

class _CommentBox extends State<CommentBox> {
  bool isExpanded = false;

  //toggle like
  void toggleLike() {
    final currentUser = FirebaseAuth.instance.currentUser!;
    // if current usr is in list of overall likes
    bool isliked = widget.commentModel.commentLikes.contains(currentUser.email);
    setState(() {
      isliked = !isliked;
    });

    // Access the document in Firebase
    DocumentReference postRef = FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.commentModel.postId)
        .collection("Comments")
        .doc(widget.commentModel.id);

    if (isliked) {
      // Add User if post is now like
      postRef.update({
        'CommentLikes': FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      //if the post is now unliked, remove the user's email from the 'Likes' field
      postRef.update({
        'CommentLikes': FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser!;
    final isliked = widget.commentModel.commentLikes.contains(
      currentUser.email,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Avatar + comment content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // avatar
                  UserAvatar(userId: widget.commentModel.userId, radius: 20),
                  const SizedBox(width: 10),

                  // Username, time, delete button, and message
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Username
                            Text(
                              widget.commentModel.userName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Time of post
                            Text(
                              formatData(widget.commentModel.time),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

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
                                widget.commentModel.message,
                                maxLines: isExpanded ? null : 2,
                                overflow:
                                    isExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  height: 1.4,
                                ),
                              ),
                              if (widget.commentModel.message.length > 100)
                                Text(
                                  isExpanded
                                      ? AppLocalizations.translate(
                                        context,
                                        'show less',
                                      )
                                      : AppLocalizations.translate(
                                        context,
                                        'show more',
                                      ),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Like + Delete Column
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // delete
                if (widget.commentModel.user == currentUser.email)
                  DeleteButton(
                    onTap:
                        () async => await PostService.deleteContent(
                          context: context,
                          postId: widget.commentModel.postId,
                          commentId: widget.commentModel.id,
                        ),
                  ),
                const SizedBox(height: 15),
                Column(
                  children: [
                    LikeButton(isLiked: isliked, onTap: toggleLike),
                    Text(
                      widget.commentModel.commentLikes.length.toString(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
