import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moonflow/components/comment_button.dart';
import 'package:moonflow/components/delete_button.dart';
import 'package:moonflow/components/like_button.dart';
import 'package:moonflow/components/user_avatar.dart';
import 'package:moonflow/helper/timeformat.dart';
import 'package:moonflow/models/post_model.dart';
import 'package:moonflow/pages/comment_page.dart';
import 'package:moonflow/services/chat/forum_sevices.dart';

class PostBox extends StatefulWidget {
  final PostModel post;
  const PostBox({super.key, required this.post});

  @override
  State<PostBox> createState() => _PostBoxState();
}

class _PostBoxState extends State<PostBox> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final isLiked = widget.post.likes.contains(currentUser.email);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 0.2,
            color: theme.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UserAvatar(
                  userId: widget.post.userId,
                  radius: 20,
                  fallbackAsset: 'assets/avatar2.png',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatData(widget.post.time),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (widget.post.user == currentUser.email)
                      DeleteButton(
                        onTap: () async => await PostService.deleteContent(
                          context: context,
                          postId: widget.post.id,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Username
            Text(
              widget.post.userName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
                    widget.post.message,
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
                  if (widget.post.message.length > 100)
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

            const SizedBox(height: 10),

            // Like + Comment row
            Row(
              children: [
                LikeButton(
                  isLiked: isLiked,
                  onTap: () async =>
                      await PostService.toggleLikePost(post: widget.post),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.post.likes.length.toString(),
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(width: 10),

                CommentButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentPage(post: widget.post),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 5),
                Text(
                  widget.post.commentCount.toString(),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

