import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/CustomApp_Bar.dart';
import 'package:moonflow/components/my_drawer.dart';
import 'package:moonflow/components/post_box.dart';
import 'package:moonflow/components/searchBar.dart';
import 'package:moonflow/components/textField.dart';
import 'package:moonflow/models/post_model.dart';
import 'package:moonflow/pages/customCalendar_page.dart';
import 'package:moonflow/services/chat/firestore.dart';
import 'package:emoji_selector/emoji_selector.dart';
import 'package:moonflow/services/period_firebaseStore_service.dart';
import 'package:moonflow/utilities/app_localizations.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final FocusNode _focusNode = FocusNode();
  bool _showEmojiPicker = false;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String _sortBy = 'newest';
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    newPostController.dispose();
    super.dispose();
  }

  void postMessage() {
    String message = newPostController.text.trim();
    if (message.isNotEmpty) {
      database.addPost(message);
      newPostController.clear();
    }
  }

  List<PostModel> sortPosts(List<PostModel> posts) {
    if (_sortBy == 'my_posts') return posts;

    switch (_sortBy) {
      case 'most_liked':
        posts.sort((a, b) => b.likes.length.compareTo(a.likes.length));
        break;
      case 'most_commented':
        posts.sort((a, b) => b.commentCount.compareTo(a.commentCount));
        break;
      case 'newest':
        posts.sort((a, b) => b.time.compareTo(a.time));
        break;
      case 'oldest':
      default:
        posts.sort((a, b) => a.time.compareTo(b.time));
    }
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sortOptions = [
      'newest',
      'oldest',
      'most_liked',
      'most_commented',
      'my_posts',
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(AppLocalizations.translate(context, 'forum')),
        onCalendarPressed: () async {
          final periods = await PeriodFirestoreService.loadAllPeriods();
            if (!context.mounted) return;

          Navigator.push(context, 
          MaterialPageRoute(builder: (context) => CustomCalendarPage(
            periods: periods,
          )));

        },
      ),
      drawer: MyDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                SmartSearchBar(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => searchQuery = val);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          sortOptions
                              .map(
                                (sortKey) => Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _sortBy = sortKey);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _sortBy == sortKey
                                                ? colorScheme.primary
                                                : theme.cardColor,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              _sortBy == sortKey
                                                  ? Colors.transparent
                                                  : theme.dividerColor,
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.translate(
                                          context,
                                          sortKey,
                                        ),
                                        style: TextStyle(
                                          color:
                                              _sortBy == sortKey
                                                  ? theme.colorScheme.onPrimary
                                                  : theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
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
                StreamBuilder(
                  stream: database.getPostsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "${AppLocalizations.translate(context, 'error')}: ${snapshot.error}",
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    final postDocs = snapshot.data?.docs ?? [];
                    List<PostModel> posts =
                        postDocs
                            .map(
                              (doc) => PostModel.fromMap(
                                doc.id,
                                doc.data() as Map<String, dynamic>,
                              ),
                            )
                            .toList();

                    posts = sortPosts(posts);

                    if (searchQuery.isNotEmpty) {
                      posts =
                          posts
                              .where(
                                (post) => post.message.toLowerCase().contains(
                                  searchQuery.toLowerCase(),
                                ),
                              )
                              .toList();
                    }

                    if (_sortBy == 'my_posts') {
                      posts =
                          posts
                              .where((post) => post.user == currentUser?.email)
                              .toList();
                    }

                    if (posts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Text(
                            AppLocalizations.translate(context, 'no_posts'),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: posts.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostBox(post: post);
                      },
                    );
                  },
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: theme.dividerColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _showEmojiPicker
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions_outlined,
                              color: theme.iconTheme.color,
                            ),
                            onPressed: () {
                              if (_showEmojiPicker) {
                                FocusScope.of(context).requestFocus(_focusNode);
                              } else {
                                FocusScope.of(context).unfocus();
                              }
                              setState(
                                () => _showEmojiPicker = !_showEmojiPicker,
                              );
                            },
                          ),
                          Expanded(
                            child: MyTextField(
                              controller: newPostController,
                              hintText: AppLocalizations.translate(
                                context,
                                'type_message',
                              ),
                              obscureText: false,
                              focusNode: _focusNode,
                              onChanged: (text) {},
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send_rounded,
                              color: const Color.fromARGB(255, 124, 121, 121),
                            ),
                            onPressed: postMessage,
                          ),
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: !_showEmojiPicker,
                      child: SafeArea(
                        top: false,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.35,
                          ),
                          child: EmojiSelector(
                            onSelected: (emoji) {
                              newPostController.text += emoji.char;
                              newPostController
                                  .selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: newPostController.text.length,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
