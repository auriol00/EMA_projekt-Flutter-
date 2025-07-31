// import 'package:flutter/material.dart';

// class MyTextBox extends StatelessWidget {
//   final String text;
//   final String sectionName;
//   final void Function()? onPressed;
//   const MyTextBox({
//     super.key,
//     required this.text,
//     this.onPressed,
//     required this.sectionName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       padding: const EdgeInsets.only(left: 15, bottom: 15),
//       margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // section name
//               Text(sectionName),

//               // edit button
//               IconButton(
//                 onPressed: onPressed,
//                 icon: Icon(Icons.settings, color: Colors.black),
//               ),
//             ],
//           ),

//             // text
//               Text(
//                 text,
//                 style: TextStyle( fontWeight: FontWeight.bold),
//               ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final VoidCallback? onPressed;

  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sectionName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (onPressed != null)
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: Theme.of(context).iconTheme.color ?? Theme.of(context).colorScheme.primary,
                  visualDensity: VisualDensity.compact,
                  onPressed: onPressed,
                  tooltip: 'Edit',
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
