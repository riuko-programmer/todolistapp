import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:nuli/dataclass.dart';
import 'package:nuli/dbservices.dart';

class TempPage extends StatefulWidget {
  const TempPage({Key? key}) : super(key: key);

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  late Future<List<Task>> listTask;
  final uid = UserService.getCurrentUserID();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot>(
            stream: TaskService().getData(uid,""),  
            builder: (context, snapshot) {
              if(snapshot.hasError) {
                return const Text('ERROR');
              } else if (snapshot.hasData || snapshot.data != null) {
                return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot _data = snapshot.data!.docs[index];
                      return Dismissible(
                          key: Key(_data['title']),
                          background: Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            alignment: Alignment.centerLeft,
                            color: Colors.green,
                            child: Text("Done"),
                          ),
                          secondaryBackground: Container(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: Text("Delete"),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment(1, -1),
                                    end: Alignment(0, 0),
                                    colors: [
                                      Color.fromARGB(255, 237, 233, 98),
                                      Color.fromARGB(255, 255, 255, 255)
                                    ]),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                  )
                                ],
                                borderRadius: BorderRadius.all(Radius.circular(14))),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.brightness_1_outlined,
                                  color: Color.fromARGB(128, 0, 0, 0),
                                ),
                                SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_data['title'],
                                        style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        Text(_data['date_time'],
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(178, 0, 0, 0))),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text("09:00 AM",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(178, 0, 0, 0))),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                    },
                    separatorBuilder: (context, index) =>
                          SizedBox(height: 20.0),
                  );
              }
              return const Center(
                    child: CircularProgressIndicator(),
                  );
              // if (snapshot.hasData)
              //   return (Text("Ada "));
              // else {
              //   return (Text('no data'));
              // }
            },
          )),
    );
  }
}
