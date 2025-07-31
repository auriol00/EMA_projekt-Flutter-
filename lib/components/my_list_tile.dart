import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  const MyListTile({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20, right: 20, bottom: 10
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(title), 
          subtitle: Text(subTitle)
        ),
      ),
    );
  }
}
