// import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:nuli/dbservices.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../dataclass.dart';
import 'EditProfile.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _progressController = true;
  late User user;
  int _taskDoneCount = 0;
  int _taskPendingCount = 0;
  int _projectDoneCount = 0;
  int _projectPendingCount = 0;
  late List<ChartData> chartData;

  List<String> chartDataLabels = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _progressController = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1C549D),
      extendBody: true,
      // bottomNavigationBar: FloatingNavbar(
      //   unselectedItemColor: const Color(0xff1C549D),
      //   selectedItemColor: Colors.black,
      //   backgroundColor: Colors.white,
      //   margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      //   borderRadius: 15.0,
      //   elevation: 45,
      //   onTap: (int val) {
      //     if (val == 0) {
      //       Navigator.pushNamed(context, '/home');
      //     } else if (val == 1) {
      //       Navigator.pushNamed(context, '/profile');
      //     } else if (val == 2) {
      //       Navigator.pushNamed(context, '/profile');
      //     }
      //     //returns tab id which is user tapped
      //   },
      //   currentIndex: 2,
      //   items: [
      //     FloatingNavbarItem(
      //       customWidget: const Image(
      //         image: AssetImage('assets/nuli/icon/homeicon.png'),
      //         color: Color(0xff1C549D),
      //       ),
      //     ),
      //     FloatingNavbarItem(
      //         customWidget: const Image(
      //             image: AssetImage('assets/nuli/icon/addicon.png'))),
      //     FloatingNavbarItem(
      //       customWidget:
      //           const Image(image: AssetImage('assets/nuli/icon/profile.png')),
      //     ),
      //   ],
      // ),
      body: _progressController
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const ImageIcon(
                            AssetImage("assets/nuli/icon/logout.png"),
                            color: Colors.transparent,
                          ),
                        ),
                        Text(
                          user.fullname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            bool check = await UserService.signOut();
                            if (check) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Logout Success"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.popUntil(
                                  context, ModalRoute.withName('/login'));
                              if (!Navigator.canPop(context)) {
                                Navigator.pushNamed(context, '/login');
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Sign out failed"),
                                ),
                              );
                            }
                          },
                          icon: const ImageIcon(
                            AssetImage("assets/nuli/icon/logout.png"),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Stack(
                      children: [
                        Positioned(
                          bottom: -20,
                          child: Container(
                            height: 90,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: NetworkImage(user.photoUrl),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(
                        maxHeight: double.infinity,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            width: 150,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xffF27470), Color(0xffFFC9C9)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "Edit Profile",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                      size: 16,
                                    )
                                  ],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.transparent,
                                elevation: 100,
                                shadowColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfile(user: user),
                                  ),
                                )
                                    .then((value) {
                                  setState(() {
                                    getCurrentUser();
                                    _progressController = true;
                                  });
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    SizedBox(height: 20),
                                    Text(
                                      "Activity",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Task per day",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  "This week",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // ignore: sized_box_for_whitespace
                          Container(
                            height: 150,
                            child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                //Hide the gridlines of x-axis
                                majorGridLines: const MajorGridLines(width: 0),
                                //Hide the axis line of x-axis
                                axisLine: const AxisLine(width: 0),
                              ),
                              primaryYAxis: NumericAxis(isVisible: false),
                              series: <ChartSeries>[
                                SplineAreaSeries<ChartData, String>(
                                  enableTooltip: true,
                                  dataSource: chartData,
                                  xValueMapper: (ChartData data, _) =>
                                      chartDataLabels[data.x],
                                  yValueMapper: (ChartData data, _) => data.y,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 90) *
                                          0.5,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xffFA9955),
                                        Color(0xffFFB636)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ImageIcon(
                                        AssetImage(
                                            "assets/nuli/icon/akar-icons_check-box.png"),
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _taskDoneCount.toString(),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                "tasks",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          const Text(
                                            "completed",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 90) *
                                          0.5,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xffF27470),
                                        const Color(0xffF27470)
                                            .withOpacity(0.58)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ImageIcon(
                                        AssetImage(
                                            "assets/nuli/icon/pending icon.png"),
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _taskPendingCount.toString(),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                "tasks",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          const Text(
                                            "pending",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 90) *
                                          0.5,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xffEDE962),
                                        const Color(0xffEDE962).withOpacity(0.6)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ImageIcon(
                                        AssetImage(
                                            "assets/nuli/icon/akar-icons_check-box.png"),
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _projectDoneCount.toString(),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                "projects",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          const Text(
                                            "done",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 90) *
                                          0.5,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xff55C8FA),
                                        Color(0xffBCEAFE)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const ImageIcon(
                                        AssetImage(
                                            "assets/nuli/icon/akar-icons_check-box.png"),
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _projectPendingCount.toString(),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                "projects",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          const Text(
                                            "on going",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
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
    chartData = await UserService.getChartData();
    setState(() {
      _progressController = false;
    });
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final int y;
}
