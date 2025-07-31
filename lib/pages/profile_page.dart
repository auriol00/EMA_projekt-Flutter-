// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:moonflow/components/text_box.dart';
// import 'package:moonflow/helper/CheckUserNameExists.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:moonflow/components/user_avatar.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final currentUser = FirebaseAuth.instance.currentUser!;
//   final usersCollection = FirebaseFirestore.instance.collection('Users');

//   Future<void> editField(String field, BuildContext context) async {
//     final doc = await usersCollection.doc(currentUser.uid).get();
//     final currentValue = doc.data()?[field] ?? '';

//     final newValue = await showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         final controller = TextEditingController(text: currentValue);
//         return AlertDialog(
//           title: Text("Edit $field"),
//           content: TextField(
//             controller: controller,
//             decoration: const InputDecoration(hintText: "Enter new value"),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, controller.text),
//               child: const Text("Save"),
//             ),
//           ],
//         );
//       },
//     );

//     if (newValue == null ||
//         newValue.trim() == currentValue ||
//         newValue.trim().isEmpty) {
//       return;
//     }

//     if (field == 'username') {
//       final exists = await checkUserNameExists(newValue.trim());
//       if (exists && context.mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Username already taken")));
//         return;
//       }
//     }

//     await usersCollection.doc(currentUser.uid).update({field: newValue.trim()});
//   }

//   Future<void> _selectAvatarSource() async {
//   final predefined = [
//     'assets/avatar2.png',
//     'assets/avatar3.png',
//     'assets/avatar4.jpg',
//     'assets/avatar5.jpg',
//     'assets/avatar6.jpg',
//     'assets/avatar7.jpg',
//     'assets/avatar8.jpg',
//   ];

//   final source = await showModalBottomSheet<dynamic>(
//     context: context,
//     builder: (_) => SafeArea(
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Ein Bild auswählen'),
//               onTap: () => Navigator.pop(context, ImageSource.gallery),
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Ein Foto aufnehmen'),
//               onTap: () => Navigator.pop(context, ImageSource.camera),
//             ),
//             const Divider(),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 8),
//               child: Text(
//                 'Oder wählen Sie einen vordefinierten Avatar',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//             SizedBox(
//               height: 80,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: predefined.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 12),
//                 itemBuilder: (_, i) => GestureDetector(
//                   onTap: () => Navigator.pop(context, predefined[i]),
//                   child: CircleAvatar(
//                     radius: 30,
//                     backgroundImage: AssetImage(predefined[i]),
//                     backgroundColor: Colors.grey[200],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     ),
//   );

//   if (source == null || !mounted) return;

//   try {
//     // Show loading dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );

//     String? newAvatar;

//     if (source is ImageSource) {
//       // Handle camera/gallery selection
//       final picked = await ImagePicker().pickImage(
//         source: source,
//         maxWidth: 600,
//         imageQuality: 85,
//       );
      
//       if (picked == null) {
//         if (mounted) Navigator.pop(context);
//         return;
//       }

//       // Upload to Firebase Storage
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('user_avatars/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}');
      
//       final uploadTask = storageRef.putFile(File(picked.path));
//       final snapshot = await uploadTask.whenComplete(() {});
//       newAvatar = await snapshot.ref.getDownloadURL();
//     } 
//     else if (source is String) {
//       // Handle predefined avatars
//       newAvatar = source;
//     }

//     if (newAvatar != null) {
//       await usersCollection.doc(currentUser.uid).update({'avatar': newAvatar});
//     }

//     if (mounted) Navigator.pop(context);
//   } catch (e) {
//     if (mounted) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Fehler: ${e.toString()}'),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[300],
//       appBar: AppBar(
//         leading: const BackButton(),
//         elevation: 0,
//         title: const Text('Profile'),
//       ),
//       body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//         stream: usersCollection.doc(currentUser.uid).snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//           final data = snapshot.data?.data();
//           if (data == null) {
//             return const Center(child: Text("User data not found."));
//           }

