import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../dataclass.dart';
import '../dbservices.dart';
import 'ProjectDetail.dart';

class AllProjectPage extends StatefulWidget {
  const AllProjectPage({Key? key}) : super(key: key);

  @override
  State<AllProjectPage> createState() => _AllProjectPageState();
}

class _AllProjectPageState extends State<AllProjectPage>
    with SingleTickerProviderStateMixin {
  late String uid;
  int taskCount = 0;
  late TabController _tabController;

  late List<int> _progressList = [];

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    var curUser = FirebaseAuth.instance.currentUser;

    if (curUser != null) {
      uid = curUser.uid;
    }

    getProgressForProjectTask();
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
              'Projects',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
                        padding: const EdgeInsets.all(5),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: ProjectService().getData(uid, ""),
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
                                                        projectDet: Project(
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
                                      padding: const EdgeInsets.all(15),
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
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Icon(Icons.more_horiz),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // const Text("Progress",
                                            //     style: TextStyle(
                                            //         fontSize: 10,
                                            //         color: Color.fromARGB(
                                            //             255, 28, 84, 157))),
                                            // Text("${_progressList[index]}%",
                                            //     style: const TextStyle(
                                            //         fontSize: 10,
                                            //         color: Color.fromARGB(
                                            //             255, 28, 84, 157)))
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        // LinearPercentIndicator(
                                        //   padding: const EdgeInsets.all(0),
                                        //   lineHeight: 7,
                                        //   percent: _progressList[index] / 100,
                                        //   progressColor: const Color.fromARGB(
                                        //       255, 28, 84, 157),
                                        //   backgroundColor:
                                        //       const Color.fromARGB(40, 0, 0, 0),
                                        //   // linearStrokeCap: LinearStrokeCap.roundAll,
                                        //   barRadius: const Radius.circular(16),
                                        // ),
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
                                                    fontSize: 14,
                                                    color: Color.fromARGB(
                                                        200, 0, 0, 0)))
                                          ],
                                        ),
                                      ]),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 20.0),
                              ));
                            }
                            return const Center(
                              child: Text(
                                'No preview available',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            );
                          },
                        )),
          ],
        ),
      ),
    );
  }

  void getProgressForProjectTask() async {
    _progressList = await TaskforProjectServices.getProgress();
    setState(() {});

    for (var element in _progressList) {
      print(element);
    }
  }
}

class CircularTabIndicator extends Decoration {
  final Color color;
  double radius;

  CircularTabIndicator({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(color: color, radius: radius);
  }
}

class _CirclePainter extends BoxPainter {
  final double radius;
  late Color color;
  _CirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    late Paint _paint;
    _paint = Paint()..color = color;
    _paint = _paint..isAntiAlias = true;
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
