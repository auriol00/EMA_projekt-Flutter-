// lib/services/post_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/helper/dialog_save_delete_funtion.dart';
import 'package:moonflow/models/post_model.dart';

class PostService {
  Future<bool> isPostLiked(String postId, String email) async {
    final doc =
        await FirebaseFirestore.instance.collection('Posts').doc(postId).get();

    if (doc.exists) {
      final data = doc.data();
      final likes = List<String>.from(data?['Likes'] ?? []);
      return likes.contains(email);
    }

    return false; // or throw an error if the post doesn't exist
  }

  Future<bool> isCommentLiked({
    required String postId,
    required String commentId,
    required String email,
  }) async {
    final commentDoc =
        await FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc(commentId)
            .get();

    if (commentDoc.exists) {
      final data = commentDoc.data();
      final likes = List<String>.from(data?['CommentLikes'] ?? []);
      return likes.contains(email);
    }

    return false; // comment doesn't exist or no likes
  }

  static Future<void> toggleLikePost({required PostModel post}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final email = currentUser.email;
    final isLiked = post.likes.contains(email);

    final postRef = FirebaseFirestore.instance.collection('Posts').doc(post.id);

    if (!isLiked) {
      // Like the post
      await postRef.update({
        'Likes': FieldValue.arrayUnion([email]),
      });
    } else {
      // Unlike the post
      await postRef.update({
        'Likes': FieldValue.arrayRemove([email]),
      });
    }
  }

  static Future<void> deleteContent({
    required BuildContext context,
    required String postId,
    String? commentId,
  }) async {
    final isPost = commentId == null;
    final postRef = FirebaseFirestore.instance.collection('Posts').doc(postId);

    await showConfirmationDialog(
      context: context,
      title: isPost ? "Delete Post" : "Delete Comment",
      content:
          isPost
              ? "Are you sure you want to delete this post and all its comments?"
              : "Are you sure you want to delete this comment?",
      barrierDismissible: false,
      onConfirm: () async {
        try {
          if (isPost) {
            // Delete all comments under the post
            final commentsSnapshot = await postRef.collection("Comments").get();
            for (var doc in commentsSnapshot.docs) {
              await postRef.collection("Comments").doc(doc.id).delete();
            }

            // Then delete the post itself
            await postRef.delete();
          } else {
            // Delete the specific comment
            await postRef.collection("Comments").doc(commentId).delete();

            // Decrement comment count
            await postRef.update({'CommentCount': FieldValue.increment(-1)});
          }
        } catch (e) {
          print("Failed to delete content: $e");
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error deleting content.")));
          }
        }
      },
    );
  }

  
}

  /*static Future<void> deletePost(BuildContext context, PostModel post, bool isPost) async {
    await showConfirmationDialog(
      context: context,
      title: isPost ? "Delete Post" : "Delete Comment",
      content: isPost ? "Are you sure you want to delete the post?" : "Are you sure you want to delete the Comment",
      barrierDismissible: false,
      onConfirm: () async {
         DocumentReference postRef = FirebaseFirestore.instance
                      .collection('Posts')
                      .doc(post.id);
      isPost ? (
              // Delete comments first
                  final commentDoc =
                                await postRef
                                    .collection("Comments")
                                    .get();

              for (var doc in commentDoc.docs) {
                await postRef
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              // Then delete post
              await postRef.delete();
    
          )

          : (
            //then delete the comment
                        postRef
                        .collection("Comments")
                        .doc(post.id)
                        .delete()
                        .then((value) => print("Post deleted"))
                        .catchError(
                          (error) => print("Failed to delete Post: $error"),
                        );
                    // update comment
                    postRef.update({'CommentCount': FieldValue.increment(-1)});
          );

      },
    );
  }*/

 

