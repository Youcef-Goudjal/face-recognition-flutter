
import 'package:app/services/db_helper.dart';
import 'package:app/shared/global.dart';
import 'package:app/widgets/loading_list.dart';
import 'package:flutter/material.dart';

import 'detail.dart';

class MyListPage extends StatefulWidget {
  @override
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  List list;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper.instance.queryAll(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          Future.delayed(Duration(seconds: 2));
          return LoadingListPage();
        } else {
          list = snapshot.data;
          //print(list.length);
          if (list.length == 0) {
            return Center(
              child: Text('No Group added'),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 1));
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
                        DatabaseHelper.instance.delete(index);
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
                                    borderRadius: BorderRadius.circular(15),
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
                                                decoration: InputDecoration(
                                                  hintText: "Group name ",
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              MaterialButton(
                                                onPressed: () async {
                                                  if (_formkey.currentState
                                                      .validate()) {
                                                    //print(val);
                                                    int i = await DatabaseHelper
                                                        .instance
                                                        .update({
                                                      DatabaseHelper.columnId:
                                                      index,
                                                      DatabaseHelper.columnName:
                                                      val,
                                                    });
                                                    //print(i);
                                                    setState(() {});
                                                    Navigator.pop(ctx);
                                                  }
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(15),
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
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
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
                                              'Editing a name of Group',
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
                      onTap: () {
                        // navigate to detail page
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetailPage(
                                  group: list[index - 1]
                                  [DatabaseHelper.columnName],
                                  id: list[index - 1]
                                  [DatabaseHelper.columnId],
                                )));
                      },
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
    );
  }
}
