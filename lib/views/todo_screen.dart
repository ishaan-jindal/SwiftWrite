import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:writer/controllers/todo_controller.dart';
import 'package:writer/data/models/todo_list_item.dart';

class TodoScreen extends StatefulWidget {
  final String data;
  final ValueChanged<String> onChanged;

  const TodoScreen({super.key, required this.data, required this.onChanged});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late final String _controllerTag;
  late final TodoController controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'todo_controller_${identityHashCode(this)}';
    Get.put(
      TodoController(
        onMarkdownChanged: widget.onChanged,
        initialData: widget.data,
      ),
      tag: _controllerTag,
    );
    controller = Get.find<TodoController>(tag: _controllerTag);
  }

  @override
  void didUpdateWidget(covariant TodoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      controller.updateFromMarkdown(widget.data);
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<TodoController>(tag: _controllerTag)) {
      Get.delete<TodoController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => ReorderableListView.builder(
          itemCount: controller.items.length,
          onReorder: controller.reorderItems,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            if (item is ChecklistItem) {
              return ListTile(
                key: ValueKey(item),
                leading: Checkbox(
                  value: item.isDone,
                  onChanged: (value) => controller.toggleTodoAt(index),
                ),
                title: TextFormField(
                  autocorrect: true,
                  initialValue: item.title,
                  autofocus: false,
                  maxLines: 3,
                  minLines: 1,
                  onChanged: (value) {
                    controller.updateTodoTitle(index, value);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => controller.removeTodoAt(index),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ],
                ),
              );
            } else if (item is MarkdownItem) {
              final isHorizontalRule = item.markdownText.trim() == '---';
              final child = MarkdownBody(data: item.markdownText);

              return Row(
                key: ValueKey(item),
                children: [
                  Expanded(
                    child: isHorizontalRule
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: child,
                          )
                        : child,
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                ],
              );
            }
            return const SizedBox.shrink(key: ValueKey('shrink'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
