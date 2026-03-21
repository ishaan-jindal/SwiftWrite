import 'package:get/get.dart';
import 'package:writer/data/models/todo_list_item.dart';

class TodoController extends GetxController {
  final RxList<TodoListItem> items = <TodoListItem>[].obs;
  final Function(String) onMarkdownChanged;
  final String initialData;

  TodoController({required this.onMarkdownChanged, required this.initialData});

  @override
  void onInit() {
    super.onInit();
    _parseTodoData(initialData);
  }

  void _parseTodoData(String data) {
    if (data.isEmpty) {
      items.clear();
      return;
    }
    final lines = data.split('\n');
    final parsedItems = lines.map((line) {
      if (line.trim().startsWith('- [')) {
        final isDone = line.contains('- [x]');
        final title = line.substring(line.indexOf(']') + 1).trim();
        return ChecklistItem(title: title, isDone: isDone);
      } else {
        return MarkdownItem(line);
      }
    }).toList();
    items.assignAll(parsedItems);
  }

  void updateFromMarkdown(String data) {
    if (_convertToMarkdown() != data) {
      _parseTodoData(data);
    }
  }

  String _convertToMarkdown() {
    return items
        .map((item) {
          if (item is ChecklistItem) {
            return '- [${item.isDone ? 'x' : ' '}] ${item.title}';
          } else if (item is MarkdownItem) {
            return item.markdownText;
          }
          return '';
        })
        .join('\n');
  }

  void _updateMarkdown() {
    onMarkdownChanged(_convertToMarkdown());
  }

  void reorderItems(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    _updateMarkdown();
  }

  void addTodo() {
    items.add(ChecklistItem(title: 'New Todo'));
    _updateMarkdown();
  }

  void removeTodoAt(int index) {
    items.removeAt(index);
    _updateMarkdown();
  }

  void toggleTodoAt(int index) {
    final item = items[index];
    if (item is ChecklistItem) {
      item.isDone = !item.isDone;
      items.refresh();
      _updateMarkdown();
    }
  }

  void updateTodoTitle(int index, String newTitle) {
    final item = items[index];
    if (item is ChecklistItem) {
      item.title = newTitle;
      _updateMarkdown();
    }
  }
}
