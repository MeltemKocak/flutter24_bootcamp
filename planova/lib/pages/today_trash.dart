import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  _TrashPageState createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
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
          const SizedBox(height: 30),
          Expanded(
            child: _buildDeletedTasksList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedTasksList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('todos')
          .where('deletedTasks', isNotEqualTo: [])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var tasks = snapshot.data!.docs;
        List<Map<String, dynamic>> deletedTasks = [];

        for (var task in tasks) {
          List<dynamic> taskDeletedDates = task['deletedTasks'];
          for (var date in taskDeletedDates) {
            deletedTasks.add({
              'task': task,
              'deletedDate': date,
            });
          }
        }

        return ListView.builder(
          itemCount: deletedTasks.length,
          itemBuilder: (context, index) {
            var taskData = deletedTasks[index];
            var task = taskData['task'];
            var deletedDate = taskData['deletedDate'];

            return Dismissible(
              key: Key(task.id + deletedDate),
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
                _showRestoreBottomSheet(task, deletedDate);
              },
              child: _buildTaskCard(task, deletedDate),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard(DocumentSnapshot task, String deletedDate) {
    return Card(
      color: const Color(0X3F607D8B),
      child: ListTile(
        title: Text(task['taskName'], style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          DateFormat('dd/MM/yyyy').format(DateTime.parse(deletedDate)),
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.swipe_left, color: Colors.white54),
        onTap: () => _showRestoreBottomSheet(task, deletedDate),
      ),
    );
  }

  void _showRestoreBottomSheet(DocumentSnapshot task, String deletedDate) {
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
                    onPressed: () => _restoreTask(task, deletedDate),
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

  void _restoreTask(DocumentSnapshot task, String deletedDate) {
    Map<String, bool> taskCompletionStatus =
        Map<String, bool>.from(task['taskCompletionStatus']);

    // Görev tamamlanma durumu için tarihi geri yükle
    taskCompletionStatus[deletedDate] = false;

    FirebaseFirestore.instance.collection('todos').doc(task.id).update({
      'taskCompletionStatus': taskCompletionStatus,
      'deletedTasks': FieldValue.arrayRemove([deletedDate]),
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
