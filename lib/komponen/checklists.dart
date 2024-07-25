import 'package:aplikasi_revamp/komponen/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Checklist extends StatelessWidget {
  final String namaTask;
  final bool TaskKelar;
  Function(bool?)? onChanged;
  Function(BuildContext)? Hapus;

  Checklist({
    Key? key,
    required this.namaTask,
    required this.TaskKelar,
    required this.onChanged,
    required this.Hapus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 15, top: 15),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20), // Corner radius 20
        child: Slidable(
          endActionPane: ActionPane(
            motion: StretchMotion(),
            children: [
              SlidableAction(onPressed: Hapus,
              icon: Icons.delete,
                backgroundColor: Colors.red,
                borderRadius: BorderRadius.circular(12),
              )
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Checkbox(
                  value: TaskKelar,
                  onChanged: onChanged,
                  activeColor: Warna.green,
                ),
                SizedBox(width: 10),
                Text(
                  namaTask,
                  style: TextStyles.body.copyWith(
                      fontSize: 17,
                      decoration: TaskKelar? TextDecoration.lineThrough : TextDecoration.none),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
