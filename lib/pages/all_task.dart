import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:nuli/pages/TaskDetail.dart';

import '../dataclass.dart';
import '../dbservices.dart';

class AllTaskPage extends StatefulWidget {
  const AllTaskPage({Key? key}) : super(key: key);

  @override
  State<AllTaskPage> createState() => _AllTaskPageState();
}

class _AllTaskPageState extends State<AllTaskPage> {
  late String uid;

  String getDateText(Timestamp t) {
    DateTime dt = t.toDate();
    DateFormat formatter = DateFormat('d MMMM y');
    String hasil = formatter.format(dt);
    return hasil;
  }

  DateTime getDate(Timestamp t) {
    DateTime dt = t.toDate();
    return dt;
  }

  String getTimeText(Timestamp t) {
    DateTime dt = t.toDate();
    var hour = dt.hour;
    var mins = dt.minute;

    String hourStr =
        hour < 10 ? hour.toString().padLeft(2, '0') : hour.toString();
    String minsStr =
        mins < 10 ? mins.toString().padLeft(2, '0') : mins.toString();

    String hasil = '${hourStr}:${minsStr}';
    return hasil;
  }

  Future showConfirmDialog(String uid, String idDel, String titleDel) =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text('Are you sure you want to delete ${titleDel}?',
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.5,
                    )),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        TaskService.deleteData(uid, idDel);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ],
              ));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var curUser = FirebaseAuth.instance.currentUser;

    if (curUser != null) {
      uid = curUser.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Text(
                'All Tasks',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: TaskService().getAllData(uid, ""),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('ERROR');
                    } else if (snapshot.hasData || snapshot.data != null) {
                      return Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot _data = snapshot.data!.docs[index];
                            return Dismissible(
                              key: Key(_data['taskid']),
                              background: Container(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                alignment: Alignment.centerLeft,
                                color: Colors.green,
                                child: const Text(
                                  "Done",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              secondaryBackground: Container(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                alignment: Alignment.centerRight,
                                color: Colors.red,
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  final isdone = TaskService().toggleTodoStatus(
                                      uid,
                                      Task(
                                          taskid: _data['taskid'],
                                          title: _data['title'],
                                          date_time:
                                              getDate(_data['date_time']),
                                          reminder: _data['reminder'],
                                          desc: _data['desc'],
                                          isdone: _data['isdone']));
                                  return false;
                                } else {
                                  showConfirmDialog(
                                      uid, _data['taskid'], _data['title']);
                                  return false;
                                }
                              },
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TaskDetail(
                                              taskDet: Task(
                                                  taskid: _data['taskid'],
                                                  title: _data['title'],
                                                  date_time: getDate(
                                                      _data['date_time']),
                                                  reminder: _data['reminder'],
                                                  desc: _data['desc'],
                                                  isdone: _data['isdone']))));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment(1, -1),
                                          end: Alignment(0, 0),
                                          colors: [
                                            Color.fromARGB(255, 237, 233, 98),
                                            Color.fromARGB(255, 255, 255, 255)
                                          ]),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                        )
                                      ],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(14))),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                          activeColor:
                                              Color.fromARGB(255, 71, 221, 0),
                                          checkColor: Colors.white,
                                          shape: CircleBorder(),
                                          value: _data['isdone'],
                                          onChanged: (_) {
                                            final isdone = TaskService()
                                                .toggleTodoStatus(
                                                    uid,
                                                    Task(
                                                        taskid: _data['taskid'],
                                                        title: _data['title'],
                                                        date_time: getDate(
                                                            _data['date_time']),
                                                        reminder:
                                                            _data['reminder'],
                                                        desc: _data['desc'],
                                                        isdone:
                                                            _data['isdone']));
                                          }),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(_data['title'],
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                  getDateText(
                                                      _data['date_time']),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromARGB(
                                                          178, 0, 0, 0))),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  getTimeText(
                                                      _data['date_time']),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromARGB(
                                                          178, 0, 0, 0))),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 20.0),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: Text('You have no task'),
                      );
                    }
                    return const Center(
                        child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ));
                    ;
                  },
                ),
              ),
            ],
          )),
    );
  }
}
