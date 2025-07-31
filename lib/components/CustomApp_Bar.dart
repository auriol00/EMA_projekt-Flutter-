import 'package:flutter/material.dart';
import 'package:moonflow/components/user_avatar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final double elevation;
  final VoidCallback? onCalendarPressed;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.elevation = 16.0,
    this.onCalendarPressed,
  });

  @override
  Widget build(BuildContext context) {
    //final uid = FirebaseAuth.instance.currentUser!.uid;
    return AppBar(
      elevation: elevation,
      centerTitle: true,
      title: title ?? const Text('Moonflow'),

      //actions: actions ??
      // [
      // IconButton(onPressed: () {}, icon: const Icon(Icons.calendar_month)),
      //  ],
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: onCalendarPressed,
            ),
          ],

      leading: Builder(
        builder:
            (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: UserAvatar(
                //userId: uid,
                radius: 16,
                fallbackAsset: 'assets/profilLogo.png',
              ),
            ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
