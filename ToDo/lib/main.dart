import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  List<Task> tasks = []; // List to store the tasks
  int counter = 0; // Counter for generating unique key for each task
  List<String> suggestions = [
    'Buy groceries',
    'Finish project report',
    'Schedule dentist appointment',
    'Pay utility bills',
    'Call mom',
    'Go for a run',
    'Attend team meeting',
    'Clean the house',
    'Prepare dinner',
    'Read a book',
    'Book flight tickets',
    'Pick up dry cleaning',
    'Update resume',
    'Renew gym membership',
    'Write blog post',
    'Plan weekend getaway',
    'Fix leaky faucet',
    'Send birthday gift',
    'Organize closet',
    'Practice guitar'
  ]; // List of random suggestions
  Random random = Random(); // Random generator for selecting random suggestion

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    loadTasks(); // Load tasks from shared preferences when the app starts
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? tasksJson = prefs.getStringList('tasks');
    if (tasksJson != null) {
      setState(() {
        tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
        counter = tasks.length;
      });
    }
  }

  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void addTask(String name) {
    setState(() {
      tasks.add(Task(name: name, completed: false));
      counter++;
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      counter--;
    });
    saveTasks();
  }

  void toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
    });
    saveTasks();
  }

  void updateTaskName(int index, String newName) {
    setState(() {
      tasks[index].name = newName;
    });
    saveTasks();
  }

  void _incrementCounter() {
    final randomTask = _Randomize();
    addTask(randomTask);
  }

  String _Randomize() {
    int randomIndex = random.nextInt(suggestions.length);
    return suggestions[randomIndex];
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      saveTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Todo App'),
        ),
        backgroundColor: Colors.amberAccent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Column(
                children: List.generate(tasks.length, (index) {
                  final task = tasks[index];
                  return Padding(
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.yellowAccent,
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.completed,
                          onChanged: (_) => toggleTaskCompletion(index),
                        ),
                        title: TextFormField(
                          initialValue: task.name,
                          onChanged: (value) => updateTaskName(index, value),
                          decoration: InputDecoration(
                            hintText: _Randomize(),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteTask(index),
                        ),
                      ),
                    ),
                  );
                }),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: "Add Task",
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class Task {
  String name;
  bool completed;

  Task({required this.name, required this.completed});

  Task.fromJson(String json)
      : name = json.split(',')[0],
        completed = json.split(',')[1] == 'true';

  String toJson() {
    return '$name,$completed';
  }
}
