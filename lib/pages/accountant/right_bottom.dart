import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/custum_widgets/appBars.dart';
import 'package:billy/custum_widgets/buttons.dart';
import 'package:billy/custum_widgets/colorpoints.dart';
import 'package:billy/custum_widgets/inputs.dart';
import 'package:billy/custum_widgets/togglebutton.dart';
import 'package:billy/firebase_functions/expense_functions.dart';
import 'package:billy/theme/themes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:billy/custum_widgets/expense.dart';
import 'package:flutter/rendering.dart';
import 'package:billy/theme/colors.dart';
import 'package:google_place/google_place.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class RightBottom_Accountant extends StatefulWidget {
  final Function() notifyParent;
  final bool largeScreen;
  RightBottom_Accountant(
      {Key? key, required this.notifyParent, required this.largeScreen})
      : super(key: key);
  _RightBottom createState() => _RightBottom();
}

class _RightBottom extends State<RightBottom_Accountant> {
  List rows = [
    "date",
    "reason",
    "precisions",
    "place",
    "amount",
    "supporting documents",
    "status",
    "accounting comment",
    "button"
  ];
  bool _buttonVisible = true;
  bool ok = true;
  bool _valided = false;
  String _buttonText = "Validate";

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (current_expense != null) {
      content = Container(
          padding: EdgeInsets.all(15),
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
                if (rows[i] == "date") {
                  TextEditingController controller = TextEditingController();
                  controller.text = current_expense!.get("date");
                  field = get_date_input(
                      constraints, (v) {}, controller, true, context);
                } else if (rows[i] == "reason") {
                  TextEditingController controller = TextEditingController();
                  controller.text = current_expense!.get("motif");
                  field = get_motif_input(constraints, (v) {}, controller,
                      false, motifsList, widget, () {}, context);
                } else if (rows[i] == "precisions" &&
                    current_expense!.get("motif") == "Autre") {
                  TextEditingController controller = TextEditingController();
                  controller.text = current_expense!.get("précision");
                  field = get_precision_input(
                      constraints, controller, true, (v) {}, context);
                } else if (rows[i] == "place") {
                  TextEditingController controller = TextEditingController();
                  controller.text = current_expense!.get("lieu");
                  field = get_lieu_input(constraints, (v) {}, controller, true,
                      false, predictionsAdd, widget, false, context);
                } else if (rows[i] == "amount") {
                  TextEditingController controller = TextEditingController();
                  controller.text = current_expense!.get("montant").toString();
                  field = get_montant_input(
                      constraints,
                      (v) {},
                      true,
                      controller,
                      () {},
                      current_expense!.get("currency"),
                      context);
                } else if (rows[i] == "supporting documents") {
                  field = get_justificatifs_input(
                      false,
                      (current_expense!.get("docs") == null)
                          ? null
                          : List.from(current_expense!.get("docs")),
                      constraints,
                      265,
                      false,
                      () {},
                      () {},
                      context);
                } else if (rows[i] == "status") {
                  if (!current_valuesAdd["etat"].contains(true))
                    current_valuesAdd["etat"][current_expense!.get("etat")] =
                        true;
                  field = get_toggleButton3(1, [
                    Container(
                        width: constraints.maxWidth * 0.4 * 0.33,
                        child: Center(
                            child: (constraints.maxWidth > 550)
                                ? Text("Accepted")
                                : green_point)),
                    Container(
                        width: constraints.maxWidth * 0.4 * 0.33,
                        child: Center(
                            child: (constraints.maxWidth > 550)
                                ? Text("Pending")
                                : orange_point)),
                    Container(
                        width: constraints.maxWidth * 0.4 * 0.33,
                        child: Center(
                            child: (constraints.maxWidth > 550)
                                ? Text("Rejected")
                                : red_point))
                  ], (newIndex) {
                    setState(() {
                      for (int index = 0;
                          index < current_valuesAdd["etat"].length;
                          index++) {
                        if (index == newIndex) {
                          current_valuesAdd["etat"][index] = true;
                        } else {
                          current_valuesAdd["etat"][index] = false;
                        }
                      }
                    });
                  }, context);
                } else if (rows[i] == "accounting comment" &&
                    current_valuesAdd["etat"][2] == true) {
                  String value = current_expense!.get("commentaire");
                  TextEditingController controller = TextEditingController();
                  controller.text = value;
                  field = Container(
                    width: constraints.maxWidth * 0.4,
                    height: 200,
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      controller: controller,
                      onChanged: (v) {
                        current_valuesAdd["commentaire"] = v;
                      },
                      minLines: 8,
                      maxLines: 8,
                      style: TextStyle(color: TEXT_COLOR_LIGHTER),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: HINT_TEXT_COLOR),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).buttonColor,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).buttonColor,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      ),
                    ),
                  );
                } else {
                  field = null;
                }
                if (field != null || rows[i] == "button") {
                  final textLength = RenderParagraph(
                          TextSpan(text: capitalize(rows[i])),
                          textDirection: TextDirection.ltr)
                      .getMaxIntrinsicWidth(18)
                      .ceilToDouble();
                  final row = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (rows[i] != "button")
                              Text(capitalize(rows[i]),
                                  style: TextStyle(
                                      color: TEXT_COLOR_DARKER, fontSize: 18)),
                            if (rows[i] == "button")
                              get_animatedText_button(_buttonText, () {
                                if (current_valuesAdd["etat"][2] == true) {
                                  if (current_valuesAdd["commentaire"] == "" &&
                                      current_expense!.get("commentaire") ==
                                          "") {
                                    ok = false;
                                  }
                                }
                                if (ok) {
                                  if (current_valuesAdd["etat"][2] == false) {
                                    current_expense!.set("commentaire", "");
                                  } else {
                                    current_expense!.set("commentaire",
                                        current_valuesAdd["commentaire"]);
                                  }
                                  current_expense!.set("etat",
                                      current_valuesAdd["etat"].indexOf(true));
                                  current_valuesAdd["etat"] = [
                                    false,
                                    false,
                                    false
                                  ];
                                  current_valuesAdd["commentaire"] = "";
                                }
                                setState(() {
                                  _buttonVisible = false;
                                });
                                widget.notifyParent();
                              }, () {
                                if (_buttonText == "Validate" && _valided) {
                                  _valided = false;
                                  ok = true;
                                  _buttonVisible = true;
                                  update_expense(true);
                                } else if ((_buttonText == "Ok" ||
                                        _buttonText == "Error") &&
                                    _buttonVisible) {
                                  setState(() {
                                    _buttonVisible = false;
                                  });
                                } else {
                                  setState(() {
                                    _buttonText = (_buttonText == "Validate")
                                        ? (ok)
                                            ? "Ok"
                                            : "Error"
                                        : "Validate";
                                    _buttonVisible =
                                        _buttonVisible ? false : true;
                                    _valided = true;
                                  });
                                }
                              },
                                  constraints.maxWidth * 0.4,
                                  50.0,
                                  EdgeInsets.fromLTRB(
                                      constraints.maxWidth * 0.3, 40, 0, 0),
                                  _buttonVisible,
                                  context),
                            if (rows[i] != "button") field!
                          ],
                        ),
                        SizedBox(height: 15)
                      ]);
                  double minWidth =
                      constraints.maxWidth * 0.4 + textLength + 20;
                  double maxWidth = constraints.maxWidth - 50;
                  if (maxWidth > minWidth) {
                    return row;
                  } else {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: row,
                    );
                  }
                } else {
                  return Container();
                }
              }),
          ])));
    } else {
      content = Container(
        decoration: (widget.largeScreen)
            ? BoxDecoration(
                border: Border.all(color: BLUE_COLOR_L),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15)))
            : null,
        child: Center(
            child: Text(
          "No expenses have been selected yet",
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
