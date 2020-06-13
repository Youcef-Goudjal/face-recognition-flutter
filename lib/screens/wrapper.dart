
import 'package:app/model/signinmodel.dart';
import 'package:app/model/user.dart';
import 'package:app/services/auth.dart';
import 'package:app/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/signin.dart';
import 'home/home.dart';

class Wrapper extends StatelessWidget {
  final AuthServices auth = AuthServices();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: auth.getCurrentUser() ,
        builder: (context , AsyncSnapshot<User> snopshot){
          if(snopshot.connectionState == ConnectionState.waiting){
            return Container(
              color: Colors.white,
              child: Loading(),
            );
          }else{
            if(snopshot.hasData){
              return Home();
            }else{
              return ChangeNotifierProvider(
                create: (_)=>Authmodel(),
                builder: (ctx , _ )=> Signin(),
              );
            }
          }
        }

    );
  }
}