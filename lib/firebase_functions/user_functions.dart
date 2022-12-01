import 'package:billy/firebase_functions/expense_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billy/custum_widgets/user.dart' as LocalUser;
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

void get_users(refresh, userType) async {
  await firestore.collection("Users").get().then((users) async {
    for (int i = 0; i < users.docs.length; i++) {
      var user = users.docs[i];
      if (userType == 1 && user["type"] == 0 || userType == 2) {
        LocalUser.list_users.add(
            LocalUser.User(user.id, "", user["email"], null, user["type"]));
        if (i == users.docs.length -1) {
          if (userType == 1) {
            await get_expenses(refresh, user.id, true);
          }
          LocalUser.list_users.removeAt(0);
          refresh();
        } else {
          if (userType == 1) {
            await get_expenses(refresh, user.id, false);
          }
        }
      }else if(i == users.docs.length -1) {
        LocalUser.list_users.removeAt(0);
        refresh();
      }
    }
  });
}

void update_user() async {
  await firestore
      .collection("Users")
      .doc(LocalUser.current_user!.get("id"))
      .set({
    "email": LocalUser.current_user!.get("email"),
    "type": LocalUser.current_user!.get("type")
  }).catchError(
    (error) => print("Erreur: $error"),
  );
}

void create_user(widget) {
  auth
      .createUserWithEmailAndPassword(
          email: LocalUser.list_users.last!.get("email"),
          password: LocalUser.list_users.last!.get("password"))
      .then((user) {
    String uid = user.user!.uid.toString();
    LocalUser.list_users.last!.set("id", uid);
    firestore.collection("Users").doc(uid).set({
      "type": LocalUser.list_users.last!.get("type"),
      "email": LocalUser.list_users.last!.get("email")
    });
  }).catchError((e) {
    LocalUser.list_users.removeLast();
    widget.notifyParent();
  });
}
