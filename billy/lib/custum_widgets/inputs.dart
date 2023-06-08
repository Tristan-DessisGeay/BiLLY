import 'package:billy/custum_widgets/listcell.dart';
import 'package:billy/custum_widgets/loading_page.dart';
import 'package:billy/firebase_functions/expense_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:billy/theme/colors.dart';
import '../data_processing/expense.dart';
import 'package:universal_html/html.dart' as html;

Container get_simple_field(text, label_on_top, width, write, controller, onchanged, onEditingComplete) {
  return Container(
    width: width,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if(label_on_top) Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: Text(
              text,
              style: TextStyle(color: BLUE_COLOR_L, fontSize: 15),
            ),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
          )
        ),
        TextField(
          onEditingComplete: onEditingComplete,
          onChanged: onchanged,
          readOnly: !write,
          controller: controller,
          cursorColor: BLUE_COLOR_L,
          style: TextStyle(color: TEXT_COLOR_LIGHTER),
          decoration: InputDecoration(
            hintStyle: TextStyle(color: HINT_TEXT_COLOR),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: BLUE_COLOR_L,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(15)
              )
              ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: BLUE_COLOR_L,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(15)
              )
              ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            hintText: label_on_top? "": text,
          ),
        ),
      ],
    ),
  );
}

Container get_hidden_field(text, label_on_top, width, gestureDetectorOnTap, obscureText, write, controller, onchanged) {
  return Container(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if(label_on_top) Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(
                    text,
                    style: TextStyle(color: BLUE_COLOR_L, fontSize: 15),
                  ),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                )
              ),
              TextField(
                cursorColor: BLUE_COLOR_L,
                style: TextStyle(color: TEXT_COLOR_LIGHTER),
                onChanged: onchanged,
                readOnly: !write,
                controller: controller,
                decoration: InputDecoration(
                  suffixIcon: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: gestureDetectorOnTap,
                        child: Icon(obscureText
                          ?Icons.visibility
                          :Icons.visibility_off,
                        color: TEXT_COLOR_DARKER),
                      ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: BLUE_COLOR_L,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15)
                    )
                    ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: BLUE_COLOR_L,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15)
                    )
                    ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                ),
                obscureText: obscureText,
              ),
            ],
          ),
        );
}

Widget get_motif_input(constraints, onchanged, controller, conditionViewList, motifsList, widget, ontap, context) {
  return Container(
      width: constraints.maxWidth * 0.4,
      decoration: BoxDecoration(
        border: Border.all(color: BLUE_COLOR_L),
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      child: Column(
        children: [
          TextField(
            onChanged: onchanged,
            controller: controller,
            readOnly: true,
            cursorColor: BLUE_COLOR_L,
            style: TextStyle(color: TEXT_COLOR_LIGHTER),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: HINT_TEXT_COLOR),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              hintText: "motif",
            ),
          ),
          if(conditionViewList)Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: BLUE_COLOR_L))
            ),
            child: ListView.builder(
              physics: PageScrollPhysics(),
              itemCount: motifsList.length,
              itemBuilder: (context, index) {
                return Cell(
                  refresh: widget.notifyParent,
                  builder: ((isHovered) {
                    final color = isHovered ? Colors.grey.withOpacity(.3) : null;
                    final decoration = isHovered ? BoxDecoration(color: color,borderRadius: BorderRadius.all(Radius.circular(20))) : null;
                    return Container(
                      decoration: decoration,
                      child: ListTile(
                                title: Text(motifsList[index], style: TextStyle(color: TEXT_COLOR_LIGHTER),),
                                onTap: () {
                                  controller.text = motifsList[index];
                                  ontap();
                                }
                              )
                    );
                  }) 
                );
              }
            )
          )
        ],
      ),
    );
}

Widget get_lieu_input(constraints, onchanged, controller, conditionReadOnly, conditionViewList, predictions, widget, viewExpense, context) {
  return Container(
      width: constraints.maxWidth * 0.4,
      decoration: BoxDecoration(
        border: Border.all(color: BLUE_COLOR_L),
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      child: Column(
        children: [
          TextField(
            onChanged: onchanged,
            controller: controller,
            readOnly: conditionReadOnly,
            cursorColor: BLUE_COLOR_L,
            style: TextStyle(color: TEXT_COLOR_LIGHTER),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: HINT_TEXT_COLOR),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              hintText: "lieu",
            ),
          ),
          if(conditionViewList)Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: BLUE_COLOR_L))
            ),
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return Cell(
                  refresh: widget.notifyParent,
                  builder: ((isHovered) {
                    final color = isHovered ? Colors.grey.withOpacity(.3) : null;
                    final decoration = isHovered ? BoxDecoration(color: color,borderRadius: BorderRadius.all(Radius.circular(20))) : null;
                    return Container(
                      decoration: decoration,
                      child: ListTile(
                                title: Text(predictions[index].description.toString(), style: TextStyle(color: TEXT_COLOR_LIGHTER),),
                                onTap: () {
                                  (viewExpense)?controller.text = predictions[index].description.toString():
                                  controller.text = predictionsAdd[index].description.toString();
                                  (viewExpense)?current_values["lieu"] = predictions[index].description.toString():
                                  current_valuesAdd["lieu"] = predictions[index].description.toString();
                                  (viewExpense)?lieuSelected = true:lieuSelectedAdd = true;
                                },
                              )
                    );
                  }) 
                );
              }
            )
          )
        ],
      ),
    );
}

