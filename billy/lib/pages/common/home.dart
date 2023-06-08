import 'package:billy/pages/accountant/accueil.dart';
import 'package:billy/pages/admin/accueil.dart';
import 'package:billy/pages/user/accueil.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final int userType;

  const HomePage({Key? key, required this.userType}) : super(key: key);

  Page createState() => Page();
}

class Page extends State<HomePage> {
  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userType == 0) {
      return Accueil_User(refresh: refresh);
    } else if (widget.userType == 1) {
      return Accueil_Accountant(refresh: refresh);
    } else {
      return Accueil_Admin(refresh: refresh);
    }
  }
}
