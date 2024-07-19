import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

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
    selectedRecurrence = widget.task['taskRecurring'] ?? 'Tekrar yapma';
    selectedTime = widget.task['taskTimes']
                [DateFormat('yyyy-MM-dd').format(widget.selectedDate)] !=
            "boş"
        ? TimeOfDay(
            hour: int.parse(widget.task['taskTimes']
                    [DateFormat('yyyy-MM-dd').format(widget.selectedDate)]
                .split(":")[0]),
            minute: int.parse(widget.task['taskTimes']
                    [DateFormat('yyyy-MM-dd').format(widget.selectedDate)]
                .split(":")[1]),
          )
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
            child: _buildUpdateButton(context),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: _buildDeleteButton(context),
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
                  "Edit Task",
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
              controller: descriptionController,
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
                          initialTime: selectedTime ?? TimeOfDay.now(),
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
              
              style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255), fontSize: 18),
            ),
            
            selected: selectedDays.contains(index + 1),
            onSelected: null, // Günlerin değiştirilemez olmasını sağlamak için
            backgroundColor: const Color(0XFF607D8B),
            selectedColor: const Color.fromARGB(255, 90, 92, 92),
            disabledColor: const Color.fromARGB(255, 90, 92, 92),
          );
        }),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return GestureDetector(
      onTap: _updateTodo,
      child: Container(
        alignment: Alignment.center,
        height: 70,
        width: 70,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: const Color(0XFF03DAC6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.update, color: Colors.white, size: 45),
      ),
    );
  }

  void _updateTodo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0XFF1E1E1E),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Saat Güncelleme",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Bu görevin saatini mi yoksa tüm tekrarlanan görevlerin saatini mi güncellemek istiyorsunuz?",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateTask(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF03DAC6),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
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
                        Navigator.pop(context);
                        _updateTask(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF03DAC6),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
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
        selectedTime != null ? selectedTime!.format(context) : "boş";

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
        const SnackBar(content: Text('Task updated successfully')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $error')),
      );
    });
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
            title: const Text("Select Recurrence",
                style: TextStyle(color: Colors.white)),
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

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDeleteTask(),
      child: Container(
        alignment: Alignment.center,
        height: 70,
        width: 70,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: const Color(0XFFCF6679),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 45),
      ),
    );
  }

  void _confirmDeleteTask() {
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
                    _deleteTask(false);
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
                    _deleteTask(true);
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

    FirebaseFirestore.instance.collection('todos').doc(widget.task.id).update({
      'taskCompletionStatus': taskCompletionStatus,
      'taskTimes': taskTimes,
      'deletedTasks': deletedTasks,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Görev başarıyla silindi.')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Görev silinirken hata oluştu: $error')),
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
