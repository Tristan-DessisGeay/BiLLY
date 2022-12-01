import 'package:billy/custum_widgets/user.dart';
import 'package:billy/theme/colors.dart';
import 'package:flutter/material.dart';

class UserList extends StatefulWidget{
  final Function() refresh;
  final int userType;
  final bool largeScreen;
  final bool exception;
  UserList({
    Key? key,
    required this.refresh,
    required this.userType,
    required this.largeScreen,
    required this.exception
  }) : super(key: key);
  _UserList createState()=> _UserList();
}

class _UserList extends State<UserList>{

  @override
  Widget build(BuildContext context) {

    List listUsers = get_users(context, widget.refresh, widget.userType);

    if(listUsers.length>0) {

    return Container(
            padding: EdgeInsets.all(15),
            decoration: (widget.exception)?null:(widget.largeScreen)?BoxDecoration(
              border: Border(
                right: BorderSide(color: BLUE_COLOR_L
              ),
            )):null,
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    Widget row = Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                current_filter = true;
                                current_sens = !current_sens;
                              });
                            }, 
                            icon: (current_filter)?(current_sens)
                            ?Icon(Icons.arrow_drop_down_rounded, color: TEXT_COLOR_DARKER, size: 40,)
                            :Icon(Icons.arrow_drop_up_rounded, color: TEXT_COLOR_DARKER, size: 40,)
                            :SlideTransition(
                              child: Icon(Icons.circle, color: TEXT_COLOR_DARKER, size: 10,),
                              position: AlwaysStoppedAnimation(Offset(0, 0.65)),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                current_filter = false;
                                current_sens = !current_sens;
                              });
                            }, 
                            icon: (!current_filter)?(current_sens)
                            ?Icon(Icons.arrow_drop_down_rounded, color: TEXT_COLOR_DARKER, size: 40,)
                            :Icon(Icons.arrow_drop_up_rounded, color: TEXT_COLOR_DARKER, size: 40,)
                            :SlideTransition(
                              child: Icon(Icons.circle, color: TEXT_COLOR_DARKER, size: 10,),
                              position: AlwaysStoppedAnimation(Offset(0, 0.65)),
                            ),
                          )
                        ],
                      )
                    );
                    double? minWidth = 80;
                    double? maxWidth = constraints.maxWidth;
                    if(maxWidth>minWidth) {
                      return row;
                    }else{
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: row,
                      );
                    }
                  } 
                ),
                SingleChildScrollView(
                  child: Expanded(
                    child: SizedBox(
                      height: (widget.largeScreen==true)
                              ?MediaQuery.of(context).size.height-210
                              :MediaQuery.of(context).size.height-280,
                      child: ListView.separated(
                              itemCount: listUsers.length,
                              itemBuilder: (context, index) {
                                return listUsers[index];
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 15);
                              },
                            )
                    )
                  )
                )
              ]
            )
          );
    }else{
      return Container(
        decoration: (widget.exception)?null:(widget.largeScreen)?BoxDecoration(
              border: Border(
                right: BorderSide(color: BLUE_COLOR_L
              ),
            )):null,
        child: Center(child: Text("No user has been created yet", textAlign: TextAlign.center ,style: TextStyle(color: TEXT_COLOR_DARKER, fontSize: 30),)),
      );
    }
  }

}