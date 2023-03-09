import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './notifiers/todo_notifier.dart';
import './../models/todo.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final searchTextProvider = StateProvider<String>((ref) => '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // (通知スケジュールに使う)タイムゾーンを設定する
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  // flutter_local_notificationsの初期化
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await FlutterLocalNotificationsPlugin().initialize(initializationSettings);

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
        primarySwatch: Colors.deepPurple,
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

  bool _visible = false;

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
    List<Todo> todos = ref.watch(todoProvider);
    final filterTodos = ref.watch(filteredTodosProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (todos.isEmpty)
              Align(
                alignment: const Alignment(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: Image.asset('images/empty.png'),
                    ),
                    const Text('Add reminder!'),
                  ],
                ),
              ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView(
                  padding: const EdgeInsets.all(6),
                  children: [
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Visibility(
                              visible: _visible,
                              maintainAnimation: true,
                              maintainState: true,
                              maintainSize: true,
                              child: TextField(
                                cursorColor: Colors.deepPurpleAccent,
                                decoration: const InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple),
                                )),
                                autofocus: true,
                                controller: _controller,
                                // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
                                onChanged: (value) => {
                                  ref.watch(searchTextProvider.notifier).state =
                                      value,
                                },
                              )),
                        ),
                        IconButton(
                          padding: const EdgeInsets.all(0.0),
                          icon: const Icon(Icons.search,
                              color: Colors.deepPurple, size: 36),
                          onPressed: () {
                            setState(() {
                              _visible = !_visible;
                            });
                          },
                        ),
                      ],
                    ),
                    Visibility(
                        visible: todos.length != filterTodos.length ||
                            ref.watch(searchTextProvider.notifier).state.isNotEmpty,
                        maintainAnimation: true,
                        maintainState: true,
                        maintainSize: true,
                        child: filterTodos.isEmpty
                            ? const Text('検索結果に一致するものはありません')
                            : Text('${filterTodos.length}件表示中')),
                    for (final todo in (filterTodos.isEmpty ? todos : filterTodos))
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
                                onChanged: (value) => ref
                                    .read(todoProvider.notifier)
                                    .toggleDone(todo.id),
                              ),
                            ]),
                      )
                  ],
                )),
          ],
        ),
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
  late DateTime? dateTime;
  late bool done;

  Future<void> scheduleNotifications(DateTime dateTime,{DateTimeComponents? dateTimeComponents}) async {
    // 日時をTimeZoneを考慮した日時に変換する
    final scheduleTime = tz.TZDateTime.from(dateTime, tz.local);

    // 通知をスケジュールする
    final flnp = FlutterLocalNotificationsPlugin();
    await flnp.zonedSchedule(
      1,
      text,
      memo,
      scheduleTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          '2',
          'スケジュール通知',
          channelDescription: '設定した時刻に通知されます',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: dateTimeComponents,
    );
  }

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
      dateTime = (widget.id != null
          ? todos.firstWhere((element) => element.id == widget.id).dateTime
          : null);
      done = (widget.id != null
          ? todos.firstWhere((element) => element.id == widget.id).done
          : false);
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
                    dateTime: dateTime,
                    done: false);
                ref.read(todoProvider.notifier).add(newTodo);
              } else {
                final editTodo = Todo(
                    id: widget.id ?? '',
                    text: text,
                    memo: memo,
                    label: label,
                    dateTime: dateTime,
                    done: done);
                ref.read(todoProvider.notifier).edit(editTodo);
              }
              if (dateTime != null && !done) scheduleNotifications(dateTime!);

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
          const SizedBox(height: 8),
          const Text('日時'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (dateTime != null) Text(DateFormat('yyyy-MM-dd HH:mm').format(dateTime!), style: const TextStyle(fontSize: 20, color: Colors.black87)),
              TextButton(
                child: const Text('日時設定'),
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(1940, 1, 1).toLocal(),
                      maxTime: DateTime(2040, 12, 31).toLocal(),
                      onConfirm: (date) {
                        DatePicker.showTimePicker(
                          context,
                          showSecondsColumn: false,
                          locale: LocaleType.jp,
                          currentTime: DateTime.now().toLocal(),
                          onConfirm: (time) {
                            final pickDate = DateTime.parse('$date').toLocal();
                            setState(() {
                              dateTime = DateTime(pickDate.year, pickDate.month, pickDate.day, time.hour, time.minute);
                            });
                          },
                        );
                      }, currentTime: DateTime.now(),
                      locale: LocaleType.jp
                  );
                },
              ),
            ],
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
