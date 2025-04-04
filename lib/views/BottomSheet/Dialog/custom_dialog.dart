import 'package:flutter/material.dart';
import 'package:project_ai_chat/views/BottomSheet/enums.dart';
import 'package:provider/provider.dart';
import '../../../models/prompt_model.dart';
import '../../../services/prompt_service.dart';
import '../../../viewmodels/prompt_list_view_model.dart';

class CustomDialog {
  static void show(BuildContext context, {required VoidCallback onPromptCreated}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CustomDialogContent(onPromptCreated: onPromptCreated);
      },
    );
  }
}

class _CustomDialogContent extends StatefulWidget {
  final VoidCallback onPromptCreated;

  _CustomDialogContent({required this.onPromptCreated});

  @override
  _CustomDialogContentState createState() => _CustomDialogContentState();
}

class _CustomDialogContentState extends State<_CustomDialogContent> {
  String selectedLanguage = Language.English.value;
  String selectedCategory = Category.other.value;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final viewModel = PromptListViewModel();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Title + Close Icon
            _buildTitleRow(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 2: Radio buttons

                    _buildPrivateForm(),
                  ],
                ),
              ),
            ),
            // Row buttons (Cancel & Create)
            _buildDialogButtons(context),
          ],
        ),
      ),
    );
  }

  // Row 1: Title + Close Icon
  Widget _buildTitleRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Create Prompt',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Form cho Private Prompt
  Widget _buildPrivateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 3: Prompt Language
        _buildLabeledDropdown<Language>(
          label: 'Prompt Language',
          isRequired: true,
          value: selectedLanguage,
          items: Language.values, // Truyền toàn bộ các giá trị enum
          onChanged: (newValue) {
            setState(() {
              selectedLanguage = newValue! as String;
            });
          },
        ),
        SizedBox(height: 10),
        // Row 4: Name
        _buildLabeledField(
          label: 'Name',
          isRequired: true,
          hint: 'Name of the prompt',
          controller: titleController,
        ),
        SizedBox(height: 10),
        // Row 5: Category
        _buildLabeledDropdown<Category>(
          label: 'Category',
          isRequired: true,
          value: selectedCategory,
          items: Category.values, // Truyền toàn bộ các giá trị enum
          onChanged: (newValue) {
            setState(() {
              selectedCategory = newValue! as String;
            });
          },
        ),
        SizedBox(height: 10),
        // Row 6: Description
        _buildLabeledField(
          label: 'Description',
          hint:
              'Describe your prompt so others can have a better understanding',
          controller: descriptionController,
        ),
        SizedBox(height: 10),
        // Row 7: Prompt
        _buildLabeledFieldWithInfo(
          label: 'Prompt',
          isRequired: true,
          hint:
              'e.g: Write an article about [TOPIC], make sure to include these keywords: [KEYWORDS]',
          infoText: 'Use square brackets [ ] to specify user input',
          controller: contentController,
        ),
      ],
    );
  }

  // Input field với label
  Widget _buildLabeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            if (isRequired)
              Text(
                '*',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  // Input field với label và info text
  Widget _buildLabeledFieldWithInfo({
    required String label,
    required String hint,
    required String infoText,
    required TextEditingController controller,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            if (isRequired)
              Text(
                '*',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        SizedBox(height: 5),
        Container(
          color: Colors.lightBlue[50],
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.lightBlue),
              SizedBox(width: 5),
              Expanded(child: Text(infoText)),
            ],
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  // Dropdown với label
  //

  Widget _buildLabeledDropdown<T extends Enum>({
    required String label,
    required String value,
    required List<T> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            if (isRequired)
              Text(
                '*',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            final label = (item as dynamic).label; // Tên hiển thị
            final itemValue =
                item.toString().split('.').last; // Giá trị lưu trữ
            return DropdownMenuItem(
              value: itemValue, // Giá trị lưu trữ
              child: Text(label), // Tên hiển thị
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  // Row buttons (Cancel & Create)
  Widget _buildDialogButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  //padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                      color: Colors.blue, width: 1),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Kiểm tra tính hợp lệ của các trường
                  if (selectedLanguage.isEmpty ||
                      selectedCategory.isEmpty ||
                      titleController.text.trim().isEmpty ||
                      contentController.text.trim().isEmpty) {
                    print("Title: ${titleController.text.trim()}");
                    print("Content: ${contentController.text.trim()}");
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text("Please fill in all required fields!"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }

                  // Tạo đối tượng RequestPrompt từ các giá trị đã nhập
                  PromptRequest newPrompt = PromptRequest(
                    language: selectedLanguage,
                    title: titleController.text,
                    category: selectedCategory.toLowerCase(),
                    description: descriptionController.text,
                    content: contentController.text,
                    isPublic: false,
                  );

                  await viewModel.createPrompt(newPrompt);

                  widget.onPromptCreated();

                  // Đóng dialog
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  //padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors
                      .transparent, // Quan trọng để giữ gradient
                  shadowColor:
                  Colors.transparent, // Loại bỏ bóng
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                child: const Text(
                  "Create",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
