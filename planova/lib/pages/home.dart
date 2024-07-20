import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planova/pages/bottom_sheet_calendar.dart';
import 'package:planova/pages/habit_add.dart';
import 'package:planova/pages/habit_page.dart';
import 'package:planova/pages/journal_page.dart';
import 'package:planova/pages/profile_page.dart';
import 'package:planova/pages/today_add.dart';
import 'package:planova/pages/today_page.dart';
import 'package:planova/pages/today_trash.dart';
import 'package:planova/pages/welcome_screen.dart';
import 'package:planova/pages/journal_add.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

class Homes extends StatelessWidget {
  const Homes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color.fromARGB(255, 3, 218, 198),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white),
          ),
        ),
      ),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  static int currentPageIndex = 0;
  final List<String> appBarTitles = ['Today', 'Habits', 'Journal', 'Profile'];

  final EasyInfiniteDateTimelineController _controller =
      EasyInfiniteDateTimelineController();
  DateTime? _focusDate = DateTime.now();

  void _openCalendarBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetCalendar(
        controller: _controller,
        onDateSelected: (selectedDate) {
          setState(() {
            _focusDate = selectedDate;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.08),
            Text(appBarTitles[currentPageIndex],
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Implement your search action here
            },
          ),

          if (currentPageIndex == 0)
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              onPressed:
                  _openCalendarBottomSheet, // Takvim butonuna basıldığında açılır
            ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF333333),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF333333),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      user?.email ?? 'Anonymous User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.white),
              title: const Text('Today', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  currentPageIndex = 0;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.white),
              title:
                  const Text('Habits', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  currentPageIndex = 1;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.white),
              title: const Text('Important Task',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                setState() {
                  currentPageIndex = 2;
                }

                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.white),
              title:
                  const Text('Deleted', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrashPage()),
                );
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Implement your settings action here
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await Auth().signOut(context: context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: currentPageIndex == 3 
  ? null 
  : FloatingActionButton(
      onPressed: () {
        switch (currentPageIndex) {
          case 0:
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const TodayAddSubPage(),
            );
            break;
          case 1:
             showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) =>  HabitAddPage (),
            );
            break;
          case 2:
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const JournalAddSubPage(),
            );
            break;
          default:
        }
      },
      backgroundColor: const Color.fromARGB(255, 3, 218, 198),
      child: const Icon(
        Icons.add,
        size: 32,
        color: Colors.black,
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(255, 42, 42, 42),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.calendar_month_outlined,
              color: Colors.black,
              size: 20,
            ),
            icon: Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: 'Today',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.flag_outlined,
              color: Colors.black,
              size: 20,
            ),
            icon: Icon(
              Icons.flag_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: 'Habits',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.library_books_outlined,
              color: Colors.black,
              size: 20,
            ),
            icon: Icon(
              Icons.library_books_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: 'Journal',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.person_outline,
              color: Colors.black,
              size: 20,
            ),
            icon: Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: [
        TodayPage(
          controller: _controller,
          focusDate: _focusDate,
          onDateChange: (selectedDate) {
            setState(() {
              _focusDate = selectedDate;
            });
          },
        ),
        const HabitPage(),
        const JournalPage(),
        const ProfilePage(),
      ][currentPageIndex],
    );
  }
}

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signOut({required BuildContext context}) async {
    await _firebaseAuth.signOut();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()));
  }
}
