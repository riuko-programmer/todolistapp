import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuli/dataclass.dart' as dataclass;
import 'package:nuli/pages/ProjectDetail.dart';
import 'package:nuli/pages/TaskDetail.dart';
import 'package:nuli/pages/all_task.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../dbservices.dart';
import 'all_project.dart';
import 'all_projects.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String uid;
  int taskCount = 0;

  bool _progressController = true;
  late dataclass.User user;
  int _taskDoneCount = 0;
  int _taskPendingCount = 0;
  int _projectDoneCount = 0;
  int _projectPendingCount = 0;
  List<int> _progressList = [0, 0, 0, 0, 0, 0, 0];

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
                        Navigator.of(context).pop();
                        ProjectService.deleteData(uid, idDel);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ],
              ));

  Future showConfirmDialogTask(String uid, String idDel, String titleDel) =>
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
                        Navigator.of(context).pop();
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
    super.initState();
    getCurrentUser();
    _progressController = true;

    var curUser = FirebaseAuth.instance.currentUser;

    if (curUser != null) {
      uid = curUser.uid;
    }
    getProgressForProjectTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _progressController
          ? const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ))
          : SingleChildScrollView(
              child: Container(
                color: const Color.fromARGB(255, 246, 250, 253),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: NetworkImage(user.photoUrl),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Hello, ${user.firstName}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const Text(
                                  '👋',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                const Text('🔥 ',
                                    style: TextStyle(fontSize: 12)),
                                StreamBuilder<QuerySnapshot>(
                                  stream: TaskService().getData(uid, ""),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text('ERROR');
                                    } else if (snapshot.hasData) {
                                      taskCount = snapshot.data!.docs.length;

                                      if (taskCount == 1) {
                                        return Text(
                                            '${taskCount.toString()} task is waiting for you today');
                                      } else {
                                        return Text(
                                            '${taskCount.toString()} tasks are waiting for you today');
                                      }
                                    }
                                    return const Text('0 task for today!');
                                  },
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Projects",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllProjectsPage()));
                          },
                          child: const Text("See all",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 0.6),
                                fontSize: 12,
                              )),
                        )
                      ],
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: ProjectService().getDataUndone(uid, ""),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('ERROR');
                            } else if (snapshot.hasData ||
                                snapshot.data != null) {
                              return Container(
                                  child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  taskCount = snapshot.data!.docs.length;
                                  DocumentSnapshot _data =
                                      snapshot.data!.docs[index];
                                  DateTime projectDeadline =
                                      _data['deadline'].toDate();
                                  DateTime today = DateTime.now();
                                  int daysLeft =
                                      projectDeadline.difference(today).inDays;
                                  String projectDeadlineStr =
                                      "$daysLeft days left";
                                  if (daysLeft < 0) {
                                    projectDeadlineStr = "Overdue";
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder:
                                                  (context) => ProjectDetail(
                                                        projectDet: dataclass.Project(
                                                            projectid: _data[
                                                                'projectid'],
                                                            title:
                                                                _data['title'],
                                                            deadline: getDate(
                                                                _data[
                                                                    'deadline']),
                                                            desc: _data['desc'],
                                                            isdone:
                                                                _data['isdone'],
                                                            reminder: _data[
                                                                'reminder']),
                                                      ))).then((value) {
                                        setState(() {
                                          getProgressForProjectTask();
                                        });
                                      });
                                    },
                                    child: Container(
                                      // constraints: BoxConstraints(maxWidth: 270),
                                      padding: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment(1, -1),
                                              end: Alignment(0, 0),
                                              colors: [
                                                Color.fromARGB(
                                                    255, 250, 153, 85),
                                                Color.fromARGB(
                                                    255, 255, 255, 255)
                                              ]),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 10,
                                            )
                                          ],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(7))),
                                      child: Column(children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _data['title'],
                                              style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 28,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Progress",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color.fromARGB(
                                                        255, 28, 84, 157))),
                                            Text("${_progressList[index]}%",
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color.fromARGB(
                                                        255, 28, 84, 157)))
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        LinearPercentIndicator(
                                          padding: const EdgeInsets.all(0),
                                          lineHeight: 7,
                                          percent: _progressList[index] / 100,
                                          progressColor: const Color.fromARGB(
                                              255, 28, 84, 157),
                                          backgroundColor:
                                              const Color.fromARGB(40, 0, 0, 0),
                                          // linearStrokeCap: LinearStrokeCap.roundAll,
                                          barRadius: const Radius.circular(16),
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                "Due " +
                                                    getDateText(
                                                        _data['deadline']),
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                            Text(projectDeadlineStr,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromARGB(
                                                        200, 0, 0, 0)))
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              TaskforProjectServices
                                                  .movePendingTask(
                                                      dataclass.Project(
                                                          projectid: _data[
                                                              'projectid'],
                                                          title: _data['title'],
                                                          deadline: getDate(
                                                              _data[
                                                                  'deadline']),
                                                          desc: _data['desc'],
                                                          isdone:
                                                              _data['isdone'],
                                                          reminder: _data[
                                                              'reminder']));
                                              setState(() {});
                                            },
                                            child: const Text(
                                              "Move pending task",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        // GestureDetector(

                                        //   child: Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.center,
                                        //     children: const [
                                        //       Text(
                                        //         'Pending tasks',
                                        //         style: TextStyle(
                                        //             fontSize: 15,
                                        //             color: Colors.grey),
                                        //       ),
                                        //       Icon(
                                        //         Icons.arrow_downward_rounded,
                                        //         size: 15,
                                        //         color: Colors.grey,
                                        //       )
                                        //     ],
                                        //   ),
                                        // ),
                                      ]),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 20.0),
                              ));
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              return const Text('You have no ongoing project',
                                  style: TextStyle(color: Colors.grey));
                            }
                            return const Center(
                                child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ));
                          },
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tasks",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllTaskPage()));
                          },
                          child: const Text("See all",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 0.6),
                                fontSize: 12,
                              )),
                        )
                      ],
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: TaskService().getData(uid, ""),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('ERROR');
                            } else if (snapshot.hasData ||
                                snapshot.data != null) {
                              return Container(
                                child: ListView.separated(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot _data =
                                        snapshot.data!.docs[index];
                                    return Dismissible(
                                      key: Key(_data['taskid']),
                                      background: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 0, 0),
                                        alignment: Alignment.centerLeft,
                                        color: Colors.green,
                                        child: const Text(
                                          "Done",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      secondaryBackground: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 10, 0),
                                        alignment: Alignment.centerRight,
                                        color: Colors.red,
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      confirmDismiss: (direction) async {
                                        if (direction ==
                                            DismissDirection.startToEnd) {
                                          final isdone = TaskService()
                                              .toggleTodoStatus(
                                                  uid,
                                                  dataclass.Task(
                                                      taskid: _data['taskid'],
                                                      title: _data['title'],
                                                      date_time: getDate(
                                                          _data['date_time']),
                                                      reminder:
                                                          _data['reminder'],
                                                      desc: _data['desc'],
                                                      isdone: _data['isdone']));
                                          return false;
                                        } else {
                                          showConfirmDialogTask(uid,
                                              _data['taskid'], _data['title']);
                                          return false;
                                        }
                                      },
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => TaskDetail(
                                                      taskDet: dataclass.Task(
                                                          taskid:
                                                              _data['taskid'],
                                                          title: _data['title'],
                                                          date_time: getDate(
                                                              _data[
                                                                  'date_time']),
                                                          reminder:
                                                              _data['reminder'],
                                                          desc: _data['desc'],
                                                          isdone: _data[
                                                              'isdone']))));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(18),
                                          decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: Alignment(1, -1),
                                                  end: Alignment(0, 0),
                                                  colors: [
                                                    Color.fromARGB(
                                                        255, 237, 233, 98),
                                                    Color.fromARGB(
                                                        255, 255, 255, 255)
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
                                                      const Color.fromARGB(
                                                          255, 71, 221, 0),
                                                  checkColor: Colors.white,
                                                  shape: CircleBorder(),
                                                  value: _data['isdone'],
                                                  onChanged: (_) {
                                                    final isdone = TaskService()
                                                        .toggleTodoStatus(
                                                            uid,
                                                            dataclass.Task(
                                                                taskid: _data[
                                                                    'taskid'],
                                                                title: _data[
                                                                    'title'],
                                                                date_time:
                                                                    getDate(_data[
                                                                        'date_time']),
                                                                reminder: _data[
                                                                    'reminder'],
                                                                desc: _data[
                                                                    'desc'],
                                                                isdone: _data[
                                                                    'isdone']));
                                                  }),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(_data['title'],
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          getDateText(_data[
                                                              'date_time']),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          178,
                                                                          0,
                                                                          0,
                                                                          0))),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                          getTimeText(_data[
                                                              'date_time']),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          178,
                                                                          0,
                                                                          0,
                                                                          0))),
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
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              return const Text('You have no task',
                                  style: TextStyle(color: Colors.grey));
                            }
                            return const Center(
                                child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ));
                          },
                        )),
                    // Text("Pending Task for Project"),
                  ],
                ),
              ),
            ),
    );
  }

  void getCurrentUser() async {
    user = await UserService.getUserFromFirestore();
    _taskDoneCount = await UserService.getTaskDoneCount();
    _taskPendingCount = await UserService.getTaskPendingCount();
    _projectDoneCount = await UserService.getProjectDoneCount();
    _projectPendingCount = await UserService.getProjectPendingCount();
    setState(() {
      _progressController = false;
    });
  }

  void getProgressForProjectTask() async {
    _progressList = await TaskforProjectServices.getProgress();
    setState(() {});
  }
}
