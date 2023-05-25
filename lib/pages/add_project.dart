import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuli/dataclass.dart';
import 'package:nuli/pages/tabbarview.dart';

import '../dbservices.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({Key? key}) : super(key: key);

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  late String uid;

  static DateTime date = DateTime.now();
  static DateFormat formatter = DateFormat('d MMMM y');
  String curDate = formatter.format(date);

  TextEditingController _projectTitleCtrl = TextEditingController();
  TextEditingController _projectDescCtrl = TextEditingController();

  String reminderChosen = "1 day before";
  List listReminderOption = ["1 day before", "No Reminder"];

  List<TextEditingController> _taskCtrl = [];
  List<TextField> _textFields = [];

  int undoneTaskCount = 0;

  @override
  void initState() {
    super.initState();
    _projectTitleCtrl = TextEditingController();
    _projectDescCtrl = TextEditingController();

    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
    }
  }

  @override
  void dispose() {
    for (final controller in _taskCtrl) {
      controller.dispose();
    }
    super.dispose();
    _projectTitleCtrl.dispose();
  }

  Widget _addToDoWidget() {
    return ListTile(
      leading: const Icon(Icons.add),
      title: const Text(
        'Add to do',
        style: TextStyle(color: Color.fromARGB(120, 0, 0, 0), fontSize: 14),
      ),
      onTap: () {
        final _controller = TextEditingController();
        final _field = TextField(
          autofocus: true,
          controller: _controller,
          decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: "To do"),
        );

        setState(() {
          _taskCtrl.add(_controller);
          _textFields.add(_field);
        });
      },
    );
  }

  Widget _listView() {
    return ListView.builder(
        itemCount: _textFields.length,
        itemBuilder: (context, index) {
          return Container(
            child: _textFields[index],
          );
        });
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
          "Create a new project",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // const SizedBox(height: 20,),
                TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                    hintText: "Write project title here",
                  ),
                  cursorColor: const Color.fromRGBO(0, 0, 0, 0.4),
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  controller: _projectTitleCtrl,
                ),
                const SizedBox(
                  height: 20,
                ),
                ////////////////////////////// Deadline
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            begin: Alignment(-1, -1),
                            end: Alignment(1, 1),
                            colors: [
                              Color.fromARGB(255, 242, 116, 112),
                              Color.fromARGB(255, 255, 201, 201)
                            ]),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        size: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Deadline",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(120, 0, 0, 0)),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            primary: Colors.black,
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () async {
                            DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100));
                            if (newDate == null) {
                              return;
                            }
                            setState(() {
                              date = newDate;
                              formatter = DateFormat('d MMMM y');
                              curDate = formatter.format(date);
                            });
                          },
                          child: Text(curDate),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ////////////////////////////// Reminder
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            begin: Alignment(-1, -1),
                            end: Alignment(1, 1),
                            colors: [
                              Color.fromARGB(255, 250, 153, 85),
                              Color.fromARGB(255, 255, 243, 201)
                            ]),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        size: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Reminder",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(120, 0, 0, 0)),
                        ),
                        SizedBox(
                          width: 250,
                          child: DropdownButton(
                            underline: Container(),
                            onChanged: (newValue) {
                              setState(() {
                                reminderChosen = newValue.toString();
                              });
                            },
                            value: reminderChosen,
                            isExpanded: true,
                            items: listReminderOption
                                .map((item) => DropdownMenuItem<String>(
                                    value: item, child: Text(item)))
                                .toList(),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                ////////////////////////////// Description
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            begin: Alignment(-1, -1),
                            end: Alignment(1, 1),
                            colors: [
                              Color.fromARGB(255, 242, 116, 112),
                              Color.fromARGB(255, 255, 201, 201)
                            ]),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(120, 0, 0, 0)),
                        ),
                        SizedBox(
                          width: 250,
                          child: TextField(
                            cursorColor: const Color.fromRGBO(0, 0, 0, 0.4),
                            controller: _projectDescCtrl,
                            decoration: const InputDecoration(
                              hintText: "(Optional)",
                              hintStyle: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 16),
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(120, 0, 0, 0))),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(200, 0, 0, 0))),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(120, 0, 0, 0))),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),

                _addToDoWidget(),
                Expanded(child: _listView()),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "SAVE",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade900,
                    shadowColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () async {
                    DateTime now = DateTime.now();
                    String formattedDate =
                        DateFormat('MM-dd-yyyy HH:mm:ss').format(now);

                    String projectid =
                        _projectTitleCtrl.text.toString() + ' ' + formattedDate;

                    if (_projectTitleCtrl.text.isNotEmpty) {
                      if (_textFields.length > 0) {
                        List<Map> convertedTask = [];
                        _taskCtrl.forEach((element) {
                          if (element.text.isNotEmpty) {
                            String taskid =
                                element.text.toString() + ' ' + formattedDate;
                            TaskforProject newTask = TaskforProject(
                                taskid: taskid,
                                title: element.text.toString(),
                                isdone: false);
                            TaskforProjectServices.addData(
                                uid, projectid, newTask);
                            undoneTaskCount++;
                          }
                        });
                      }

                      DateTime dateTime =
                          DateTime(date.year, date.month, date.day);
                      // Timestamp ts = Timestamp.fromMillisecondsSinceEpoch(
                      //     dateTime.millisecondsSinceEpoch);

                      Project newProject = Project(
                          projectid: projectid,
                          title: _projectTitleCtrl.text.toString(),
                          deadline: dateTime,
                          desc: _projectDescCtrl.text.toString(),
                          isdone: false,
                          reminder: reminderChosen);
                      ProjectService.addData(uid, newProject);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Project created"),
                      ));
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const TabBarView1()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("You must fill in project title"),
                      ));
                    }
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
