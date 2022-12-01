import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/custum_widgets/appBars.dart';
import 'package:billy/custum_widgets/inputs.dart';
import 'package:billy/theme/colors.dart';
import 'package:billy/theme/themes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:billy/custum_widgets/expense.dart';

class ExpenseList extends StatefulWidget{
  final Function() refresh;
  final bool largeScreen;
  final int userType;
  final bool exception;
  ExpenseList({
    Key? key,
    required this.refresh,
    required this.largeScreen,
    required this.userType,
    required this.exception
  }) : super(key: key);
  _ExpenseList createState()=> _ExpenseList();
}

class _ExpenseList extends State<ExpenseList>{

  @override
  Widget build(BuildContext context) {

    List expenses_list = get_expenses(context, widget.refresh, widget.userType);
    Widget filter = Container(
                color: (darkMode)?BACKGROUND_COLOR_D:BACKGROUND_COLOR_L,
                height: 65,
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: LayoutBuilder(
                  builder:(context, constraints) {
                    TextEditingController c1 = TextEditingController();
                    c1.text = (currentYearFilter!=null)?currentYearFilter.toString():"";
                    TextEditingController c2 = TextEditingController();
                    c2.text = (currentMonthFilter!=null)?currentMonthFilter.toString():"";
                    Widget row = Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        get_simple_field("Specific year", false, constraints.maxWidth * 0.4, true, c1, 
                                        (v) {
                                          if(v=="") currentYearFilter = null;
                                          else if(int.tryParse(v)!=null) currentYearFilter = double.parse(v);
                                        },
                                        () {
                                          setState(() {});
                                          widget.refresh();
                                        }),
                                        get_simple_field("Specific month", false, constraints.maxWidth * 0.4, true, c2,
                                        (v) {
                                          if(v == "") currentMonthFilter = null;
                                          else if(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"].contains(v)) currentMonthFilter = v; 
                                        },
                                        () {
                                          setState(() {});
                                          widget.refresh();
                                        })
                                      ],
                                    );
                    double? minWidth = 5;
                    double? maxWidth = constraints.maxWidth;
                    if(maxWidth>minWidth) {
                      return row;
                    }else{
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: row,
                      );
                    }
                  }
                ),
              );

    Widget content;
    if(expenses_list.length>0) {
      content = Container(
        decoration: (widget.exception)?null:(widget.largeScreen&&widget.userType==0)?BoxDecoration(
                border: Border(right: BorderSide(color: BLUE_COLOR_L))
              ):(widget.largeScreen&&widget.userType==1)?BoxDecoration(
                border: Border.all(color: BLUE_COLOR_L),
                borderRadius: BorderRadius.only(bottomLeft : Radius.circular(15))):null,
        child: 
        Stack(
            children: [
                Container(
                  padding: EdgeInsets.fromLTRB(15, 65, 15, 15),
                  child: SingleChildScrollView(
                    child: Expanded(
                      child: SizedBox(
                        height: (!widget.exception)?MediaQuery.of(context).size.height-210:MediaQuery.of(context).size.height-225,
                        child: ListView.separated(
                                itemCount: expenses_list.length,
                                itemBuilder: (context, index) {
                                  return expenses_list[index];
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 15);
                                },
                              )
                      )
                    )
                  )
                ),
                filter
            ]
          )
        
      );
    }else{
      content = Container(
        decoration: (widget.exception)?null:(widget.largeScreen&&widget.userType==0)?BoxDecoration(
                      border: Border(right: BorderSide(color: BLUE_COLOR_L))
                    ):(widget.largeScreen&&widget.userType==1)?BoxDecoration(
                      border: Border.all(color: BLUE_COLOR_L),
                      borderRadius: BorderRadius.only(bottomLeft : Radius.circular(15))):null,
        child: SingleChildScrollView(
          child: Column(
            children: [
              filter,
              Padding(padding: EdgeInsets.fromLTRB(0, 100, 0, 0)),
              Center(child: Text("No expenses have been incurred yet", textAlign: TextAlign.center, style: TextStyle(color: TEXT_COLOR_DARKER, fontSize: 30),)),
              Padding(padding: EdgeInsets.fromLTRB(0, 500, 0, 0)),
            ],
          )
        )
      );
    }

    return Scaffold(
        appBar: (!widget.largeScreen)?get_appBar([
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
          ], context, false, false):null,
        body: content,
      );
  }

}