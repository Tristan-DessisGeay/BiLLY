import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:billy/custum_widgets/routemanager.dart';
import 'package:billy/theme/themes.dart';
import 'package:flutter/material.dart';
import 'custum_widgets/scrollbehavior.dart';
void main() {
  runApp(const MyApp());
}

// flutter run -d chrome --web-renderer html --no-sound-null-safety

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: lightTheme,
      dark: darkTheme,
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
                      scrollBehavior: MyCustomScrollBehavior(),
                      debugShowCheckedModeBanner: false,
                      title: 'BiLLY',
                      initialRoute: 'auth',
                      onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings),
                      theme: theme,
                      darkTheme: darkTheme,
                    )
    );
  }
}
