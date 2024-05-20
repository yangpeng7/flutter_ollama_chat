import 'package:flutter/material.dart';
import 'package:ping/model/message.dart';

class Answer extends StatelessWidget {
  final Message chat;

  const Answer({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffE0E4Eb),
          ),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/robot.png',
            width: 26,
            height: 26,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xffE0E4Eb),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 140),
            child: Text(
              chat.message ?? "",
              style: const TextStyle(
                color: Color(0xFF1A2032),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
