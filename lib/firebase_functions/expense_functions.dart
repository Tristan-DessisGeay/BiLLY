import 'package:billy/custum_widgets/expense.dart';
import 'package:billy/custum_widgets/user.dart' as LocalUser;
import 'package:billy/custum_widgets/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:universal_html/html.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseStorage firestorage = FirebaseStorage.instance;

void update_expense(accountant) {
  if(!accountant) {
    for(int i=0;i<current_expense!.get("docs").length;i++) {
      var doc = current_expense!.get("docs")[i];
      if(doc.length==2) {
        final reader = FileReader();
        reader.readAsDataUrl(doc[1]!);
        reader.onLoadEnd.listen((event) async {
          var snapshot = await firestorage.ref(current_expense!.get("id")).child(doc[1].name).putBlob(doc[1]);
          String downloadUrl = await snapshot.ref.getDownloadURL();
          current_expense!.get("docs")[i][0] = downloadUrl;
        });
      }
    }
    firestore
      .collection('Users/${auth.currentUser!.uid}/Expenses')
      .doc(current_expense!.get("id"))
      .set({
        'commentaire': current_expense!.get("commentaire"),
        'date': current_expense!.get("date"),
        'etat': current_expense!.get("etat"),
        'lieu': current_expense!.get("lieu"),
        'monnaie': current_expense!.get("currency"),
        'montant': current_expense!.get("montant"),
        'motif': current_expense!.get("motif"),
        'précision': current_expense!.get("précision"),
      })
      .catchError(
        (error) => print("Erreur: $error"),
      );
  }else{
    firestore
      .collection('Users/${current_user!.get("id")}/Expenses')
      .doc(current_expense!.get("id"))
      .set({
        'commentaire': current_expense!.get("commentaire"),
        'date': current_expense!.get("date"),
        'etat': current_expense!.get("etat"),
        'lieu': current_expense!.get("lieu"),
        'monnaie': current_expense!.get("currency"),
        'montant': current_expense!.get("montant"),
        'motif': current_expense!.get("motif"),
        'précision': current_expense!.get("précision"),
      })
      .catchError(
        (error) => print("Erreur: $error"),
      );
  }
}

void delete_expense() async {
  String id = current_expense!.get("id");
  await firestore.collection("Users/${auth.currentUser!.uid.toString()}/Expenses").doc(id).delete();
  await firestorage.ref(id)
                    .listAll().then((listDoc) {
                      listDoc.items.forEach((doc) {
                        firestorage.ref(doc.fullPath).delete();
                      });
  });
}

void delete_doc(doc) async {
  String docName = ((doc[0].split("/").last).split("?").first).substring(current_expense!.get("id").length+3);
  await firestorage.ref(current_expense!.get("id")).child(docName).delete();
}

void add_expense(expense, widget) async {
  firestore
    .collection('Users/${auth.currentUser!.uid}/Expenses')
    .add(
        {
        'commentaire': expense!.get("commentaire"),
        'date': expense!.get("date"),
        'etat': expense!.get("etat"),
        'lieu': expense!.get("lieu"),
        'monnaie': expense!.get("currency"),
        'montant': expense!.get("montant"),
        'motif': expense!.get("motif"),
        'précision': expense!.get("précision"),
      }
    )
    .catchError(
      (error) => print("Erreur: $error"),
    ).then((value) {
      expense.set("id", value.id);
      for(int i=0;i<expense!.get("docs").length;i++) {
        var doc = expense!.get("docs")[i];
        if(doc.length==2) {
          final reader = FileReader();
          reader.readAsDataUrl(doc[1]!);
          reader.onLoadEnd.listen((event) async {
            var snapshot = await firestorage.ref(expense!.get("id")).child(doc[1].name).putBlob(doc[1]);
            String downloadUrl = await snapshot.ref.getDownloadURL();
            List docList = expense!.get("docs");
            docList[i][0] = downloadUrl;
            expense!.set("docs", docList);
          });
        }
      }
      list_expenses.add(expense);
      widget.notifyParent();
    });
}

Future get_expenses(refresh, userUid, lastUser) async {
  // print("UserUId :"+userUid);
  List<Expense> userExpenses = [];
  await firestore.collection("Users/${(userUid==null)?auth.currentUser!.uid.toString():userUid}/Expenses").get().then((expenses) {
    if(expenses.docs.length>0) {
      for(int i=0;i<expenses.docs.length;i++) {
        var expense = expenses.docs[i];
        // print(expense.id);
        userExpenses.add(Expense(
          expense.id,
          expense["date"],
          expense["motif"],
          expense["précision"],
          expense["lieu"],
          expense["montant"],
          expense["monnaie"],
          expense["etat"],
          null,
          expense["commentaire"]
        ));
        if((userUid==null&&i==expenses.docs.length-1)) {
          refresh();
        }
      }
    }else{
      if(userUid==null) {
        refresh();
      }else if(userUid!=null&&lastUser) {
        LocalUser.list_users[LocalUser.list_users.length-1]!.set("expenses", userExpenses);
      }
    }
  });
  if(userUid==null) {
    LocalUser.current_user = new LocalUser.User(
      "",
      "",
      "", 
      userExpenses, 
      0
    );
  }else{
    LocalUser.list_users[LocalUser.list_users.length-1]!.set("expenses", userExpenses);
  }
}

void get_docs(refresh) {
  List docs = [];
  Reference ref = firestorage.ref(current_expense!.get("id"));
  ref.listAll().then((docList) {
    if(docList.items.length>0) {
      for (int i=0;i<docList.items.length;i++) {
        docList.items[i].getDownloadURL().then((downloadUrl) {
          docs.add([downloadUrl.toString()]);
          if(i==docList.items.length-1) {
            current_expense!.set("docs", docs);
            refresh();
          }
        });
      }
    }else{
      current_expense!.set("docs", []);
      refresh();
    }
  });
}