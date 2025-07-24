import 'package:flutter/material.dart';
import 'package:appp/settings_page.dart';
import 'package:appp/about_page.dart';
import 'package:appp/follow_us_page.dart'; // Replace with your actual project name
import 'package:url_launcher/url_launcher.dart';
import 'package:appp/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init(); //
  runApp(MyApp());
}


class Task {
  String title;
  bool isDone;
  DateTime? dueDate;

  Task({required this.title, this.isDone = false, this.dueDate});
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  String userName = "Harshit Kumar Singh";

  void _onBottomNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _addTask() async {
    String taskText = _taskController.text.trim();
    if (taskText.isEmpty) return;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    TimeOfDay? pickedTime;
    if (pickedDate != null) {
      pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
    }

    DateTime? finalDateTime;
    if (pickedDate != null && pickedTime != null) {
      finalDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }

    setState(() {
      _tasks.add(Task(title: taskText, dueDate: finalDateTime));
      _taskController.clear();
    });
  }

  void _deleteTask(int index) {
    setState(() => _tasks.removeAt(index));
  }

  void _editTask(int index) {
    TextEditingController editController =
    TextEditingController(text: _tasks[index].title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task'),
        content: TextField(controller: editController),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _tasks[index].title = editController.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildTaskList() {
    _tasks.sort((a, b) {
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    hintText: 'Enter a new task',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(onPressed: _addTask, child: Text('Add')),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                child: Text('No tasks yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey)))
                : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                Task task = _tasks[index];
                return Card(
                  color: task.isDone
                      ? Colors.green.shade100
                      : (task.dueDate != null &&
                      task.dueDate!.isBefore(DateTime.now()))
                      ? Colors.red.shade100
                      : Colors.white,
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (value) {
                        setState(() => task.isDone = value!);
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: task.dueDate != null
                        ? Text('Due: ${task.dueDate}')
                        : null,
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteTask(index),
                    ),
                    onLongPress: () => _editTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editUserName() {
    TextEditingController nameController =
    TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Name'),
        content: TextField(controller: nameController),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => userName = nameController.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _editUserName,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, $userName!',
                            style:
                            TextStyle(color: Colors.white, fontSize: 18)),
                        Text('Tap to change name',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.list, 'Task Lists', () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 1);
            }),
            _buildDrawerItem(Icons.feedback, 'Send Feedback', () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Send Feedback'),
                  content: Text('This feature is coming in the next update.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK')),
                  ],
                ),
              );
            }),
            _buildDrawerItem(Icons.share, 'Invite Friends', () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Invite Friends'),
                  content: Text('This feature is coming in the next update.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK')),
                  ],
                ),
              );
            }),
            _buildDrawerItem(Icons.group, 'Follow Us', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FollowUsPage()),
              );
            }),
            _buildDrawerItem(Icons.settings, 'Settings', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            }),
            _buildDrawerItem(Icons.info, 'About App', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutPage()),
              );
            }),
          ],
        ),
      ),
      appBar: AppBar(
        title: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  TextEditingController nameController = TextEditingController(text: userName);
                  TextEditingController emailController = TextEditingController();
                  TextEditingController phoneController = TextEditingController();
                  TextEditingController statusController = TextEditingController();

                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
                        TextField(controller: statusController, decoration: InputDecoration(labelText: 'Status')),
                        TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
                        TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
                        SizedBox(height: 10),
                        ElevatedButton(
                          child: Text('Save'),
                          onPressed: () {
                            setState(() {
                              userName = nameController.text;
                            });
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),

        ],
        backgroundColor: Colors.yellow[200],
        elevation: 0,
      ),
      body: _selectedIndex == 1
          ? _buildTaskList()
          : Center(
        child: Text(
          _selectedIndex == 0 ? 'Home Page' : 'Help Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_box), label: 'My Task'),
          BottomNavigationBarItem(
              icon: Icon(Icons.help_outline), label: 'Help'),
        ],
      ),
    );
  }
}
