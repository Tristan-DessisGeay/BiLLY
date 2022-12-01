import 'dart:collection';
import 'dart:math';

import 'package:billy/custum_widgets/colorpoints.dart';
import 'package:billy/data_processing/expense.dart';
import 'package:billy/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sprung/sprung.dart';

List<User?> list_users = [null];

User? current_user = null;
bool current_filter = true;
bool current_sens = false;
Map currentValuesUser = {
  "email": null,
  "type": [false, false, false]
};
Map currentValuesUserAdd = {
  "email": "",
  "password": "azerty1234",
  "type": [true, false, false]
};

class User {
  late String id;
  late String email;
  late String password;
  late List<Expense>? expenses;
  late int type;

  User(this.id, this.password, this.email, this.expenses, this.type);

  dynamic get(String attr) {
    Map attrs = {
      "id": id,
      "password": password,
      "email": email,
      "expenses": expenses,
      "type": type
    };
    return attrs[attr];
  }

  void set(String attr, dynamic value) {
    switch (attr) {
      case "id":
        {
          id = value;
        }
        ;
        break;
      case "expenses":
        {
          expenses = value;
        }
        ;
        break;
      case "type":
        {
          type = value;
        }
        ;
        break;
    }
  }
}

class UserCell extends StatefulWidget {
  final Widget Function(bool isHovered) builder;
  final Function() refresh;
  final int userType;
  final User user;

  const UserCell(
      {Key? key,
      required this.user,
      required this.userType,
      required this.refresh,
      required this.builder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserCell();
}

class _UserCell extends State<UserCell> {
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
                  current_user = widget.user;
                  currentValuesUser = {
                    "email": null,
                    "password": null,
                    "type": [false, false, false]
                  };
                  widget.refresh();
                  if (MediaQuery.of(context).size.width < 1000) {
                    setState(() {
                      Navigator.pushNamed(context, 'home/view', arguments: {
                        "refresh": widget.refresh,
                        "userType": widget.userType
                      });
                    });
                  }
                },
                child: widget.builder(isHovered))));
  }

  void onEntered(bool isHovered) => setState(() {
        this.isHovered = isHovered;
      });
}

Widget get_user(user, context, refresh, userType) {
  return Container(
      color: Theme.of(context).primaryColor,
      child: UserCell(
          user: user,
          userType: userType,
          refresh: refresh,
          builder: (isHovered) {
            final color = isHovered ? Colors.grey.withOpacity(.3) : null;
            final decoration = isHovered
                ? BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.all(Radius.circular(20)))
                : null;
            var value;
            if (userType == 1) {
              value = 0;
              user.get("expenses").forEach((expense) {
                if (expense.get("etat") == 1) value += 1;
              });
            } else {
              value = ["User", "Accountant", "Admin"][user.get("type")];
            }
            final textlen = RenderParagraph(
                        TextSpan(text: user.get("email") + value.toString()),
                        textDirection: TextDirection.ltr)
                    .getMaxIntrinsicWidth(16)
                    .ceilToDouble() +
                20;
            final row = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(user.get("email"),
                    style: TextStyle(color: TEXT_COLOR_LIGHTER, fontSize: 16)),
                SizedBox(width: 20),
                Row(children: [
                  Text(value.toString(),
                      style:
                          TextStyle(color: TEXT_COLOR_LIGHTER, fontSize: 16)),
                  if (userType == 1) SizedBox(width: 10),
                  if (userType == 1) orange_point
                ])
              ],
            );
            return Container(
                decoration: decoration,
                padding: EdgeInsets.all(5),
                child: LayoutBuilder(builder: (context, constraints) {
                  double? minWidth = textlen + 50;
                  double? maxWidth = constraints.maxWidth;
                  if (maxWidth > minWidth) {
                    return row;
                  } else {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: row,
                    );
                  }
                }));
          }));
}

List get_users(context, refresh, userType) {
  if (list_users.length > 0) {
    SplayTreeMap<dynamic, List<User>> users =
        SplayTreeMap<dynamic, List<User>>();
    list_users.forEach((user) {
      if (current_filter == true) {
        users[user!.get("email")] = [user];
      } else {
        if (userType == 1) {
          int attente = 0;
          user!.get("expenses").forEach((expense) {
            if (expense.get("etat") == 1) attente += 1;
          });
          if (users.containsKey(attente)) {
            users[attente]?.add(user);
          } else {
            users[attente] = [user];
          }
        } else {
          String typeUser = ["User", "Accountant", "Admin"][user!.get("type")];
          if (users.containsKey(typeUser)) {
            users[typeUser]?.add(user);
          } else {
            users[typeUser] = [user];
          }
        }
      }
    });
    List out = [];
    User? first = null;
    User? last = null;
    int counter = 0;
    users.forEach((key, value) {
      counter += 1;
      value.forEach((element) {
        out.add(get_user(element, context, refresh, userType));
      });
      if (counter == 1) first = value[0];
      if (counter == users.length) last = value[value.length - 1];
    });
    if (current_sens == true) {
      if (current_user == null) current_user = last!;
      return List.from(out.reversed);
    }
    if (current_user == null) current_user = first!;
    return out;
  } else {
    return [];
  }
}
