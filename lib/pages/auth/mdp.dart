import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/custum_widgets/inputs.dart';
import 'package:billy/custum_widgets/appBars.dart';
import 'package:billy/custum_widgets/buttons.dart';
import 'package:billy/firebase_functions/auth_functions.dart';
import 'package:billy/theme/themes.dart';
import 'package:flutter/material.dart';

class MdpPage extends StatefulWidget{
  Page createState()=> Page();
}

class Page extends State<MdpPage>{
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: get_appBar([
            IconButton(onPressed: () async {
              final savedThemeMode = await AdaptiveTheme.getThemeMode();
              if(savedThemeMode.toString() == 'AdaptiveThemeMode.light') {
                setState(() {
                  darkMode = true;
                  AdaptiveTheme.of(context).setDark();
                });
              }else{
                setState(() {
                  darkMode = false;
                  AdaptiveTheme.of(context).setLight();
                });
              }
            }, icon: Icon((darkMode)?Icons.light_mode_rounded:Icons.dark_mode_rounded), iconSize: 40,)
          ], context, false, false),
        body: Container(
          color: Theme.of(context).primaryColor,
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.1, 0, 0),
          child: Column(
            children: [
              get_simple_field("E-mail", true, MediaQuery.of(context).size.width * 0.5, true, _emailController, (v) {}, () {}),
              get_B_button(
                          () async {
                            bool result = await sendPassReset(_emailController.text);
                            if(result) {
                              _emailController.text = "";
                            }
                          },
                          EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.25, 0, 0), context)
            ]
          )
        )
      );
  }
}