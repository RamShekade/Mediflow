import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatBotPage extends StatefulWidget {
  final String userId;

  ChatBotPage({required this.userId});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  List<Map<String, dynamic>> messages = [];
  TextEditingController controller = TextEditingController();
  bool isTyping = false;
  String userName = '';
  String email = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? 'N/A';
      userName = prefs.getString('userName') ?? 'User';
      email = prefs.getString('email') ?? 'No Email';
    });
  }

  Future<void> sendMessage([String? messageToSend]) async {
    String userMessage = messageToSend ?? controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'text': userMessage});
      isTyping = true;
    });

    controller.clear();

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.5:5000/api/chat"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': userId, 'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String botReply = data['reply'] ?? 'Sorry, I did not understand that.';

        if (data['options'] != null) {
          List<String> options = List<String>.from(data['options']);
          setState(() {
            messages.add({'role': 'bot', 'text': botReply, 'options': options});
          });
        } else {
          setState(() {
            messages.add({'role': 'bot', 'text': botReply});
          });
        }
      } else {
        setState(() {
          messages.add({
            'role': 'bot',
            'text': 'Server error. Try again later.',
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          'role': 'bot',
          'text': 'Failed to connect. Please try again.',
        });
      });
    } finally {
      setState(() {
        isTyping = false;
      });
    }
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    bool isUser = msg['role'] == 'user';
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser ? Colors.blueAccent : Colors.grey.shade300,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(isUser ? 12 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 12),
              ),
            ),
            child: Text(
              msg['text'],
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ),
        if (!isUser && msg['options'] != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4, right: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(msg['options'].length, (index) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.blueAccent),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () {
                    sendMessage(msg['options'][index]);
                  },
                  child: Text(
                    msg['options'][index],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BouncingDotsIndicator(),
            SizedBox(width: 8),
            Text("Assistant is typing...", style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pre-Visit Assistant"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
                  return buildTypingIndicator();
                } else {
                  return buildMessage(messages[index]);
                }
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Ask me anything...",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BouncingDotsIndicator extends StatefulWidget {
  final int numberOfDots;
  final double dotSpacing;
  final double dotSize;
  final Color color;
  final Duration duration;

  BouncingDotsIndicator({
    this.numberOfDots = 3,
    this.dotSpacing = 6,
    this.dotSize = 8,
    this.color = Colors.black87,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  _BouncingDotsIndicatorState createState() => _BouncingDotsIndicatorState();
}

class _BouncingDotsIndicatorState extends State<BouncingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int currentDot = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            currentDot = (currentDot + 1) % widget.numberOfDots;
          });
          _controller.forward();
        }
      });

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.dotSize / 2,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.dotSpacing / 2),
      child: AnimatedContainer(
        duration: widget.duration,
        width: widget.dotSize,
        height: currentDot == index ? widget.dotSize + 4 : widget.dotSize,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.numberOfDots, (index) => _buildDot(index)),
    );
  }
}
