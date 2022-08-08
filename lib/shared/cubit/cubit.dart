import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:to_do/modules/done_tasks/done_tasks_screen.dart';
import 'package:to_do/modules/new_tasks/new_tasks_screen.dart';
import 'package:to_do/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>{

  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  List<Widget> screen = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archive Tasks',
  ];

  void changeIndex(int index)
  {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  late Database database;
  void createDatabase() async
  {
    database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database.execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error when creating table ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);

        print('database opened');
      },
    ).then((value)
    {
      database = value;
      emit(AppCreateDatabaseState());
      return database;
    });

  }

  insertToDatabase({
    @required String? title,
    @required String? time,
    @required String? date,
  }) async
  {
    await database.transaction((txn) async {
      txn.rawInsert(
          'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);
      }).catchError((error){
        print('Error when inserting into table ${error.toString()}');
      });

    });

  }

  void getDataFromDatabase(database)
  {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element){
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else archivedTasks.add(element);

      });
      emit(AppGetDatabaseState());
    }

    );

  }

  void updateDatabase({
    @required String? status,
    @required int? id,
  }) async {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', '$id'],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());

    });
  }

  void deleteDatabase({
    @required int? id,
  }) async {
    database.rawUpdate(
        'DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());

    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    @required bool? isShow,
    @required IconData? icon,
  }){
    isBottomSheetShown = isShow!;
    fabIcon = icon!;

    emit(AppChangeBottomSheetState());

  }


}