//           return ListView(
//             children: [
//               const SizedBox(height: 20),
//               Center(
//                 child: UserAvatar(
//                   userId: FirebaseAuth.instance.currentUser!.uid,
//                   radius: 50,
//                   fallbackAsset: 'assets/avatar2.png',
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Center(
//                 child: IconButton(
//                   iconSize: 28,
//                   color: Colors.grey[700],
//                   icon: const Icon(Icons.photo_camera),
//                   onPressed: _selectAvatarSource,
//                 ),
//               ),
//               const SizedBox(height: 25),
//               Text(
//                 data['username'] ?? '',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 data['email'] ?? '',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey[600]),
//               ),
//               const SizedBox(height: 25),
//               const Padding(
//                 padding: EdgeInsets.only(left: 25),
//                 child: Text('My Details', style: TextStyle(color: Colors.grey)),
//               ),
//               MyTextBox(
//                 sectionName: 'username',
//                 text: data['username'] ?? '',
//                 onPressed: () => editField('username', context),
//               ),
//               MyTextBox(
//                 sectionName: 'bio',
//                 text: data['bio'] ?? '',
//                 onPressed: () => editField('bio', context),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moonflow/components/text_box.dart';
import 'package:moonflow/helper/CheckUserNameExists.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonflow/components/user_avatar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection('Users');
  final _predefinedAvatars = [
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.jpg',
    'assets/avatar5.jpg',
    'assets/avatar6.jpg',
    'assets/avatar7.jpg',
    'assets/avatar8.jpg',
  ];

  Future<void> editField(String field, BuildContext context) async {
    final doc = await usersCollection.doc(currentUser.uid).get();
    final currentValue = doc.data()?[field] ?? '';

    final newValue = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: currentValue);
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            "Edit $field",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter new value",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(
                "Save",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ],
        );
      },
    );

    if (newValue == null || newValue.trim() == currentValue) return;

    if (field == 'username') {
      final exists = await checkUserNameExists(newValue.trim());
      if (exists && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Username already taken",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    await usersCollection.doc(currentUser.uid).update({field: newValue.trim()});
  }

  Future<void> _selectAvatarSource() async {
    final source = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Choose from gallery',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Take a photo',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Or choose a predefined avatar',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _predefinedAvatars.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => Navigator.pop(context, _predefinedAvatars[i]),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage(_predefinedAvatars[i]),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );

      String? newAvatar;

      if (source is ImageSource) {
        final picked = await ImagePicker().pickImage(
          source: source,
          maxWidth: 600,
          imageQuality: 85,
        );
        
        if (picked == null) {
          if (mounted) Navigator.pop(context);
          return;
        }

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_avatars/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}');
        
        final uploadTask = storageRef.putFile(File(picked.path));
        final snapshot = await uploadTask.whenComplete(() {});
        newAvatar = await snapshot.ref.getDownloadURL();
      } 
      else if (source is String) {
        newAvatar = source;
      }

      if (newAvatar != null) {
        await usersCollection.doc(currentUser.uid).update({'avatar': newAvatar});
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: usersCollection.doc(currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading profile",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final userData = snapshot.data!.data()!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    UserAvatar(
                      userId: currentUser.uid,
                      radius: 60,
                      fallbackAsset: 'assets/avatar2.png',
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: Theme.of(context).colorScheme.onPrimary,
                        onPressed: _selectAvatarSource,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  userData['username'] ?? 'No username',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  userData['email'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profile Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                MyTextBox(
                  sectionName: 'Username',
                  text: userData['username'] ?? '',
                  onPressed: () => editField('username', context),
                ),
                const SizedBox(height: 12),
                MyTextBox(
                  sectionName: 'Bio',
                  text: userData['bio'] ?? 'Tell us about yourself',
                  onPressed: () => editField('bio', context),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}