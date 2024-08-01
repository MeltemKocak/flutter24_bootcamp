// TodayEditPage.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';

class TodayEditPage extends StatefulWidget {
  final DocumentSnapshot task;
  final DateTime selectedDate;

  const TodayEditPage(
      {super.key, required this.task, required this.selectedDate});

  @override
  _TodayEditPageState createState() => _TodayEditPageState();
}

class _TodayEditPageState extends State<TodayEditPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late FocusNode taskNameFocusNode;
  late FocusNode descriptionFocusNode;
  late List<int> selectedDays;
  late String selectedRecurrence;
  late TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.task['taskName']);
    descriptionController =
        TextEditingController(text: widget.task['taskDescription']);
    taskNameFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();
    selectedDays = List<int>.from(widget.task['selectedDays'] ?? []);
    selectedRecurrence = widget.task['taskRecurring'] ?? 'Do not repeat';
    selectedTime = widget.task['taskTimes']
                [DateFormat('yyyy-MM-dd').format(widget.selectedDate)] !=
            "empty"
        ? _parseTimeOfDay(widget.task['taskTimes']
            [DateFormat('yyyy-MM-dd').format(widget.selectedDate)])
        : null;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    taskNameFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColumnVector(context, theme),
                const SizedBox(height: 26),
                _buildTaskSection(context, theme),
                const SizedBox(height: 14),
                _buildDescriptionSection(context, theme),
                const SizedBox(height: 24),
                _buildRecurringSection(context, theme),
                if (selectedRecurrence != 'Do not repeat')
                  _buildDaySelectionSection(context, theme),
                const SizedBox(height: 95),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: _buildUpdateButton(context, theme),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: _buildDeleteButton(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnVector(BuildContext context, CustomThemeData theme) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      "assets/images/img_vector.svg",
                      color: theme.welcomeDot,
                    ),
                  ),
                ),
                Text(
                  "Edit Task",
                  style: GoogleFonts.didactGothic(
                    color: theme.welcomeText,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ).tr(),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      height: 38,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context, CustomThemeData theme) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Row(
              children: [
                Text(
                  "Task Name",
                  style: GoogleFonts.didactGothic(
                    color: theme.welcomeText,
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                  ),
                ).tr(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: SvgPicture.asset(
                        "assets/images/img_task_logo.svg",
                        color: theme.welcomeDot,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.maxFinite,
            child: TextFormField(
              controller: nameController,
              focusNode: taskNameFocusNode,
              style: GoogleFonts.didactGothic(color: theme.welcomeText),
              decoration: InputDecoration(
                hintText: tr("Enter Task Name"),
                hintStyle: GoogleFonts.didactGothic(
                  color: theme.subText,
                  fontSize: 15,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.toDoCardBackground,
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(descriptionFocusNode);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, CustomThemeData theme) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Description",
                    style: GoogleFonts.didactGothic(
                      color: theme.welcomeText,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ).tr(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: SizedBox(
                    height: 12,
                    width: 10,
                    child: SvgPicture.asset(
                      "assets/images/img_describtion_logo.svg",
                      color: theme.welcomeDot,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.maxFinite,
            child: TextFormField(
              controller: descriptionController,
              focusNode: descriptionFocusNode,
              style: GoogleFonts.didactGothic(color: theme.welcomeText),
              textInputAction: TextInputAction.done,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: tr("Enter Description"),
                hintStyle: GoogleFonts.didactGothic(
                  color: theme.subText,
                  fontSize: 15,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.toDoCardBackground,
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
              ),
              onFieldSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecurringSection(BuildContext context, CustomThemeData theme) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: double.maxFinite,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.toDoCardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _showRecurringDialog,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Icon(Icons.refresh_outlined,
                                color: theme.welcomeText, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Recurring",
                            style: GoogleFonts.didactGothic(
                              color: theme.welcomeText,
                              fontSize: 17,
                            ),
                          ).tr()
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.toDoCardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        visualDensity: const VisualDensity(
                          vertical: -4,
                          horizontal: -4,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData(
                                colorScheme: ColorScheme.dark(
                                  primary: theme.addButton,
                                  onPrimary: theme.addButtonIcon,
                                  surface: theme.background,
                                  onSurface: theme.welcomeText,
                                ),
                                dialogBackgroundColor: theme.background,
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                      backgroundColor: theme.addButton,
                                      foregroundColor: theme.welcomeText),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          setState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, color: theme.welcomeText),
                          const SizedBox(width: 12),
                          Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : tr("Select Time"),
                            style: GoogleFonts.didactGothic(
                              color: theme.welcomeText,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelectionSection(
      BuildContext context, CustomThemeData theme) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List<Widget>.generate(7, (int index) {
          return FilterChip(
            label: Text(
              _getDayName(index + 1),
              style: GoogleFonts.didactGothic(
                  color: theme.addButtonIcon, fontSize: 18),
            ),
            labelStyle: GoogleFonts.didactGothic(
                color: theme.addButtonIcon,
                fontSize: 18,
                fontWeight: FontWeight.bold),
            selected: selectedDays.contains(index + 1),
            onSelected: null, // Günlerin değiştirilemez olmasını sağlamak için
            backgroundColor: theme.checkBoxBorderColor,
            selectedColor: theme.checkBoxActiveColor,
            disabledColor: theme.checkBoxBorderColor,
          );
        }),
      ),
    );
  }

  // Güncelleme Butonunu sadece saat değiştiğinde göstermek için _buildUpdateButton widget'ında şart ekleniyor.
  Widget _buildUpdateButton(BuildContext context, CustomThemeData theme) {
    return selectedTime != null
        ? GestureDetector(
            onTap: _updateTodo,
            child: Container(
              alignment: Alignment.center,
              height: 50,
              width: 120,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: theme.addButton,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(tr("Update Task")),
            ),
          )
        : Container(); // Eğer saat seçilmemişse boş bir widget döndürüyor.
  }

  void _updateTodo() {
    final theme =
        Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: theme.background,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // Merkezi hizalama
              children: [
                Text(
                  "Hour Update",
                  style: GoogleFonts.didactGothic(
                    color: theme.welcomeText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ).tr(),
                const SizedBox(height: 10),
                Text(
                  "Do you want to update the time for this task or for all recurring tasks?",
                  style: GoogleFonts.didactGothic(color: theme.subText),
                  textAlign: TextAlign.center, // Merkezi hizalama
                ).tr(),
                const SizedBox(height: 20),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateTask(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.checkBoxActiveColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Only This Task",
                        style: GoogleFonts.didactGothic(
                          fontSize: 16,
                          color: theme.welcomeText,
                        ),
                      ).tr(),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateTask(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.checkBoxActiveColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "All Recurring Tasks",
                        style: GoogleFonts.didactGothic(
                          fontSize: 16,
                          color: theme.welcomeText,
                        ),
                      ).tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateTask(bool updateAll) {
    Map<String, String> taskTimes =
        Map<String, String>.from(widget.task['taskTimes']);

    String selectedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    String newTime =
        selectedTime != null ? _formatTimeOfDay(selectedTime!) : "empty";

    if (updateAll) {
      // Tüm tekrarlanan görevlerin saatini güncelle
      for (String date in taskTimes.keys) {
        taskTimes[date] = newTime;
      }
    } else {
      // Sadece seçilen günün saatini güncelle
      taskTimes[selectedDate] = newTime;
    }

    FirebaseFirestore.instance.collection('todos').doc(widget.task.id).update({
      'taskName': nameController.text,
      'taskDescription': descriptionController.text,
      'selectedDays': selectedDays,
      'taskRecurring': selectedRecurrence,
      'taskTimes': taskTimes,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Task updated successfully',
                    style: GoogleFonts.didactGothic())
                .tr()),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error updating task:" + " $error",
                    style: GoogleFonts.didactGothic())
                .tr()),
      );
    });
  }

  void _showRecurringDialog() {
    final theme =
        Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: theme.checkBoxActiveColor,
              onPrimary: Colors.black,
              surface: theme.background,
              onSurface: theme.welcomeText,
            ),
            dialogBackgroundColor: theme.background,
          ),
          child: AlertDialog(
            title: Text("Select Recurrence",
                    style: GoogleFonts.didactGothic(color: theme.welcomeText))
                .tr(),
            content: DropdownButton<String>(
              value: selectedRecurrence,
              items: [
                'Do not repeat',
                'Repeat every week',
                'Repeat every 2 weeks',
                'Repeat every 3 weeks',
                'Repeat every month'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.didactGothic()).tr(),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRecurrence = newValue!;
                });
                Navigator.of(context).pop();
              },
              dropdownColor: theme.background,
              style: GoogleFonts.didactGothic(color: theme.welcomeText),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context, CustomThemeData theme) {
    return GestureDetector(
      onTap: () => _confirmDeleteTask(),
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: 120,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Color.fromARGB(150, 200, 0, 0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(tr("Delete Task")),
      ),
    );
  }

  void _confirmDeleteTask() {
    final theme =
        Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            // Başlığı ortalamak için Center widget'ı eklendi
            child: Text(
              "Delete Task",
              style: GoogleFonts.didactGothic(
                  color: theme.welcomeText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ).tr(),
          ),
          content: Text(
            "Do you want to delete this task or all recurring tasks?",
            style: GoogleFonts.didactGothic(color: theme.welcomeText),
            textAlign: TextAlign.center, // İçerik metni de ortalandı
          ).tr(),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteTask(false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.checkBoxActiveColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Only This Task",
                    style: GoogleFonts.didactGothic(
                        fontSize: 16, color: theme.welcomeText),
                  ).tr(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteTask(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.checkBoxActiveColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "All Recurring Tasks",
                    style: GoogleFonts.didactGothic(
                        fontSize: 16, color: theme.welcomeText),
                  ).tr(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(bool deleteAll) {
    String formattedSelectedDate =
        DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    Map<String, bool> taskCompletionStatus =
        Map<String, bool>.from(widget.task['taskCompletionStatus']);
    Map<String, String> taskTimes =
        Map<String, String>.from(widget.task['taskTimes']);
    List<dynamic> deletedTasks;
    if ((widget.task.data() as Map).containsKey('deletedTasks')) {
      deletedTasks = List<dynamic>.from(widget.task['deletedTasks']);
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

    _moveTaskToTrash(widget.task.id, taskCompletionStatus, taskTimes,
            deletedTasks, deleteAll)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("The task was deleted successfully.",
                    style: GoogleFonts.didactGothic())
                .tr()),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error while deleting task:" + " $error",
                    style: GoogleFonts.didactGothic())
                .tr()),
      );
    });
  }

  Future<void> _moveTaskToTrash(
      String taskId,
      Map<String, bool> taskCompletionStatus,
      Map<String, String> taskTimes,
      List<dynamic> deletedTasks,
      bool deleteAll) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final taskData = widget.task.data() as Map<String, dynamic>;

      // Silinen görevi 'deleted_tasks' koleksiyonuna taşı
      await FirebaseFirestore.instance.collection('deleted_tasks').add({
        'name': taskData['taskName'],
        'description': taskData['taskDescription'],
        'deletedDate': DateTime.now(),
        'collection': 'todos',
        'docId': taskId,
        'userId': user.uid,
        'data': taskData,
        'deletedTasks': deletedTasks,
      });

      // Orijinal görevden sadece belirli bir günü silme
      if (!deleteAll) {
        Map<String, dynamic> updatedTaskData =
            Map<String, dynamic>.from(taskData);
        updatedTaskData['taskCompletionStatus'] = taskCompletionStatus;
        updatedTaskData['taskTimes'] = taskTimes;
        updatedTaskData['deletedTasks'] = deletedTasks;
        await FirebaseFirestore.instance
            .collection('todos')
            .doc(taskId)
            .update(updatedTaskData);
      } else {
        // Orijinal görevden tüm günleri silme
        await FirebaseFirestore.instance
            .collection('todos')
            .doc(taskId)
            .delete();
      }
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return tr("Mon");
      case 2:
        return tr("Tue");
      case 3:
        return tr("Wed");
      case 4:
        return tr("Thu");
      case 5:
        return tr("Fri");
      case 6:
        return tr("Sat");
      case 7:
        return tr("Sun");
      default:
        return '';
    }
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final format = DateFormat.jm(); // AM/PM format
    final dateTime = format.parse(timeString);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); // AM/PM format
    return format.format(dt);
  }
}
