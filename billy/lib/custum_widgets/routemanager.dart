import 'package:billy/pages/accountant/right_bottom.dart';
import 'package:billy/pages/admin/right_bottom.dart';
import 'package:billy/pages/admin/right_top.dart';
import 'package:billy/pages/common/expense_list.dart';
import 'package:billy/pages/user/right_bottom.dart';
import 'package:billy/pages/user/right_top.dart';
import 'package:billy/pages/auth/mdp.dart';
import 'package:flutter/material.dart';
import 'package:billy/pages/auth/auth.dart';
import 'package:billy/pages/common/home.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case 'auth':
        return MaterialPageRoute(builder: (context) => LoginPage());
      case 'auth/mdp':
        return SwipeablePageRoute(
          canOnlySwipeFromEdge: true,
          builder: (context) => MdpPage(),
        );
      case 'home':
        Map arguments = settings.arguments as Map;
        return PageRouteBuilder(pageBuilder: (context, a1, a2) => HomePage(userType: arguments["userType"]), 
        transitionDuration: Duration(milliseconds: 280),
        transitionsBuilder: (context, a1, a2, child) {
          return ScaleTransition(scale: a1,child: child,);
        });
      case 'home/view':
        Map arguments = settings.arguments as Map;
        if(arguments["userType"]==0) {
          return SwipeablePageRoute(
            canOnlySwipeFromEdge: true,
            builder: (context) => RightTop_User(notifyParent: arguments["refresh"], largeScreen: false),
          );
        }else if(arguments["userType"]==1) {
          return SwipeablePageRoute(
            canOnlySwipeFromEdge: true,
            builder: (context) => ExpenseList(refresh: arguments["refresh"], largeScreen: false, userType: 1, exception: false,),
          );
        }else{
          return SwipeablePageRoute(
            canOnlySwipeFromEdge: true,
            builder: (context) => RightTop_Admin(notifyParent: arguments["refresh"], largeScreen: false),
          );
        }
      case 'home/add':
        Map arguments = settings.arguments as Map;
        if(arguments["userType"]==0) {
          return SwipeablePageRoute(
            canOnlySwipeFromEdge: true,
            builder: (context) => RightBottom_User(notifyParent: arguments["refresh"], largeScreen: false),
          );
        }else if(arguments["userType"]==1) {
          return SwipeablePageRoute(
            canOnlySwipeFromEdge: true,
            builder: (context) => RightBottom_Accountant(notifyParent: arguments["refresh"], largeScreen: false),
          );
        }else{
          return SwipeablePageRoute(
            canOnlySwipeFromEdge: true,
            builder: (context) => RightBottom_Admin(notifyParent: arguments["refresh"], largeScreen: false),
          );
        }
      default :
        return MaterialPageRoute(builder: (context) => LoginPage());
    }
  }
}