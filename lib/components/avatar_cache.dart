import 'package:flutter/material.dart';

class AvatarCache extends StatefulWidget {
  final String? userId;
  final String? avatarUrl;
  final double radius;
  final String fallbackAsset;
  final Widget child;

  const AvatarCache({
    super.key, 
    required this.userId,
    required this.avatarUrl,
    required this.radius,
    required this.fallbackAsset,
    required this.child,
  });

  @override
  State<AvatarCache> createState() => _AvatarCacheState();
}

class _AvatarCacheState extends State<AvatarCache> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}