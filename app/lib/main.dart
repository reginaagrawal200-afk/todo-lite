import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Lite',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List tasks = [];
  TextEditingController controller = TextEditingController();

  // 🔥 IMPORTANT: change this after deployment
  final String API = "http://192.168.1.67:5000/tasks";
  // For Android emulator use 10.0.2.2 instead of localhost

  Future fetchTasks() async {
    final res = await http.get(Uri.parse(API));
    setState(() {
      tasks = json.decode(res.body);
    });
  }

  Future addTask() async {
    if (controller.text.isEmpty) return;

    await http.post(
      Uri.parse(API),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"title": controller.text}),
    );

    controller.clear();
    fetchTasks();
  }

  Future toggleTask(String id) async {
    await http.put(Uri.parse("$API/$id"));
    fetchTasks();
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Todo Lite")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter task",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addTask,
              child: Text("Add Task"),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: tasks.map<Widget>((task) {
                  return ListTile(
                    title: Text(
                      "${task['title']} (${task['status']})",
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () => toggleTask(task['_id']),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}