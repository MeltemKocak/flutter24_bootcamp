import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:planova/pages/today_edit.dart';

class TodayPage extends StatefulWidget {
  final EasyInfiniteDateTimelineController controller;
  final DateTime? focusDate;
  final Function(DateTime) onDateChange;

  const TodayPage(
      {super.key,
      required this.controller,
      required this.focusDate,
      required this.onDateChange});

  @override
  _TodayPageState createState() => _TodayPageState();

  static Future<Map<String, int>> getTaskCounts(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'incomplete': 0, 'completed': 0};
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final snapshot = await FirebaseFirestore.instance
        .collection('todos')
        .where('userId', isEqualTo: user.uid)
        .get();

    int incompleteCount = 0;
    int completedCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['taskTimes'] != null &&
          data['taskTimes'].containsKey(formattedDate)) {
        final completionStatus = data['taskCompletionStatus'] as Map<String, dynamic>?;
        if (completionStatus != null && completionStatus[formattedDate] == true) {
          completedCount++;
        } else {
          incompleteCount++;
        }
      }
    }

    return {'incomplete': incompleteCount, 'completed': completedCount};
  }
}

class _TodayPageState extends State<TodayPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  DateTime? get _focusDate => widget.focusDate;
  bool _showIncomplete = true;
  bool _showCompleted = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 30, 30, 30),
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.only(right: 18),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: EasyInfiniteDateTimeLine(
              showTimelineHeader: false,
              selectionMode: const SelectionMode.autoCenter(),
              controller: widget.controller,
              focusDate: _focusDate,
              firstDate: DateTime(2024),
              lastDate: DateTime(2024, 12, 31),
              onDateChange: widget.onDateChange,
              activeColor: const Color.fromARGB(255, 3, 218, 75),
              dayProps: const EasyDayProps(
                todayStyle: DayStyle(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(99, 43, 158, 87),
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
                activeDayStyle: DayStyle(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 3, 218, 182),
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
                borderColor: Color.fromARGB(0, 0, 255, 242),
                height: 60.0,
                width: 50,
                dayStructure: DayStructure.dayStrDayNum,
                inactiveDayStyle: DayStyle(
                  borderRadius: 18,
                  dayNumStyle: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('todos')
                  .where('userId', isEqualTo: _user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> tasksForToday = [];
                String formattedFocusDate =
                    DateFormat('yyyy-MM-dd').format(_focusDate!);

                for (var doc in snapshot.data!.docs) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;

                  if (data['taskTimes'] != null &&
                      data['taskTimes'].containsKey(formattedFocusDate)) {
                    tasksForToday.add(doc);
                  }
                }

                Map<String, bool> getCompletionStatus(DocumentSnapshot doc) {
                  return (doc.data()
                              as Map<String, dynamic>)['taskCompletionStatus']
                          ?.cast<String, bool>() ??
                      {};
                }

                List<DocumentSnapshot> incompleteTasks = tasksForToday
                    .where((task) =>
                        !(getCompletionStatus(task)[formattedFocusDate] ??
                            false))
                    .toList();
                List<DocumentSnapshot> completedTasks = tasksForToday
                    .where((task) =>
                        getCompletionStatus(task)[formattedFocusDate] ?? false)
                    .toList();

                return ListView(
                  children: [
                    _buildTaskSection(
                        'Incomplete', incompleteTasks, _showIncomplete),
                    _buildTaskSection(
                        'Completed', completedTasks, _showCompleted),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection(
      String title, List<DocumentSnapshot> tasks, bool isExpanded) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (title == 'Incomplete') {
                _showIncomplete = !_showIncomplete;
              } else {
                _showCompleted = !_showCompleted;
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '$title (${tasks.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...tasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildTaskCard(DocumentSnapshot task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                TodayEditPage(task: task, selectedDate: _focusDate!),
          );
        },
        child: Card(
          color: const Color.fromARGB(120, 96, 125, 139),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  side: const BorderSide(color: Color.fromARGB(200, 3, 218, 198)),
                  value: task['taskCompletionStatus']
                          [DateFormat('yyyy-MM-dd').format(_focusDate!)] ??
                      false,
                  onChanged: (bool? value) {
                    Map<String, bool> completionStatus =
                        Map<String, bool>.from(task['taskCompletionStatus']);
                    completionStatus[DateFormat('yyyy-MM-dd').format(_focusDate!)] =
                        value!;
                    FirebaseFirestore.instance
                        .collection('todos')
                        .doc(task.id)
                        .update({
                      'taskCompletionStatus': completionStatus,
                    });
                  },
                  activeColor: const Color.fromARGB(150, 3, 218, 198),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['taskName'],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (task['taskRecurring'] != 'Tekrar yapma')
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.repeat,
                                  color: Colors.white70, size: 16),
                            ),
                          _timeShow(task)
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.person_outlined,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeShow(DocumentSnapshot task) {
    String selectedDate = DateFormat('yyyy-MM-dd').format(_focusDate!);
    Map<String, dynamic> taskData = task.data() as Map<String, dynamic>;
    String taskTime = taskData.containsKey('taskTimes')
        ? taskData['taskTimes'][selectedDate] ?? "boş"
        : "boş";

    return Row(
      children: [
        if (taskTime != "boş") ...[
          const Padding(
            padding: EdgeInsets.only(left: 0),
            child: Icon(Icons.access_time, color: Colors.white70, size: 16),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              taskTime,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ],
    );
  }

  void _deleteTask(DocumentSnapshot task, bool deleteAll) {
    String formattedSelectedDate = DateFormat('yyyy-MM-dd').format(_focusDate!);

    Map<String, bool> taskCompletionStatus =
        Map<String, bool>.from(task['taskCompletionStatus']);
    Map<String, String> taskTimes =
        Map<String, String>.from(task['taskTimes']);
    List<dynamic> deletedTasks;
    if ((task.data() as Map).containsKey('deletedTasks')) {
      deletedTasks = List<dynamic>.from(task['deletedTasks']);
    } else {
      deletedTasks = [];
    }

    if (deleteAll) {
      // Tüm tekrarlanan görevleri sil
      taskCompletionStatus.forEach((date, _) {
        deletedTasks.add(date);
      });
      taskCompletionStatus.clear();
      taskTimes.clear();
    } else {
      // Sadece seçili tarihi sil
      if (taskCompletionStatus.containsKey(formattedSelectedDate)) {
        taskCompletionStatus.remove(formattedSelectedDate);
        deletedTasks.add(formattedSelectedDate);
      }
      if (taskTimes.containsKey(formattedSelectedDate)) {
        taskTimes.remove(formattedSelectedDate);
      }
    }

    FirebaseFirestore.instance.collection('todos').doc(task.id).update({
      'taskCompletionStatus': taskCompletionStatus,
      'taskTimes': taskTimes,
      'deletedTasks': deletedTasks,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Görev başarıyla silindi.')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Görev silinirken hata oluştu: $error')),
      );
    });
  }

  void _confirmDeleteTask(DocumentSnapshot task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0XFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Görevi Sil",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Bu görevi mi yoksa tüm tekrarlanan görevleri mi silmek istiyorsunuz?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteTask(task, false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF03DAC6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Sadece Bu Görev",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteTask(task, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF03DAC6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tüm Tekrarlanan Görevler",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
