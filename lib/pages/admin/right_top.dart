import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/custum_widgets/appBars.dart';
import 'package:billy/custum_widgets/togglebutton.dart';
import 'package:billy/data_processing/user.dart';
import 'package:billy/firebase_functions/user_functions.dart';
import 'package:billy/theme/colors.dart';
import 'package:billy/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:billy/custum_widgets/inputs.dart';
import 'package:flutter/rendering.dart';
import 'package:billy/custum_widgets/buttons.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class RightTop_Admin extends StatefulWidget {
  final Function() notifyParent;
  final bool largeScreen;

  RightTop_Admin(
      {Key? key, required this.notifyParent, required this.largeScreen})
      : super(key: key);
  _RightTop createState() => _RightTop();
}

class _RightTop extends State<RightTop_Admin> {
  Map fields = {};
  bool _buttonVisible = true;
  bool _modified = false;
  String _buttonText = "Update";
  bool ok = true;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    List rows = ["email", "type", "buttons"];
    Widget content;
    if (current_user != null) {
      content = Container(
          padding: EdgeInsets.all(15),
          decoration: (widget.largeScreen)
              ? BoxDecoration(
                  border: Border.all(color: BLUE_COLOR_L),
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(15)))
              : null,
          child: SingleChildScrollView(
              child: Column(
            children: [
              for (int i = 0; i < rows.length; i++)
                LayoutBuilder(builder: (context, constraints) {
                  Widget? field;
                  if (rows[i] == "email") {
                    String value = current_user!.get("email");
                    TextEditingController controller = TextEditingController();
                    controller.text = (currentValuesUser["email"] == null)
                        ? value
                        : currentValuesUser["email"];
                    field = get_simple_field("email", false,
                        constraints.maxWidth * 0.4, false, controller, (v) {
                      currentValuesUser["email"] = v;
                    }, () {});
                    fields["email"] = controller;
                  } else if (rows[i] == "type") {
                    if (!currentValuesUser["type"].contains(true))
                      currentValuesUser["type"][current_user!.get("type")] =
                          true;
                    field = get_toggleButton3(2, [
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
                            index < currentValuesUser["type"].length;
                            index++) {
                          if (index == newIndex) {
                            currentValuesUser["type"][index] = true;
                          } else {
                            currentValuesUser["type"][index] = false;
                          }
                        }
                      });
                    }, context);
                  } else {
                    field = null;
                  }
                  final row;
                  double textLength = 0;
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
                    row = Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 500),
                        child: get_animatedText_button(_buttonText, () {
                          if (ok) {
                            current_user!.set("type",
                                currentValuesUser["type"].indexOf(true));
                            currentValuesUser = {
                              "email": null,
                              "type": [false, false, false]
                            };
                          }
                          setState(() {
                            _buttonVisible = false;
                          });
                          widget.notifyParent();
                        }, () {
                          if (_buttonText == "Update" && _modified) {
                            _modified = false;
                            ok = true;
                            _buttonVisible = true;
                            update_user();
                          } else if ((_buttonText == "Ok" ||
                                  _buttonText == "Error") &&
                              _buttonVisible) {
                            setState(() {
                              _buttonVisible = false;
                            });
                          } else {
                            setState(() {
                              _buttonText = (_buttonText == "Update")
                                  ? (ok)
                                      ? "Ok"
                                      : "Error"
                                  : "Update";
                              _buttonVisible = _buttonVisible ? false : true;
                              _modified = true;
                            });
                          }
                        },
                            constraints.maxWidth * 0.4,
                            50.0,
                            (widget.largeScreen)
                                ? EdgeInsets.fromLTRB(0, 40, 0, 0)
                                : EdgeInsets.fromLTRB(
                                    0,
                                    MediaQuery.of(context).size.height - 320,
                                    0,
                                    0),
                            _buttonVisible,
                            context));
                  }
                  double minWidth =
                      constraints.maxWidth * 0.4 + textLength + 20 + 50;
                  double maxWidth = constraints.maxWidth - 50;
                  if (maxWidth > minWidth) {
                    return row;
                  } else {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: row,
                    );
                  }
                })
            ],
          )));
    } else {
      content = Container(
        decoration: (widget.largeScreen)
            ? BoxDecoration(
                border: Border.all(color: BLUE_COLOR_L),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(15)))
            : null,
        child: Center(
            child: Text(
          "No user has been selected yet",
          textAlign: TextAlign.center,
          style: TextStyle(color: TEXT_COLOR_DARKER, fontSize: 30),
        )),
      );
    }
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
      body: content,
    );
  }
}
