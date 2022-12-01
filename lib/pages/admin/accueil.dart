import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/custum_widgets/appBars.dart';
import 'package:billy/custum_widgets/buttons.dart';
import 'package:billy/custum_widgets/loading_page.dart';
import 'package:billy/custum_widgets/splitviews.dart';
import 'package:billy/pages/admin/right_bottom.dart';
import 'package:billy/pages/admin/right_top.dart';
import 'package:billy/pages/common/user_list.dart';
import 'package:billy/theme/colors.dart';
import 'package:billy/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:billy/custum_widgets/user.dart' as LocalUser;
import 'package:billy/firebase_functions/user_functions.dart' as userFunctions;

class Accueil_Admin extends StatefulWidget {
  final Function() refresh;

  const Accueil_Admin({Key? key, required this.refresh}) : super(key: key);

  _Accueil createState() => _Accueil();
}

class _Accueil extends State<Accueil_Admin> {
  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (LocalUser.list_users[0] == null) {
      userFunctions.get_users(refresh, 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: get_appBar([
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
          icon: Icon(
              (darkMode) ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          iconSize: 40,
        )
      ], context, true, false),
      body: Container(
          color: Theme.of(context).primaryColor,
          child: (MediaQuery.of(context).size.width > 1000)
              ? VerticalSplitView(
                  ratio: 0.3,
                  left: Container(
                      padding: EdgeInsets.fromLTRB(0, 15, 15, 15),
                      child: (LocalUser.list_users[0] != null)
                          ? UserList(
                              refresh: widget.refresh,
                              userType: 2,
                              largeScreen: true,
                              exception: false,
                            )
                          : loadingPage(BoxDecoration(
                              border: Border(
                                  right: BorderSide(color: BLUE_COLOR_L))))),
                  right: Container(
                    child: HorizontalSplitView(
                      top: Container(
                          padding: EdgeInsets.all(15),
                          child: Stack(
                            children: [
                              (LocalUser.list_users[0] != null)
                                  ? RightTop_Admin(
                                      notifyParent: widget.refresh,
                                      largeScreen: true)
                                  : loadingPage(BoxDecoration(
                                      border: Border.all(color: BLUE_COLOR_L),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15)))),
                              Container(
                                  height: 2,
                                  color:
                                      (darkMode) ? Colors.black : Colors.white),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                        width: 1,
                                        color: (darkMode)
                                            ? Colors.black
                                            : Colors.white)
                                  ])
                            ],
                          )),
                      bottom: Container(
                          padding: EdgeInsets.all(15),
                          child: Stack(
                            children: [
                              (LocalUser.list_users[0] != null)
                                  ? RightBottom_Admin(
                                      notifyParent: widget.refresh,
                                      largeScreen: true)
                                  : loadingPage(BoxDecoration(
                                      border: Border.all(color: BLUE_COLOR_L),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15)))),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                        width: 1,
                                        color: (darkMode)
                                            ? Colors.black
                                            : Colors.white)
                                  ]),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                        height: 1,
                                        color: (darkMode)
                                            ? Colors.black
                                            : Colors.white)
                                  ])
                            ],
                          )),
                    ),
                  ),
                )
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                      height: MediaQuery.of(context).size.height - 100 - 100,
                      child: (LocalUser.list_users[0] != null)
                          ? UserList(
                              refresh: widget.refresh,
                              userType: 2,
                              largeScreen: false,
                              exception: true,
                            )
                          : loadingPage(null)),
                  get_simple_button("Add", () {
                    setState(() {
                      Navigator.pushNamed(context, 'home/add', arguments: {
                        "refresh": widget.refresh,
                        "userType": 2
                      });
                    });
                  }, MediaQuery.of(context).size.width * 0.4, 50,
                      EdgeInsets.fromLTRB(0, 20, 0, 20), context)
                ])),
    );
  }
}
