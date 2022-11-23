import 'package:flutter/material.dart';

class DropdownField<T> extends StatelessWidget {
  final T? dropdownValue;
  final void Function(T) callback;
  final List<T> values;
  final bool? disable;
  const DropdownField({
    Key? key,
    required this.dropdownValue,
    required this.values,
    required this.callback,
    this.disable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: dropdownValue,
      elevation: 16,
      onChanged: disable != null && disable == true
          ? null
          : (value) {
              callback(value as T);
            },
      items: values.map<DropdownMenuItem<T>>((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }
}
