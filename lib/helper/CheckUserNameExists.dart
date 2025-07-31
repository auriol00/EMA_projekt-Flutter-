import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> checkUserNameExists(String username) async {
  final result = await FirebaseFirestore.instance
      .collection('Users')
      .where('username', isEqualTo: username.trim())
      .get();

  return result.docs.isNotEmpty;
}
