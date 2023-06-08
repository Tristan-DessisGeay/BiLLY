import 'package:billy/data_processing/expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
String label_connected_user = '';

void loginToFirebase(
    _emailController, _passwordController, refresh, context, darkMode) async {
  try {
    await auth
        .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim())
        .then((userCredential) async {
      await firestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .get()
          .then((document) {
        Navigator.pushNamed(context, 'home',
            arguments: {"userType": document.data()!["type"]});
        label_connected_user = _emailController.text.trim() + ' - ' + ['User', 'Accountant', 'Admin'][document.data()!["type"]];
        refresh();
      });
    });
  } catch (e) {

    String msg = '';
    if (e.toString().contains('invalid-email')) msg = 'The email address is badly formatted.';
    else if(e.toString().contains('internal-error')) msg = 'This email does not exists.';
    else if(e.toString().contains('too-many-requests')) msg = 'Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.';
    else msg = 'The password is invalid or the user does not have a password.';

    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Connexion - Error', style: TextStyle(color: BACKGROUND_COLOR_L),),
      content: Text(msg, style: TextStyle(color: BACKGROUND_COLOR_L),),
      actions: [
        TextButton(
            child: Text('Ok', style: TextStyle(color: BACKGROUND_COLOR_L)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
      ],
      elevation: 24,
      backgroundColor: darkMode ? BLUE_COLOR_D : BLUE_COLOR_L,
      actionsAlignment: MainAxisAlignment.center
    ));
  }
}

Future sendPassReset(email) async {
  return await auth
      .sendPasswordResetEmail(email: email)
      .then((value) => true)
      .catchError((e) {
    print(e);
    return false;
  });
}
