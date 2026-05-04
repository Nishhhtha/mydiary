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
        useMaterial3: true,
        fontFamily: 'Roboto',
        // Seed the colour scheme from your soft teal
        colorScheme: ColorScheme.light(
          primary:          const Color(0xFFBADFDB), // soft teal
          onPrimary:        const Color(0xFF3D3D3D), // dark text on teal
          primaryContainer: const Color(0xFFBADFDB).withOpacity(0.4),
          secondary:        const Color(0xFFFFA4A4), // coral
          onSecondary:      const Color(0xFF3D3D3D),
          secondaryContainer: const Color(0xFFFFBDBD),
          surface:          const Color(0xFFFCF9EA), // cream — all card/surface backgrounds
          onSurface:        const Color(0xFF3D3D3D),
          background:       const Color(0xFFFCF9EA), // cream — page backgrounds
          onBackground:     const Color(0xFF3D3D3D),
          error:            const Color(0xFFFFA4A4), // coral instead of red
          outline:          const Color(0xFFBADFDB).withOpacity(0.5),
        ),
        scaffoldBackgroundColor: const Color(0xFFFCF9EA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFBADFDB),
          foregroundColor: Color(0xFF3D3D3D),
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFFCF9EA),
          indicatorColor: const Color(0xFFBADFDB).withOpacity(0.5),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: Color(0xFF3D3D3D));
            }
            return IconThemeData(color: const Color(0xFF3D3D3D).withOpacity(0.45));
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                  color: Color(0xFF3D3D3D));
            }
            return TextStyle(fontSize: 12,
                color: const Color(0xFF3D3D3D).withOpacity(0.45));
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBADFDB),
            foregroundColor: const Color(0xFF3D3D3D),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: const Color(0xFFBADFDB).withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: const Color(0xFFBADFDB).withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFBADFDB), width: 2),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFBADFDB).withOpacity(0.15),
          selectedColor: const Color(0xFFBADFDB).withOpacity(0.4),
          labelStyle: const TextStyle(color: Color(0xFF3D3D3D)),
          side: BorderSide(color: const Color(0xFFBADFDB).withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFA4A4),
          foregroundColor: Color(0xFF3D3D3D),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFFFCF9EA),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0xFFBADFDB).withOpacity(0.3)),
          ),
        ),
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