import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:nuli/dbservices.dart';

import '../dataclass.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  static DateTime date = DateTime.now();
  static DateFormat formatter = DateFormat('d MMMM y');
  String curDate = formatter.format(date);

  TextEditingController _taskTitleCtrl = TextEditingController();
  TextEditingController _taskDescCtrl = TextEditingController();

  TimeOfDay time = TimeOfDay(hour: 9, minute: 0);

  late String uid;

  String reminderChosen = "1 hour before";
  List listReminderOption = [
    "5 mins before",
    "15 mins before",
    "1 hour before",
    "1 day before",
    "No Reminder"
  ];

  String getTimerText() {
    if (time == null) {
      return 'Select time';
    } else {
      var hours = time.hour.toString();
      if (time.hour < 10) {
        hours = time.hour.toString().padLeft(2, '0');
      }
      var minutes = time.minute.toString();
      if (time.minute < 10) {
        minutes = time.minute.toString().padLeft(2, '0');
      }
      return ('${hours}:${minutes}');
    }
  }

  Timestamp _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromMillisecondsSinceEpoch(
        dateTime.millisecondsSinceEpoch);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _taskTitleCtrl = TextEditingController();
    _taskDescCtrl = TextEditingController();

    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
    }
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
            "Create a new task",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                // const SizedBox(height: 20,),
                TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                    hintText: "Write task title here",
                  ),
                  cursorColor: const Color.fromRGBO(0, 0, 0, 0.4),
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  controller: _taskTitleCtrl,
                ),
                const SizedBox(
                  height: 20,
                ),
                ////////////////////////////// Date
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
                          "Date",
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
                ////////////////////////////// Time
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
                              Color.fromARGB(255, 250, 153, 85),
                              Color.fromARGB(255, 255, 243, 201)
                            ]),
                      ),
                      child: const Icon(
                        Icons.access_time,
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
                          "Time",
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
                            final newTime = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );
                            if (newTime == null) return;
                            setState(() {
                              time = newTime;
                            });
                          },
                          child: Text(getTimerText()),
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
                              Color.fromARGB(255, 242, 116, 112),
                              Color.fromARGB(255, 255, 201, 201)
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
                              Color.fromARGB(255, 250, 153, 85),
                              Color.fromARGB(255, 255, 243, 201)
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
                            controller: _taskDescCtrl,
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
                SizedBox(
                  height: 25,
                ),
                ////////////////////// Save Button
                ElevatedButton(
                  onPressed: () {
                    if (_taskTitleCtrl.text.isNotEmpty) {
                      DateTime dateTime = DateTime(date.year, date.month,
                          date.day, time.hour, time.minute);

                      DateTime now = DateTime.now();
                      String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
                      
                      String taskid = _taskTitleCtrl.text.toString()+' '+formattedDate;
                      
                      Task newTask = Task(
                          taskid: taskid,
                          title: _taskTitleCtrl.text.toString(),
                          date_time: dateTime,
                          desc: _taskDescCtrl.text.toString(),
                          reminder: reminderChosen,
                          isdone: false);
                      TaskService.addData(uid, newTask);
                      Navigator.pushReplacementNamed(context, '/tabbarview');
                    } else {
                      const snackBar = SnackBar(
                        content: Text('You should fill the task title'),
                      );
                    }
                  },
                  child: Text('SAVE'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade900,
                    shadowColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                )
              ]),
            ),
          ),
        ));
  }
}
