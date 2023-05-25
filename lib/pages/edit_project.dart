import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuli/dataclass.dart';

import '../dbservices.dart';

class EditProjectPage extends StatefulWidget {
  Project projectDet;
  EditProjectPage({Key? key, required this.projectDet}) : super(key: key);

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  late String uid;

  late DateTime date;
  static DateFormat formatter = DateFormat('d MMMM y');
  late String curDate = formatter.format(date);

  TextEditingController _projectTitleCtrl = TextEditingController();
  TextEditingController _projectDescCtrl = TextEditingController();

  late String reminderChosen;
  List listReminderOption = [
    "5 mins before",
    "15 mins before",
    "1 hour before",
    "1 day before",
    "No Reminder"
  ];

  List<TextEditingController> _taskCtrl = [];
  List<TextField> _textFields = [];

  int undoneTaskCount = 0;

  TextEditingController _taskTitleCtrl = TextEditingController();
  TextEditingController _editTaskCtrl = TextEditingController();

  Future showDialogAdd(String uid, String projectid) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Add task to your project'),
            content: TextField(
              autofocus: true,
              controller: _taskTitleCtrl,
              decoration: InputDecoration(hintText: 'Task title'),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    if (_taskTitleCtrl.text.isNotEmpty) {
                      DateTime now = DateTime.now();
                      String formattedDate =
                          DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
                      String taskid =
                          _taskTitleCtrl.text.toString() + ' ' + formattedDate;
                      TaskforProject newTask = TaskforProject(
                          taskid: taskid,
                          title: _taskTitleCtrl.text.toString(),
                          isdone: false);
                      TaskforProjectServices.addData(uid, projectid, newTask);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))
            ],
          ));

  void setEditTextCtrl(String tasktitle) {
    _editTaskCtrl.text = tasktitle;
  }

  Future showDialogEdit(String uid, String projectid, TaskforProject item) =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Add task to your project'),
                content: TextFormField(
                  autofocus: true,
                  controller: _editTaskCtrl,
                  decoration: const InputDecoration(hintText: 'Task title'),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        if (_editTaskCtrl.text.isNotEmpty) {
                          TaskforProject newTask = TaskforProject(
                              taskid: item.taskid,
                              title: _editTaskCtrl.text.toString(),
                              isdone: item.isdone);
                          TaskforProjectServices.editData(
                              uid, projectid, newTask);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ],
              ));

  Future showConfirmDialog(
          String uid, String idProject, String idDel, String titleDel) =>
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
                        TaskforProjectServices.deleteData(
                            uid, idProject, idDel);
                        Navigator.of(context).pop();
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
    _projectTitleCtrl = TextEditingController();
    _projectDescCtrl = TextEditingController();
    _taskTitleCtrl = TextEditingController();
    _editTaskCtrl = TextEditingController();

    _projectTitleCtrl.text = widget.projectDet.title;
    _projectDescCtrl.text = widget.projectDet.desc;
    date = widget.projectDet.deadline;
    reminderChosen = widget.projectDet.reminder;

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
    _projectDescCtrl.dispose();
    _taskTitleCtrl.dispose();
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
          "Edit project",
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
                // const Text(
                //   "Add task",
                //   style: TextStyle(
                //       fontSize: 14, color: Color.fromARGB(190, 0, 0, 0)),
                // ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text(
                    'Add task',
                    style: TextStyle(
                        color: Color.fromARGB(120, 0, 0, 0), fontSize: 14),
                  ),
                  onTap: () {
                    // show dialog box
                    showDialogAdd(uid, widget.projectDet.projectid);
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: TaskforProjectServices()
                        .getData(uid, widget.projectDet.projectid, ""),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Expanded(
                          child: ListView.separated(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 20.0),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot _data =
                                    snapshot.data!.docs[index];

                                return Dismissible(
                                  key: Key(_data['taskid']),
                                  background: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    alignment: Alignment.centerLeft,
                                    color: Colors.green,
                                    child: const Text(
                                      "Done",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  secondaryBackground: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 10, 0),
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
                                      final isdone = TaskforProjectServices()
                                          .toggleTodoStatus(
                                              uid,
                                              widget.projectDet.projectid,
                                              TaskforProject(
                                                  taskid: _data['taskid'],
                                                  title: _data['title'],
                                                  isdone: _data['isdone']));
                                      return false;
                                    } else {
                                      showConfirmDialog(
                                          uid,
                                          widget.projectDet.projectid,
                                          _data['taskid'],
                                          _data['title']);
                                      return false;
                                    }
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      setEditTextCtrl(_data['title']);
                                      showDialogEdit(
                                          uid,
                                          widget.projectDet.projectid,
                                          TaskforProject(
                                              taskid: _data['taskid'],
                                              title: _data['title'],
                                              isdone: _data['isdone']));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment(-1, 1),
                                              end: Alignment(1, -1),
                                              colors: [
                                                Color(0xFFFA9955),
                                                Color(0xFFFFB636)
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                                taskid: _data[
                                                                    'taskid'],
                                                                title: _data[
                                                                    'title'],
                                                                isdone: _data[
                                                                    'isdone']));
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
                                    ),
                                  ),
                                );
                              }),
                        );
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text(
                          'No task',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return const Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ));
                    }),
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
                    String projectid = widget.projectDet.projectid;

                    if (_projectTitleCtrl.text.isNotEmpty) {
                      // if (_textFields.length > 0) {
                      //   List<Map> convertedTask = [];
                      //   _taskCtrl.forEach((element) {
                      //     if (element.text.isNotEmpty) {
                      //       String taskid =
                      //           element.text.toString() + ' ' + formattedDate;
                      //       TaskforProject newTask = TaskforProject(
                      //           taskid: taskid,
                      //           title: element.text.toString(),
                      //           isdone: false);
                      //       TaskforProjectServices.addData(
                      //           uid, projectid, newTask);
                      //       undoneTaskCount++;
                      //     }
                      //   });
                      // }

                      DateTime dateTime =
                          DateTime(date.year, date.month, date.day);

                      Project newProject = Project(
                          projectid: projectid,
                          title: _projectTitleCtrl.text.toString(),
                          deadline: dateTime,
                          desc: _projectDescCtrl.text.toString(),
                          isdone: false,
                          reminder: reminderChosen);
                      ProjectService.editData(uid, newProject);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Changes saved"),
                      ));
                      Navigator.pushReplacementNamed(context, '/tabbarview');
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
