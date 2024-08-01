import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  _TrashPageState createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.loginTextAndBorder,
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Container(), // Empty Container to center the title properly
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_forever,
              color: theme.loginTextAndBorder,
            ),
            onPressed: () {
              _showDeleteAllConfirmDialog(theme);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Expanded(
            child: _buildDeletedTasksList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedTasksList(CustomThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('deleted_tasks')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
              child: CircularProgressIndicator(color: theme.habitProgress));

        var tasks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            var taskData = tasks[index];

            return Dismissible(
              key: Key(taskData.id),
              background: Container(
                color: const Color.fromARGB(200, 250, 70, 60),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.delete, color: theme.welcomeText),
                  ),
                ),
              ),
              secondaryBackground: Container(
                color: const Color.fromARGB(200, 77, 177, 81),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.restore, color: theme.welcomeText),
                  ),
                ),
              ),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  _showDeleteConfirmDialog(taskData, theme);
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  _restoreTask(taskData);
                  return false;
                }
                return false;
              },
              child: _buildTaskCard(taskData, theme),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard(DocumentSnapshot taskData, CustomThemeData theme) {
    var data = taskData.data() as Map<String, dynamic>;
    var taskName = data['name'];
    var deletedDate = data['deletedDate'];

    return Card(
      color: theme.toDoCardBackground,
      child: ListTile(
        title: Text(
          taskName,
          style: GoogleFonts.didactGothic(color: theme.welcomeText),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy').format(deletedDate.toDate()),
          style: GoogleFonts.didactGothic(color: theme.subText),
        ),
        trailing: Icon(Icons.swipe_left, color: theme.welcomeText),
        onTap: () => _showRestoreBottomSheet(taskData, theme),
      ),
    );
  }

  void _showRestoreBottomSheet(
      DocumentSnapshot taskData, CustomThemeData theme) {
    var data = taskData.data() as Map<String, dynamic>;
    var taskName = data['name'];
    var taskDescription = data['description'];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.background,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                taskName,
                style: GoogleFonts.didactGothic(
                  color: theme.welcomeText,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                taskDescription,
                style: GoogleFonts.didactGothic(color: theme.subText),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.subText,
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.didactGothic(color: theme.welcomeText),
                    ).tr(),
                  ),
                  ElevatedButton(
                    onPressed: () => _restoreTask(taskData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.checkBoxActiveColor,
                    ),
                    child: Text(
                      "Bring Back",
                      style:
                          GoogleFonts.didactGothic(color: theme.addButtonIcon),
                    ).tr(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(
      DocumentSnapshot taskData, CustomThemeData theme) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.background,
          title: Text(
            "Delete",
            style: GoogleFonts.didactGothic(color: theme.welcomeText),
          ).tr(),
          content: Text(
            "Are you sure you want to permanently delete this item?",
            style: GoogleFonts.didactGothic(color: theme.subText),
          ).tr(),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style:
                    GoogleFonts.didactGothic(color: theme.checkBoxActiveColor),
              ).tr(),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTaskPermanently(taskData);
              },
              child: Text(
                "Delete",
                style:
                    GoogleFonts.didactGothic(color: theme.checkBoxActiveColor),
              ).tr(),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllConfirmDialog(CustomThemeData theme) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.background,
          title: Text(
            "Delete All",
            style: GoogleFonts.didactGothic(color: theme.welcomeText),
          ).tr(),
          content: Text(
            "Are you sure you want to permanently delete all deleted items?",
            style: GoogleFonts.didactGothic(color: theme.subText),
          ).tr(),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'İptal',
                style:
                    GoogleFonts.didactGothic(color: theme.checkBoxActiveColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAllTasksPermanently();
              },
              child: Text(
                "Delete",
                style:
                    GoogleFonts.didactGothic(color: theme.checkBoxActiveColor),
              ).tr(),
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
    await FirebaseFirestore.instance
        .collection('deleted_tasks')
        .doc(taskData.id)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Deleted", style: GoogleFonts.didactGothic()).tr()),
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
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .delete();

      // 'deleted_tasks' koleksiyonundan sil
      await FirebaseFirestore.instance
          .collection('deleted_tasks')
          .doc(doc.id)
          .delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Deleted", style: GoogleFonts.didactGothic()).tr()),
    );
  }

  void _restoreTask(DocumentSnapshot taskData) async {
    var data = taskData.data() as Map<String, dynamic>;
    var collection = data['collection'];
    var docId = data['docId'];
    var taskDataOriginal = data['data'];

    // Orijinal koleksiyona geri yükle
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .set(taskDataOriginal);

    // 'deleted_tasks' koleksiyonundan sil
    await FirebaseFirestore.instance
        .collection('deleted_tasks')
        .doc(taskData.id)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Mission successfully brought back",
                  style: GoogleFonts.didactGothic())
              .tr()),
    );
  }
}
