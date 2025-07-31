// return a formatted data as a string

/*import 'package:cloud_firestore/cloud_firestore.dart';

String formatData(Timestamp timestamp) {
  // Timestamp is an object we retrieve from firebase
  // we conwert to string to display
  DateTime dateTime = timestamp.toDate();

  //

}
*/
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatData(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  DateTime now = DateTime.now();

  // Check if it's today
  if (DateFormat('yyyy-MM-dd').format(dateTime) == DateFormat('yyyy-MM-dd').format(now)) {
    return DateFormat('h:mm a').format(dateTime); // e.g., 2:30 PM
  }

  // Check if it was yesterday
  if (DateFormat('yyyy-MM-dd').format(dateTime) ==
      DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: 1)))) {
    return 'Yesterday';
  }

  // If it's this year, show month and day
  if (dateTime.year == now.year) {
    return DateFormat('MMM d').format(dateTime); // e.g., Apr 4
  }

  // Otherwise, show full date
  return DateFormat('MMM d, yyyy').format(dateTime); // e.g., Mar 14, 2023
}
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatData(Timestamp timestamp) {
  DateTime messageTime = timestamp.toDate();
  DateTime now = DateTime.now();
  Duration diff = now.difference(messageTime);

  if (diff.inSeconds < 60) {
    return 'Just now';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
  } else if (diff.inHours < 24 && messageTime.day == now.day) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  } else if (diff.inDays == 1 || (now.day - messageTime.day == 1)) {
    return 'Yesterday';
  } else if (diff.inDays < 7) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  } else if (messageTime.year == now.year) {
    return DateFormat('MMM d').format(messageTime); // e.g., Apr 4
  } else {
    return DateFormat('MMM d, yyyy').format(messageTime); // e.g., Mar 14, 2023
  }
}
