import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:planova/pages/habit_detail_screen.dart';
import 'package:planova/pages/today_edit.dart';
import 'package:rxdart/rxdart.dart';

class TodayPage extends StatefulWidget {
  final EasyInfiniteDateTimelineController controller;
  final DateTime? focusDate;
  final Function(DateTime) onDateChange;
  final String filter;

  const TodayPage(
      {super.key,
      required this.controller,
      required this.focusDate,
      required this.onDateChange,
      this.filter = 'All Tasks'});

  @override
  _TodayPageState createState() => _TodayPageState();

  static Future<Map<String, int>> getTaskCounts(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'incomplete': 0, 'completed': 0};
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final todosSnapshot = await FirebaseFirestore.instance
        .collection('todos')
        .where('userId', isEqualTo: user.uid)
        .get();

    final habitsSnapshot = await FirebaseFirestore.instance
        .collection('habits')
        .where('user_id', isEqualTo: user.uid)
        .get();

    int incompleteCount = 0;
    int completedCount = 0;

    for (var doc in todosSnapshot.docs) {
      final data = doc.data();
      if (data['taskTimes'] != null &&
          data['taskTimes'].containsKey(formattedDate)) {
        final completionStatus =
            data['taskCompletionStatus'] as Map<String, dynamic>?;
        if (completionStatus != null &&
            completionStatus[formattedDate] == true) {
          completedCount++;
        } else {
          incompleteCount++;
        }
      }
    }

