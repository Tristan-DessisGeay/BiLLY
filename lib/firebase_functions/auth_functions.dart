import 'package:billy/data_processing/expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

void loginToFirebase(
    _emailController, _passwordController, refresh, context) async {
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
        refresh();
      });
    });
  } catch (e) {
    print(e.toString());
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
