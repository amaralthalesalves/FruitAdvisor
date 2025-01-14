import 'package:flutter/material.dart';
import 'package:fruitadvisor/colors.dart';
import 'package:supabase/supabase.dart';
import 'package:fruitadvisor/pages/fruitview.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _currentIndex = 1;
  final SupabaseClient supabaseClient = SupabaseClient(
    'https://vvmdsjzgtiunuybqbsqh.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2bWRzanpndGl1bnV5YnFic3FoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3ODYzMDIsImV4cCI6MjA1MDM2MjMwMn0.AUDxxuJAW-DNF0KVYu4uJEq7wm-uZD16dM8NscQqbmo',
  );
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _allFruits = [];

  final List<String> _routes = [
    '/home',
    '/search',
    '/camera',
    '/history',
    '/profile',
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllFruits();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  Future<void> _fetchAllFruits() async {
    final response = await supabaseClient.from('fruits').select();

    setState(() {
      _allFruits = response;
      _searchResults = response;
    });
  }

  Future<void> _searchFruits(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = _allFruits;
      });
    } else {
      final response = await supabaseClient
          .from('fruits')
          .select()
          .ilike('translated_name', '%$query%');

      setState(() {
        _searchResults = response;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
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
                  'Pesquisar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar fruta',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  onSubmitted: (query) {
                    _searchFruits(query);
                  },
                ),
                SizedBox(height: 40),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio:
                          1.0, // Set aspect ratio to 1.0 to make items square
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final fruit = _searchResults[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FruitView(
                              fruitName: fruit['name'],
                            ),
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize
                                .min, // Take only the necessary space
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Image.asset(
                                  'assets/images/fruitImages/${fruit!['name']}.png',
                                  width: 75, // Adjust as needed
                                  fit: BoxFit
                                      .contain, // Ensure the image scales properly
                                ),
                              ),
                              SizedBox(
                                  height:
                                      8), // Optional: Add spacing between image and text
                              Text(
                                fruit['translated_name'],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
