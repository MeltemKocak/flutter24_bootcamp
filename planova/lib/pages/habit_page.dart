import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:planova/pages/habit_detail_screen.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  User? user = FirebaseAuth.instance.currentUser;
  String? userProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
  }

  Future<void> _loadUserProfileImage() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
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
          title: const Text('Warning'),
          content: const Text('You cannot check this habit today.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 30, 30, 30),
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.only(right: 18),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('habits')
            .where('user_id', isEqualTo: user?.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong', style: TextStyle(color: Colors.white)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0XFF03DAC6)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No habits available', style: TextStyle(color: Colors.white)));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

              if (data == null) {
                return const SizedBox.shrink();
              }

              int targetDays = data['target_days'] ?? 0;
              Map<String, dynamic> completedDates = data['completed_days'] ?? {};
              int completedCount = completedDates.values.where((value) => value == true).length;
              DateTime today = DateTime.now();
              String formattedDate = DateFormat('yyyy-MM-dd').format(today);
              bool isTodayHabitDay = data['days'][formattedDate] ?? false;
              bool isCompleted = completedDates[formattedDate] ?? false;

              // En yakın günü veya bugünün gününü bul
              String displayDate = _findNearestOrTodayDate(data['days']);
              bool isActiveDay = displayDate == formattedDate;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitDetailPage(habitId: document.id),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: const Color.fromRGBO(42, 46, 55, 1),
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
                                  data['name'] ?? 'No name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  data['description'] ?? 'No description',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Checkbox(
                              value: isCompleted,
                              onChanged: isTodayHabitDay
                                  ? (bool? value) {
                                      setState(() {
                                        completedDates[formattedDate] = value ?? false;
                                        FirebaseFirestore.instance
                                            .collection('habits')
                                            .doc(document.id)
                                            .update({
                                          'completed_days': completedDates,
                                        });
                                      });
                                    }
                                  : (bool? value) {
                                      _showAlertDialog(context);
                                    },
                              checkColor: Colors.white,
                              activeColor: const Color(0XFF03DAC6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.list, color: Colors.grey, size: 18),
                            const SizedBox(width: 5),
                            Text(
                              'Progress',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '$completedCount/$targetDays days',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        LinearProgressIndicator(
                          value: targetDays > 0 ? completedCount / targetDays : 0,
                          backgroundColor: const Color(0XFF1E1E1E),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0XFF03DAC6)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(60, 63, 65, 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isActiveDay ? 'Aktif Gün' : DateFormat('dd MMM yyyy').format(DateTime.parse(displayDate)),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (userProfileImageUrl != null && userProfileImageUrl!.isNotEmpty)
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: NetworkImage(userProfileImageUrl!),
                              )
                            else
                              const CircleAvatar(
                                radius: 14,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
