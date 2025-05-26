import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/add_new_task.dart';
import '../utils.dart';
import '../widgets/date_selector.dart';
import '../widgets/task_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DocumentSnapshot> _taskDocs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewTask(),
                ),
              );
            },
            icon: const Icon(
              CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const DateSelector(),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: Text('No tasks found :(', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
                  );
                }

                _taskDocs = snapshot.data!.docs;

                return Expanded(
                  child: ListView.builder(
                    itemCount: _taskDocs.length,
                    itemBuilder: (context, index) {
                      final task = _taskDocs[index];

                      return Dismissible(
                        key: ValueKey(task.id),
                        onDismissed: (direction) async {
                          final deletedData = snapshot.data!.docs[index].data();

                          // setState(() {
                          //   _taskDocs.removeAt(index);
                          // });

                          await FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Task deleted'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () {
                                  FirebaseFirestore.instance.collection('tasks').doc(task.id).set(deletedData);
                                },
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: TaskCard(
                                color: hexToColor(task['color']),
                                headerText: task['title'],
                                descriptionText: task['description'],
                                scheduledDate: task['date'].toString(),
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: strengthenColor(const Color.fromRGBO(246, 222, 194, 1), 0.69),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                '10:00AM',
                                style: TextStyle(fontSize: 17),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}