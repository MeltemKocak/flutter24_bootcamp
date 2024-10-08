import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:planova/pages/habit_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:planova/utilities/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  User? user = FirebaseAuth.instance.currentUser;
  String? userProfileImageUrl;
  String userName = "";

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

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning', style: GoogleFonts.didactGothic()).tr(),
          content: Text('You cannot check this habit today.',
                  style: GoogleFonts.didactGothic())
              .tr(),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: GoogleFonts.didactGothic()).tr(),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            final theme = Provider.of<ThemeProvider>(context).currentTheme;
            return AlertDialog(
              backgroundColor: theme.background,
              title: Text(
                tr('Confirm Deletion'),
                style: GoogleFonts.didactGothic(color: theme.welcomeText),
              ),
              content: Text(
                tr('Are you sure you want to delete this entry?'),
                style: GoogleFonts.didactGothic(color: theme.welcomeText),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    tr('Cancel'),
                    style: GoogleFonts.didactGothic(color: theme.addButton),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    tr('Delete'),
                    style: GoogleFonts.didactGothic(color: theme.addButton),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  String _findNearestOrTodayDate(Map<String, dynamic> days) {
    DateTime today = DateTime.now();
    String formattedToday = DateFormat('yyyy-MM-dd').format(today);

    if (days.containsKey(formattedToday)) {
      return formattedToday;
    }

    String nearestDate = '';
    Duration nearestDuration = const Duration(days: 365);

    days.forEach((key, value) {
      DateTime date = DateTime.parse(key);
      Duration difference = date.difference(today).abs();
      if (difference < nearestDuration) {
        nearestDuration = difference;
        nearestDate = key;
      }
    });

    return nearestDate;
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

  Future<void> _updateCompletionStatus(
      bool? value, String date, DocumentSnapshot document) async {
    if (user == null) return;

    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
    if (data == null) return;

    String userId = user!.uid;
    Map<String, dynamic> completedDays =
        (data['completed_days'] ?? {}).cast<String, dynamic>();

    if (!completedDays.containsKey(userId)) {
      completedDays[userId] = {};
    }

    completedDays[userId][date] = value ?? false;

    await FirebaseFirestore.instance
        .collection('habits')
        .doc(document.id)
        .update({
      'completed_days': completedDays,
    });

    List<dynamic> friends = data['friends'] ?? [];
    if (friends.isNotEmpty) {
      for (String friendId in friends.cast<String>()) {
        QuerySnapshot friendHabits = await FirebaseFirestore.instance
            .collection('habits')
            .where('user_id', isEqualTo: friendId)
            .where('name', isEqualTo: data['name'])
            .get();

        for (var habit in friendHabits.docs) {
          Map<String, dynamic> friendCompletedDays =
              (habit['completed_days'] ?? {}).cast<String, dynamic>();

          if (!friendCompletedDays.containsKey(userId)) {
            friendCompletedDays[userId] = {};
          }

          friendCompletedDays[userId][date] = value ?? false;

          await FirebaseFirestore.instance
              .collection('habits')
              .doc(habit.id)
              .update({
            'completed_days': friendCompletedDays,
          });
        }
      }
    }

    setState(() {
      data['completed_days'] = completedDays;
    });
  }

  Widget _buildHabitCard(
      DocumentSnapshot document, bool isSharedHabit, CustomThemeData theme) {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data == null) {
      return const SizedBox.shrink();
    }

    int targetDays = data['target_days'] ?? 0;
    Map<String, dynamic> completedDays = data['completed_days'] ?? {};
    Map<String, dynamic> userCompletedDates = completedDays[user?.uid] ?? {};
    int completedCount =
        userCompletedDates.values.where((value) => value == true).length;
    DateTime today = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    bool isTodayHabitDay = data['days'][formattedDate] ?? false;
    bool isCompleted = userCompletedDates[formattedDate] ?? false;

    String displayDate = _findNearestOrTodayDate(data['days']);
    bool isActiveDay = displayDate == formattedDate;

    return Dismissible(
      key: Key(document.id),
      background: Container(
        color: const Color.fromARGB(200, 250, 70, 60),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        bool? confirmed = await _showConfirmationDialog(context);
        if (confirmed == true) {
          _moveHabitToTrash(document);
        } else {
          setState(() {});
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitDetailPage(habitId: document.id),
            ),
          );
        },
        child: Card(
          color: theme.habitCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? tr('No name'),
                          style: GoogleFonts.didactGothic(
                            color: theme.habitTitle,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.67,
                          child: Text(
                            data['description'] ?? tr('No description'),
                            style: GoogleFonts.didactGothic(
                              color: theme.subText,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Checkbox(
                      value: isCompleted,
                      onChanged: isTodayHabitDay
                          ? (bool? value) {
                              _updateCompletionStatus(
                                  value, formattedDate, document);
                            }
                          : (bool? value) {
                              _showAlertDialog(context);
                            },
                      checkColor: theme.habitCardBackground,
                      activeColor: theme.checkBoxActiveColor,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.list, color: theme.habitIcons, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      tr('Progress'),
                      style: GoogleFonts.didactGothic(
                        color: theme.habitIcons,
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '$completedCount/$targetDays ${tr('days')}',
                      style: GoogleFonts.didactGothic(
                        color: theme.habitTitle,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: targetDays > 0 ? completedCount / targetDays : 0,
                  backgroundColor: theme.habitDetailEditBackground,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.habitProgress),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.habitActiveDay,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActiveDay
                            ? tr('Active day')
                            : DateFormat('dd-MM-yyyy')
                                .format(DateTime.parse(displayDate)),
                        style: GoogleFonts.didactGothic(
                          color: theme.habitActiveDayText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    if (userProfileImageUrl != null &&
                        userProfileImageUrl!.isNotEmpty)
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(userProfileImageUrl!),
                          ),
                          Text(
                            userName,
                            style: GoogleFonts.didactGothic(
                              color: theme.habitTitle,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    else
                      CircleAvatar(
                        radius: 14,
                        child: Icon(Icons.person, color: theme.habitIcons),
                      ),
                    if (isSharedHabit)
                      FutureBuilder<List<Widget>>(
                        future: Future.wait((data['friends'] as List)
                            .map<Future<Widget>>((friendId) async {
                          String? friendImageUrl =
                              await _getUserProfileImage(friendId);
                          String friendName = await _getUserName(friendId);
                          if (friendImageUrl != null &&
                              friendImageUrl.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 0.0),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundImage:
                                        NetworkImage(friendImageUrl),
                                  ),
                                  Text(
                                    friendName,
                                    style: GoogleFonts.didactGothic(
                                      color: theme.habitTitle,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }).toList()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(
                                color: theme.checkBoxActiveColor);
                          }
                          if (snapshot.hasError) {
                            return const SizedBox.shrink();
                          }
                          return Row(
                            children: snapshot.data ?? [],
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);

    return Scaffold(
      backgroundColor: theme.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('habits')
            .where('user_id', isEqualTo: user?.uid)
            .where('isPending', isEqualTo: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text(tr('Something went wrong'),
                    style: GoogleFonts.didactGothic(color: theme.habitTitle)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: theme.habitProgress));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(tr('No habits available'),
                    style: GoogleFonts.didactGothic(color: theme.habitTitle)));
          }

          List<DocumentSnapshot> activeDayHabits = [];
          List<DocumentSnapshot> otherDayHabits = [];

          for (DocumentSnapshot document in snapshot.data!.docs) {
            Map<String, dynamic>? data =
                document.data() as Map<String, dynamic>?;
            if (data == null) continue;

            String displayDate = _findNearestOrTodayDate(data['days']);
            bool isActiveDay =
                displayDate == DateFormat('yyyy-MM-dd').format(DateTime.now());

            if (isActiveDay) {
              activeDayHabits.add(document);
            } else {
              otherDayHabits.add(document);
            }
          }

          otherDayHabits.sort((a, b) {
            Map<String, dynamic>? aData = a.data() as Map<String, dynamic>?;
            Map<String, dynamic>? bData = b.data() as Map<String, dynamic>?;

            String aDate = _findNearestOrTodayDate(aData?['days'] ?? {});
            String bDate = _findNearestOrTodayDate(bData?['days'] ?? {});

            return aDate.compareTo(bDate);
          });

          List<DocumentSnapshot> sortedHabits = [
            ...activeDayHabits,
            ...otherDayHabits
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: sortedHabits.map((DocumentSnapshot document) {
              Map<String, dynamic>? data =
                  document.data() as Map<String, dynamic>?;

              if (data == null) {
                return const SizedBox.shrink();
              }

              bool isSharedHabit = data.containsKey('friends') &&
                  (data['friends'] as List).isNotEmpty;

              return _buildHabitCard(document, isSharedHabit, theme);
            }).toList(),
          );
        },
      ),
    );
  }

  void _moveHabitToTrash(DocumentSnapshot habit) async {
    final data = habit.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.collection('deleted_tasks').add({
      'name': data['name'],
      'description': data['description'],
      'deletedDate': DateTime.now(),
      'collection': 'habits',
      'docId': habit.id,
      'userId': user!.uid,
      'data': data,
    });

    await FirebaseFirestore.instance
        .collection('habits')
        .doc(habit.id)
        .delete();
  }
}
