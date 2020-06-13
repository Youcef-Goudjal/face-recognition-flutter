
import 'package:app/model/signinmodel.dart';
import 'package:app/model/user.dart';
import 'package:app/screens/auth/register.dart';
import 'package:app/services/auth.dart';
import 'package:app/shared/global.dart';
import 'package:app/util/utilitis.dart';
import 'package:app/widgets/btn_widget.dart';
import 'package:app/widgets/loading.dart';
import 'package:app/widgets/txtfield_widget.dart';
import 'package:app/widgets/wave_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../wrapper.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  bool isloading = false;

  final _formkey = GlobalKey<FormState>();

  String _email = '', _password = "", error = "";

  AuthServices auth = AuthServices();

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Authmodel>(context);
    final size = MediaQuery.of(context).size;
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: Global.white,
      body: Stack(
        children: <Widget>[
          Container(
            height: size.height - 200,
            color: Global.mediumBlue,
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOutQuad,
            top: keyboardOpen ? -size.height / 3.7 : 0,
            child: WaveWidget(
              size: size,
              yOffset: size.height / 3,
              color: Global.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Login',
                  style: TextStyle(
                    color: Global.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextFieldWidget(
                    hintText: 'email',
                    prefixIconData: Icons.email,
                    obscureText: false,
                    suffixIconData: model.isValid ? Icons.check : null,
                    onChanged: (value) {
                      model.isValidEmail(value);
                      _email = value;
                    },
                    Validator: (val) =>
                    (checkEmail(val) ? null : "Entre a valid email "),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      TextFieldWidget(
                          hintText: 'password',
                          prefixIconData: Icons.lock_outline,
                          obscureText: model.isVisible ? false : true,
                          suffixIconData: model.isVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          onChanged: (val) {
                            _password = val;
                          },
                          Validator: (val) => (chekPassword(val)
                              ? null
                              : "Password must be +6")),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Global.mediumBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ButtonWidget(
                    title: "Login",
                    hasBorder: false,
                    onTap: () async {
                      if (_formkey.currentState.validate()) {
                        setState(() {
                          isloading = true;
                        });
                        User user = await auth
                            .signin(User(
                          email: _email,
                          password: _password,
                        ))
                            .catchError((e) {
                          error = e.toString();
                          Fluttertoast.showToast(
                            msg: "there was an error",
                            backgroundColor: Colors.red,
                            toastLength: Toast.LENGTH_LONG,
                          );
                        });
                        if (user != null) {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (ctx) => Wrapper()));
                        }
                      }
                      setState(() {
                        isloading = false;
                      });
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ButtonWidget(
                    title: "Sign Up",
                    hasBorder: true,
                    onTap: () {
                      print("register");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (context) => Authmodel(),
                            builder: (ctx, _) => Register(),
                          ),
                        ),
                      );
                    },
                  ),
                  Text(
                    error,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  )
                ],
              ),
            ),
          ),
          isloading ? Loading() : Container(),
        ],
      ),
    );
  }
}