Widget get_montant_input(constraints, onchanged, conditionReadOnly, controller, ontap, conditionCurrencyDisplayed, context) {
  return Container(
      width: constraints.maxWidth * 0.4,
      child: TextField(
                onChanged: onchanged,
                readOnly: conditionReadOnly,
                controller: controller,
                cursorColor: BLUE_COLOR_L,
                style: TextStyle(color: TEXT_COLOR_LIGHTER),
                decoration: InputDecoration(
                  suffixIcon: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: ontap,
                      child: SlideTransition(
                        position: AlwaysStoppedAnimation(Offset(0, 0.14)),
                        child: Text(conditionCurrencyDisplayed, style: TextStyle(color: TEXT_COLOR_LIGHTER, fontSize: 20), textAlign: TextAlign.center,)
                      ),
                    ),
                  ),
                  hintStyle: TextStyle(color: HINT_TEXT_COLOR),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: BLUE_COLOR_L,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15)
                    )
                    ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: BLUE_COLOR_L,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15)
                    )
                    ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  hintText: "montant",
                ),
              )
    );
}

Widget get_justificatifs_input(viewExpense, cdl, constraints, conditionHeightContainer, conditionAddDeleteDoc, howToDeleteF, howToAddF, context) {
  List docs_list = [];
  if(cdl!=null) {
    (viewExpense)?current_docs_list = List.from(cdl):current_docs_listAdd = List.from(cdl);
    cdl.forEach((element) {
      docs_list.add(
        Container(
          width: constraints.maxWidth * 0.4 - 2,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: conditionHeightContainer,
                child: Image.network(element[0])
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if(conditionAddDeleteDoc)MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: Icon(Icons.close, color: Colors.red,size: 30,),
                      onTap: () {
                              if(element.length==1) delete_doc(element);
                              cdl.remove(element);
                              (viewExpense)?current_docs_list = List.from(cdl):current_docs_listAdd = List.from(cdl);
                              howToDeleteF();
                            },
                    )
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: Icon(Icons.loupe_rounded, color: TEXT_COLOR_DARKER),
                      onTap: () async {
                        html.window.open(element[0], "_blank");
                      },
                    )
                  )
                ],
              ),
            ],
          )
        )
      );
    });
    if(conditionAddDeleteDoc)docs_list.add(
      Container(
        width: constraints.maxWidth * 0.4 - 2,
        color: Theme.of(context).primaryColor,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Icon(Icons.add_photo_alternate_outlined, size: 60, color: TEXT_COLOR_DARKER,),
            onTap: howToAddF,
          )
        )
      )
    );
  }else{
    docs_list.add(Container(
      width: constraints.maxWidth * 0.4 - 2,
      child: loadingPage(null)
    ));
  }
  return Container(
      decoration: BoxDecoration(
        border: Border.all(color: BLUE_COLOR_L),
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      width: constraints.maxWidth * 0.4,
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: ListView.builder(
          physics: PageScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return docs_list[index];
          },
          itemCount: docs_list.length
        )
      )
  );
}

Widget get_precision_input(constraints, controller, conditionReadOnly, onchanged, context) {
  return Container(
      width : constraints.maxWidth * 0.4,
      height: 200,
      child: TextField(
        style: TextStyle(color: TEXT_COLOR_LIGHTER),
        keyboardType: TextInputType.multiline,
        controller: controller,
        minLines: 8,
        maxLines: 8,
        readOnly: conditionReadOnly,
        onChanged: onchanged,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: HINT_TEXT_COLOR),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: BLUE_COLOR_L,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15)
                    )
                    ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: BLUE_COLOR_L,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15)
                    )
                    ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  hintText: "précisions"
        ),
      ),
    );
}

Widget get_date_input(constraints, onchanged, controller, conditionReadOnly, context) {
  return Container(
      width: constraints.maxWidth * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextField(
            onChanged: onchanged,
            keyboardType: TextInputType.text,
            readOnly: conditionReadOnly,
            controller: controller,
            cursorColor: BLUE_COLOR_L,
            style: TextStyle(color: TEXT_COLOR_LIGHTER),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: HINT_TEXT_COLOR),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: BLUE_COLOR_L,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(15)
                )
                ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: BLUE_COLOR_L,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(15)
                )
                ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              hintText: "date (yyyy/mm/dd)",
            ),
          ),
        ],
      ),
    );
}

Widget get_etat_input(constraints, onchanged, controller, widget, ontap, context) {
  List etats = ["Accepté", "En attente", "Refusé"];
  return Container(
      width: constraints.maxWidth * 0.4,
      decoration: BoxDecoration(
        border: Border.all(color: BLUE_COLOR_L),
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      child: Column(
        children: [
          TextField(
            onChanged: onchanged,
            controller: controller,
            readOnly: true,
            cursorColor: BLUE_COLOR_L,
            style: TextStyle(color: TEXT_COLOR_LIGHTER),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: HINT_TEXT_COLOR),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              hintText: "etat",
            ),
          ),
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: BLUE_COLOR_L))
            ),
            child: ListView.builder(
              physics: PageScrollPhysics(),
              itemCount: etats.length,
              itemBuilder: (context, index) {
                return Cell(
                  refresh: widget.notifyParent,
                  builder: ((isHovered) {
                    final color = isHovered ? Colors.grey.withOpacity(.3) : null;
                    final decoration = isHovered ? BoxDecoration(color: color,borderRadius: BorderRadius.all(Radius.circular(20))) : null;
                    return Container(
                      decoration: decoration,
                      child: ListTile(
                                title: Text(etats[index], style: TextStyle(color: TEXT_COLOR_LIGHTER),),
                                onTap: () {
                                  controller.text = etats[index];
                                  ontap();
                                }
                              )
                    );
                  }) 
                );
              }
            )
          )
        ],
      ),
    );
}