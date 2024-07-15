import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String selectedReminder = '1 gün';

  @override
  Widget build(BuildContext context) {
    // Mevcut build metodu aynı kalacak
    return Container(
      decoration: const BoxDecoration(
        color: Color(0XFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColumnVector(context),
              const SizedBox(height: 26),
              _buildTaskSection(context),
              const SizedBox(height: 14),
              _buildDescriptionSection(context),
              const SizedBox(height: 24),
              _buildRecurringSection(context),
              const SizedBox(height: 150),
            ],
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


  // Diğer widget metodları aynı kalacak, sadece _buildRecurringSection ve _buildAiButton'ı güncelleyeceğim

  Widget _buildRecurringSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
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
                        visualDensity: const VisualDensity(
                          vertical: -4,
                          horizontal: -4,
                        ),
                        padding: const EdgeInsets.only(
                          top: 16,
                          right: 30,
                          bottom: 16,
                        ),
                      ),
                      onPressed: _showRecurringDialog,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: const Icon(Icons.refresh_outlined, color: Colors.white, size: 28),
                          ),
                          const Text(
                            "Recurring",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
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
                        padding: const EdgeInsets.only(
                          top: 16,
                          right: 30,
                          bottom: 16,
                        ),
                      ),
                      onPressed: _showReminderDialog,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 25),
                          ),
                          const Text(
                            "Reminder",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
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
        return AlertDialog(
          title: const Text("Select Recurring Days"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Wrap(
                children: List<Widget>.generate(7, (int index) {
                  return FilterChip(
                    label: Text(_getDayName(index + 1)),
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
                  );
                }),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
 

  
 

  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Reminder"),
          content: DropdownButton<String>(
            value: selectedReminder,
            items: ['1 gün', '1 hafta', '1 ay', '1 yıl'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedReminder = newValue!;
              });
              Navigator.of(context).pop();
            },
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

    FirebaseFirestore.instance.collection('todos').add({
      'userId': _user!.uid,
      'taskName': nameController.text,
      'taskDescription': edittextController.text,
      'taskCreateDate': FieldValue.serverTimestamp(),
      'taskIsDone': false,
      'taskRecurring': selectedDays,
      'taskReminder': selectedReminder,
    }).then((_) {
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
      case 1: return 'Pzt';
      case 2: return 'Sal';
      case 3: return 'Çar';
      case 4: return 'Per';
      case 5: return 'Cum';
      case 6: return 'Cmt';
      case 7: return 'Paz';
      default: return '';
    }
  }
}