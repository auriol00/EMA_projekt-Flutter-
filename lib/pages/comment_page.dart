//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_selector/emoji_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/comment_box.dart';
import 'package:moonflow/components/live_post_box.dart';
import 'package:moonflow/components/textField.dart';
import 'package:moonflow/models/comment_model.dart';
import 'package:moonflow/models/post_model.dart';
import 'package:moonflow/services/chat/firestore.dart';
import 'package:moonflow/utilities/app_localizations.dart';

class CommentPage extends StatefulWidget {
  final PostModel post;

  const CommentPage({super.key, required this.post});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final FocusNode _focusNode = FocusNode();
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();

    // Hide emoji picker when keyboard is shown
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  String _sortBy = 'Newest'; // current sort type

  // current logged in user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController newCommentController = TextEditingController();

  // helper to sort comments
  List<CommentModel> sortComments(List<CommentModel> comments) {
    if (_sortBy == 'My Comments') return comments;

    switch (_sortBy) {
      case 'Most Liked':
        comments.sort(
          (a, b) => b.commentLikes.length.compareTo(a.commentLikes.length),
        );
        break;
      case 'Newest':
        comments.sort((a, b) => b.time.compareTo(a.time));
        break;
      case 'Oldest':
      default:
        comments.sort((a, b) => a.time.compareTo(b.time));
    }
    return comments;
  }

  // post comment
  Future<void> postComment() async {
    final message = newCommentController.text.trim();
    if (message.isEmpty) return;

    try {
      await FirestoreDatabase().addComment(
        commentText: message,
        postId: widget.post.id,
      );

      await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.post.id)
          .update({'CommentCount': FieldValue.increment(1)});

      newCommentController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.translate(context, 'failed_post_comment')}: ${e.toString()}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content
            ListView(
              padding: EdgeInsets.only(bottom: 80),
              children: [
                // Filter bar
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          ['Newest', 'Oldest', 'Most Liked', 'My Comments']
                              .map(
                                (sortOption) => Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _sortBy = sortOption;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _sortBy == sortOption
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        sortOption,
                                        style: TextStyle(
                                          color:
                                              _sortBy == sortOption
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Live post
                LivePostBox(postModel: widget.post),
                const SizedBox(height: 10),

                Text(
                  AppLocalizations.translate(context, 'comments'),
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 10),

                // Comments stream
                StreamBuilder(
                  stream:
                      FirebaseFirestore.instance
                          .collection('Posts')
                          .doc(widget.post.id)
                          .collection("Comments")
                          //.orderBy('CommentTime', descending: true)
                          .orderBy(
                            'CommentTime',
                            descending: _sortBy == 'Newest',
                          )
                          .limit(20)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${AppLocalizations.translate(context, 'error')}: ${snapshot.error}',
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    List<CommentModel> comments =
                        docs
                            .map(
                              (doc) => CommentModel.fromMap(
                                postId: widget.post.id,
                                doc.id,
                                data: doc.data(),
                              ),
                            )
                            .toList();

                    if (_sortBy == 'My Comments') {
                      comments =
                          comments
                              .where((c) => c.user == currentUser.email)
                              .toList();
                    }

                    comments = sortComments(comments);

                    if (comments.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            AppLocalizations.translate(context, 'no_comments'),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      addAutomaticKeepAlives: true,
                      itemCount: comments.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      itemBuilder: (context, index) {
                        //final comment = comments[index];
                        return CommentBox(
                          key: ValueKey(comments[index].id), // Unique key
                          commentModel: comments[index],
                        );
                      },
                    );
                  },
                ),
              ],
            ),

            // Fixed emoji + input box
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _showEmojiPicker
                              ? Icons.keyboard
                              : Icons.emoji_emotions_outlined,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          if (_showEmojiPicker) {
                            FocusScope.of(context).requestFocus(_focusNode);
                          } else {
                            FocusScope.of(context).unfocus();
                          }
                          setState(() {
                            _showEmojiPicker = !_showEmojiPicker;
                          });
                        },
                      ),
                      Expanded(
                        child: MyTextField(
                          controller: newCommentController,
                          hintText: AppLocalizations.translate(
                            context,
                            'type_message',
                          ),
                          obscureText: false,
                          focusNode: _focusNode,
                          onChanged: (text) {
                            // Handle text changes
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.blueAccent,
                        ),
                        onPressed: postComment,
                      ),
                    ],
                  ),

                  // Emoji Picker
                  Offstage(
                    offstage: !_showEmojiPicker,
                    child: EmojiSelector(
                      onSelected: (emoji) {
                        newCommentController.text += emoji.char;
                        newCommentController
                            .selection = TextSelection.fromPosition(
                          TextPosition(
                            offset: newCommentController.text.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
