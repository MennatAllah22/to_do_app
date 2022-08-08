import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:to_do/shared/cubit/cubit.dart';


Widget buildTaskItem(Map model, context) => Dismissible(
  key: Key(model['id'].toString()),
  child: Padding(
    padding: const EdgeInsets.all(15.0) ,
    child: Row(
      children:  [
        CircleAvatar(
          radius: 35.0,
          child:  Text(
            '${model['time']}' ,
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${model['title']}',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${model['date']}',
                style: const TextStyle(
                    color: Colors.grey
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        IconButton(
          onPressed: () {
            AppCubit.get(context).updateDatabase(
                status: 'done',
                id: model['id']);
          },
          icon: const Icon(
              Icons.check_circle
          ),
          color: Colors.blue,
        ),
        IconButton(
          onPressed: () {
            AppCubit.get(context).updateDatabase(
                status: 'archived',
                id: model['id']);
          },
          icon: const Icon(
            Icons.archive,
          ),
          color: Colors.black26,
        ),

      ],
    ),
  ),
  onDismissed: (direction){
    AppCubit.get(context).deleteDatabase(id: model['id']);
  },
);

Widget tasksBuilder({
  @required List<Map>? tasks,
}) => ConditionalBuilder(
  condition: tasks!.isNotEmpty,
  builder: (context) => ListView.separated(
    itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
    separatorBuilder: (context, index) => myDivider(),
    itemCount: tasks.length,
  ),
  fallback: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.menu,
          size: 100.0,
          color: Colors.grey,
        ),
        Text(
          'No Tasks here!',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ),
);


Widget myDivider() => Padding(
  padding: const EdgeInsetsDirectional.only(
    start: 20.0,
  ),
  child: Container(
    width: double.infinity,
    height: 1.0,
    color: Colors.grey[200],
  ),
);

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function? onSubmit,
  ValueChanged<String>? onChanged,
  VoidCallback? onTap,
  required FormFieldValidator<String>? onValidate,
  VoidCallback? suffixPressed,
  required String label,
  required IconData prefix,
  bool isPassword = false,
  IconData? suffix,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      onFieldSubmitted: (s) {
        onSubmit;
      },
      onChanged: onChanged,

      onTap: onTap,
      validator: onValidate,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: IconButton(
          onPressed: suffixPressed,
          icon: Icon(
            suffix,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 2.0,
          ),
        ),
      ),
    );