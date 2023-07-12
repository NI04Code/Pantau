
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantau/models/message.dart';
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isSender;

  ChatBubble({required this.message, required this.isSender});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isSender ? Colors.green : Colors.blue;
    double marginRight = isSender? 16 : 64;
    double marginLeft = isSender? 64 : 16;

    return Column(
      children: [
        Row(
          mainAxisAlignment: isSender? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if(!isSender) SizedBox(width: 16,),
            Text(DateFormat.Hm().format(message.time) + ' ', style: TextStyle(color: Colors.black),),
            Text(DateFormat.yMMMd().format(message.time), style: TextStyle(color: Colors.black),),
            if(isSender)SizedBox(width:  16,)
          ],
        ),
        Container(
          margin: EdgeInsets.only(right:  marginRight, left: marginLeft, top:  8, bottom:  8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              message.chat,
              style: TextStyle(fontFamily: 'Times New Roman', color:  Colors.white, fontSize: 14),
            ),

          ),
        ),
      ],
    );
  }
}