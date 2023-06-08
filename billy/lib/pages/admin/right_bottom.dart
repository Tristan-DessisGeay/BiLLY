import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/custum_widgets/appBars.dart';
import 'package:billy/custum_widgets/buttons.dart';
import 'package:billy/custum_widgets/inputs.dart';
import 'package:billy/custum_widgets/togglebutton.dart';
import 'package:billy/data_processing/user.dart';
import 'package:billy/firebase_functions/user_functions.dart';
import 'package:billy/theme/themes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:billy/data_processing/expense.dart';
import 'package:flutter/rendering.dart';
import 'package:billy/theme/colors.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class RightBottom_Admin extends StatefulWidget {
  final Function() notifyParent;
  final bool largeScreen;
  RightBottom_Admin(
      {Key? key, required this.notifyParent, required this.largeScreen})
      : super(key: key);
  _RightBottom createState() => _RightBottom();
}

class _RightBottom extends State<RightBottom_Admin> {
  List rows = ["email", "password", "type", "button"];
  Map fields = {};
  bool _buttonVisible = true;
  bool ok = true;
  bool _added = false;
  String _buttonText = "Add";
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
        padding: EdgeInsets.fromLTRB(15, 70, 15, 15),
        decoration: (widget.largeScreen)
            ? BoxDecoration(
                border: Border.all(color: BLUE_COLOR_L),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15)))
            : null,
        child: SingleChildScrollView(
            child: Column(children: [
          for (int i = 0; i < rows.length; i++)
            LayoutBuilder(builder: (context, constraints) {
              Widget? field;
              if (rows[i] == "email") {
                String value = currentValuesUserAdd["email"];
                TextEditingController controller = TextEditingController();
                controller.text = value;
                field = get_simple_field("email", false,
                    constraints.maxWidth * 0.4, true, controller, (v) {
                  currentValuesUserAdd["email"] = v;
                }, () {});
                fields["email"] = controller;
              } else if (rows[i] == "password") {
                String value = currentValuesUserAdd["password"];
                TextEditingController controller = TextEditingController();
                controller.text = value;
                field = get_hidden_field(
                    "password",
                    false,
                    constraints.maxWidth * 0.4,
                    () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    _obscureText,
                    true,
                    controller,
                    (v) {
                      currentValuesUserAdd["password"] = v;
                    });
                fields["password"] = controller;
              } else if (rows[i] == "type") {
                field = get_toggleButton3(3, [
                  Container(
                      width: constraints.maxWidth * 0.4 * 0.33,
                      child: Center(
                          child: (constraints.maxWidth > 550)
                              ? Text("User")
                              : Icon(Icons.person))),
                  Container(
                      width: constraints.maxWidth * 0.4 * 0.33,
                      child: Center(
                          child: (constraints.maxWidth > 550)
                              ? Text("Accountant")
                              : Icon(Icons.note_alt_rounded))),
                  Container(
                      width: constraints.maxWidth * 0.4 * 0.33,
                      child: Center(
                          child: (constraints.maxWidth > 550)
                              ? Text("Admin")
                              : Icon(Icons.admin_panel_settings_rounded)))
                ], (newIndex) {
                  setState(() {
                    for (int index = 0;
                        index < currentValuesUserAdd["type"].length;
                        index++) {
                      if (index == newIndex) {
                        currentValuesUserAdd["type"][index] = true;
                      } else {
                        currentValuesUserAdd["type"][index] = false;
                      }
                    }
                  });
                }, context);
              } else {
                field = null;
              }
              double textLength = 0;
              Widget row;
              if (field != null) {
                textLength = RenderParagraph(
                        TextSpan(text: capitalize(rows[i])),
                        textDirection: TextDirection.ltr)
                    .getMaxIntrinsicWidth(18)
                    .ceilToDouble();
                row = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(capitalize(rows[i]),
                              style: TextStyle(
                                  color: TEXT_COLOR_DARKER, fontSize: 18)),
                          SizedBox(width: 20),
                          field
                        ],
                      ),
                      SizedBox(height: 15)
                    ]);
              } else {
                row = get_animatedText_button(_buttonText, () {
                  fields.forEach((key, value) {
                    if (key == "email") {
                      if (value.text == "") {
                        ok = false;
                      } else {
                        for (var user in list_users) {
                          if (user!.get("email") == value.text) {
                            ok = false;
                            break;
                          }
                        }
                      }
                    }
                  });
                  if (ok) {
                    User user = new User(
                        "",
                        fields["password"].text,
                        fields["email"].text,
                        [],
                        currentValuesUserAdd["type"].indexOf(true));
                    list_users.add(user);
                    currentValuesUserAdd = {
                      "email": "",
                      "password": "azerty1234",
                      "type": [true, false, false]
                    };
                  }
                  setState(() {
                    _buttonVisible = false;
                  });
                  widget.notifyParent();
                }, () {
                  if (_buttonText == "Add" && _added) {
                    _added = false;
                    ok = true;
                    _buttonVisible = true;
                    create_user(widget);
                  } else if ((_buttonText == "Ok" || _buttonText == "Error") &&
                      _buttonVisible) {
                    setState(() {
                      _buttonVisible = false;
                    });
                  } else {
                    setState(() {
                      _buttonText = (_buttonText == "Add")
                          ? (ok)
                              ? "Ok"
                              : "Error"
                          : "Add";
                      _buttonVisible = _buttonVisible ? false : true;
                      _added = true;
                    });
                  }
                },
                    constraints.maxWidth * 0.4,
                    50.0,
                    (widget.largeScreen)
                        ? EdgeInsets.fromLTRB(0, 40, 0, 500)
                        : EdgeInsets.fromLTRB(
                            0, MediaQuery.of(context).size.height - 430, 0, 0),
                    _buttonVisible,
                    context);
              }
              double minWidth = constraints.maxWidth * 0.4 + textLength + 20;
              double maxWidth = constraints.maxWidth - 50;
              if (maxWidth > minWidth) {
                return row;
              } else {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: row,
                );
              }
            }),
        ])));
    return Scaffold(
      appBar: (!widget.largeScreen)
          ? get_appBar([
              IconButton(
                onPressed: () async {
                  final savedThemeMode = await AdaptiveTheme.getThemeMode();
                  if (savedThemeMode.toString() == 'AdaptiveThemeMode.light') {
                    setState(() {
                      darkMode = true;
                      AdaptiveTheme.of(context).setDark();
                    });
                  } else {
                    setState(() {
                      darkMode = false;
                      AdaptiveTheme.of(context).setLight();
                    });
                  }
                },
                icon: Icon((darkMode)
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded),
                iconSize: 40,
              )
            ], context, false, false)
          : null,
      body: (!widget.largeScreen) ? Stack(
        children: [
          content,
          Container(
                    height: 35,
                    child: Center(
                      child: Text(
                        'Adding users',
                        style: TextStyle(color: TEXT_COLOR_DARKER, fontSize: 25)
                      )
                    )
                  )
        ],
      ) : content,
    );
  }
}
