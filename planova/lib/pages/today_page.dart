import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:planova/pages/today_edit.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  _TodayPageState createState() => _TodayPageState();
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
        DateTime taskAddedDate = (Timestamp.now()).toDate();

  final EasyInfiniteDateTimelineController _controller = EasyInfiniteDateTimelineController();
  DateTime? _focusDate = DateTime.now();
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
            child:  EasyInfiniteDateTimeLine(
              showTimelineHeader: false,
              selectionMode: const SelectionMode.autoCenter(),
              controller: _controller,
              focusDate: _focusDate,
              firstDate: DateTime(2024),
              lastDate: DateTime(2024, 12, 31),
              onDateChange: (selectedDate) {
                setState(() {
                  _focusDate = selectedDate;
                });
              },
              activeColor: const Color.fromARGB(255, 3, 218, 75),
              dayProps: const EasyDayProps(
                todayStyle: DayStyle(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(99, 43, 158, 87),
                        borderRadius: BorderRadius.all(Radius.circular(18)))),
                activeDayStyle: DayStyle(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 3, 218, 182),
                        borderRadius: BorderRadius.all(Radius.circular(18)))),
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
      return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white));
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

      List<DocumentSnapshot> tasksForToday = [];
    DateTime now = DateTime.now();

    for (var doc in snapshot.data!.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime taskDate = (data['taskCreateDate'] as Timestamp?)?.toDate() ?? now;
      List<int> recurringDays = List<int>.from(data['taskRecurring'] ?? []);
      DateTime? deletedDate = (data['deletedDate'] as Timestamp?)?.toDate();
      
      if (deletedDate == null || _focusDate!.isAfter(deletedDate)) {
        if (
          (isSameDay(taskDate, _focusDate!) && taskDate.isAfter(DateTime(now.year, now.month, now.day))) || 
          (recurringDays.isNotEmpty && recurringDays.contains(_focusDate!.weekday) && _focusDate!.isAfter(now))
        ) {
          tasksForToday.add(doc);
        }
      }
    }

    Map<String, dynamic> getCompletionStatus(DocumentSnapshot doc) {
      return (doc.data() as Map<String, dynamic>)['taskCompletionStatus'] ?? {};
    }

    List<DocumentSnapshot> incompleteTasks = tasksForToday.where((task) => 
      !(getCompletionStatus(task)[_focusDate!.weekday.toString()] ?? false)).toList();
    List<DocumentSnapshot> completedTasks = tasksForToday.where((task) => 
      getCompletionStatus(task)[_focusDate!.weekday.toString()] ?? false).toList();

    return ListView(
      children: [
        _buildTaskSection('Incomplete', incompleteTasks, _showIncomplete),
        _buildTaskSection('Completed', completedTasks, _showCompleted),
      ],
    );
  },
)
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime taskDate, DateTime focusDate) {
  return taskDate.year == focusDate.year &&
         taskDate.month == focusDate.month &&
         taskDate.day == focusDate.day;
}

  Widget _buildTaskSection(String title, List<DocumentSnapshot> tasks, bool isExpanded) {
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
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ...tasks.map((task) => _buildTaskCard(task)),
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
          builder: (context) => TaskEditPage(task: task),
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
                value: task['taskCompletionStatus'][_focusDate!.weekday.toString()] ?? false,
                onChanged: (bool? value) {
                  Map<String, dynamic> completionStatus = Map<String, dynamic>.from(task['taskCompletionStatus']);
                  completionStatus[_focusDate!.weekday.toString()] = value;
                  FirebaseFirestore.instance.collection('todos').doc(task.id).update({
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat('HH:mm').format((task['taskCreateDate'] as Timestamp).toDate()),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (task['taskRecurring'] != null && (task['taskRecurring'] as List).isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.repeat, color: Colors.white70, size: 16),
                          ),
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
}


