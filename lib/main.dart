import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './notifiers/todo_notifier.dart';
import './../models/todo.dart';
import 'package:uuid/uuid.dart';

final searchTextProvider = StateProvider<String>((ref) => '');

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: const TopPage(),
    );
  }
}

final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final searchText = ref.watch(searchTextProvider);
  final todos = ref.watch(todoProvider);

  if (searchText == '') {
    return todos.toList();
  }
  return todos.where((t) => t.text.contains(searchText)).toList();
});

class TopPage extends ConsumerStatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  TopPageState createState() => TopPageState();
}

class TopPageState extends ConsumerState<TopPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: ref.read(searchTextProvider));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<Todo> todos = ref.watch(todoProvider);
    final filterTodos = ref.watch(filteredTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('リスト一覧'),
      ),
      body: ListView(
        children: [
          TextField(
            controller: _controller,
            // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
            onChanged: (value) => {
              ref.watch(searchTextProvider.notifier).state = value,
            },
          ),
          Text('${filterTodos.length}件表示中'),
          for (final todo in filterTodos)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    // 遷移先の画面としてリスト追加画面を指定
                    return RemindEditPage(id: todo.id);
                  }),
                );
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(todo.text),
                    Checkbox(
                      value: todo.done,
                      onChanged: (value) =>
                          ref.read(todoProvider.notifier).toggleDone(todo.id),
                    ),
                  ]),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              // 遷移先の画面としてリスト追加画面を指定
              return const RemindEditPage();
            }),
          );
        },
      ),
    );
  }
}

class RemindEditPage extends ConsumerStatefulWidget {
  const RemindEditPage({Key? key, this.id}) : super(key: key);
  final String? id;

  @override
  RemindEditPageState createState() => RemindEditPageState();
}

class RemindEditPageState extends ConsumerState<RemindEditPage> {
  late String text;
  late String memo;
  late String label;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    List<Todo> todos = ref.watch(todoProvider);
    setState(() {
      text = widget.id != null
          ? todos.firstWhere((element) => element.id == widget.id).text
          : '';
      memo = (widget.id != null
          ? todos.firstWhere((element) => element.id == widget.id).memo
          : '')!;
      label = (widget.id != null
          ? todos.firstWhere((element) => element.id == widget.id).label
          : '')!;
    });
  }

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    const uuid = Uuid();

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            // "pop"で前の画面に戻る
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('詳細'),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (widget.id == null) {
                final newTodo = Todo(
                    id: uuid.v4(),
                    text: text,
                    memo: memo,
                    label: label,
                    done: false);
                ref.read(todoProvider.notifier).add(newTodo);
              } else {
                final editTodo = Todo(
                    id: widget.id ?? '',
                    text: text,
                    memo: memo,
                    label: label,
                    done: false);
                ref.read(todoProvider.notifier).edit(editTodo);
              }

              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0),
            ),
            child: const Text(
              '完了',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const SizedBox(height: 8),
          // テキスト入力
          const Text('タイトル'),
          TextField(
            controller: TextEditingController(text: text),
            // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
            onChanged: (String value) {
              text = value;
            },
          ),
          const SizedBox(height: 8),
          const Text('メモ'),
          TextField(
            controller: TextEditingController(text: memo),
            // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
            onChanged: (String value) {
              memo = value;
            },
          ),
          const SizedBox(height: 8),
          const Text('ラベル'),
          TextField(
            controller: TextEditingController(text: label),
            // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
            onChanged: (String value) {
              label = value;
            },
          ),
          SizedBox(
            width: double.infinity,
            child: widget.id != null
                ? ElevatedButton(
                    onPressed: () {
                      if (widget.id == null) return;
                      ref.read(todoProvider.notifier).remove(widget.id ?? '');
                      Navigator.of(context).pop();
                    },
                    child:
                        const Text('削除', style: TextStyle(color: Colors.white)),
                  )
                : null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
