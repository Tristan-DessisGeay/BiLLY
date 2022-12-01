import 'dart:collection';

import 'package:billy/data_processing/user.dart';
import 'package:billy/firebase_functions/expense_functions.dart';
import 'package:billy/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_place/google_place.dart';
import 'package:sprung/sprung.dart';
import 'package:billy/custum_widgets/colorpoints.dart';

List list_expenses = current_user!.get("expenses");

Expense? current_expense = null;
String? current_currency = null;
String current_currencyAdd = "€";
List current_docs_list = [];
List current_docs_listAdd = [];
Map current_values = {
  "date": null,
  "motif": null,
  "précision": null,
  "lieu": null,
  "montant": null
};
Map current_valuesAdd = {
  "date": "",
  "motif": "Autre",
  "précision": "",
  "lieu": "",
  "montant": "",
  "etat": [false, false, false],
  "commentaire": ""
};
List<AutocompletePrediction> predictions = [];
List<AutocompletePrediction> predictionsAdd = [];
List<String> motifsList = [
  "Restaurant",
  "Hôtel",
  "Frais kilométriques",
  "Frais médicaux",
  "Autre"
];
bool lieuSelected = true;
bool lieuSelectedAdd = false;
double? currentYearFilter = null;
String? currentMonthFilter = null;

class Expense {
  late String id;
  late String date;
  late String motif;
  late String precision;
  late String lieu;
  late double montant;
  late String currency;
  late int etat;
  late List? docs;
  late String commentaire;

  Expense(
      String id,
      String date,
      String motif,
      String precision,
      String lieu,
      double montant,
      String currency,
      int etat,
      List? docs,
      String commentaire) {
    this.id = id;
    this.date = date;
    this.motif = motif;
    this.precision = precision;
    this.lieu = lieu;
    this.montant = montant;
    this.currency = currency;
    this.etat = etat;
    this.docs = docs;
    this.commentaire = commentaire;
  }

  dynamic get(String attr) {
    Map attrs = {
      "id": this.id,
      "date": this.date,
      "motif": this.motif,
      "précision": this.precision,
      "lieu": this.lieu,
      "montant": this.montant,
      "currency": this.currency,
      "etat": this.etat,
      "docs": this.docs,
      "commentaire": this.commentaire
    };
    return attrs[attr];
  }

  void set(String attr, dynamic value) {
    switch (attr) {
      case "id":
        {
          this.id = value;
        }
        break;
      case "date":
        {
          this.date = value;
        }
        break;
      case "motif":
        {
          this.motif = value;
        }
        break;
      case "précision":
        {
          this.precision = value;
        }
        break;
      case "lieu":
        {
          this.lieu = value;
        }
        break;
      case "montant":
        {
          this.montant = value;
        }
        break;
      case "currency":
        {
          this.currency = value;
        }
        break;
      case "etat":
        {
          this.etat = value;
        }
        break;
      case "docs":
        {
          this.docs = value;
        }
        break;
      case "commentaire":
        {
          this.commentaire = value;
        }
        break;
    }
  }
}

class ExpenseCell extends StatefulWidget {
  final Widget Function(bool isHovered) builder;
  final Function() refresh;
  final int userType;
  final Expense expense;

  const ExpenseCell(
      {Key? key,
      required this.expense,
      required this.builder,
      required this.refresh,
      required this.userType})
      : super(key: key);

  @override
  _ExpenseCell createState() => _ExpenseCell();
}

class _ExpenseCell extends State<ExpenseCell> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverdTransform = Matrix4.identity()..scale(0.98);
    final transform = isHovered ? hoverdTransform : Matrix4.identity();

    return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => onEntered(true),
        onExit: (event) => onEntered(false),
        child: AnimatedContainer(
            curve: Sprung.overDamped,
            duration: Duration(milliseconds: 200),
            transform: transform,
            child: GestureDetector(
                onTap: () {
                  current_expense = widget.expense;
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
                  lieuSelected = true;
                  lieuSelectedAdd = true;
                  if (widget.userType == 1) {
                    current_valuesAdd["etat"] = [false, false, false];
                    current_valuesAdd["commentaire"] = "";
                    current_docs_listAdd = [];
                  }
                  widget.refresh();

                  if (MediaQuery.of(context).size.width < 1000) {
                    setState(() {
                      Navigator.pushNamed(context,
                          (widget.userType == 0) ? 'home/view' : 'home/add',
                          arguments: {
                            "refresh": widget.refresh,
                            "userType": widget.userType
                          });
                    });
                  } else {
                    if (current_expense!.get("docs") == null) {
                      get_docs(widget.refresh);
                    }
                  }
                },
                child: widget.builder(isHovered))));
  }

  void onEntered(bool isHovered) => setState(() {
        this.isHovered = isHovered;
      });
}

