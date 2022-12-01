import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/custum_widgets/appBars.dart';
import 'package:billy/custum_widgets/colorpoints.dart';
import 'package:billy/custum_widgets/togglebutton.dart';
import 'package:billy/firebase_functions/expense_functions.dart';
import 'package:billy/theme/colors.dart';
import 'package:billy/theme/themes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:billy/custum_widgets/expense.dart';
import 'package:billy/custum_widgets/inputs.dart';
import 'package:flutter/rendering.dart';
import 'package:billy/custum_widgets/buttons.dart';
import 'package:google_place/google_place.dart';
import 'dart:html' as html;

import 'package:image_whisperer/image_whisperer.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class RightTop_User extends StatefulWidget {
  final Function() notifyParent;
  final bool largeScreen;
  RightTop_User(
      {Key? key, required this.notifyParent, required this.largeScreen})
      : super(key: key);
  _RightTop createState() => _RightTop();
}

class _RightTop extends State<RightTop_User> {
  final _SearchFieldController = TextEditingController();
  late GooglePlace googlePlace;
  Timer? _debounce;
  Map fields = {};
  bool _buttonVisible = true;
  bool _modified = false;
  String _buttonText = "Update";
  bool ok = true;

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    String apiKey = '';
    googlePlace = GooglePlace(apiKey, proxyUrl: 'cors-anywhere.herokuapp.com');
    if (!widget.largeScreen && current_expense!.get("docs") == null) {
      get_docs(refresh);
    }
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (current_expense != null) {
      List rows = [
        "date",
        "reason",
        if ((current_values["motif"] == null &&
                current_expense!.get("motif") == "Autre") ||
            current_values["motif"] == "Autre")
          "precisions",
        "place",
        "amount",
        "supporting documents",
        "status",
        if (current_expense!.get("etat") == 2) "accounting comment",
        if (current_expense!.get("etat") == 1) "update"
      ];
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
                  Widget buttonsRow = Row(children: [
                    get_animatedText_button(_buttonText, () {
                      fields.forEach((key, value) {
                        if (key == "date") {
                          RegExp testDate = RegExp(
                              r'\d{4}\/(0[1-9]|1[012])\/(0[1-9]|[12][0-9]|3[01])');
                          if (!testDate.hasMatch(value.text)) {
                            ok = false;
                          }
                        }
                        if (key == "montant") {
                          if (double.tryParse(value.text) == null) {
                            ok = false;
                          }
                        }
                        if (key == "lieu") {
                          if (!lieuSelected) {
                            ok = false;
                          }
                        }
                        if (key == "précision") {
                          if (value == "") {
                            ok = false;
                          }
                        }
                      });
                      if (ok) {
                        fields.forEach((key, value) {
                          if (key == "date" ||
                              key == "motif" ||
                              key == "précision" ||
                              key == "lieu" ||
                              key == "commentaire comptable") {
                            if (key == "commentaire comptable") {
                              current_expense!.set("commentaire", value.text);
                            } else {
                              current_expense!.set(key, value.text);
                              if (key == "précision" &&
                                  current_expense!.get("motif") != "Autre") {
                                current_expense!.set("précision", "");
                              }
                            }
                          } else if (key == "montant") {
                            current_expense!
                                .set("montant", double.parse(value.text));
                          }
                        });
                        if (current_currency != null)
                          current_expense!.set("currency", current_currency);
                        current_expense!.set("docs", current_docs_list);
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
                        update_expense(false);
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
                        constraints.maxWidth * 0.3,
                        50.0,
                        EdgeInsets.fromLTRB(0, 40, 0, 0),
                        _buttonVisible,
                        context),
                    SizedBox(width: constraints.maxWidth * 0.1),
                    get_simple_button("Delete", () {
                      delete_expense();
                      list_expenses.remove(current_expense);
                      current_expense = null;
                      current_currency = null;
                      current_docs_list = [];
                      current_values = {
                        "date": null,
                        "motif": null,
                        "précision": null,
                        "lieu": null,
                        "montant": null
                      };
                      predictions = [];
                      widget.notifyParent();
                    }, constraints.maxWidth * 0.3, 50.0,
                        EdgeInsets.fromLTRB(0, 40, 0, 0), context)
                  ]);
                  String value;
                  Widget field;
                  if (rows[i] == "amount") {
                    value = current_expense!.get("montant").toString();
                    TextEditingController controller = TextEditingController();
                    controller.text = (current_values["montant"] == null)
                        ? value
                        : current_values["montant"];
                    field = get_montant_input(
                        constraints,
                        (v) {
                          current_values["montant"] = v;
                        },
                        (current_expense!.get("etat") == 1) ? false : true,
                        controller,
                        () {
                          if (current_expense!.get("etat") == 1) {
                            setState(() {
                              if (current_currency == "€" ||
                                  current_currency == null &&
                                      current_expense!.get("currency") == "€") {
                                current_currency = "\$";
                              } else {
                                current_currency = "€";
                              }
                            });
                          }
                        },
                        (current_currency == null)
                            ? current_expense!.get("currency")
                            : current_currency,
                        context);
                    fields["montant"] = controller;
                  } else if (rows[i] == "supporting documents") {
                    field = get_justificatifs_input(
                        true,
                        (current_expense!.get("docs") == null)
                            ? null
                            : (current_docs_list.length == 0)
                                ? List.from(current_expense!.get("docs"))
                                : current_docs_list,
                        constraints,
                        265,
                        current_expense!.get("etat") == 1, () {
                      setState(() {});
                    }, () async {
                      var input = html.FileUploadInputElement()
                        ..accept = 'image/*';
                      input.click();
                      input.onChange.listen((event) {
                        html.File? file = input.files?.first;
                        if (file != null) {
                          setState(() {
                            current_docs_list =
                                List.from(current_expense!.get("docs"));
                            current_docs_list.add([BlobImage(file).url, file]);
                          });
                        }
                      });
                    }, context);
                  } else if (rows[i] == "status") {
                    field = get_toggleButton3(
                        0,
                        [
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
                        ],
                        (newIndex) {},
                        context);
                  } else if (rows[i] == "accounting comment") {
                    value = current_expense!.get("commentaire");
                    TextEditingController controller = TextEditingController();
                    controller.text = value;
                    field = Container(
                      width: constraints.maxWidth * 0.4,
                      height: 200,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        controller: controller,
                        minLines: 8,
                        maxLines: 8,
                        readOnly: true,
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
                    fields["commentaire comptable"] = controller;
                  } else if (rows[i] == "update") {
                    field = Container();
                  } else if (rows[i] == "place") {
                    value = current_expense!.get("lieu");
                    _SearchFieldController.text =
                        (current_values["lieu"] == null)
                            ? value
                            : current_values["lieu"];
                    field = get_lieu_input(constraints, (v) {
                      lieuSelected = false;
                      current_values["lieu"] = _SearchFieldController.text;
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        if (value.isNotEmpty) {
                          autoCompleteSearch(v);
                        } else {}
                      });
                    },
                        _SearchFieldController,
                        (current_expense!.get("etat") == 1) ? false : true,
                        current_expense!.get("etat") == 1,
                        predictions,
                        widget,
                        true,
                        context);
                    fields["lieu"] = _SearchFieldController;
                  } else if (rows[i] == "reason") {
                    value = current_expense!.get("motif");
                    TextEditingController controller = TextEditingController();
                    controller.text = (current_values[rows[i]] == null)
                        ? value
                        : current_values[rows[i]];
                    field = get_motif_input(
                        constraints,
                        (v) {
                          current_values["motif"] = controller.text;
                        },
                        controller,
                        current_expense!.get("etat") == 1,
                        motifsList,
                        widget,
                        () {
                          current_values["motif"] = controller.text;
                          setState(() {});
                        },
                        context);
                    fields["motif"] = controller;
                  } else if (rows[i] == "precisions") {
                    value = current_expense!.get("précision");
                    TextEditingController controller = TextEditingController();
                    controller.text = (current_values["précision"] == null)
                        ? value
                        : current_values[rows[i]];
                    field = get_precision_input(constraints, controller,
                        (current_expense!.get("etat") == 1) ? false : true,
                        (v) {
                      current_values["précision"] = v;
                    }, context);
                    fields["précision"] = controller;
                  } else {
                    value = current_expense!.get(rows[i]);
                    TextEditingController controller = TextEditingController();
                    controller.text = (current_values[rows[i]] == null)
                        ? value
                        : current_values[rows[i]];
                    field = get_date_input(constraints, (v) {
                      current_values["date"] = v;
                    },
                        controller,
                        (current_expense!.get("etat") == 1) ? false : true,
                        context);
                    fields["date"] = controller;
                  }
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
                            (rows[i] != "update")
                                ? Text(capitalize(rows[i]),
                                    style: TextStyle(
                                        color: TEXT_COLOR_DARKER, fontSize: 18))
                                : Container(),
                            (rows[i] != "update")
                                ? SizedBox(width: 20)
                                : buttonsRow,
                            (rows[i] != "update") ? field : Container()
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
