import 'package:billy/custum_widgets/expense.dart';
import 'package:billy/custum_widgets/user.dart';
import 'package:billy/theme/colors.dart';
import 'package:flutter/material.dart';

Widget get_toggleButton3(userNum, children, onpressed, context) {
  List<bool> isSelectedUser = [false, false, false];
  if(userNum==0) {
    isSelectedUser[current_expense!.get("etat")] = true;
  }
  return ToggleButtons(
      children: children, 
      isSelected: (userNum==0)?isSelectedUser:(userNum==1)?current_valuesAdd["etat"]:(userNum==2)?currentValuesUser["type"]:currentValuesUserAdd["type"],
      onPressed: onpressed,
      selectedColor: Colors.white,
      color: TEXT_COLOR_LIGHTER,
      fillColor: Theme.of(context).buttonColor,
      splashColor: BLUE_COLOR_L,
      highlightColor: Theme.of(context).buttonColor,
      renderBorder: true,
      borderColor: BLUE_COLOR_L,
      borderWidth: 1,
      borderRadius: BorderRadius.circular(15),
      selectedBorderColor: BLUE_COLOR_L,
    );
}