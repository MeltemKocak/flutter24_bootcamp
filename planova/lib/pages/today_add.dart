import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TodayAddSubPage extends StatefulWidget {
  const TodayAddSubPage({super.key});

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
  String selectedRecurrence = 'Tekrar yapma';
  TimeOfDay? selectedTime;
  bool isTaskNameEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0XFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColumnVector(context),
                const SizedBox(height: 26),
                _buildTaskSection(context),
                const SizedBox(height: 14),
                _buildDescriptionSection(context),
                const SizedBox(height: 24),
                _buildRecurringSection(context),
                if (selectedRecurrence != 'Tekrar yapma')
                  _buildDaySelectionSection(context),
                const SizedBox(height: 150),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: _buildAiButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnVector(BuildContext context) {
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
                    ),
                  ),
                ),
                const Text(
                  "Task",
                  style: TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      height: 38,
                      width: 38,
                      child: SvgPicture.asset(
                        "assets/images/img_check.svg",
                      ),
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

  Widget _buildTaskSection(BuildContext context) {
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
                const Text(
                  "Task Name",
                  style: TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
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
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Enter Task Name",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(150, 255, 255, 255),
                  fontSize: 15,
                  fontFamily: 'Roboto',
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isTaskNameEmpty ? Colors.red : Colors.transparent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isTaskNameEmpty ? Colors.red : Colors.transparent,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isTaskNameEmpty ? Colors.red : Colors.transparent,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isTaskNameEmpty ? Colors.red : Colors.transparent,
                  ),
                ),
                filled: true,
                fillColor: const Color(0X3F607D8B),
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

  Widget _buildDescriptionSection(BuildContext context) {
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
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Description",
                    style: TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: SizedBox(
                    height: 12,
                    width: 10,
                    child: SvgPicture.asset(
                      "assets/images/img_describtion_logo.svg",
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
              controller: edittextController,
              focusNode: descriptionFocusNode,
              style: const TextStyle(
                color: Colors.white,
              ),
              textInputAction: TextInputAction.done,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Enter Description",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(150, 255, 255, 255),
                  fontSize: 15,
                  fontFamily: 'Roboto',
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
                fillColor: const Color(0X3F607D8B),
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

  Widget _buildRecurringSection(BuildContext context) {
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
                        backgroundColor: const Color(0X3F607D8B),
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
                            child: const Icon(Icons.refresh_outlined,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Recurring",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 17,
                              fontFamily: 'Roboto',
                            ),
                          )
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
                        backgroundColor: const Color(0X3F607D8B),
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
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0XFF03DAC6),
                                  onPrimary: Colors.black,
                                  surface: Color(0XFF1E1E1E),
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: const Color(0XFF1E1E1E),
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
                          const Icon(Icons.access_time, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : "Select Time",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontFamily: 'Roboto',
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

  Widget _buildDaySelectionSection(BuildContext context) {
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
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
            backgroundColor: const Color(0XFF607D8B),
            selectedColor: const Color(0XFF03DAC6),
          );
        }),
      ),
    );
  }

  Widget _buildAiButton(BuildContext context) {
    return GestureDetector(
      onTap: _addTodo,
      child: Container(
        alignment: Alignment.center,
        height: 70,
        width: 70,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: const Color(0XFF03DAC6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          child: Icon(Icons.psychology_outlined, color: Colors.white, size: 45),
        ),
      ),
    );
  }

  void _showRecurringDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0XFF03DAC6),
              onPrimary: Colors.black,
              surface: Color(0XFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0XFF1E1E1E),
          ),
          child: AlertDialog(
            title: const Text("Select Recurrence", style: TextStyle(color: Colors.white)),
            content: DropdownButton<String>(
              value: selectedRecurrence,
              items: [
                'Tekrar yapma',
                '1 hafta tekrar',
                '2 hafta tekrar',
                '3 hafta tekrar',
                '1 ay tekrar'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRecurrence = newValue!;
                });
                Navigator.of(context).pop();
              },
              dropdownColor: const Color(0XFF1E1E1E),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void _addTodo() {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add a task')),
      );
      return;
    }

    setState(() {
      isTaskNameEmpty = nameController.text.trim().isEmpty;
    });

    if (isTaskNameEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task name cannot be empty')),
      );
      return;
    }

    int recurrenceDays = 0;
    switch (selectedRecurrence) {
      case '1 hafta tekrar':
        recurrenceDays = 7;
        break;
      case '2 hafta tekrar':
        recurrenceDays = 14;
        break;
      case '3 hafta tekrar':
        recurrenceDays = 21;
        break;
      case '1 ay tekrar':
        recurrenceDays = 30;
        break;
    }

    Map<String, String> taskTimes = {};
    DateTime currentDate = DateTime.now();
    String taskTime = selectedTime != null ? selectedTime!.format(context) : "boş";

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
        const SnackBar(content: Text('Task added successfully')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding task: $error')),
      );
    });
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Pzt';
      case 2:
        return 'Sal';
      case 3:
        return 'Çar';
      case 4:
        return 'Per';
      case 5:
        return 'Cum';
      case 6:
        return 'Cmt';
      case 7:
        return 'Paz';
      default:
        return '';
    }
  }
}
