import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/custum_widgets/appBars.dart';
import 'package:billy/custum_widgets/buttons.dart';
import 'package:billy/custum_widgets/loading_page.dart';
import 'package:billy/custum_widgets/splitviews.dart';
import 'package:billy/data_processing/user.dart';
import 'package:billy/pages/common/expense_list.dart';
import 'package:billy/pages/user/right_bottom.dart';
import 'package:billy/pages/user/right_top.dart';
import 'package:billy/theme/colors.dart';
import 'package:billy/theme/themes.dart';
import 'package:flutter/material.dart';
import '../../../firebase_functions/expense_functions.dart';

class Accueil_User extends StatefulWidget{
  final Function() refresh;

  const Accueil_User({
    Key? key,
    required this.refresh
  }) : super(key: key);

  _Accueil createState()=> _Accueil();
}

class _Accueil extends State<Accueil_User>{

  @override
  void initState() {
    super.initState();
    if(current_user==null) {
      get_expenses(() {
        setState(() {});
      }, null, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: get_appBar([
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
          ], context, true, false),
        body: Container(
          color: Theme.of(context).primaryColor,
          child: (MediaQuery.of(context).size.width>1000)?VerticalSplitView(
            ratio: 0.3,
            left: Container(
              padding: EdgeInsets.fromLTRB(0, 15, 15, 15),
              child: (current_user!=null)
                      ?ExpenseList(refresh: widget.refresh, userType: 0, largeScreen: true, exception: false,)
                      :loadingPage(BoxDecoration(border: Border(right: BorderSide(color: BLUE_COLOR_L))))
            ),
            right: Container(
              child: HorizontalSplitView(
                top: Container(
                  padding: EdgeInsets.all(15),
                  child: Stack(
                    children: [
                      (current_user!=null)
                      ?RightTop_User(notifyParent: widget.refresh, largeScreen: true)
                      :loadingPage(BoxDecoration(border: Border.all(color: BLUE_COLOR_L),
        borderRadius: BorderRadius.only(bottomLeft : Radius.circular(15)))),
                      Container(height: 2, color: (darkMode)?Colors.black:Colors.white),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children : [
                          Container(width: 1, color: (darkMode)?Colors.black:Colors.white)
                        ]
                      )
                    ]
                  )
                ),
                bottom: Container(
                  padding: EdgeInsets.all(15),
                  child: Stack(
                    children: [
                      (current_user!=null)
                      ?RightBottom_User(notifyParent: widget.refresh, largeScreen: true,)
                      :loadingPage(BoxDecoration(border: Border.all(color: BLUE_COLOR_L),
        borderRadius: BorderRadius.only(topLeft : Radius.circular(15)))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children : [
                          Container(width: 1, color: (darkMode)?Colors.black:Colors.white)
                        ]
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children : [
                          Container(height: 1, color: (darkMode)?Colors.black:Colors.white)
                        ]
                      )
                    ],
                  )
                ),
              ),
            ),
          ):Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children : [
              Container(
                height: MediaQuery.of(context).size.height-100-100,
                child: (current_user!=null)
                ?ExpenseList(refresh: widget.refresh, userType: 0, largeScreen: true, exception:true)
                :loadingPage(null)
              ),
              get_simple_button("Ajouter", 
              () {
                setState( () {
                  Navigator.pushNamed(context, 'home/add', arguments: {
                    "refresh": widget.refresh,
                    "userType": 0
                  });
                });
              }, MediaQuery.of(context).size.width * 0.4, 50, EdgeInsets.fromLTRB(0, 20, 0, 20), context)
            ]
          )
        ),
      );
  }
}