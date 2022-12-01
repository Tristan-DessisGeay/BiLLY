import 'package:billy/pages/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:billy/theme/colors.dart';

PreferredSizeWidget get_appBar(actions, context, homePage, authPage) {
  return AppBar(
    centerTitle: true,
    iconTheme: IconThemeData (color: Colors.white),
    backgroundColor: Theme.of(context).primaryColor,
    toolbarHeight: 100,
    leading: (authPage)?null:(homePage)?
    IconButton(
      onPressed: () {
        reset();
        Navigator.pop(context);
      } , 
      icon: Icon(Icons.exit_to_app_rounded),
      iconSize: (MediaQuery.of(context).size.width>300)?30:20,
    )
    :IconButton(
      onPressed: () => Navigator.pop(context), 
      icon: Icon(Icons.arrow_back_ios_new_rounded),
      iconSize: (MediaQuery.of(context).size.width>300)?30:20,
    ),
    shadowColor: Theme.of(context).buttonColor.withOpacity(0.3),
    title: Center(
      child: Text(
        'BiLLY',
        style: TextStyle(
          fontSize: (MediaQuery.of(context).size.width>300)?50:40,
          color: Colors.white,
        ),
      )
    ),
    actions: actions,
    flexibleSpace: Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          BLUE_COLOR_L.withOpacity(1),
          BLUE_COLOR_L.withOpacity(0.9),
          BLUE_COLOR_L.withOpacity(0.8),
          BLUE_COLOR_L.withOpacity(0.7),
          BLUE_COLOR_L.withOpacity(0.6),
          BLUE_COLOR_L.withOpacity(0.5),
          BLUE_COLOR_L.withOpacity(0.4),
          BLUE_COLOR_L.withOpacity(0.3),
        ]
      )
    ),
    )
  );
}