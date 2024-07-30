import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planova/localization_checker.dart';
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
import 'package:planova/pages/pin_entry_page.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:provider/provider.dart';
import 'package:planova/utilities/theme.dart';
import 'settings_page.dart';

class LanguageChangeNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

class Homes extends StatelessWidget {
  const Homes({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);

    return ChangeNotifierProvider(
      create: (_) => LanguageChangeNotifier(),
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: theme.addButton,
            labelTextStyle: MaterialStateProperty.all(
              TextStyle(color: theme.welcomeText),
            ),
          ),
        ),
        home: const NavigationExample(),
      ),
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
  String filter = tr('All Tasks');

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

  List<String> get appBarTitles => [
    tr("Today"),
    tr("Habits"),
    tr("Journal"),
    tr("Profile")
  ];

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
        final theme = Provider.of<ThemeProvider>(context).currentTheme;
        return AlertDialog(
          backgroundColor: theme.background,
          title: Text(
            tr('Filter'),
            style: TextStyle(color: theme.welcomeText),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RadioListTile<String>(
                  activeColor: theme.welcomeDotActive,
                  title: Text(
                    tr('All Tasks'),
                    style: TextStyle(color: theme.welcomeText),
                  ),
                  value: tr('All Tasks'),
                  groupValue: filter,
                  onChanged: (value) {
                    setState(() {
                      filter = value!;
                      Navigator.of(context).pop();
                    });
                  },
                ),
                RadioListTile<String>(
                  activeColor: theme.welcomeDotActive,
                  title: Text(
                    tr('Favorite Tasks'),
                    style: TextStyle(color: theme.welcomeText),
                  ),
                  value: tr('Favorite Tasks'),
                  groupValue: filter,
                  onChanged: (value) {
                    setState(() {
                      filter = value!;
                      Navigator.of(context).pop();
                    });
                  },
                ),
                RadioListTile<String>(
                  activeColor: theme.welcomeDotActive,
                  title: Text(
                    tr('Habits'),
                    style: TextStyle(color: theme.welcomeText),
                  ),
                  value: tr('Habits'),
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
          title: const Text('Warning').tr(),
          content: const Text(
              'You cannot use the Habit section while logged in as a guest. Please create an account.').tr(),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  currentPageIndex = 0;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Confirm').tr(),
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
          title: const Text('Warning').tr(),
          content: const Text(
              'You need to create a profile to continue this action.\n\n(You can make the story part more detailed by adding text to the bio section.)').tr(),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  currentPageIndex = 0;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  currentPageIndex = 3;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Confirm').tr(),
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
    final languageNotifier = Provider.of<LanguageChangeNotifier>(context);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: theme.appBar),
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
                style: TextStyle(color: theme.appBar)),
          ],
        ),
        actions: [
          if (currentPageIndex == 2)
            IconButton(
              icon: Icon(Icons.lock, color: theme.appBar),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PinEntryPage(),
                  ),
                );
              },
            ),
          if (currentPageIndex != 0)
            IconButton(
              icon: Icon(Icons.book_outlined, color: theme.appBar),
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
                );
              },
            ),
          if (currentPageIndex == 3)
            IconButton(
              icon: Icon(Icons.settings_outlined, color: theme.appBar),
              onPressed: null,
            ),
          if (currentPageIndex == 0)
            IconButton(
              icon: Icon(Icons.filter_list, color: theme.appBar),
              onPressed: _openFilterDialog,
            ),
          if (currentPageIndex == 0)
            IconButton(
              icon: Icon(Icons.calendar_today, color: theme.appBar),
              onPressed: _openCalendarBottomSheet,
            ),
          if (currentPageIndex == 1)
            IconButton(
              icon: Icon(Icons.inbox, color: theme.appBar),
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
        backgroundColor: theme.bottomBarBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.bottomBarBackground,
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
                            style: TextStyle(
                              color: theme.welcomeText,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        } else {
                          return Text(
                            (user?.email) ?? tr('Anonymous User'),
                            style: TextStyle(
                              color: theme.welcomeText,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ).tr();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.list, color: theme.bottomBarIcon),
              title: Text(tr('Today'), style: TextStyle(color: theme.bottomBarText)),
              onTap: () {
                setState(() {
                  currentPageIndex = 0;
                });
                languageNotifier.notify(); // Dil değişikliğini dinleyiciye bildirin
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: theme.bottomBarIcon),
              title: Text(tr('Habits'), style: TextStyle(color: theme.bottomBarText)),
              onTap: () {
                setState(() {
                  currentPageIndex = 1;
                });
                languageNotifier.notify(); // Dil değişikliğini dinleyiciye bildirin
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.library_books_outlined, color: theme.bottomBarIcon),
              title: Text(tr('Journal'),
                  style: TextStyle(color: theme.bottomBarText)),
              onTap: () {
                setState(() {
                  currentPageIndex = 2;
                });
                languageNotifier.notify(); // Dil değişikliğini dinleyiciye bildirin
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.book, color: theme.bottomBarIcon),
              title: Text(tr('User Stories'),
                  style: TextStyle(color: theme.bottomBarText)),
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
            ListTile(
              leading: Icon(Icons.delete, color: theme.bottomBarIcon),
              title: Text(tr('Deleted'), style: TextStyle(color: theme.bottomBarText)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrashPage()),
                );
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: Icon(Icons.settings, color: theme.bottomBarIcon),
              title: Text(tr('Settings'),
                  style: TextStyle(color: theme.bottomBarText)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(tr('Logout'), style: TextStyle(color: Colors.red)),
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
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.85,
                        minChildSize: 0.8,
                        maxChildSize: 1.0,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: TodayAddSubPage(focusDate: _focusDate),
                          );
                        },
                      ),
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
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        minChildSize: 0.9,
                        maxChildSize: 0.9,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: JournalAddSubPage(),
                          );
                        },
                      ),
                    );
                    break;
                  default:
                }
              },
              backgroundColor: theme.addButton,
              child: Icon(
                Icons.add,
                size: 32,
                color: theme.addButtonIcon,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.bottomBarBackground,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
          languageNotifier.notify(); // Dil değişikliğini dinleyiciye bildirin
        },
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(
              Icons.calendar_month_outlined,
              color: theme.bottomBarActiveIcon,
              size: 20,
            ),
            icon: Icon(
              Icons.calendar_month_outlined,
              color: theme.bottomBarIcon,
              size: 20,
            ),
            label: tr('Today'),
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.flag_outlined,
              color: theme.bottomBarActiveIcon,
              size: 20,
            ),
            icon: Icon(
              Icons.flag_outlined,
              color: theme.bottomBarIcon,
              size: 20,
            ),
            label: tr('Habits'),
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.library_books_outlined,
              color: theme.bottomBarActiveIcon,
              size: 20,
            ),
            icon: Icon(
              Icons.library_books_outlined,
              color: theme.bottomBarIcon,
              size: 20,
            ),
            label: tr('Journal'),
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.person_outline,
              color: theme.bottomBarActiveIcon,
              size: 20,
            ),
            icon: Icon(
              Icons.person_outline,
              color: theme.bottomBarIcon,
              size: 20,
            ),
            label: tr('Profile'),
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
    return userDoc['name'] ?? tr('Unknown User');
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

String monthName(int index) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return tr(months[index]);
}
