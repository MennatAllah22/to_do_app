import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:to_do/shared/components/components.dart';
import 'package:to_do/shared/cubit/cubit.dart';
import 'package:to_do/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => AppCubit()..createDatabase(),
        child: BlocConsumer<AppCubit, AppStates>(
          listener: (BuildContext context, state) {
            if (state is AppInsertDatabaseState) {
              Navigator.pop(context);
            }
          },
          builder: (BuildContext context, state) {
            AppCubit cubit = AppCubit.get(context);
            return Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.grey[200],
              body: ConditionalBuilder(
                condition: state is! AppGetDatabaseLoadingState,
                builder: (context) => cubit.screen[cubit.currentIndex],
                fallback: (context) => const Center(child: CircularProgressIndicator()),
              ),
              appBar: AppBar(
                backgroundColor: Colors.grey[200],
                elevation: 0,
                title: Text(
                    cubit.titles[cubit.currentIndex],
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold
                    ),
                  ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor:Colors.blue,
                onPressed: () {
                  if (cubit.isBottomSheetShown) {
                    if (formKey.currentState!.validate()) {
                      cubit.insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text,
                      );
                    }
                  } else {
                    scaffoldKey.currentState!
                        .showBottomSheet(
                          (context) => Container(
                             color: Colors.grey[300],
                             padding: EdgeInsets.all(20.0),
                             child: Form(
                               key: formKey,
                               child: Column(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                  defaultFormField(
                                   controller: titleController,
                                   type: TextInputType.text,
                                    onValidate: (String? value){
                                      if(value!.isEmpty){
                                        return 'title must not be empty';
                                      }
                                      return null;
                                    },
                                   label: 'Task Title',
                                   prefix: Icons.title,
                                 ),
                                 const SizedBox(
                                   height: 15,
                                ),


                                 defaultFormField(
                                controller: timeController,
                                type: TextInputType.datetime,
                                onValidate: (String? value){
                                  if(value!.isEmpty){
                                    return 'time must not be empty';
                                  }
                                  return null;
                                },
                                onTap: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value) {
                                    timeController.text =
                                        value!.format(context).toString();
                                  });
                                },
                                 label: 'Task Time',
                                 prefix: Icons.watch_later_outlined,
                                ),
                                 const SizedBox(
                                height: 15,
                                 ),

                                 defaultFormField(
                                   controller: dateController,
                                   type: TextInputType.datetime,
                                   onValidate: (String? value){
                                     if(value!.isEmpty){
                                       return 'date must not be empty';
                                     }
                                     return null;
                                   },
                                   onTap: () {
                                    showDatePicker(
                                     context: context,
                                     initialDate: DateTime.now(),
                                     firstDate: DateTime.now(),
                                     lastDate: DateTime.parse('2023-05-13'),
                                   ).then((value) {
                                     dateController.text =
                                        DateFormat.yMMMd().format(value!);
                                   });
                                 },
                                  label: 'Task Date',
                                  prefix: Icons.calendar_today_outlined,
                                ),
                              ],
                             ),
                          ),
                         ),
                      elevation: 20.0,
                    )
                        .closed
                        .then((value) {
                      cubit.changeBottomSheetState(
                        isShow: false,
                        icon: Icons.edit,
                      );
                    });
                    cubit.changeBottomSheetState(
                      isShow: true,
                      icon: Icons.add,
                    );
                  }
                },
                child: Icon(
                  cubit.fabIcon,
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.grey[300],
                //selectedItemColor: Colors.blue,
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    backgroundColor: Colors.grey,
                    icon: Icon(
                      Icons.menu,
                    ),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    backgroundColor: Colors.grey,
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'Done',
                  ),
                  BottomNavigationBarItem(
                    backgroundColor: Colors.grey,
                    icon: Icon(
                      Icons.archive_outlined,
                    ),
                    label: 'Archive',
                  ),
                ],
              ),
            );
          },
        ));
  }
}
