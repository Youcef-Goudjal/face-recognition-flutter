import 'dart:async';

import 'package:app/services/db_helper.dart';
import 'package:app/services/face.dart';
import 'package:app/shared/global.dart';
import 'package:app/util/utilitis.dart';
import 'package:app/widgets/camera.dart';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isselected = false;
  String group_picked = "All";
  List<String> grouplist; // from database table list
  List faces_detected = List(); // known faces from camera
  List _list = List(); // list to compare from database table person
  StreamController streamController = StreamController();


  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.queryAll().then((value) => additems(value));
    fetchdata().then((value) => setState(() {}));
  }

  additems(List list) {
    grouplist = List();
    grouplist.add("All");
    for (int i = 1; i <= list.length; i++) {
      grouplist.add(list[i - 1][DatabaseHelper.columnName]);
    }
  }

  addperson(String person) {
    faces_detected.add(person);
    streamController.sink.add(person);
  }

  Future fetchdata() async {
    _list.clear();
    if (group_picked == "All") {
      DatabaseHelper.instance.PqueryAll().then((l) {
        l.forEach((element) {
          _list.add(DatabaseHelper.instance.readData(element));
        });
      });
    } else {
      int i = await DatabaseHelper.instance.findlistbyname(group_picked);

      _list.clear();
      DatabaseHelper.instance.PGqueryAll(i).then((value) {
        for (int j = 0; j < value.length; j++) {
          _list.add(DatabaseHelper.instance.readData(value[j]));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(" lenght :${_list.length}");
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Ink(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                  onTap: () {
                    isselected = true;

                    setState(() {});
                    faces_detected.removeRange(0, faces_detected.length);
                    streamController.sink.add('');

                  },
                  child: isselected
                      ? LiveCamera(_list)
                      : Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 40,
                          ),
                        )),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Faces detected',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                  //color: Colors.red,
                  child: !isselected
                      ? Center(
                          child: Text('press to start processing !!! '),
                        )
                      : StreamBuilder(
                          stream: streamController.stream,
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              if (faces_detected == null) {
                                return Center(
                                  child: Text('No faces detected Yet!!'),
                                );
                              } else {
                                return ListView.builder(
                                  itemCount: faces_detected.length * 2,
                                  padding: EdgeInsets.all(8),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (_, idx) {
                                    if (idx.isOdd) {
                                      return SizedBox(
                                        width: 10,
                                      );
                                    }
                                    final index = idx ~/ 2 + 1;
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 3)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          ' ${faces_detected[index - 1]}', //todo
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          })),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            pick_group(context);
          },
          child: Text('Pick')),
    );
  }

  pick_group(BuildContext context) {
    DatabaseHelper.instance.queryAll().then((value) {
      additems(value);
      final List<DropdownMenuItem<String>> _dropDownMenuItems = grouplist
          .map((String e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
          .toList();
      showDialog(
          context: context,
          builder: (ctx) {
            return Dialog(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: StatefulBuilder(
                  builder: (BuildContext ctx, StateSetter state) {
                return Stack(
                  children: <Widget>[
                    Container(
                      height: 200,
                      padding: EdgeInsets.only(top: 50, left: 10, right: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          DropdownButton<String>(
                              value: group_picked,
                              items: _dropDownMenuItems,
                              onChanged: (String val) {
                                group_picked = val;
                                state(() {});
                              }),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: MaterialButton(
                              onPressed: () async {
                                fetchdata().then((value) => setState(() {}));

                                Navigator.pop(ctx);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Global.mediumBlue,
                              child: Text('confirm'),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Global.mediumBlue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add_circle,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Choose a Group',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              }),
            );
          });
    });
  }


}
