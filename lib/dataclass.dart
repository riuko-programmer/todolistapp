import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String fullname;
  final String uid;
  late String photoUrl;

  User({
    required this.email,
    required this.fullname,
    required this.uid,
    required this.photoUrl,
  });

  String get firstName => fullname.split(' ')[0];
  String get lastName => fullname.substring(fullname.indexOf(' ') + 1);

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullname': fullname,
        'uid': uid,
        'photoUrl': photoUrl,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json['email'],
        fullname: json['fullname'],
        uid: json['uid'],
        photoUrl: json['photoUrl'],
      );
}

class Task {
  String taskid;
  String title;
  DateTime date_time;
  String reminder;
  String desc;
  bool isdone;

  Task(
      {required this.taskid,
      required this.title,
      required this.date_time,
      required this.reminder,
      required this.desc,
      required this.isdone});

  Map<String, dynamic> toJson() => {
        'taskid': taskid,
        'title': title,
        'date_time': Timestamp.fromMillisecondsSinceEpoch(
            date_time.millisecondsSinceEpoch),
        'reminder': reminder,
        'desc': desc,
        'isdone': isdone
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        taskid: json['taskid'],
        title: json['title'],
        date_time: json['date_time'],
        reminder: json['reminder'],
        desc: json['desc'],
        isdone: json['isdone']);
  }
}

class Project {
  String projectid;
  String title;
  DateTime deadline;
  String desc;
  bool isdone;
  String reminder;

  Project(
      {required this.projectid,
      required this.title,
      required this.deadline,
      required this.desc,
      required this.isdone,
      required this.reminder});

  Map<String, dynamic> toJson() => {
        'projectid': projectid,
        'title': title,
        'deadline': Timestamp.fromMillisecondsSinceEpoch(
            deadline.millisecondsSinceEpoch),
        'reminder': reminder,
        'desc': desc,
        'isdone': isdone
      };

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
        projectid: json['projectid'],
        title: json['title'],
        deadline: json['deadline'],
        reminder: json['reminder'],
        desc: json['desc'],
        isdone: json['isdone']);
  }
}

class TaskforProject {
  String taskid;
  String title;
  bool isdone;

  TaskforProject(
      {required this.taskid, required this.title, required this.isdone});

  Map<String, dynamic> toJson() =>
      {'taskid': taskid, 'title': title, 'isdone': isdone};

  factory TaskforProject.fromJson(Map<String, dynamic> json) {
    return TaskforProject(
        taskid: json['taskid'], title: json['title'], isdone: json['isdone']);
  }
}
