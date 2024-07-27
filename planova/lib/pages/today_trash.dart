import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              color: Color.fromARGB(255, 3, 218, 198),
            ),
            onPressed: () {
              _showDeleteAllConfirmDialog();
            },
          ),
        ],
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
          .collection('deleted_tasks')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var tasks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            var taskData = tasks[index];

            return Dismissible(
              key: Key(taskData.id),
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
              secondaryBackground: Container(
                color: Colors.red,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  _showDeleteConfirmDialog(taskData);
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  _restoreTask(taskData);
                  return false;
                }
                return false;
              },
              child: _buildTaskCard(taskData),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard(DocumentSnapshot taskData) {
    var data = taskData.data() as Map<String, dynamic>;
    var taskName = data['name'];
    var deletedDate = data['deletedDate'];

    return Card(
      color: const Color(0X3F607D8B),
      child: ListTile(
        title: Text(taskName, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          DateFormat('dd/MM/yyyy').format(deletedDate.toDate()),
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.swipe_left, color: Colors.white54),
        onTap: () => _showRestoreBottomSheet(taskData),
      ),
    );
  }

  void _showRestoreBottomSheet(DocumentSnapshot taskData) {
    var data = taskData.data() as Map<String, dynamic>;
    var taskName = data['name'];
    var taskDescription = data['description'];

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
              Text(taskName, style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 10),
              Text(taskDescription, style: const TextStyle(color: Colors.white70)),
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
                    onPressed: () => _restoreTask(taskData),
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

  void _showDeleteConfirmDialog(DocumentSnapshot taskData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Sil',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Bu öğeyi kalıcı olarak silmek istediğinize emin misiniz?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'İptal',
                style: TextStyle(color: Color(0xFF03DAC6)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTaskPermanently(taskData);
              },
              child: const Text(
                'Sil',
                style: TextStyle(color: Color(0xFF03DAC6)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Tümünü Sil',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Tüm silinmiş öğeleri kalıcı olarak silmek istediğinize emin misiniz?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'İptal',
                style: TextStyle(color: Color(0xFF03DAC6)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAllTasksPermanently();
              },
              child: const Text(
                'Sil',
                style: TextStyle(color: Color(0xFF03DAC6)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTaskPermanently(DocumentSnapshot taskData) async {
    var data = taskData.data() as Map<String, dynamic>;
    var docId = data['docId'];
    var collection = data['collection'];

    // Orijinal koleksiyondan sil
    await FirebaseFirestore.instance.collection(collection).doc(docId).delete();

    // 'deleted_tasks' koleksiyonundan sil
    await FirebaseFirestore.instance.collection('deleted_tasks').doc(taskData.id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Öğe kalıcı olarak silindi')),
    );
  }

  void _deleteAllTasksPermanently() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('deleted_tasks')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      var docId = data['docId'];
      var collection = data['collection'];

      // Orijinal koleksiyondan sil
      await FirebaseFirestore.instance.collection(collection).doc(docId).delete();

      // 'deleted_tasks' koleksiyonundan sil
      await FirebaseFirestore.instance.collection('deleted_tasks').doc(doc.id).delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tüm silinmiş öğeler kalıcı olarak silindi')),
    );
  }

  void _restoreTask(DocumentSnapshot taskData) async {
    var data = taskData.data() as Map<String, dynamic>;
    var collection = data['collection'];
    var docId = data['docId'];
    var taskDataOriginal = data['data'];

    // Orijinal koleksiyona geri yükle
    await FirebaseFirestore.instance.collection(collection).doc(docId).set(taskDataOriginal);

    // 'deleted_tasks' koleksiyonundan sil
    await FirebaseFirestore.instance.collection('deleted_tasks').doc(taskData.id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Görev başarıyla geri getirildi')),
    );
  }
}
