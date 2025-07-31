import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices extends ChangeNotifier {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get current user
  User? getCurrentUser() => _auth.currentUser;

  //get current user id
  String getCurrentUserId() => _auth.currentUser!.uid;

  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential? userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await Future.delayed(const Duration(seconds: 1));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String userName,
    password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // create document for new user
      _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'username': userName.isNotEmpty ? userName : email.split('@')[0],
        'bio': 'No bio yet',
        'avatar': 'assets/avatar2.png',
        'profileComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
        //add additional fields as needed
      });
      await _auth.signOut();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  final GoogleSignIn _googleSignIn =
      GoogleSignIn(); // declare once at class level

  Future<void> signOut() async {
    await _auth.signOut();

    try {
      // Disconnect only if previously signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect(); // Revokes access
      }
      await _googleSignIn.signOut(); // Signs out locally
    } on FirebaseAuthException catch (e) {
      throw Exception('error logout: ${e.message}');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Abort if user cancels
      if (googleUser == null) return null;

      // Get Google auth credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Get user
      final user = userCredential.user;
      if (user == null) return userCredential;

      // Create Firestore document if not exists
      final docRef = _firestore.collection('Users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set({
          'email': user.email,
          'username': user.displayName ?? user.email?.split('@')[0],
          'bio': 'No bio yet',
          'avatar': 'assets/avatar2.png',
          'profileComplete': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('Google sign-in failed: ${e.message}');
    }
  }

  // reset password

  //errors
}
