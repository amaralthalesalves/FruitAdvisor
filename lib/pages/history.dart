import 'package:flutter/material.dart';
import 'package:fruitadvisor/colors.dart';
import 'package:fruitadvisor/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fruitadvisor/pages/fruitview.dart';
import 'package:intl/intl.dart'; // Import the intl package


class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final SupabaseClient supabaseClient = SupabaseClient(
    'https://vvmdsjzgtiunuybqbsqh.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2bWRzanpndGl1bnV5YnFic3FoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3ODYzMDIsImV4cCI6MjA1MDM2MjMwMn0.AUDxxuJAW-DNF0KVYu4uJEq7wm-uZD16dM8NscQqbmo',
  );
  int _currentIndex = 3; // Index to indicate the current page for the navbar
  final displayName = AuthService()
      .getCurrentDisplayName(); // Request to get the user's display name from Supabase
  List<dynamic> _history = [];
  List<dynamic> _allFruits = [];
  // List of routes in the application
  final List<String> _routes = [
    '/home',
    '/search',
    '/camera',
    '/history',
    '/profile',
  ];

  // Function to navigate between pages in the navbar
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  Future<void> _fetchHistory() async {
    // Function to fetch the user's search history
    final response = await supabaseClient
        .from('history')
        .select()
        .ilike('user_name', AuthService().getCurrentDisplayName() ?? '');
    setState(() {
      _history = response; // Filter the history by the current user
    });
  }

  Future<void> _fetchAllFruits() async {
    final response = await supabaseClient.from('fruits').select();

    setState(() {
      _allFruits = response;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllFruits();
    _fetchHistory();
  }

  String formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'),
      home: Scaffold(
        backgroundColor: AppColors.background, // Light background color
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Histórico',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final historyItem = _history[index];
                      final fruit = _allFruits.firstWhere(
                        (fruit) => fruit['name'] == historyItem['fruit_name'],
                        orElse: () => <String, dynamic>{},
                      );
                      return Card(
                        color: AppColors.secondary,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          leading: fruit.isNotEmpty
                              ? Image.asset(
                                  'assets/images/fruitImages/${fruit['name']}.png',
                                  width: 50,
                                  height: 50)
                              : Icon(Icons.image),
                          title: Text(style: TextStyle(color: AppColors.background), fruit.isNotEmpty && fruit['name'] != null
                              ? fruit['translated_name']
                              : 'Unknown'),
                          subtitle: Text(style: TextStyle(color: const Color.fromARGB(255, 243, 243, 245)),
                              'Data: ${formatTimestamp(historyItem['created_at'].toString())}'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FruitView(
                                fruitName: fruit['name'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primaryText,
          selectedItemColor: AppColors.secondary, // Dark green
          unselectedItemColor: AppColors.background,
          currentIndex: _currentIndex, // Set current index to center item
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF214C38), // Center button background color
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.background,
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
