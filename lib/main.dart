import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'web_storage_service.dart';
import 'screens/calendar_screen.dart';
import 'screens/todo_screen.dart';
import 'screens/timetable_screen.dart';
import 'screens/add_task_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WebStorageService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  DateTime? _selectedDateFromCalendar; // NEW: Store selected date from calendar

  // REMOVED: const List<Widget> _screens - because we need to rebuild them with new date

  // NEW: Build screens dynamically with selected date
  List<Widget> _buildScreens() {
    return [
      CalendarScreen(onDateSelected: _onDateSelectedFromCalendar),
      TodoScreen(selectedDate: _selectedDateFromCalendar),
      TimetableScreen(selectedDate: _selectedDateFromCalendar),
      const AddTaskScreen(),
    ];
  }

  // NEW: Callback when date is selected in calendar
  void _onDateSelectedFromCalendar(DateTime date) {
    setState(() {
      _selectedDateFromCalendar = date;
      _currentIndex = 1; // Navigate to Todo screen
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens(); // FIXED: Build screens dynamically
    
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'To Do'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Timetable'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Add'),
        ],
      ),
    );
  }
}