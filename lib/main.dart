import 'dart:developer';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
      home: const RemindListPage(),
    );
  }
}

// class RemindItem extends StatefulWidget {
//
//   // const RemindItem({Key? key, required this.title}): super(key: key);
//   // final Text title;
//
//   const RemindItem({Key? key}) : super(key: key);
//
//
//   @override
//   State<RemindItem> createState() => _RemindItemState();
// }

// class _RemindItemState extends State<RemindItem> {
//
//   String _itemText = '';
//   bool _isDelete = false;
//
//   // void _add (String value) {
//   //   setState(() {
//   //     _itemText = value;
//   //   });
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[
//         Text(_itemText),
//         TextButton(
//           onPressed: () {
//             setState(() {
//               _isDelete = !_isDelete;
//             });
//           },
//           child: _isDelete ? const Text('削除') : const Text('-'),
//         ),
//       ],
//     );
//   }
// }

class RemindListPage extends StatefulWidget {

  const RemindListPage({super.key});
  @override
  State<RemindListPage> createState() => _RemindListPageState();

}

// リスト一覧画面用Widget
class _RemindListPageState extends State<RemindListPage> {
  List<String> todoList = [];

  List<Map> test = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('リスト一覧'),
      ),
      body: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          return Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      // リスト追加
                      todoList.removeAt(index);
                    });
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(todoList[index]),
                    ),
                  ),
                )
              ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newListText = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              // 遷移先の画面としてリスト追加画面を指定
              return const RemindAddPage();
            }),
          );
          if (newListText == null) return;
          // キャンセルした場合は newListText が null となるので注意
          setState(() {
            // リスト追加
            todoList.add(newListText);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RemindAddPage extends StatefulWidget {
  const RemindAddPage({super.key});

  @override
  State<RemindAddPage> createState() => _RemindAddPageState();
}

class _RemindAddPageState extends State<RemindAddPage> {
  // 入力されたテキストをデータとして持つ
  String _text = '';


  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('リスト追加'),
      ),
      body: Container(
        // 余白を付ける
        padding: EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 入力されたテキストを表示
            Text(_text, style: TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            // テキスト入力
            TextField(
              // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
              onChanged: (String value) {
                // データが変更したことを知らせる（画面を更新する）
                setState(() {
                  // データを変更
                  _text = value;
                });
              },
            ),
            const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_text);
              },
              child: const Text('リスト追加', style: TextStyle(color: Colors.white)),
            ),
          ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    // データを変更

                  });
                },
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