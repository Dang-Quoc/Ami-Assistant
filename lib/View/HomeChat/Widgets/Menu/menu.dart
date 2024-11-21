import 'package:flutter/material.dart';
import 'package:project_ai_chat/View/HomeChat/model/ai_logo.dart';
import 'package:project_ai_chat/View/Knowledge/page/knowledge_screen.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/message_homechat.dart';
import '../../../UpgradeVersion/upgrade-version.dart';
import '../../../../viewmodels/aichat_list.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = -1;
  late final AIChatList aiChatList;
  late AIItem currentAI;
  @override
  void initState() {
    super.initState();
    aiChatList = Provider.of<AIChatList>(context, listen: false);
    currentAI = aiChatList.selectedAIItem;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversations();
    });
  }

  Future<void> _loadConversations() async {
    try {
      await Provider.of<MessageModel>(context, listen: false)
          .fetchAllConversations(currentAI.id, 'dify');
    } catch (e) {
      print("error: $e");
    }
  }

  void _logout() async {}
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[100],
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "assets/logoAI.png",
                        height: 60,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "Ami Assistant",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildWidgetItem(Icons.smart_button, "Prompt Management", 0),
          _buildWidgetItem(Icons.play_lesson, "Knowledge Management", 1),
          _buildWidgetItem(Icons.verified_sharp, "Upgrade Version", 2),
          const Divider(
            height: 0.5,
            color: Color.fromRGBO(2, 13, 82, 1.0),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Text(
                  'Tất cả cuộc trò chuyện',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.search,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<MessageModel>(
              builder: (context, messageModel, child) {
                if (messageModel.isLoading) {
                  // Display loading indicator while fetching conversations
                  return const Center(child: CircularProgressIndicator());
                }

                if (messageModel.errorMessage != null) {
                  // Display error message if there's an error
                  return Center(
                    child: Text(
                      messageModel.errorMessage ?? 'Có lỗi xảy ra',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: messageModel.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = messageModel.conversations[index];
                    return ListTile(
                      title: Text("Conversation ${index + 1}"),
                      subtitle: Text(
                        conversation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () async {
                        // Lấy assistantId từ currentAI
                        final assistantId = currentAI.id;

                        // Gọi loadConversationHistory
                        await Provider.of<MessageModel>(context, listen: false)
                            .loadConversationHistory(
                                assistantId, conversation.id);

                        Navigator.pop(context); // Đóng drawer
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetItem(IconData icon, String title, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 2) {
          // Assuming "Upgrade Version" is at index 3
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UpgradeVersion()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KnowledgeScreen()),
          );
        }
      },
      child: Container(
        color: (index == (_selectedIndex)) ? Colors.grey[400] : null,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
        ),
      ),
    );
  }

  Widget _buildButtonItem({
    required String title,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color.fromRGBO(69, 37, 229, 1.0),
            side: const BorderSide(
              width: 0.5,
              color: Colors.grey,
            )),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
