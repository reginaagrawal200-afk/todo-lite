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
      debugShowCheckedModeBanner: false,
      title: 'Todo Lite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  bool isLoading = true;

  final String API = "https://todo-lite.onrender.com/tasks";

  
  Future fetchTasks() async {
    try {
      setState(() => isLoading = true);

      final res = await http.get(Uri.parse(API));

      if (res.statusCode == 200) {
        setState(() {
          tasks = json.decode(res.body);
        });
      } else {
        print("Failed to fetch tasks");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  
  Future addTask() async {
    if (controller.text.trim().isEmpty) return;

    try {
      await http.post(
        Uri.parse(API),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"title": controller.text.trim()}),
      );

      controller.clear();
      fetchTasks();
    } catch (e) {
      print("Error adding task: $e");
    }
  }

  
  
  Future toggleTask(String id) async {
    try {
      await http.put(Uri.parse("$API/$id"));
      fetchTasks();
    } catch (e) {
      print("Error toggling task: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo Lite"),
        centerTitle: true,
      ),
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
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : tasks.isEmpty
                      ? Center(child: Text("No tasks yet"))
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(
                                  task['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: task['status'] == 'done'
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(task['status']),

                                
                                trailing: IconButton(
                                  icon: Icon(
                                    task['status'] == 'done'
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: task['status'] == 'done'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  onPressed: () =>
                                      toggleTask(task['_id']),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}