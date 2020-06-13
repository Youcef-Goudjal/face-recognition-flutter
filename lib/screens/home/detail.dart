import 'dart:io';
import 'dart:typed_data';

import 'package:app/services/db_helper.dart';
import 'package:app/services/face.dart';
import 'package:app/shared/global.dart';
import 'package:app/widgets/loading.dart';
import 'package:app/widgets/loading_list.dart';
import 'package:app/widgets/modeltile.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailPage extends StatefulWidget {
  final String group;
  final int id;

  DetailPage({this.group, this.id});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List list;
  File _imagefile;
  List<Face> _faces;
  bool isloading = false;
  Image _image;
  CustomFace _faceDetector = CustomFace();

  @override
  Widget build(BuildContext context) {
    print(widget.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: DatabaseHelper.instance.PGqueryAll(widget.id),
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                Future.delayed(Duration(seconds: 2));
                return LoadingListPage();
              } else {
                list = snapshot.data;



                if (list.length == 0) {
                  return Center(
                    child: Text('No Person added'),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      Future.delayed(Duration(seconds: 2));
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: list.length * 2,
                      itemBuilder: (ctx, i) {
                        if (i.isOdd) {
                          return Divider(
                            color: Global.mediumBlue,
                          );
                        }
                        final index = i ~/ 2 + 1;
                        return Dismissible(
                          dismissThresholds: {
                            DismissDirection.endToStart: 0.2,
                            DismissDirection.startToEnd: 0.5,
                          },
                          onDismissed: (dis) {
                            if (dis == DismissDirection.startToEnd) {
                              print("delete");
                              DatabaseHelper.instance.Pdelete(index);
                              setState(() {});
                            } else {
                              if (dis == DismissDirection.endToStart) {
                                print('edit');
                                showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      String val;
                                      final _formkey = GlobalKey<FormState>();
                                      return Dialog(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Stack(
                                          children: <Widget>[
                                            Container(
                                              height: 200,
                                              padding: EdgeInsets.only(
                                                  top: 50, left: 10, right: 10),
                                              child: Form(
                                                key: _formkey,
                                                child: Column(
                                                  children: <Widget>[
                                                    TextFormField(
                                                      validator: (input) =>
                                                          (input.length == 0)
                                                              ? "type something"
                                                              : null,
                                                      onChanged: (input) =>
                                                          val = input,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            "Person name ",
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    MaterialButton(
                                                      onPressed: () async {
                                                        if (_formkey
                                                            .currentState
                                                            .validate()) {
                                                          print(val);
                                                          int i =
                                                              await DatabaseHelper
                                                                  .instance
                                                                  .Pupdate({
                                                            DatabaseHelper
                                                                    .columnId:
                                                                index,
                                                            DatabaseHelper
                                                                    .columnName:
                                                                val,
                                                          });
                                                          print(i);
                                                          setState(() {});
                                                          Navigator.pop(ctx);
                                                        }
                                                      },
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      color: Global.mediumBlue,
                                                      child: Text('Edit'),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  color: Global.mediumBlue,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                  )),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                    'Editing a name of Person',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              }
                            }
                          },
                          background: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            color: Colors.red,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                Icons.delete_outline,
                                size: 40,
                              ),
                            ),
                          ),
                          secondaryBackground: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            color: Colors.green,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.edit,
                                size: 40,
                              ),
                            ),
                          ),
                          key: UniqueKey(),
                          child: ListTile(
                            onTap: () {},
                            contentPadding: EdgeInsets.only(top: 6),
                            leading: CircleAvatar(
                              child: Text('${index - 1}'),
                            ),
                            title: Text(
                              '${list[index - 1][DatabaseHelper.columnName]}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }
            },
          ),
          detecting ? Loading() : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // insert person
          showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                ),
              ),
              elevation: 10,
              builder: (ctx) {
                return Container(
                  padding: EdgeInsets.all(20),
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Pick Ur Image Source',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      ModelTile(
                        icon: Icons.image,
                        title: "From Gallery",
                        subtitle: "pick Ur image to scan from gallery",
                        onTap: () {
                          print('gallery tapped');
                          processimage(ctx, false);
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      ModelTile(
                        icon: Icons.camera_alt,
                        title: "From camera",
                        subtitle: "pick Ur image to scan from camera",
                        onTap: () {
                          print("camera tapped");
                          processimage(ctx, true);
                        },
                      ),
                    ],
                  ),
                );
              });
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }

  bool detecting = false;

  // true => camera , false => gallery
  void processimage(BuildContext ctx, bool source) async {
    _imagefile = await _faceDetector.loadImage(source);
    if (_imagefile != null) {
      Fluttertoast.showToast(
        msg: "processing",
        toastLength: Toast.LENGTH_SHORT,
      );
      setState(() => detecting = true);
      _faces = await _faceDetector.lookForFaces(_imagefile);
      setState(() => detecting = false);
      Navigator.pop(ctx);
      if (_faces.isEmpty) {
        Fluttertoast.showToast(
          msg: "No Face Detected",
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        showcustomdialog(context);
      }
    } else {
      Fluttertoast.showToast(
        msg: "please select an image",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  void showcustomdialog(BuildContext context) {

    showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 370,
                    padding: EdgeInsets.only(top: 40),
                    child: PageView.builder(
                      itemCount: _faces.length,
                      itemBuilder: (c, idx) {
                        String val = '';
                        Uint8List bytes;

                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: ListView(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                  padding: EdgeInsets.all(20),
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25)),
                                  //TODO: child: Image(image: null),
                                  // idea image from memory
                                  child: FutureBuilder(
                                      future: _faceDetector.face_to_img(
                                          _faces[idx], _imagefile),
                                      builder:
                                          (c, AsyncSnapshot<Uint8List> data) {
                                        if (data.hasData) {
                                          return Image.memory(
                                            data.data,
                                            fit: BoxFit.cover,
                                          );
                                        } else {
                                          return Center(
                                              child: Text("waiting data"));
                                        }
                                      })),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                onChanged: (input) => val = input,
                                decoration: InputDecoration(
                                  hintText: "Match the Name",
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  //TODO add item to group button
                                  int i = await DatabaseHelper.instance
                                      .Pinsert2(_faces[idx], widget.id, val);
                                  Fluttertoast.showToast(
                                    msg: "done !!  $i",
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                  Navigator.pop(context);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                color: Global.mediumBlue,
                                child: Text('Add'),
                              )
                            ],
                          ),
                        );
                      },
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
                          Icons.link,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Matching',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 7,
                    right: 10,
                    child: Ink(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ));
        });
  }
}
