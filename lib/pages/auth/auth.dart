import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/data_processing/expense.dart';
import 'package:billy/custum_widgets/inputs.dart';
import 'package:billy/custum_widgets/appBars.dart';
import 'package:billy/custum_widgets/buttons.dart';
import 'package:billy/data_processing/user.dart' as LocalUser;
import 'package:billy/firebase_functions/auth_functions.dart';
import 'package:billy/firebase_options.dart';
import 'package:billy/theme/colors.dart';
import 'package:billy/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void reset() {
  print("Reset !");
  LocalUser.current_user = null;
  LocalUser.list_users = [null];
  current_expense = null;
}

class LoginPage extends StatefulWidget {
  Page createState() => Page();
}

class Page extends State<LoginPage> {
  bool _obscureText = true;
  Color _lastString = TEXT_COLOR_DARKER;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    reset();
    firebaseInit();
    refreshThemeMode();
  }

  Future<void> firebaseInit() async {
    await WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void refreshThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if (savedThemeMode.toString() == 'AdaptiveThemeMode.light') {
      darkMode = false;
    } else {
      darkMode = true;
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
          iconSize: (MediaQuery.of(context).size.width > 300) ? 40 : 30,
        )
      ], context, false, true),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Stack(
          children: [
            Positioned(
                left: MediaQuery.of(context).size.width * 0.25,
                top: MediaQuery.of(context).size.height * 0.10,
                child: get_simple_field(
                    'Email',
                    true,
                    MediaQuery.of(context).size.width * 0.5,
                    true,
                    _emailController,
                    (v) {},
                    () {})),
            Positioned(
                left: MediaQuery.of(context).size.width * 0.25,
                top: MediaQuery.of(context).size.height * 0.25,
                child: get_hidden_field(
                    'Password', true, MediaQuery.of(context).size.width * 0.5,
                    () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                }, _obscureText, true, _passwordController, (v) {})),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.35,
                left: MediaQuery.of(context).size.width * 0.5 - 30,
                child: get_B_button(() {
                  loginToFirebase(_emailController, _passwordController, () {
                    setState(() {});
                  }, context);
                },
                    EdgeInsets.fromLTRB(
                        0, MediaQuery.of(context).size.height * 0.10, 0, 0),
                    context)),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.55,
              left: MediaQuery.of(context).size.width * 0.5 -
                  (MediaQuery.of(context).size.width * 0.5 / 2),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 10,
                margin: EdgeInsets.fromLTRB(
                    0, MediaQuery.of(context).size.height * 0.10, 0, 0),
                decoration: BoxDecoration(
                    color: Theme.of(context).buttonColor,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
            ),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.7,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: Text('Forgotten password',
                          style: TextStyle(color: _lastString)),
                      onTap: () {
                        Navigator.pushNamed(context, 'auth/mdp');
                      },
                    ),
                    onHover: (event) {
                      setState(() {
                        _lastString = Theme.of(context).buttonColor;
                      });
                    },
                    onExit: (event) {
                      setState(() {
                        _lastString = TEXT_COLOR_DARKER;
                      });
                    },
                  )),
                  margin: EdgeInsets.fromLTRB(
                      0, MediaQuery.of(context).size.height * 0.05, 0, 0),
                )),
          ],
        ),
      ),
    );
  }
}
