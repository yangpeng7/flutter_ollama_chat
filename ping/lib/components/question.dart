import 'package:flutter/material.dart';
import 'package:ping/model/message.dart';

class Question extends StatelessWidget {
  final Message chat;

  const Question({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0085F9),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            /// 解决文本自适应问题
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 140),
            child: Text(
              chat.message ?? "",
              softWrap: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Color(0xffE0E4Eb)),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            chat.sender,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
