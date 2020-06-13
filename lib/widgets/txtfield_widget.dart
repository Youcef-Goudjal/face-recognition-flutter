
import 'package:app/model/signinmodel.dart';
import 'package:app/shared/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData prefixIconData;
  final IconData suffixIconData;
  final bool obscureText;
  final Function onChanged;
  final Function Validator;

  TextFieldWidget({
    this.hintText,
    this.prefixIconData,
    this.suffixIconData,
    this.obscureText,
    this.onChanged,
    this.Validator,
  });

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Authmodel>(context);
    return TextFormField(
      onChanged: onChanged,
      obscureText: obscureText,
      validator: Validator,
      keyboardType: obscureText ? null : TextInputType.emailAddress,
      style: TextStyle(
        color: Global.mediumBlue,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: hintText,
        prefixIcon: Icon(
          prefixIconData,
          size: 18,
          color: Global.mediumBlue,
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Global.mediumBlue,
          ),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            model.isVisible = !model.isVisible;
          },
          child: Icon(
            suffixIconData,
            size: 18,
            color: Global.mediumBlue,
          ),
        ),
        labelStyle: TextStyle(
          color: Global.mediumBlue,
        ),
        focusColor: Global.mediumBlue,
      ),
    );
  }
}
