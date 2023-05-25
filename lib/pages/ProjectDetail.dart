import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuli/dataclass.dart';
import 'package:nuli/dbservices.dart';
import 'package:nuli/pages/edit_project.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProjectDetail extends StatefulWidget {
  Project projectDet;
  ProjectDetail({Key? key, required this.projectDet}) : super(key: key);

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  late String uid;
  late int pendingTaskCount = 0;
  late int progress = 0;

  String getDateText(DateTime dt) {
    DateFormat formatter = DateFormat('d MMMM y');
    String hasil = formatter.format(dt);
    return hasil;
  }

  void getPendingTaskCount() async {
    pendingTaskCount = await TaskforProjectServices.getPendingTask(
        widget.projectDet.projectid);
    setState(() {});
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
                        ProjectService.deleteData(uid, idDel);
                        Navigator.pushReplacementNamed(context, '/tabbarview');
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
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      uid = user.uid;
    }
    getPendingTaskCount();
    getProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 28, 84, 157),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Project Details",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.projectDet.title,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            widget.projectDet.isdone ? "Done" : "In progress",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                      CircularPercentIndicator(
                        radius: 42,
                        lineWidth: 12,
                        percent: progress / 100,
                        progressColor: const Color(0xFFFF5C00),
                        backgroundColor: const Color(0xFFBEC5CC),
                        circularStrokeCap: CircularStrokeCap.round,
                        center: Text(
                          '$progress%',
                          style: const TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ]),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 160,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Deadline",
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF9A9A9A)),
                              ),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  // color: Color(0xFFD9D9D9),
                                  gradient: LinearGradient(
                                      begin: Alignment(-1, -1),
                                      end: Alignment(1, 1),
                                      colors: [
                                        Color(0xFF55C8FA),
                                        Color(0xFFBCEAFE)
                                      ]),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            getDateText(widget.projectDet.deadline),
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 160,
                      padding: const EdgeInsets.all(20),
                      // margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Pending Task",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xFF9A9A9A)),
                              ),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment(-1, -1),
                                      end: Alignment(1, 1),
                                      colors: [
                                        Color(0xFFFA9955),
                                        Color(0xFFFFB636)
                                      ]),
                                ),
                                child: const Icon(
                                  Icons.file_copy_outlined,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            pendingTaskCount.toString(),
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Description",
                    style: TextStyle(fontSize: 17, color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.projectDet.desc,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("List of Task",
                      style: TextStyle(fontSize: 17, color: Colors.grey)),
                ),
                const SizedBox(
                  height: 20,
                ),
                //listview
                Container(
                    padding: const EdgeInsets.all(5),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: TaskforProjectServices()
                          .getData(uid, widget.projectDet.projectid, ""),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('ERROR');
                        } else if (snapshot.hasData || snapshot.data != null) {
                          return Container(
                              child: ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              // taskCount = snapshot.data!.docs.length;
                              DocumentSnapshot _data =
                                  snapshot.data!.docs[index];
                              if (_data['isdone'] == "true") {
                                return Container(
                                  // constraints: BoxConstraints(maxWidth: 270),
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment(1, -1),
                                          end: Alignment(-1, 1),
                                          colors: [
                                            Color.fromARGB(255, 250, 153, 85),
                                            Color.fromARGB(255, 255, 255, 255)
                                          ]),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                        )
                                      ],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                          activeColor: Colors.green,
                                          checkColor: Colors.white,
                                          shape: CircleBorder(),
                                          value: _data['isdone'],
                                          onChanged: (_) {
                                            final isdone =
                                                TaskforProjectServices()
                                                    .toggleTodoStatus(
                                              uid,
                                              widget.projectDet.projectid,
                                              TaskforProject(
                                                taskid: _data['taskid'],
                                                title: _data['title'],
                                                isdone: _data['isdone'],
                                              ),
                                            );
                                            setState(() async {
                                              getPendingTaskCount();
                                              getProgress();
                                            });
                                          }),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        _data['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container(
                                  // constraints: BoxConstraints(maxWidth: 270),
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment(1, -1),
                                          end: Alignment(-1, 1),
                                          colors: [
                                            Color.fromARGB(255, 250, 153, 85),
                                            Color.fromARGB(255, 255, 255, 255)
                                          ]),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                        )
                                      ],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                          activeColor: Colors.green,
                                          checkColor: Colors.white,
                                          shape: CircleBorder(),
                                          value: _data['isdone'],
                                          onChanged: (_) {
                                            final isdone =
                                                TaskforProjectServices()
                                                    .toggleTodoStatus(
                                                        uid,
                                                        widget.projectDet
                                                            .projectid,
                                                        TaskforProject(
                                                            taskid:
                                                                _data['taskid'],
                                                            title:
                                                                _data['title'],
                                                            isdone: _data[
                                                                'isdone']));

                                            setState(() async {
                                              getPendingTaskCount();
                                              getProgress();
                                            });
                                          }),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        _data['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 20.0),
                          ));
                        }
                        return const Center(
                          child: Text(
                            'No preview available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                      },
                    )),

                //edit button
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProjectPage(
                                    projectDet: widget.projectDet,
                                  )));
                    },
                    child: const Padding(
                        padding: EdgeInsets.all(15), child: Text('EDIT')),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(40),
                      primary: Colors.blue.shade900,
                      shadowColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                //delete button
                const SizedBox(
                  height: 18,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      showConfirmDialog(uid, widget.projectDet.projectid,
                          widget.projectDet.title);
                    },
                    child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text('DELETE',
                            style: TextStyle(
                              color: Colors.red,
                            ))),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      primary: Colors.white,
                      side: const BorderSide(color: Colors.red),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void getProgress() async {
    progress = await TaskforProjectServices.getProgressSingle(
        widget.projectDet.projectid);
    setState(() {
      print(progress);
    });
  }
}
