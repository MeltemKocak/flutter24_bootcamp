import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  User? user = FirebaseAuth.instance.currentUser;

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

              bool isCompleted = completedDates[formattedDate] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: const Color(0X3F607D8B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
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
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Progress: $completedCount / $targetDays',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: targetDays > 0 ? completedCount / targetDays : 0,
                        backgroundColor: const Color(0XFF1E1E1E),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0XFF03DAC6)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Checkbox(
                            value: isCompleted,
                            onChanged: (bool? value) {
                              setState(() {
                                completedDates[formattedDate] = value ?? false;
                                FirebaseFirestore.instance
                                    .collection('habits')
                                    .doc(document.id)
                                    .update({
                                  'completed_days': completedDates,
                                });
                              });
                            },
                            checkColor: Colors.white,
                            activeColor: const Color(0XFF03DAC6),
                          ),
                        ],
                      ),
                    ],
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