Widget get_expense(date, values, context, refresh, userType) {
  return Container(
    padding: EdgeInsets.all(15),
    color: Theme.of(context).primaryColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(color: TEXT_COLOR_DARKER, fontSize: 18),
          softWrap: false,
        ),
        for (int i = 0; i < values.length; i++)
          ExpenseCell(
              refresh: refresh,
              userType: userType,
              expense: values[i],
              builder: (isHovered) {
                final color = isHovered ? Colors.grey.withOpacity(.3) : null;
                final decoration = isHovered
                    ? BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.all(Radius.circular(20)))
                    : null;
                final textlen = RenderParagraph(
                        TextSpan(
                            text: values[i].get("motif") +
                                values[i].get("montant").toString() +
                                " " +
                                values[i].get("currency")),
                        textDirection: TextDirection.ltr)
                    .getMaxIntrinsicWidth(16)
                    .ceilToDouble();
                final row = Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      [
                        green_point,
                        orange_point,
                        red_point
                      ][values[i].get("etat")],
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(values[i].get("motif"),
                              style: TextStyle(
                                  color: TEXT_COLOR_LIGHTER, fontSize: 16))),
                    ]),
                    Padding(padding: EdgeInsets.all(10)),
                    Text(
                        values[i].get("montant").toString() +
                            " " +
                            values[i].get("currency"),
                        style:
                            TextStyle(color: TEXT_COLOR_LIGHTER, fontSize: 16))
                  ],
                );
                return Container(
                  decoration: decoration,
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.fromLTRB(30, 10, 0, 0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    double? minWidth = textlen + 90;
                    double? maxWidth = constraints.maxWidth;
                    if (maxWidth > minWidth) {
                      return row;
                    } else {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: row,
                      );
                    }
                  }),
                );
              }),
      ],
    ),
  );
}

List get_expenses(context, refresh, userType) {
  if (current_user != null) {
    list_expenses = current_user!.get("expenses");
    if (list_expenses.length > 0) {
      Map years = {};
      for (int i = 0; i < list_expenses.length; i++) {
        var e = list_expenses[i];
        int year = int.parse((e.get("date")).split("/")[0]);
        if (years.containsKey(year)) {
          years[year].add(e);
        } else {
          years[year] = [e];
        }
      }
      years = new SplayTreeMap<int, dynamic>.from(years);
      Map months;
      years.forEach((year, values) {
        months = {};
        for (int i = 0; i < values.length; i++) {
          int month = int.parse((values[i].get("date")).split("/")[1]);
          if (months.containsKey(month)) {
            months[month].add(values[i]);
          } else {
            months[month] = [values[i]];
          }
        }
        years[year] = SplayTreeMap<int, dynamic>.from(months);
        Map days;
        years[year].forEach((month, values) {
          days = {};
          for (int i = 0; i < values.length; i++) {
            int day = int.parse((values[i].get("date")).split("/")[2]);
            if (days.containsKey(day)) {
              days[day].add(values[i]);
            } else {
              days[day] = [values[i]];
            }
          }
          years[year][month] = SplayTreeMap<int, dynamic>.from(days);
        });
      });

      List out = [];
      int yearsIndex = -1;
      years.forEach((key, value) {
        yearsIndex += 1;
        List expenses = [];
        String date = "";
        value.forEach((month, days) {
          if (date == "") {
            date = key.toString() + "/" + month.toString();
          }
          if (date == key.toString() + "/" + month.toString()) {
            days.forEach((day, exps) {
              for (int i = 0; i < exps.length; i++) {
                expenses.insert(0, exps[i]);
              }
            });
          } else {
            String year = date.split("/")[0];
            int m = int.parse(date.split("/")[1]);
            String month = [
              "January",
              "February",
              "March",
              "April",
              "May",
              "June",
              "July",
              "August",
              "September",
              "October",
              "November",
              "December"
            ][m - 1];
            if (context != null &&
                (double.parse(year) == currentYearFilter ||
                    currentYearFilter == null) &&
                (month == currentMonthFilter || currentMonthFilter == null)) {
              out.add(get_expense(
                  year + " - " + month, expenses, context, refresh, userType));
              date = key.toString() + "/" + m.toString();
              expenses = [];
              days.forEach((day, exps) {
                for (int i = 0; i < exps.length; i++) {
                  expenses.insert(0, exps[i]);
                }
              });
            }
          }
          date = key.toString() + "/" + month.toString();
        });
        String year = date.split("/")[0];
        int m = int.parse(date.split("/")[1]);
        String month = [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December"
        ][m - 1];
        if (context != null &&
            (double.parse(year) == currentYearFilter ||
                currentYearFilter == null) &&
            (month == currentMonthFilter || currentMonthFilter == null)) {
          out.add(get_expense(
              year + " - " + month, expenses, context, refresh, userType));
          if (yearsIndex == years.length - 1 && current_expense == null) {
            current_expense = expenses[0];
            if (current_expense!.get("docs") == null) {
              get_docs(refresh);
            }
          }
        }
      });
      return List.from(out.reversed);
    } else {
      return [];
    }
  } else {
    return [];
  }
}
