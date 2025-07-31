// lib/utils/avatar_utils.dart
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Retourne un ImageProvider adapté :
/// - si `avatarPath` est null ou vide, on tombe sur l’asset de fallback,
/// - si `avatarPath` commence par 'assets/', on crée un AssetImage,
/// - sinon on crée un FileImage.
ImageProvider avatarImageProvider(String? avatarPath, {
  String fallbackAsset = 'assets/avatar2.png',
}) {
  if (avatarPath == null || avatarPath.isEmpty) {
    return AssetImage(fallbackAsset);
  }
  if (avatarPath.startsWith('assets/')) {
    return AssetImage(avatarPath);
  }
  if (avatarPath.startsWith('http')) {
    return NetworkImage(avatarPath); // Handle Firebase Storage URLs
  }
  if (avatarPath.startsWith('http')) {  // <-- Add this block
    return CachedNetworkImageProvider(avatarPath);
  }
  return FileImage(File(avatarPath)); // Fallback for local files (optional)
}