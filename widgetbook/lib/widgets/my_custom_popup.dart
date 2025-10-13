import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/widgets/custom_popup.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default Message', type: MyPopupMenuItem)
Widget customPopupUseCase(BuildContext context) {
  return SingleChildScrollView(
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        spacing: 150,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomPopupMenu(
            items: [
              MyPopupMenuItem(
                leading: Icon(Icons.edit, color: consts.colors.content.mediumContrast),
                title: Text(
                  'Edit',
                ),
                onTap: () => debugPrint('Edit bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () => debugPrint('Delete bosildi'),
              ),
              MyPopupMenuItem(
                leading: Icon(Icons.share, color: consts.colors.content.mediumContrast),
                title: Text(
                  'Share',
                ),
                onTap: () => debugPrint('Share bosildi'),
              ),
            ],
            child: Container(width: 200, height: 56, color: Colors.amber),
          ),
          CustomPopupMenu(
            items: [
              MyPopupMenuItem(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () => debugPrint('Edit bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () => debugPrint('Delete bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Share'),
                onTap: () => debugPrint('Share bosildi'),
              ),
            ],
            child: Container(width: 200, height: 56, color: Colors.amber),
          ),
          CustomPopupMenu(
            items: [
              MyPopupMenuItem(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () => debugPrint('Edit bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () => debugPrint('Delete bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Share'),
                onTap: () => debugPrint('Share bosildi'),
              ),
            ],
            child: Container(width: 200, height: 56, color: Colors.amber),
          ),

          CustomPopupMenu(
            items: [
              MyPopupMenuItem(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () => debugPrint('Edit bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () => debugPrint('Delete bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Share'),
                onTap: () => debugPrint('Share bosildi'),
              ),
            ],
            child: Container(width: 200, height: 56, color: Colors.amber),
          ),

          CustomPopupMenu(
            items: [
              MyPopupMenuItem(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () => debugPrint('Edit bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () => debugPrint('Delete bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Share'),
                onTap: () => debugPrint('Share bosildi'),
              ),
            ],
            child: Container(width: 200, height: 56, color: Colors.amber),
          ),
          CustomPopupMenu(
            items: [
              MyPopupMenuItem(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () => debugPrint('Edit bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () => debugPrint('Delete bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Share'),
                onTap: () => debugPrint('Share bosildi'),
              ),
            ],
            child: Container(width: 200, height: 56, color: Colors.amber),
          ),
          CustomPopupMenu(
            items: [
              MyPopupMenuItem(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () => debugPrint('Edit bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () => debugPrint('Delete bosildi'),
              ),
              MyPopupMenuItem(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Share'),
                onTap: () => debugPrint('Share bosildi'),
              ),
            ],
            child: Container(width: 200, height: 56, color: Colors.amber),
          ),
        ],
      ),
    ),
  );
}
