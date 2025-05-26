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
              stream: FirebaseFirestore.instance.collection('tasks').where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: const Text('No data here :(', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
                  );
                }

                return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TaskCard(
                            color: hexToColor(snapshot.data!.docs[index].data()['color']),
                            headerText: snapshot.data!.docs[index].data()['title'],
                            descriptionText: snapshot.data!.docs[index].data()['description'],
                            scheduledDate: snapshot.data!.docs[index].data()['date'].toString(),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: strengthenColor(
                              const Color.fromRGBO(246, 222, 194, 1),
                              0.69,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            '10:00AM',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              );
              },
            ),
          ],
        ),
      ),
    );
  }
}