import 'package:flutter/material.dart';
import 'package:moonflow/pages/chat_screen.dart';
import 'package:moonflow/pages/forum_page.dart';
import 'package:moonflow/pages/partner_page.dart';
import 'package:moonflow/pages/today_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  final pages = [
    TodayPage(),
    ChatScreenPage(),
    ForumPage(),
    PartnerPage(),
  ];

  int pageIndex = 0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],
        bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: NavigationBar(
          selectedIndex: pageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              pageIndex = index;
            });
          },
          //backgroundColor: const Color.fromRGBO(220, 200, 250, 0.7),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month),
              label: "Today",
            ),
            NavigationDestination(icon: Icon(Icons.message), label: "Messages"),
            NavigationDestination(icon: Icon(Icons.masks), label: "Forum"),
            NavigationDestination(icon: Icon(Icons.people), label: "Partner"),
          ],
        ),
      ),
      //drawer: MyDrawer(),
      /**
        appBar: CustomAppBar(
        isTodayPage: pageIndex == 0,
        onCalendarIconTap: pageIndex == 0 ? handleCalendarPick : null,
      ),
       */
    );
  }
}

