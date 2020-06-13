import 'package:app/services/auth.dart';
import 'package:app/services/db_helper.dart';
import 'package:app/shared/global.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../wrapper.dart';
import 'home_page.dart';
import 'lists.dart';
import 'settings_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthServices auth = AuthServices();
  List<String> pages = ["Home", "Lists", "Settings"];
  int currentindex = 0;
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[currentindex]),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Global.secondColor,
                    Global.mediumBlue,
                  ])),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                auth
                    .signOut()
                    .then(
                      (value) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (ctx) => Wrapper()),
                  ),
                )
                    .catchError((e) {
                  Fluttertoast.showToast(
                      msg: "error",
                      backgroundColor: Colors.red,
                      toastLength: Toast.LENGTH_LONG);
                });
              })
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (idx) => setState(() => currentindex = idx),
        children: <Widget>[
          HomePage(),
          MyListPage(),
          SettingPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('My Lists'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
        selectedItemColor: Global.mediumBlue,
        currentIndex: currentindex,
        onTap: (index) {
          setState(() {
            currentindex = index;
            _pageController.animateToPage(currentindex,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOutQuad);
          });
        },
      ),
      floatingActionButton: (currentindex == 1)
          ? FloatingActionButton(
        onPressed: () {
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
                        padding:
                        EdgeInsets.only(top: 50, left: 10, right: 10),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                validator: (input) => (input.length == 0)
                                    ? "type something"
                                    : null,
                                onChanged: (input) => val = input,
                                decoration: InputDecoration(
                                  hintText: "Group name ",
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              MaterialButton(
                                onPressed: ()async {
                                  if (_formkey.currentState.validate()) {
                                    print(val);
                                    int i = await DatabaseHelper.instance.insert({
                                      DatabaseHelper.columnName : val,
                                    });
                                    print(i);
                                    setState(() {

                                    });
                                    Navigator.pop(ctx);
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                color: Global.mediumBlue,
                                child: Text('Add'),
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
                              'Adding a Group',
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
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
      )
          : Container(),
    );
  }
}
