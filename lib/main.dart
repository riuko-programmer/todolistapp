import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nuli/dbservices.dart';
import 'package:nuli/pages/NotificationPage.dart';
import 'package:nuli/pages/SplashScreen.dart';
import 'package:nuli/pages/WelcomePage2.dart';
import 'package:nuli/pages/SignUpScreen.dart';
import 'package:nuli/pages/WelcomeScreen.dart';
import 'package:nuli/pages/LoginScreen.dart';
import 'package:nuli/pages/add_project.dart';
import 'package:nuli/pages/add_task.dart';
import 'package:nuli/pages/all_projects.dart';
import 'package:nuli/pages/home.dart';
import 'package:nuli/pages/tabbarview.dart';
import 'package:nuli/pages/profile.dart';
import 'package:nuli/temp.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: 'task_channel_group',
        channelKey: 'task_channel',
        channelName: 'Task notifications',
        channelDescription: 'Notification Channel to check tasks',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelGroupKey: 'project_channel_group',
        channelKey: 'project_channel',
        channelName: 'Project notifications',
        channelDescription: 'Notification Channel to check projects',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ],
    // Channel groups are only visual and are not required
    channelGroups: [
      NotificationChannelGroup(
          channelGroupkey: 'basic_channel_group',
          channelGroupName: 'Basic group')
    ],
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    try {
      AwesomeNotifications()
          .actionStream
          .listen((ReceivedNotification receivedNotification) {
        Navigator.of(context)
            .pushNamed('/tabbarview', arguments: receivedNotification);
      });
    } catch (e) {
      print(e);
    }
    checkNotification();
    return MaterialApp(
      title: "NULI - Productive App",
      debugShowCheckedModeBanner: false,
      initialRoute: UserService.isLoggedIn() ? '/tabbarview' : '/welcome',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/welcome2': (context) => const WelcomePage2(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const Profile(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/temppage': (context) => const TempPage(),
        '/tabbarview': (context) => const TabBarView1(),
        '/add_task': (context) => const AddTaskPage(),
        '/add_project': (context) => const AddProjectPage(),
        '/notif_testing': (context) => const NotificationPage(),
        '/allprojects': (context) => const AllProjectPage(),
      },
    );
  }

  void checkNotification() async {
    await NotificationServices.checkTasks();
    await NotificationServices.checkProjects();
  }
}