    for (var doc in habitsSnapshot.docs) {
      final data = doc.data();
      if (data['days'] != null && data['days'].containsKey(formattedDate)) {
        DateTime focusDateOnly = DateTime(date.year, date.month, date.day);
        DateTime now = DateTime.now();
        DateTime nowDate = DateTime(now.year, now.month, now.day);

        if (nowDate == focusDateOnly) {
          final completedDays = data['completed_days'] as Map<String, dynamic>?;
          if (completedDays != null &&
              completedDays[user.uid] is Map &&
              completedDays[user.uid][formattedDate] == true) {
            completedCount++;
          } else {
            incompleteCount++;
          }
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
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            child: EasyInfiniteDateTimeLine(
              showTimelineHeader: false,
              selectionMode: const SelectionMode.autoCenter(),
              controller: widget.controller,
              focusDate: _focusDate,
              firstDate: DateTime(2024),
              lastDate: DateTime(2024, 12, 31),
              onDateChange: (date) {
                widget.onDateChange(date);
                setState(() {});
              },
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
            child: StreamBuilder<List<QuerySnapshot>>(
              stream: CombineLatestStream.list([
                FirebaseFirestore.instance
                    .collection('todos')
                    .where('userId', isEqualTo: _user!.uid)
                    .snapshots(),
                FirebaseFirestore.instance
                    .collection('habits')
                    .where('user_id', isEqualTo: _user!.uid)
                    .snapshots(),
              ]),
              builder: (context, snapshots) {
                if (snapshots.hasError) {
                  return Text(
                    'Error: ${snapshots.error}',
                    style: const TextStyle(color: Colors.white),
                  );
                }

                if (snapshots.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> tasksForToday = [];
                String formattedFocusDate =
                    DateFormat('yyyy-MM-dd').format(_focusDate!);

                for (var snapshot in snapshots.data!) {
                  for (var doc in snapshot.docs) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    if (data['taskTimes'] != null &&
                        data['taskTimes'].containsKey(formattedFocusDate)) {
                      tasksForToday.add(doc);
                    } else if (data['days'] != null &&
                        data['days'].containsKey(formattedFocusDate)) {
                      DateTime endDate =
                          (data['end_date'] as Timestamp).toDate();
                      DateTime startDate =
                          (data['start_date'] as Timestamp).toDate();

                      DateTime focusDateOnly = DateTime(
                        _focusDate!.year,
                        _focusDate!.month,
                        _focusDate!.day,
                      );

                      DateTime startDateOnly = DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day,
                      );

                      DateTime endDateOnly = DateTime(
                        endDate.year,
                        endDate.month,
                        endDate.day,
                      );

                      if (focusDateOnly.isAfter(startDateOnly) &&
                          focusDateOnly.isBefore(
                              endDateOnly.add(const Duration(days: 1)))) {
                        tasksForToday.add(doc);
                      } else if (focusDateOnly
                              .isAtSameMomentAs(startDateOnly) ||
                          focusDateOnly.isAtSameMomentAs(endDateOnly)) {
                        tasksForToday.add(doc);
                      }
                    }
                  }
                }

                List<DocumentSnapshot> filteredTasks =
                    _filterTasks(tasksForToday, widget.filter);

                List<DocumentSnapshot> incompleteTasks = filteredTasks
                    .where(
                        (task) => !_isTaskCompleted(task, formattedFocusDate))
                    .toList();
                List<DocumentSnapshot> completedTasks = filteredTasks
                    .where((task) => _isTaskCompleted(task, formattedFocusDate))
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

  List<DocumentSnapshot> _filterTasks(
      List<DocumentSnapshot> tasks, String filter) {
    if (filter == 'All Tasks') {
      return tasks;
    } else if (filter == 'Favorite Tasks') {
      return tasks.where((task) {
        final data = task.data() as Map<String, dynamic>;
        return data['isFavorite'] == true;
      }).toList();
    } else if (filter == 'Habits') {
      return tasks.where((task) {
        final data = task.data() as Map<String, dynamic>;
        return data.containsKey('completed_days');
      }).toList();
    }
    return tasks;
  }

  bool _isTaskCompleted(DocumentSnapshot task, String formattedDate) {
    final data = task.data() as Map<String, dynamic>;
    final isHabit = data.containsKey('completed_days');

    if (isHabit) {
      final completedDays = data['completed_days'] as Map<String, dynamic>?;
      return completedDays != null &&
          completedDays[_user!.uid] is Map &&
          (completedDays[_user!.uid][formattedDate] ?? false);
    } else {
      final taskCompletionStatus =
          data['taskCompletionStatus'] as Map<String, dynamic>?;
      return taskCompletionStatus != null &&
          (taskCompletionStatus[formattedDate] ?? false);
    }
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
    final data = task.data() as Map<String, dynamic>;
    final isHabit = data.containsKey('completed_days');
    final taskName = isHabit ? data['name'] : data['taskName'];

    String formattedDate = DateFormat('yyyy-MM-dd').format(_focusDate!);
    bool taskCompletionStatus = _isTaskCompleted(task, formattedDate);

    bool isToday = _isToday(_focusDate!);

    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.amber,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(Icons.star, color: Colors.white),
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          bool? confirm = await _showDeleteConfirmDialog();
          if (confirm != null && confirm) {
            _moveTaskToTrash(task);
            return true;
          }
          return false;
        } else if (direction == DismissDirection.endToStart) {
          if (isHabit) {
            await _showHabitAlert();
            return false;
          } else {
            _toggleFavorite(task);
            return false;
          }
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onTap: () {
            if (!isHabit) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    TodayEditPage(task: task, selectedDate: _focusDate!),
              );
            }

            if (isHabit) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HabitDetailPage(habitId: task.id),
                ),
              );
            }
          },
          child: Card(
            color: isHabit
                ? const Color.fromARGB(200, 39, 79, 94)
                : const Color.fromARGB(120, 96, 125, 139),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    side: const BorderSide(
                        color: Color.fromARGB(200, 3, 218, 198)),
                    value: taskCompletionStatus,
                    onChanged: isHabit
                        ? (isToday
                            ? (bool? value) {
                                if (value != null) {
                                  _updateCompletionStatus(task, value, formattedDate);
                                }
                              }
                            : (value) {
                                _showFutureDateAlert();
                              })
                        : (bool? value) {
                            if (value != null) {
                              Map<String, bool> completionStatus =
                                  Map<String, bool>.from(
                                      data['taskCompletionStatus'] ?? {});
                              completionStatus[formattedDate] = value;
                              FirebaseFirestore.instance
                                  .collection('todos')
                                  .doc(task.id)
                                  .update({
                                'taskCompletionStatus': completionStatus,
                              });
                            }
                          },
                    activeColor: const Color.fromARGB(150, 3, 218, 198),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          taskName,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        if (!isHabit)
                          Row(
                            children: [
                              if (data['taskRecurring'] != 'Tekrar yapma')
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
                  Icon(
                    isHabit
                        ? Icons.flag_outlined
                        : (data['isFavorite'] == true)
                            ? Icons.star
                            : Icons.person_outlined,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateCompletionStatus(DocumentSnapshot task, bool value, String formattedDate) async {
    final data = task.data() as Map<String, dynamic>;
    String userId = FirebaseAuth.instance.currentUser!.uid;

    Map<String, dynamic> completedDays = (data['completed_days'] ?? {}).cast<String, dynamic>();
    if (!completedDays.containsKey(userId)) {
      completedDays[userId] = {};
    }
    completedDays[userId][formattedDate] = value;

    await FirebaseFirestore.instance.collection('habits').doc(task.id).update({
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
          Map<String, dynamic> friendCompletedDays = (habit['completed_days'] ?? {}).cast<String, dynamic>();

          if (!friendCompletedDays.containsKey(userId)) {
            friendCompletedDays[userId] = {};
          }

          friendCompletedDays[userId][formattedDate] = value;

          await FirebaseFirestore.instance.collection('habits').doc(habit.id).update({
            'completed_days': friendCompletedDays,
          });
        }
      }
    }

    setState(() {});
  }

  Future<void> _showHabitAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Hata',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Yalnızca tasklar favori olarak işaretlenebilir.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Tamam',
                style: TextStyle(color: Color(0xFF03DAC6)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showFutureDateAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Geçersiz İşlem"),
          content:
              const Text("Sadece güncel tarihteki görevler tamamlanabilir."),
          actions: <Widget>[
            TextButton(
              child: const Text("Tamam"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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

  Future<void> _showRecurringTaskAlert(DocumentSnapshot task) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Tekrarlı Görev',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'Bu görev tekrarlı bir görevdir.',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  'Tüm tekrarlı görevleri silmek için görev detaylarına gidiniz.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Tamam',
                style: TextStyle(color: Color(0xFF03DAC6)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _moveTaskToTrash(DocumentSnapshot task) async {
    final data = task.data() as Map<String, dynamic>;
    final collection = data.containsKey('completed_days') ? 'habits' : 'todos';

    // Silinen görevi 'deleted_tasks' koleksiyonuna taşı
    await FirebaseFirestore.instance.collection('deleted_tasks').add({
      'name': data['name'] ?? data['taskName'],
      'description': data['description'] ?? '',
      'deletedDate': DateTime.now(),
      'collection': collection,
      'docId': task.id,
      'userId': _user!.uid,
      'data': data,
    });

    // Görevi orijinal koleksiyonundan sil
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(task.id)
        .delete();
  }

  Future<void> _toggleFavorite(DocumentSnapshot task) async {
    final data = task.data() as Map<String, dynamic>;
    final collection = data.containsKey('completed_days') ? 'habits' : 'todos';

    bool isFavorite = data['isFavorite'] == true;

    await FirebaseFirestore.instance.collection(collection).doc(task.id).update({
      'isFavorite': !isFavorite,
    });

    setState(() {});
  }

  Future<bool?> _showDeleteConfirmDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Sil',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Bu görevi silmek istediğinizden emin misiniz?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'İptal',
                style: TextStyle(color: Color(0xFF03DAC6)),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                'Sil',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
