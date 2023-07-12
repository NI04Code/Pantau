import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateAndTimePicker extends ConsumerStatefulWidget{
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _DateAndTimePickerState();
  }
}
class _DateAndTimePickerState extends ConsumerState<DateAndTimePicker>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 120,
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(onPressed: (){
            }, icon: const
            Icon(Icons.timer, color: Colors.red,), label: Text('Tambahkan Waktu', style:
            Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),)),
            TextButton.icon(onPressed: (){

            }, icon: const
            Icon(Icons.date_range_rounded, color: Colors.red,), label: Text('Tambahkan Tanggal', style:
            Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),))
          ],
      ),
    );
  }
}