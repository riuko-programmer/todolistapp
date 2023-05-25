import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nuli/dataclass.dart' as dataclass;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:nuli/pages/profile.dart';
import 'dataclass.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class UserService {
  static final cloud_firestore.CollectionReference _userCollection =
      cloud_firestore.FirebaseFirestore.instance.collection('tblUser');
  static final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;
  static final FirebaseStorage _storage =
      FirebaseStorage.instanceFor(bucket: "gs://nuli-todolist.appspot.com");

  static firebase_auth.User? _userFromFirebase(firebase_auth.User? user) {
    if (user == null) {
      return null;
    }
    return user;
  }

  static Future signUp(
      {required String email,
      required String password,
      required String fullname,
      required BuildContext context}) async {
    var checkUser =
        await _userCollection.where('email', isEqualTo: email).get();
    if (checkUser.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User already exists'),
        ),
      );
      return null;
    }
    try {
      firebase_auth.UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      firebase_auth.User user = result.user!;
      storeUserToFirestore(
          user: dataclass.User(
        email: user.email!,
        fullname: fullname,
        uid: user.uid,
        photoUrl: "",
      ));
      return _userFromFirebase(user);
    } catch (e) {
      return null;
    }
  }

  static Future signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isLoggedIn() {
    firebase_auth.User? user = _auth.currentUser;
    if (user == null) {
      return false;
    }
    return true;
  }

  static String getCurrentUserID() {
    firebase_auth.User? user = _auth.currentUser;
    if (user == null) {
      return "";
    }
    return user.uid.toString();
  }

  static Future<void> storeUserToFirestore(
      {required dataclass.User user}) async {
    dataclass.User userData = dataclass.User(
      email: user.email,
      fullname: user.fullname,
      uid: user.uid,
      photoUrl: user.photoUrl,
    );
    cloud_firestore.DocumentReference userRef = _userCollection.doc(user.uid);

    await userRef.set(userData.toJson());
  }

  static Future<String> getDownloadUrl(String uid) async {
    var defaultStorageRef = _storage.ref().child("users/images/default.png");
    String url = await defaultStorageRef.getDownloadURL();
    var storageRef = _storage.ref().child("users/images/$uid.png");
    await storageRef.getDownloadURL().then((value) {
      if (value.isNotEmpty) {
        url = value;
      }
    }).catchError((e) {});
    return url;
  }

  static Future<dynamic> getUserFromFirestore() async {
    firebase_auth.User? user = _auth.currentUser;
    cloud_firestore.DocumentReference userRef = _userCollection.doc(user!.uid);
    dataclass.User userData = await userRef.get().then((value) =>
        dataclass.User.fromJson(value.data() as Map<String, dynamic>));

    String photoUrl = await getDownloadUrl(userData.uid);
    userData.photoUrl = photoUrl;

    // return user;
    return userData;
  }

  static Future<bool> verifyPassword(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> updateUserToFirestore(
      {required dataclass.User user}) async {
    cloud_firestore.DocumentReference userRef = _userCollection.doc(user.uid);
    await userRef.update(user.toJson());
  }

  static Future<String> uploadImage(String path) async {
    var user = _auth.currentUser;
    var storageRef = _storage.ref().child("users/images/${user!.uid}.png");
    storageRef
        .putFile(File(path))
        .whenComplete(() => storageRef.getDownloadURL());
    return "default.png";
  }

  static Future<bool> updatePassword(String email, String newpassword) async {
    var user = _auth.currentUser;
    bool result = await user!.updatePassword(newpassword).then((value) {
      return true;
    }).catchError((e) {
      return false;
    });
    return result;
  }

  static Future<int> getTaskDoneCount() async {
    var firstDayOfWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    var lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    var user = _auth.currentUser;
    try {
      QuerySnapshot tasksDone = await cloud_firestore.FirebaseFirestore.instance
          .collection("tblTask")
          .doc(user!.uid)
          .collection("myTasks")
          .where("isdone", isEqualTo: true)
          .get();
      return tasksDone.docs.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<int> getTaskPendingCount() async {
    var firstDayOfWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    var lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    var user = _auth.currentUser;
    try {
      QuerySnapshot tasksUndone = await cloud_firestore
          .FirebaseFirestore.instance
          .collection("tblTask")
          .doc(user!.uid)
          .collection("myTasks")
          .where("isdone", isEqualTo: false)
          .get();
      return tasksUndone.docs.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<int> getProjectDoneCount() async {
    // var firstDayOfWeek =
    //     DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    // var lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    var user = _auth.currentUser;
    try {
      QuerySnapshot projectsDone = await cloud_firestore
          .FirebaseFirestore.instance
          .collection("tblProject")
          .doc(user!.uid)
          .collection("myProjects")
          .where("isdone", isEqualTo: true)
          .get();
      return projectsDone.docs.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<int> getProjectPendingCount() async {
    // var firstDayOfWeek =
    //     DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    // var lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    var user = _auth.currentUser;
    try {
      QuerySnapshot projectsUndone = await cloud_firestore
          .FirebaseFirestore.instance
          .collection("tblProject")
          .doc(user!.uid)
          .collection("myProjects")
          .where("isdone", isEqualTo: false)
          .get();

      return projectsUndone.docs.length;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  static Future<int> getProjectProgress(String projectid) async {
    var user = _auth.currentUser;
    try {
      QuerySnapshot undoneTasks = await cloud_firestore
          .FirebaseFirestore.instance
          .collection("tblProject")
          .doc(user!.uid)
          .collection("myProjects")
          .doc(projectid)
          .collection("tasks")
          .where("isdone", isEqualTo: false)
          .get();

      int undoneTasksCount = undoneTasks.docs.length;

      QuerySnapshot allTasks = await cloud_firestore.FirebaseFirestore.instance
          .collection("tblProject")
          .doc(user.uid)
          .collection("myProjects")
          .doc(projectid)
          .collection("tasks")
          .get();

      int allTasksCount = allTasks.docs.length;

      int hasil = (undoneTasksCount / allTasksCount).round() * 100;

      return hasil;
    } catch (e) {
      return 0;
    }
  }

  static Future<List<ChartData>> getChartData() async {
    List<ChartData> chartData = [];
    var _user = _auth.currentUser;
    try {
      for (int i = 0; i < 7; i++) {
        var now = DateTime.now();
        var day = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: DateTime.now().weekday - 1))
            .add(Duration(days: i));
        QuerySnapshot tasks = await cloud_firestore.FirebaseFirestore.instance
            .collection("tblTask")
            .doc(_user!.uid)
            .collection("myTasks")
            .where("date_time", isGreaterThanOrEqualTo: day)
            .where("date_time", isLessThan: day.add(const Duration(days: 1)))
            .get();
        chartData.add(ChartData(i, tasks.docs.length));
      }
      return chartData;
    } catch (e) {
      return <ChartData>[
        ChartData(0, 0),
        ChartData(1, 0),
        ChartData(2, 0),
        ChartData(3, 0),
        ChartData(4, 0),
        ChartData(5, 0),
        ChartData(6, 0),
      ];
    }
  }
}

class TaskService {
  Stream<QuerySnapshot> getAllData(String uid, String judul) {
    final _taskCollection = FirebaseFirestore.instance
        .collection('tblTask')
        .doc(uid)
        .collection('myTasks');

    if (judul == "")
      return _taskCollection.snapshots();
    else
      return _taskCollection
          .orderBy("title")
          .startAt([judul]).endAt([judul + '\uf8ff']).snapshots();
  }

  Stream<QuerySnapshot> getData(String uid, String judul) {
    final _taskCollection = FirebaseFirestore.instance
        .collection('tblTask')
        .doc(uid)
        .collection('myTasks')
        .where('isdone', isEqualTo: false);

    if (judul == "")
      return _taskCollection.snapshots();
    else
      return _taskCollection
          .orderBy("title")
          .startAt([judul]).endAt([judul + '\uf8ff']).snapshots();
  }

  static Future<void> addData(String uid, dataclass.Task item) async {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblTask')
        .doc(uid)
        .collection('myTasks');

    DocumentReference docRef = _taskCollection.doc(item.taskid);

    await docRef
        .set(item.toJson())
        .whenComplete(() => print("Data berhasil ditambahkan"))
        .catchError((e) => print(e));

    NotificationServices.checkTasks(
        notifId: (item.date_time.microsecondsSinceEpoch ~/ 1000000));
  }

  bool toggleTodoStatus(String uid, dataclass.Task item) {
    item.isdone = !item.isdone;
    TaskService.editData(uid, item);
    NotificationServices.checkTasks(
        notifId: (item.date_time.microsecondsSinceEpoch ~/ 1000000));
    return item.isdone;
  }

  static Future<void> editData(String uid, dataclass.Task item) async {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblTask')
        .doc(uid)
        .collection('myTasks');

    DocumentReference docRef = _taskCollection.doc(item.taskid);

    await docRef
        .update(item.toJson())
        .whenComplete(() => print("Data berhasil diubah"))
        .catchError((e) => print(e));

    NotificationServices.checkTasks(
        notifId: (item.date_time.microsecondsSinceEpoch ~/ 1000000));
  }

  static Future<void> deleteData(String uid, String taskid) async {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblTask')
        .doc(uid)
        .collection('myTasks');

    DocumentReference docRef = _taskCollection.doc(taskid);
    var docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      NotificationServices.checkTasks(
          notifId:
              (data["date_time"].toDate().microsecondsSinceEpoch ~/ 1000000));
    }

    await docRef
        .delete()
        .whenComplete(() => print("Data berhasil dihapus"))
        .catchError((e) => print(e));
  }

  // void countDocuments() async {
  //   QuerySnapshot _myDoc = await FirebaseFirestore.instance.collection('product').doc();
  //   List<DocumentSnapshot> _myDocCount = _myDoc.documents;
  //   print(_myDocCount.length);  // Count of Documents in Collection
  // }

  static Future<int> countPendingTask(String uid, String projectid) async {
    final Query<Map<String, dynamic>> undoneTasks = FirebaseFirestore.instance
        .collection('tblTask')
        .doc(uid)
        .collection('myTasks')
        .where('isdone', isEqualTo: false);

    Future<int> undone = undoneTasks.snapshots().length;
    return undone;
  }
}

class ProjectService {
  Stream<QuerySnapshot> getData(String _uid, String judul) {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(_uid)
        .collection('myProjects');

    if (judul == "")
      return _taskCollection.snapshots();
    else
      return _taskCollection
          .orderBy("title")
          .startAt([judul]).endAt([judul + '\uf8ff']).snapshots();
  }

  Stream<QuerySnapshot> getDataDone(String _uid, String judul) {
    final _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(_uid)
        .collection('myProjects')
        .where('isdone', isEqualTo: true);

    if (judul == "")
      return _taskCollection.snapshots();
    else
      return _taskCollection
          .orderBy("title")
          .startAt([judul]).endAt([judul + '\uf8ff']).snapshots();
  }

  Stream<QuerySnapshot> getDataUndone(String _uid, String judul) {
    final _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(_uid)
        .collection('myProjects')
        .where('isdone', isEqualTo: false);

    if (judul == "")
      return _taskCollection.snapshots();
    else
      return _taskCollection
          .orderBy("title")
          .startAt([judul]).endAt([judul + '\uf8ff']).snapshots();
  }

  static Future<void> addData(String uid, Project item) async {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(uid)
        .collection('myProjects');

    DocumentReference docRef = _taskCollection.doc(item.projectid);

    await docRef
        .set(item.toJson())
        .whenComplete(() => print("Data berhasil ditambahkan"))
        .catchError((e) => print(e));

    NotificationServices.checkProjects(
        notifId: item.deadline.microsecondsSinceEpoch ~/ 10000000);
  }

  static Future<void> editData(String uid, dataclass.Project item) async {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(uid)
        .collection('myProjects');

    DocumentReference docRef = _taskCollection.doc(item.projectid);

    await docRef
        .update(item.toJson())
        .whenComplete(() => print("Data berhasil diubah"))
        .catchError((e) => print(e));

    NotificationServices.checkProjects(
        notifId: item.deadline.microsecondsSinceEpoch ~/ 10000000);
  }

  static Future<void> deleteData(String uid, String projectid) async {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(uid)
        .collection('myProjects');

    DocumentReference docRef = _taskCollection.doc(projectid);
    var docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      NotificationServices.checkTasks(
          notifId:
              (data["deadline"].toDate().microsecondsSinceEpoch ~/ 1000000));
    }

    await docRef
        .delete()
        .whenComplete(() => print("Data berhasil dihapus"))
        .catchError((e) => print(e));
  }
}

class TaskforProjectServices {
  static Future<bool> movePendingTask(dataclass.Project project) async {
    var _user = FirebaseAuth.instance.currentUser;

    List<dataclass.TaskforProject> _tasks = await cloud_firestore
        .FirebaseFirestore.instance
        .collection('tblProject')
        .doc(_user!.uid)
        .collection('myProjects')
        .doc(project.projectid)
        .collection('tasks')
        .where('isdone', isEqualTo: false)
        .get()
        .then((value) => value.docs
            .map((e) => dataclass.TaskforProject.fromJson(e.data()))
            .toList());

    for (var task in _tasks) {
      dataclass.Task newdata = dataclass.Task(
        taskid: task.taskid,
        title: task.title,
        desc: project.desc,
        date_time: project.deadline,
        isdone: false,
        reminder: project.reminder,
      );
      await cloud_firestore.FirebaseFirestore.instance
          .collection('tblTask')
          .doc(_user.uid)
          .collection('myTasks')
          .doc(task.taskid)
          .set(newdata.toJson())
          .catchError((e) => false);
    }
    return true;
  }

  Stream<QuerySnapshot> getData(String _uid, String projectid, String judul) {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(_uid)
        .collection('myProjects')
        .doc(projectid)
        .collection('tasks');

    if (judul == "") {
      return _taskCollection.snapshots();
    } else {
      return _taskCollection
          .orderBy("title")
          .startAt([judul]).endAt([judul + '\uf8ff']).snapshots();
    }
  }

  Stream<QuerySnapshot> getData2(String _uid, String projectid, String judul) {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(_uid)
        .collection('myProjects')
        .doc(projectid)
        .collection('tasks');

    if (judul == "") {
      return _taskCollection.snapshots();
    } else {
      return _taskCollection
          .orderBy("title")
          .startAt([judul]).endAt([judul + '\uf8ff']).snapshots();
    }
  }

  Stream<QuerySnapshot> getDataUndone(
      String _uid, String projectid, String judul) {
    final _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(_uid)
        .collection('myProjects')
        .doc(projectid)
        .collection('tasks')
        .where('isdone', isEqualTo: false);

    if (judul == "") {
      return _taskCollection.snapshots();
    } else {
      return _taskCollection
          .orderBy("title")
          .startAt([judul]).endAt([judul + '\uf8ff']).snapshots();
    }
  }

  static Future<void> addData(
      String uid, String projectid, dataclass.TaskforProject item) async {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(uid)
        .collection('myProjects')
        .doc(projectid)
        .collection('tasks');

    DocumentReference docRef = _taskCollection.doc(item.taskid);

    await docRef
        .set(item.toJson())
        .whenComplete(() => print("Data berhasil ditambahkan"))
        .catchError((e) => print(e));
  }

  static Future<List<int>> getProgress() async {
    var _user = firebase_auth.FirebaseAuth.instance.currentUser;

    List<int> _progress = [];

    try {
      List<dataclass.Project> _projects = await cloud_firestore
          .FirebaseFirestore.instance
          .collection('tblProject')
          .doc(_user!.uid)
          .collection('myProjects')
          .where('isdone', isEqualTo: false)
          .get()
          .then((value) => value.docs
              .map(
                (doc) => dataclass.Project(
                  projectid: doc.id,
                  title: doc.data()['title'] as String,
                  desc: doc.data()['desc'] as String,
                  deadline: doc.data()['deadline'].toDate(),
                  isdone: doc.data()['isdone'] as bool,
                  reminder: doc.data()['reminder'] as String,
                ),
              )
              .toList());

      for (dataclass.Project project in _projects) {
        List<dataclass.TaskforProject> _tasks = await cloud_firestore
            .FirebaseFirestore.instance
            .collection('tblProject')
            .doc(_user.uid)
            .collection('myProjects')
            .doc(project.projectid)
            .collection('tasks')
            .get()
            .then((value) => value.docs
                .map((doc) => dataclass.TaskforProject.fromJson(doc.data()))
                .toList());

        int progress = 0;
        int total = 0;
        for (TaskforProject task in _tasks) {
          if (task.isdone) {
            progress++;
          }
          total++;
        }
        if (progress == total) {
          await cloud_firestore.FirebaseFirestore.instance
              .collection('tblProject')
              .doc(_user.uid)
              .collection('myProjects')
              .doc(project.projectid)
              .update({'isdone': true});
        }
        try {
          _progress.add((progress / total * 100).round());
        } catch (e) {
          _progress.add(0);
        }
      }
    } catch (e) {
      print(e);
    }

    return _progress;
  }

  static Future<int> getProgressSingle(String projectId) async {
    var _user = firebase_auth.FirebaseAuth.instance.currentUser;

    List<dataclass.TaskforProject> _tasks = await cloud_firestore
        .FirebaseFirestore.instance
        .collection('tblProject')
        .doc(_user!.uid)
        .collection('myProjects')
        .doc(projectId)
        .collection('tasks')
        .get()
        .then((value) => value.docs
            .map((doc) => dataclass.TaskforProject.fromJson(doc.data()))
            .toList());

    int progress = 0;
    int total = 0;
    for (TaskforProject task in _tasks) {
      if (task.isdone) {
        progress++;
      }
      total++;
    }
    if (progress == total) {
      await cloud_firestore.FirebaseFirestore.instance
          .collection('tblProject')
          .doc(_user.uid)
          .collection('myProjects')
          .doc(projectId)
          .update({'isdone': true});
    }
    try {
      return (progress / total * 100).round();
    } catch (e) {
      return 0;
    }
  }

  static Future<int> getPendingTask(String projectId) async {
    var _user = firebase_auth.FirebaseAuth.instance.currentUser;
    QuerySnapshot undoneTasks = await FirebaseFirestore.instance
        .collection('tblProject')
        .doc(_user!.uid)
        .collection('myProjects')
        .doc(projectId)
        .collection('tasks')
        .where('isdone', isEqualTo: false)
        .get();

    return undoneTasks.docs.length;
  }

  bool toggleTodoStatus(
      String uid, String projectid, dataclass.TaskforProject item) {
    item.isdone = !item.isdone;
    TaskforProjectServices.editData(uid, projectid, item);

    return item.isdone;
  }

  static Future<void> editData(
      String uid, String projectid, dataclass.TaskforProject item) async {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(uid)
        .collection('myProjects')
        .doc(projectid)
        .collection('tasks');

    DocumentReference docRef = _taskCollection.doc(item.taskid);

    await docRef
        .update(item.toJson())
        .whenComplete(() => print("Data berhasil diubah"))
        .catchError((e) => print(e));
  }

  static Future<void> deleteData(
      String uid, String projectid, String taskid) async {
    final CollectionReference _taskCollection = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(uid)
        .collection('myProjects')
        .doc(projectid)
        .collection('tasks');

    DocumentReference docRef = _taskCollection.doc(taskid);

    await docRef
        .delete()
        .whenComplete(() => print("Data berhasil dihapus"))
        .catchError((e) => print(e));
  }

  // Future<int> countProgress(String uid, String projectid) async {
  //   final Query<Map<String, dynamic>> undoneTasks = FirebaseFirestore.instance
  //       .collection('tblProject')
  //       .doc(uid)
  //       .collection('myProjects')
  //       .doc(projectid)
  //       .collection('tasks')
  //       .where('isdone', isEqualTo: false);

  //   Future<int> undone = undoneTasks.snapshots().length;

  //   final Query<Map<String, dynamic>> doneTasks = FirebaseFirestore.instance
  //       .collection('tblProject')
  //       .doc(uid)
  //       .collection('myProjects')
  //       .doc(projectid)
  //       .collection('tasks')
  //       .where('isdone', isEqualTo: false);

  //   Future<int> done = doneTasks.snapshots().length;

  //   int progress = (undone / done) * 100.round();
  // }

  static Future<int> countPendingTask(String uid, String projectid) async {
    final Query<Map<String, dynamic>> undoneTasks = FirebaseFirestore.instance
        .collection('tblProject')
        .doc(uid)
        .collection('myProjects')
        .doc(projectid)
        .collection('tasks')
        .where('isdone', isEqualTo: false);

    Future<int> undone = undoneTasks.snapshots().length;
    return undone;
  }
}

class NotificationServices {
  static Future<void> checkTasks({int notifId = 0}) async {
    AwesomeNotifications().cancel(notifId);
    var now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    var user = firebase_auth.FirebaseAuth.instance.currentUser;
    try {
      List<dataclass.Task> tasksUndone = await cloud_firestore
          .FirebaseFirestore.instance
          .collection("tblTask")
          .doc(user!.uid)
          .collection("myTasks")
          .where("isdone", isEqualTo: false)
          .where("date_time", isGreaterThanOrEqualTo: day)
          .where("date_time", isLessThan: day.add(const Duration(days: 2)))
          .get()
          .then((value) => value.docs
              .map(
                (doc) => dataclass.Task(
                  date_time: doc.data()['date_time'].toDate(),
                  isdone: doc.data()['isdone'],
                  title: doc.data()['title'],
                  taskid: doc.data()['taskid'],
                  desc: doc.data()['desc'],
                  reminder: doc.data()['reminder'],
                ),
              )
              .toList());
      for (var task in tasksUndone) {
        var taskDate = task.date_time;
        bool noReminder = false;
        var reminder = taskDate;
        switch (task.reminder) {
          case "5 mins before":
            reminder = taskDate.subtract(const Duration(minutes: 5));
            break;
          case "15 mins before":
            reminder = taskDate.subtract(const Duration(minutes: 15));
            break;
          case "1 hour before":
            reminder = taskDate.subtract(const Duration(hours: 1));
            break;
          case "1 day before":
            reminder = taskDate.subtract(const Duration(days: 1));
            break;
          case "No Reminder":
            noReminder = true;
            break;
          default:
        }

        if (!noReminder) {
          int diff = reminder.difference(DateTime.now()).inSeconds;
          if (diff < 0) {
            continue;
          }
          int secId = taskDate.microsecondsSinceEpoch ~/ 1000000;
          String due = () {
            if (taskDate.day == DateTime.now().day) {
              return "Today";
            } else if (taskDate.day == DateTime.now().day + 1) {
              return "Tomorrow";
            } else {
              return taskDate.day.toString();
            }
          }();
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: secId,
              channelKey: 'task_channel',
              title: 'Task Reminder',
              body:
                  'Your task "${task.title}" is due at $due, ${taskDate.hour}:${taskDate.minute}',
            ),
            schedule: NotificationInterval(
              interval: diff,
              timeZone: 'Asia/Jakarta',
              preciseAlarm: true,
            ),
          );
        }
      }
    } catch (e) {
      return;
    }
  }

  static Future<void> checkProjects({int notifId = 0}) async {
    AwesomeNotifications().cancel(notifId);
    var now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    var user = firebase_auth.FirebaseAuth.instance.currentUser;
    try {
      List<dataclass.Project> projects = await cloud_firestore
          .FirebaseFirestore.instance
          .collection("tblProject")
          .doc(user!.uid)
          .collection("myProjects")
          .where("isdone", isEqualTo: false)
          .where("deadline", isGreaterThanOrEqualTo: day)
          .where("deadline", isLessThan: day.add(const Duration(days: 2)))
          .get()
          .then((value) => value.docs
              .map(
                (doc) => dataclass.Project(
                  deadline: doc.data()['date_time'].toDate(),
                  isdone: doc.data()['isdone'],
                  title: doc.data()['title'],
                  projectid: doc.data()['taskid'],
                  desc: doc.data()['desc'],
                  reminder: doc.data()['reminder'],
                ),
              )
              .toList());
      for (var project in projects) {
        var projectDate = project.deadline;
        bool noReminder = false;
        var reminder = projectDate;
        switch (project.reminder) {
          case "5 mins before":
            reminder = projectDate.subtract(const Duration(minutes: 5));
            break;
          case "15 mins before":
            reminder = projectDate.subtract(const Duration(minutes: 15));
            break;
          case "1 hour before":
            reminder = projectDate.subtract(const Duration(hours: 1));
            break;
          case "1 day before":
            reminder = projectDate.subtract(const Duration(days: 1));
            break;
          case "No Reminder":
            noReminder = true;
            break;
          default:
        }

        if (!noReminder) {
          int diff = reminder.difference(DateTime.now()).inSeconds;
          if (diff < 0) {
            continue;
          }
          int secId = projectDate.microsecondsSinceEpoch ~/ 10000000;
          String due = () {
            if (projectDate.day == DateTime.now().day) {
              return "Today";
            } else if (projectDate.day == DateTime.now().day + 1) {
              return "Tomorrow";
            } else {
              return projectDate.day.toString();
            }
          }();
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: secId,
              channelKey: 'project_channel',
              title: 'Project Reminder',
              body:
                  'Your project "${project.title}" is due at $due, ${projectDate.hour}:${projectDate.minute}',
            ),
            schedule: NotificationInterval(
              interval: diff,
              timeZone: 'Asia/Jakarta',
              preciseAlarm: true,
            ),
          );
        }
      }
    } catch (e) {
      return;
    }
  }
}
