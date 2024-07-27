import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planova/pages/bottom_sheet_calendar.dart';
import 'package:planova/pages/habit_add.dart';
import 'package:planova/pages/habit_page.dart';
import 'package:planova/pages/incoming_request_page.dart';
import 'package:planova/pages/journal_page.dart';
import 'package:planova/pages/profile_page.dart';
import 'package:planova/pages/today_add.dart';
import 'package:planova/pages/today_page.dart';
import 'package:planova/pages/today_trash.dart';
import 'package:planova/pages/user_stories_page.dart';
import 'package:planova/pages/welcome_screen.dart';
import 'package:planova/pages/journal_add.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:provider/provider.dart';
import 'package:planova/utilities/theme.dart';

class Homes extends StatelessWidget {
  const Homes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color.fromARGB(255, 3, 218, 198),
          labelTextStyle: MaterialStateProperty.all(
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
  User? user = FirebaseAuth.instance.currentUser;
  late String userId = user!.uid;
  String? userProfileImageUrl;
  String userName = "";
  String filter = 'All Tasks'; // Default filter

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
  }

  Future<void> _loadUserProfileImage() async {
    userName = await _getUserName(user?.uid ?? '');

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        userProfileImageUrl = userDoc['imageUrl'] ?? '';
      });
    }
  }

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

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Filtrele',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RadioListTile<String>(
                  title: const Text(
                    'All Tasks',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: 'All Tasks',
                  groupValue: filter,
                  onChanged: (value) {
                    setState(() {
                      filter = value!;
                      Navigator.of(context).pop();
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text(
                    'Favorite Tasks',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: 'Favorite Tasks',
                  groupValue: filter,
                  onChanged: (value) {
                    setState(() {
                      filter = value!;
                      Navigator.of(context).pop();
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text(
                    'Habits',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: 'Habits',
                  groupValue: filter,
                  onChanged: (value) {
                    setState(() {
                      filter = value!;
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAnonymousAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uyarı'),
          content: const Text(
              'Habit kısmını misafir ile giriş yapmış iken kullanamazsınız. Lütfen hesap oluşturun.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  currentPageIndex = 0;
                });
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );
  }

  void _showProfileAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uyarı'),
          content: const Text(
              'Bu işleme devam edebilmek için profil oluşturmanız gerekmektedir.\n\n(Bio kısmına yazı ekleyerek story kısmını daha detaylı hale getirebilirsiniz.)'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  currentPageIndex = 0;
                });
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  currentPageIndex = 3;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isUserInCollection(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);

    return Scaffold(
      backgroundColor: theme.cardBackground,
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
          if (currentPageIndex != 0)
          IconButton(
            icon: const Icon(Icons.book_outlined, color: Colors.white),
            onPressed: () async {
              
              
                 if (user != null && user.isAnonymous) {
                    _showAnonymousAlertDialog(context);
                    return;
                  }
                  bool userExists = await _isUserInCollection(userId);
                  if (!userExists) {
                    _showProfileAlertDialog(context);
                    return;
                  }
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserStoriesPage()),
                );},
          ),
          if (currentPageIndex == 3)
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: null,
          ),

           if (currentPageIndex == 2)
          IconButton(
            icon: const Icon(Icons.weekend_outlined, color: Colors.white),
            onPressed: null,
          ),


          if (currentPageIndex == 0)
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _openFilterDialog,
          ),
          if (currentPageIndex == 0)
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              onPressed: _openCalendarBottomSheet,
            ),
          if (currentPageIndex == 1)
            IconButton(
              icon: const Icon(Icons.inbox, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => IncomingRequestsPage()),
                );
              },
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
                  FutureBuilder(
                    future: _getUserProfileImage(userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(snapshot.data!),
                        );
                      } else {
                        return CircleAvatar(
                          radius: 30,
                          backgroundImage: const AssetImage(
                              'assets/images/default_profile.png'),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _getUserName(userId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        } else {
                          return Text(
                            (user?.email) ?? 'Anonymous User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                      },
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
              title: const Text('Habits', style: TextStyle(color: Colors.white)),
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
                setState(() {
                  currentPageIndex = 2;
                });
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
            ListTile(
              leading: const Icon(Icons.book, color: Colors.white),
              title: const Text('User Stories',
                  style: TextStyle(color: Colors.white)),
              onTap: () async {

                if (user != null && user.isAnonymous) {
                    _showAnonymousAlertDialog(context);
                    return;
                  }
                  bool userExists = await _isUserInCollection(userId);
                  if (!userExists) {
                    _showProfileAlertDialog(context);
                    return;
                  }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserStoriesPage()),
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
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.color_lens, color: Colors.white),
              title: const Text('Change Theme', style: TextStyle(color: Colors.white)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Select Theme'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Theme 1'),
                            onTap: () {
                              themeProvider.setThemeValue(1);
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            title: const Text('Theme 2'),
                            onTap: () {
                              themeProvider.setThemeValue(2);
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            title: const Text('Theme 3'),
                            onTap: () {
                              themeProvider.setThemeValue(3);
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            title: const Text('Theme 4'),
                            onTap: () {
                              themeProvider.setThemeValue(4);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: currentPageIndex == 3
          ? null
          : FloatingActionButton(
              onPressed: () async {
                if (currentPageIndex == 1 || currentPageIndex == 2) {
                  if (user != null && user.isAnonymous) {
                    _showAnonymousAlertDialog(context);
                    return;
                  }
                  bool userExists = await _isUserInCollection(userId);
                  if (!userExists) {
                    _showProfileAlertDialog(context);
                    return;
                  }
                }
                switch (currentPageIndex) {
                  case 0:
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => TodayAddSubPage(focusDate: _focusDate),
                    );
                    break;
                  case 1:
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const HabitAddPage(),
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
              backgroundColor: theme.activeColor,
              child: const Icon(
                Icons.add,
                size: 32,
                color: Colors.black,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.cardBackground,
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
          filter: filter,
        ),
        const HabitPage(),
        const JournalPage(),
        const ProfilePage(),
      ][currentPageIndex],
    );
  }

  Future<String?> _getUserProfileImage(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['imageUrl'] ?? '';
  }

  Future<String> _getUserName(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['name'] ?? '';
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
