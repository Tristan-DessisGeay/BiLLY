import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/custum_widgets/appBars.dart';
import 'package:billy/custum_widgets/buttons.dart';
import 'package:billy/custum_widgets/inputs.dart';
import 'package:billy/firebase_functions/expense_functions.dart';
import 'package:billy/theme/themes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:billy/data_processing/expense.dart';
import 'package:flutter/rendering.dart';
import 'package:billy/theme/colors.dart';
import 'dart:html' as html;
import 'package:google_place/google_place.dart';
import 'package:image_whisperer/image_whisperer.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class RightBottom_User extends StatefulWidget {
  final Function() notifyParent;
  final bool largeScreen;
  RightBottom_User(
      {Key? key, required this.notifyParent, required this.largeScreen})
      : super(key: key);
  _RightBottom createState() => _RightBottom();
}

class _RightBottom extends State<RightBottom_User> {
  final _SearchFieldController = TextEditingController();
  late GooglePlace googlePlace;
  Timer? _debounce;
  bool motifAutre = true;
  List rows = [
    "date",
    "reason",
    "precisions",
    "place",
    "amount",
    "supporting documents",
    "button"
  ];
  Map fields = {};
  bool _buttonVisible = true;
  bool ok = true;
  bool _added = false;
  String _buttonText = "Add";

  @override
  void initState() {
    super.initState();
    String apiKey = 'AIzaSyD5bHoBeex77LinY_0EjPggDE48bGueZuY';
    googlePlace = GooglePlace(apiKey, proxyUrl: 'cors-anywhere.herokuapp.com');
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictionsAdd = result.predictions!;
      });
    }
  }

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
              Widget field;
              if (rows[i] == "date") {
                TextEditingController controller = TextEditingController();
                controller.text = current_valuesAdd["date"];
                field = get_date_input(constraints, (v) {
                  current_valuesAdd["date"] = v;
                }, controller, false, context);
                fields["date"] = controller;
              } else if (rows[i] == "reason") {
                TextEditingController controller = TextEditingController();
                controller.text = current_valuesAdd["motif"];
                field = get_motif_input(
                    constraints,
                    (v) {
                      current_valuesAdd["motif"] = v;
                    },
                    controller,
                    true,
                    motifsList,
                    widget,
                    () {
                      current_valuesAdd["motif"] = controller.text;
                      setState(() {});
                    },
                    context);
                fields["motif"] = controller;
              } else if (rows[i] == "precisions" &&
                  fields["motif"].text == "Autre") {
                TextEditingController controller = TextEditingController();
                controller.text = current_valuesAdd["précision"];
                field =
                    get_precision_input(constraints, controller, false, (v) {
                  current_valuesAdd["précision"] = controller.text;
                }, context);
                fields["précision"] = controller;
              } else if (rows[i] == "place") {
                _SearchFieldController.text = current_valuesAdd["lieu"];
                field = get_lieu_input(constraints, (v) {
                  lieuSelected = false;
                  current_valuesAdd["lieu"] = _SearchFieldController.text;
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 1000), () {
                    if (v.isNotEmpty) {
                      autoCompleteSearch(v);
                    } else {}
                  });
                }, _SearchFieldController, false, true, predictionsAdd, widget,
                    false, context);
                fields["lieu"] = _SearchFieldController;
              } else if (rows[i] == "amount") {
                TextEditingController controller = TextEditingController();
                controller.text = current_valuesAdd["montant"];
                field = get_montant_input(
                    constraints,
                    (v) {
                      current_valuesAdd["montant"] = v;
                    },
                    false,
                    controller,
                    () {
                      setState(() {
                        if (current_currencyAdd == "€") {
                          current_currencyAdd = "\$";
                        } else {
                          current_currencyAdd = "€";
                        }
                      });
                    },
                    current_currencyAdd,
                    context);
                fields["montant"] = controller;
              } else if (rows[i] == "supporting documents") {
                field = get_justificatifs_input(
                    false, current_docs_listAdd, constraints, 265, true, () {
                  setState(() {});
                }, () async {
                  var input = html.FileUploadInputElement()..accept = 'image/*';
                  input.click();
                  input.onChange.listen((event) {
                    html.File? file = input.files?.first;
                    if (file != null) {
                      setState(() {
                        current_docs_listAdd.add([BlobImage(file).url, file]);
                      });
                    }
                  });
                }, context);
              } else {
                field = Container();
              }
              if ((rows[i] == "precisions" &&
                      fields["motif"].text == "Autre") ||
                  rows[i] != "precisions") {
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
                                  if (!lieuSelectedAdd) {
                                    ok = false;
                                  }
                                }
                              });
                              if (ok) {
                                Expense expense = new Expense(
                                    "",
                                    fields["date"].text,
                                    fields["motif"].text,
                                    fields["précision"].text,
                                    fields["lieu"].text,
                                    double.parse(fields["montant"].text),
                                    current_currencyAdd,
                                    1,
                                    current_docs_listAdd,
                                    "");
                                add_expense(expense, widget);
                              }
                              setState(() {
                                _buttonVisible = false;
                              });
                              widget.notifyParent();
                            }, () {
                              if (_buttonText == "Add" && _added) {
                                if (ok) {
                                  setState(() {
                                    current_valuesAdd.forEach((key, value) {
                                      if (key == "motif") {
                                        current_valuesAdd["motif"] = "Autre";
                                      } else {
                                        current_valuesAdd[key] = "";
                                      }
                                    });
                                    current_currencyAdd = "€";
                                    current_docs_listAdd = [];
                                    predictionsAdd = [];
                                  });
                                }
                                _added = false;
                                ok = true;
                                _buttonVisible = true;
                              } else if ((_buttonText == "Ok" ||
                                      _buttonText == "Error") &&
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
                                  _buttonVisible =
                                      _buttonVisible ? false : true;
                                  _added = true;
                                });
                              }
                            },
                                constraints.maxWidth * 0.4,
                                50.0,
                                EdgeInsets.fromLTRB(
                                    constraints.maxWidth * 0.3, 40, 0, 0),
                                _buttonVisible,
                                context),
                          if (rows[i] != "button") field
                        ],
                      ),
                      SizedBox(height: 15)
                    ]);
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
              } else {
                return Container();
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
      body: (!widget.largeScreen) ? Stack(children: [
        content,
        Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        'Adding expenses',
                        style: TextStyle(color: TEXT_COLOR_DARKER, fontSize: 25)
                      )
                    )
                  )
      ]) : content,
    );
  }
}
