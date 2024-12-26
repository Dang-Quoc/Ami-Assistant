import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:project_ai_chat/View/BottomSheet/Widgets/PromptDetailsBottomSheet/prompt_details_bottom_sheet.dart';
import 'package:project_ai_chat/models/response/my_aibot_message_response.dart';
import 'package:project_ai_chat/utils/exceptions/chat_exception.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:project_ai_chat/viewmodels/prompt_list_view_model.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../viewmodels/homechat_view_model.dart';

class ChatWidget extends StatefulWidget {
  final bool isPreview;

  const ChatWidget({Key? key, this.isPreview = false}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  bool _showSlash = false;



  @override
  void initState() {
    super.initState();

    //Provider.of<BotViewModel>(context, listen: false).isPreview = widget.isPreview;

    //Lắng nghe ô nhập dữ liệu
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });

  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   Provider.of<BotViewModel>(context, listen: false).isPreview = widget.isPreview;
  // }

  void _onTextChanged(String input) {
    if (input.isNotEmpty) {
      _showSlash = input.startsWith('/');
    } else {
      _showSlash = false; // Đặt lại _showSlash khi không có input
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageModel = context.watch<BotViewModel>();
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: messageModel.myAiBotMessages.length,
            itemBuilder: (context, index) {
              final message =
              messageModel.myAiBotMessages[index];
              return _buildMessage(message);
            },
          ),
        ),
        const SizedBox(height: 10),
        if (_showSlash)
          Consumer<PromptListViewModel>(
            builder: (context, promptList, child) {
              if (promptList.isLoading) {
                return const CircularProgressIndicator(); // Hoặc một widget khác để hiển thị khi đang tải
              } else if (promptList.hasError) {
                return Text(
                    'Có lỗi xảy ra: ${promptList.error}'); // Hiển thị lỗi
              } else {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    width: MediaQuery.of(context)
                        .size
                        .width /
                        3 *
                        2,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(
                            255,
                            158,
                            198,
                            232), // Color of the border
                        width:
                        1.0, // Width of the border
                      ),
                      borderRadius:
                      BorderRadius.circular(
                          20.0), // Border radius
                    ),
                    constraints: BoxConstraints(
                        maxHeight:
                        MediaQuery.of(context)
                            .size
                            .height /
                            3),
                    child: ListView.builder(
                      itemCount: promptList
                          .allprompts.items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(promptList
                              .allprompts
                              .items[index]
                              .title),
                          onTap: () {
                            _controller.text =
                            ""; // Chọn prompt
                            _showSlash = false;
                            PromptDetailsBottomSheet
                                .show(
                                context,
                                promptList
                                    .allprompts
                                    .items[index]);
                          },
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(20),
                  color: const Color.fromARGB(
                      255, 238, 240, 243),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      onChanged: _onTextChanged,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey,
                              width:
                              1), // Viền bình thường
                          borderRadius:
                          BorderRadius.circular(
                              20), // Bo cong góc
                        ),
                        enabledBorder:
                        OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey
                                .withOpacity(0.5),
                            width: 0.5,
                          ),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        focusedBorder:
                        OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 0.5,
                          ),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _hasText
                  ? _sendMessage
                  : null,
              style: IconButton.styleFrom(
                foregroundColor:
                _hasText
                    ? Colors.black
                    : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    try {
      Provider.of<BotViewModel>(context, listen: false).askAssistant(_controller.text.isEmpty ? '' : _controller.text);
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is ChatException ? e.message : 'Có lỗi xảy ra khi gửi tin nhắn',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMessage(MyAiBotMessage message) {
    bool isUser = message.role == 'user';
    bool isError = message.isErrored ?? false;

    Future<void> _launchURL(String url) async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở link: $url')),
        );
      }
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red[100]
              : (isUser ? Colors.blue[100] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Consumer<BotViewModel>(builder: (context, messageModel, child) {
          // Hiển thị loading nếu là tin nhắn model rỗng và đang trong trạng thái gửi
          if (!isUser && message.content.isEmpty && messageModel.isSending) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: isError ? Colors.red : Colors.black,
                  ),
                ),
              ],
            );
          }

          // Sử dụng Markdown widget cho tin nhắn model
          return Column(
            children: [
              isUser
                  ? Column(
                children: [

                  Text(
                    message.content,
                    style: TextStyle(
                        color: isError ? Colors.red : Colors.black),
                  ),
                ],
              )
                  : MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                      color: isError ? Colors.red : Colors.black),
                  a: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  listBullet: TextStyle(
                      color: isError ? Colors.red : Colors.black),
                ),
                selectable: true,
                onTapLink: (text, href, title) {
                  if (href != null) {
                    _launchURL(href);
                  }
                },
              )
            ],
          );
        }),
      ),
    );
  }

}
