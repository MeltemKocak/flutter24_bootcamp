// TodayAddPage.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';

class TodayAddSubPage extends StatefulWidget {
  final DateTime? focusDate;

  const TodayAddSubPage({super.key, required this.focusDate});

  @override
  _TodayAddSubPageState createState() => _TodayAddSubPageState();
}

class _TodayAddSubPageState extends State<TodayAddSubPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController edittextController = TextEditingController();
  FocusNode taskNameFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  List<int> selectedDays = [];
  String selectedRecurrence = 'Do not repeat';
  TimeOfDay? selectedTime;
  bool isTaskNameEmpty = false;

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
                const SizedBox(height: 150),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: _buildConfirmTaskButton(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnVector(BuildContext context, CustomThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context, CustomThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Task Name",
                    style: GoogleFonts.didactGothic(
                      color: theme.welcomeText,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ).tr(),
                ),
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
            width: double.infinity,
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
                  borderSide: BorderSide(
                    color:
                        isTaskNameEmpty ? Colors.red : theme.toDoCardBackground,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                        isTaskNameEmpty ? Colors.red : theme.toDoCardBackground,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isTaskNameEmpty ? Colors.red : theme.borderColor,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isTaskNameEmpty ? Colors.red : theme.borderColor,
                  ),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
            width: double.infinity,
            child: TextFormField(
              controller: edittextController,
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
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
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
                              fontSize: 16,
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
                    width: double.infinity,
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
                          initialTime: TimeOfDay.now(),
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
                                    foregroundColor: theme.welcomeText
                                  ),
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
                                : "Select Time",
                            style: GoogleFonts.didactGothic(
                              color: theme.welcomeText,
                              fontSize: 16,
                            ),
                          ).tr(),
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
                  color: theme.welcomeText, fontSize: 18),
            ),
            selected: selectedDays.contains(index + 1),
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  selectedDays.add(index + 1);
                } else {
                  selectedDays.remove(index + 1);
                }
              });
            },
            backgroundColor: theme.checkBoxBorderColor,
            selectedColor: theme.checkBoxActiveColor,
          );
        }),
      ),
    );
  }

  Widget _buildConfirmTaskButton(BuildContext context, CustomThemeData theme) {
    return GestureDetector(
      onTap: _addTodo,
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: 150,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: theme.addButton,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Confirm Task',
          style: GoogleFonts.didactGothic(
            color: theme.addButtonIcon,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ).tr(),
      ),
    );
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
              style: TextStyle(color: theme.welcomeText)).tr(),
          content: DropdownButton<String>(
            value: selectedRecurrence, // Bu değer "items" listesindeki bir öğeyle eşleşmelidir
  items: [
    DropdownMenuItem(
      value: 'Do not repeat',
      child: Text('Do not repeat'),
    ),
    DropdownMenuItem(
      value: 'Repeat every week',
      child: Text('Repeat every week'),
    ),
    DropdownMenuItem(
      value: 'Repeat every 2 weeks',
      child: Text('Repeat every 2 weeks'),
    ),
    DropdownMenuItem(
      value: 'Repeat every 3 weeks',
      child: Text('Repeat every 3 weeks'),
    ),
    DropdownMenuItem(
      value: 'Repeat every month',
      child: Text('Repeat every month'),
    ),
  ],
  onChanged: (String? newValue) {
    setState(() {
      selectedRecurrence = newValue!;
    });
              Navigator.of(context).pop();
            },
            dropdownColor: theme.background,
            style: TextStyle(color: theme.welcomeText),
          ),
        ),
      );
    },
  );
}

  void _addTodo() {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('You must be logged in to add a task',
                    style: GoogleFonts.didactGothic())
                .tr()),
      );
      return;
    }

    setState(() {
      isTaskNameEmpty = nameController.text.trim().isEmpty;
    });

    if (isTaskNameEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Task name cannot be empty",
                    style: GoogleFonts.didactGothic())
                .tr()),
      );
      return;
    }

    int recurrenceDays = 0;
    switch (selectedRecurrence) {
      case 'Repeat every week':
        recurrenceDays = 7;
        break;
      case 'Repeat every 2 weeks':
        recurrenceDays = 14;
        break;
      case 'Repeat every 3 weeks':
        recurrenceDays = 21;
        break;
      case 'Repeat every month':
        recurrenceDays = 30;
        break;
    }

    Map<String, String> taskTimes = {};
    DateTime currentDate = widget.focusDate ?? DateTime.now();
    String taskTime =
        selectedTime != null ? _formatTimeOfDay(selectedTime!) : "empty";

    if (selectedDays.isNotEmpty) {
      for (int i = 0; i < recurrenceDays; i++) {
        DateTime taskDate = currentDate.add(Duration(days: i));
        if (selectedDays.contains(taskDate.weekday)) {
          taskTimes[DateFormat('yyyy-MM-dd').format(taskDate)] = taskTime;
        }
      }
    } else {
      taskTimes[DateFormat('yyyy-MM-dd').format(currentDate)] = taskTime;
    }

    Map<String, dynamic> taskData = {
      'userId': _user!.uid,
      'taskName': nameController.text,
      'taskDescription': edittextController.text,
      'taskCreateDate': FieldValue.serverTimestamp(),
      'taskRecurring': selectedRecurrence,
      'taskCompletionStatus': {},
      'taskTimes': taskTimes,
      'selectedDays': selectedDays,
    };

    FirebaseFirestore.instance.collection('todos').add(taskData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Task added successfully',
                    style: GoogleFonts.didactGothic())
                .tr()),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(tr("Error") + " $error",
                style: GoogleFonts.didactGothic())),
      );
    });
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Mon'.tr();
      case 2:
        return 'Tue'.tr();
      case 3:
        return 'Wed'.tr();
      case 4:
        return 'Thu'.tr();
      case 5:
        return 'Fri'.tr();
      case 6:
        return 'Sat'.tr();
      case 7:
        return 'Sun'.tr();
      default:
        return '';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); // AM/PM format
    return format.format(dt);
  }
}
