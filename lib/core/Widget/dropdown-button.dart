import 'package:flutter/material.dart';

import '../../View/HomeChat/model/ai_logo_list.dart';

class AIDropdown extends StatelessWidget {
  final List<AIItem> listAIItems;
  final ValueChanged<String?> onChanged;

  const AIDropdown({
    Key? key,
    required this.listAIItems,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 235, 240, 244),
        ),
        height: 30,
        child: DropdownButtonFormField<String>(
          value: listAIItems.first.name,
          isExpanded: true,
          onChanged: onChanged,
          items: listAIItems.map<DropdownMenuItem<String>>((AIItem item) {
            return DropdownMenuItem<String>(
              value: item.name,
              child: Row(
                children: [
                  Image.asset(
                    fit: BoxFit.cover,
                    item.logoPath,
                    width: 25,
                    height: 25,
                  ),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  //Spacer(),
                  const Icon(Icons.flash_on,
                      color: Colors.greenAccent, size: 12),
                  Text(item.tokenCount.toString(),
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return listAIItems.map<Widget>((AIItem item) {
              return Image.asset(
                fit: BoxFit.cover,
                item.logoPath,
                width: 25,
                height: 25,
              );
            }).toList();
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 10, right: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
