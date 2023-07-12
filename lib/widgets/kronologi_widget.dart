import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantau/models/kronologi.dart';
import 'package:pantau/widgets/expandable_text.dart';

class KronologiWidget extends StatefulWidget{
  final Kronologi kronologi;
  final int maxLines;
  const KronologiWidget({super.key, required this.kronologi, this.maxLines = 1});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return KronologiWidgetState();
  }
}

class KronologiWidgetState extends State<KronologiWidget>{
  final dateFormatter = DateFormat('dd');
  final monthFormatter = DateFormat.MMM();
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue,width: 2)
        ),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dateFormatter.format(widget.kronologi.tanggal)),
                Text(monthFormatter.format(widget.kronologi.tanggal))
              ],
            ),
            decoration:  BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10)
            ),
          ),
          title: Text(widget.kronologi.judul, style:Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black),),
          subtitle: ExpandableText(text: widget.kronologi.konten, maxLines: 3,),
        ),
      ),
    );
    }
  }