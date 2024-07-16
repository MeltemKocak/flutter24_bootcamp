import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  _TrashPageState createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
          DateTime taskAddedDate = (Timestamp.now()).toDate();

  final EasyInfiniteDateTimelineController _controller = EasyInfiniteDateTimelineController();
  DateTime? _focusDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF1E1E1E),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: null,
          toolbarHeight: 100,
          titleSpacing: 0,
          title: Row(
            children: [
              IconButton(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    const Icon(
                      Icons.arrow_back_ios,
                      color: Color.fromARGB(255, 3, 218, 198),
                      size: 28,
                    ),
                    const Text(
                      'Geri',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        color: Color.fromARGB(255, 3, 218, 198),
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      body: Column(
        children: [
          _buildDatePicker(),
          const SizedBox(height: 30,),
          Expanded(
            
            child: _buildDeletedTasksList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return EasyInfiniteDateTimeLine(
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
            );
  }

  Widget _buildDeletedTasksList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('todos')
          .where('deletedDate', isNull: false)
          .orderBy('deletedDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var tasks = snapshot.data!.docs;
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            var task = tasks[index];
            return Dismissible(
            
              key: Key(task.id),
              background: Container(
                color: const Color(0XFF03DAC6),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.restore, color: Colors.white),
                  ),
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _showRestoreBottomSheet(task);
              },
              child: _buildTaskCard(task),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard(DocumentSnapshot task) {
    
    return Card(
      
      color: const Color(0X3F607D8B),
      child: ListTile(
        
        title: Text(task['taskName'], style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(task['deletedDate'].toDate()),
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.swipe_left, color: Colors.white54),
        onTap: () => _showRestoreBottomSheet(task),
      ),
    );
  }

  void _showRestoreBottomSheet(DocumentSnapshot task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0XFF1E1E1E),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task['taskName'], style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 10),
              Text(task['taskDescription'], style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white70),
                    child: const Text('İptal', style: TextStyle(color: Colors.white),),
                  ),
                  ElevatedButton(
                    onPressed: () => _restoreTask(task),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0XFF03DAC6)),
                    child: const Text('Geri Getir'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _restoreTask(DocumentSnapshot task) {
    FirebaseFirestore.instance.collection('todos').doc(task.id).update({
      'deletedDate': FieldValue.delete(),
    }).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Görev başarıyla geri getirildi')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $error')),
      );
    });
  }
}