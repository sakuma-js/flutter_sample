import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './notifiers/todo_notifier.dart';
import './../models/todo.dart';
import 'package:uuid/uuid.dart';

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

class TopPage extends ConsumerWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Todo> todos = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('リスト一覧'),
      ),
      body: ListView(
        children: [
          for (final todo in todos)
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    List<Todo> todos = ref.watch(todoProvider);
    setState(() => text = widget.id != null
        ? todos.firstWhere((element) => element.id == widget.id).text
        : '');
  }

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    const uuid = Uuid();

    return Scaffold(
      appBar: AppBar(
        title: const Text('リスト追加'),
      ),
      body: Container(
        // 余白を付ける
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.id ?? ''),
            // 入力されたテキストを表示
            Text(text, style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            // テキスト入力
            TextField(
              controller: TextEditingController(text: text),
              // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
              onChanged: (String value) {
                text = value;
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final newTodo = Todo(
                      id: uuid.v4(), text: text, description: '', done: false);
                  ref.read(todoProvider.notifier).add(newTodo);
                  Navigator.of(context).pop();
                },
                child:
                    Text(widget.id != null ? 'リスト編集' : 'リスト追加', style: const TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('削除', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              // 横幅いっぱいに広げる
              width: double.infinity,
              // キャンセルボタン
              child: TextButton(
                // ボタンをクリックした時の処理
                onPressed: () {
                  // "pop"で前の画面に戻る
                  Navigator.of(context).pop();
                },
                child: const Text('キャンセル'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

