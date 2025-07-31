/*import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/components/avatar_cache.dart';

class UserAvatar extends StatelessWidget {
  final String? userId;
  final String? avatarUrl;
  final double radius;
  final String fallbackAsset;

  const UserAvatar({
    super.key,
    this.userId,
    this.avatarUrl,
    this.radius = 20,
    this.fallbackAsset = 'assets/avatar2.png',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;
    
    return AvatarCache(
      userId: effectiveUserId,
      avatarUrl: avatarUrl,
      radius: radius,
      fallbackAsset: fallbackAsset,
      child: _buildAvatar(context, effectiveUserId),
    );
  }

  Widget _buildAvatar(BuildContext context, String? userId) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: userId == null 
            ? _buildFallback()
            : _buildAvatarContent(context, userId),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context, String userId) {
    if (avatarUrl != null) {
      return _buildNetworkImage(avatarUrl!);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
    .collection('Users')
    .doc(userId)
    .snapshots(includeMetadataChanges: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildPlaceholder();
        }

        final avatarUrl = snapshot.data!['avatar'] as String?;
        return avatarUrl != null 
            ? _buildNetworkImage(avatarUrl)
            : _buildFallback();
      },
    );
  }

  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      placeholder: (_, __) => _buildPlaceholder(),
      errorWidget: (_, __, ___) => _buildPlaceholder(),
      memCacheHeight: (radius * 2).toInt(),
      memCacheWidth: (radius * 2).toInt(),
      cacheKey: url, // Important for consistent caching
      fadeInDuration: Duration.zero, // Remove fade animation
      fadeOutDuration: Duration.zero,
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Center(
        child: Icon(Icons.person, size: radius),
      ),
    );
  }

  Widget _buildFallback() {
    return Image.asset(
      fallbackAsset,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      cacheWidth: (radius * 2).toInt(),
      cacheHeight: (radius * 2).toInt(),
    );
  }
}*/


import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/utilities/avatar_utils.dart';

/// Widget réutilisable pour afficher l'avatar d'un utilisateur.
///
/// - [userId] : identifiant du document utilisateur dans Firestore.
///   Si non fourni, on utilise l'utilisateur courant.
/// - [radius] : rayon du cercle.
/// - [fallbackAsset] : chemin de l'asset à afficher si aucun avatar n'est défini.
///
class UserAvatar extends StatelessWidget {
  final String userId;
  final double radius;
  final String fallbackAsset;

  UserAvatar({
    super.key,
    String? userId,
    this.radius = 20,
    this.fallbackAsset = 'assets/avatar2.png',
  }) : userId = userId ?? FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(fallbackAsset),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(radius: radius);
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final avatarPath = data?['avatar'] ?? '';

        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[200],
          child: ClipOval(
            child:
                (avatarPath?.startsWith('http') ?? false)
                    ? CachedNetworkImage(
                      imageUrl: avatarPath!,
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Icon(Icons.person, size: radius),
                      errorWidget: (_, __, ___) => Icon(Icons.error),
                    )
                    : Image(
                      image: avatarImageProvider(
                        avatarPath,
                        fallbackAsset: fallbackAsset,
                      ),
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                    ),
          ),
        );
      },
    );
  }
}

 


/*

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moonflow/utilities/avatar_utils.dart';

/// Widget réutilisable pour afficher l'avatar d'un utilisateur.
///
/// - [userId] : identifiant du document utilisateur dans Firestore.
///   Si non fourni, on utilise l'utilisateur courant.
/// - [radius] : rayon du cercle.
/// - [fallbackAsset] : chemin de l'asset à afficher si aucun avatar n'est défini.
/// 
class UserAvatar extends StatelessWidget {
  final String userId;
  final double radius;
  final String fallbackAsset;

   UserAvatar({
    super.key,
    String? userId,
    this.radius = 20,
    this.fallbackAsset = 'assets/avatar2.png',
  })  : userId = userId ?? FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {

     if (userId.isEmpty) {
      // pas d'ID valide ⇒ avatar de fallback
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(fallbackAsset),
      );
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        // Affiche un loader pendant la récupération
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: radius,
            //backgroundColor: Colors.grey[200],
            //child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final data = snapshot.data?.data();
        String avatarPath = data!['avatar'];

        // Génère l'ImageProvider via la fonction utilitaire
        final imageProvider = avatarImageProvider(
          avatarPath,
          fallbackAsset: fallbackAsset,
        );

        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[200],
          backgroundImage: imageProvider,
        );
      },
    );
  }
}
*/