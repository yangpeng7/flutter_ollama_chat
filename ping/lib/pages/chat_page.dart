import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ping/components/answer.dart';
import 'package:ping/components/question.dart';
import 'package:ping/config.dart';
import 'package:ping/db/database_helper.dart';
import 'package:ping/model/message.dart';
import 'package:ping/model/message_type.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isLoading = false;
  List<Message> chatList = [];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _currentPage = 1;
  int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(onScroll);
    _focusNode.addListener(onTextFocus);
    _loadMessages();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_scrollController.position.maxScrollExtent == 0) {
        // call load more
        if (_isLoading) return;
        _loadMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Ping",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Height of the divider
          child: Divider(
            color: Colors.grey[200], // Color of the divider
            // thickness: 1.0, // Thickness of the divider
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _focusNode.unfocus();
              },
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView.separated(
                  separatorBuilder: (_, __) => const SizedBox(
                    height: 12,
                  ),
                  padding: EdgeInsets.only(bottom: 10),
                  itemBuilder: (ctx, index) {
                    Message chat = chatList[index];
                    return Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        chat.sender == Config.yourName
                            ? Question(chat: chat)
                            : Answer(chat: chat)
                      ],
                    );
                  },
                  controller: _scrollController,
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: chatList.length,
                  physics: const BouncingScrollPhysics(),
                ),
              ),
            ),
          ),
          _bottomInputField(),
        ],
      ),
    );
  }

  Widget _bottomInputField() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E5EA),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: _textEditingController,
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                  right: 42,
                  left: 16,
                  top: 18,
                ),
                // hintText: 'message',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Material(
            color: Color(0xFF0085F9),
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              onTap: onSendMessage,
              child: Container(
                  height: 30,
                  width: 50,
                  alignment: Alignment.center,
                  child: const Text(
                    "send",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  void onScroll() {
    _focusNode.unfocus();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      debugPrint("load more");
      if (_isLoading) return;
      _isLoading = true;
      _loadMessages();
    }
  }

  void onTextFocus() {
    _scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  Future<void> _refreshMessages() async {
    setState(() {
      _currentPage = 1;
      _perPage = 10;
      _isLoading = true;
    });
    final newMessages = await DatabaseHelper()
        .getMessages(_perPage, (_currentPage - 1) * _perPage);
    setState(() {
      chatList.clear();
      chatList.addAll(newMessages);
      _isLoading = false;
      _currentPage++;
    });
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });
    final newMessages = await DatabaseHelper()
        .getMessages(_perPage, (_currentPage - 1) * _perPage);
    setState(() {
      chatList.addAll(newMessages);
      _isLoading = false;
      _currentPage++;
    });
  }

  void onSendMessage() async {
    if (_textEditingController.text.trim().isEmpty) return;
    await DatabaseHelper().insertMessage(Message(
      message: _textEditingController.text.trim(),
      type: MessageType.text,
      sender: Config.yourName,
      receiver: Config.botName,
      // time: DateTime.now().subtract(const Duration(minutes: 15)),
    ));
    _refreshMessages();

    if (Config.stream) {
      _getBotAnswerStream(_textEditingController.text.trim());
    } else {
      _getBotAnswer(_textEditingController.text.trim());
    }
    _textEditingController.text = "";
  }

  Future<void> _getBotAnswerStream(String question) async {
    final requestBody = {
      "model": "gemma:2b",
      "prompt": question,
      "stream": true
    };

    var request = http.Request("POST", Uri.parse("${Config.url}/api/generate"));
    request.body = jsonEncode(requestBody);
    http.Client().send(request).then((response) {
      String showContent = "";
      final stream = response.stream.transform(utf8.decoder);
      chatList.insert(
          0,
          Message(
            message: showContent,
            type: MessageType.text,
            sender: Config.botName,
            receiver: Config.yourName,
            // time: DateTime.now().subtract(const Duration(minutes: 15)),
          ));

      stream.listen(
        (data) async {
          Map<String, dynamic> resp = json.decode(data);
          debugPrint("data${resp["response"]}");
          chatList[0] = Message(
            message: "${chatList[0].message}${resp["response"]}",
            type: MessageType.text,
            sender: Config.botName,
            receiver: Config.yourName,
            // time: DateTime.now().subtract(const Duration(minutes: 15)),
          );
          if (resp["done"]) {
            await DatabaseHelper().insertMessage(chatList[0]);
            _refreshMessages();
          }
          setState(() {});
        },
        onDone: () {
          debugPrint("onDone");
        },
        onError: (error) {
          debugPrint("onError");
        },
      );
    });
  }

  Future<void> _getBotAnswer(String question) async {
    final requestBody = {
      "model": "gemma:2b",
      "prompt": question,
      "stream": false
    };
    final response = await http.post(
      Uri.parse("${Config.url}/api/generate"),
      body: jsonEncode(requestBody),
    );

    Map<String, dynamic> responseData =
        json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      String content = responseData["response"];
      await DatabaseHelper().insertMessage(Message(
        message: content,
        type: MessageType.text,
        sender: Config.botName,
        receiver: Config.yourName,
        // time: DateTime.now().subtract(const Duration(minutes: 15)),
      ));
      _refreshMessages();
    } else {
      debugPrint("request error");
    }
  }
}
