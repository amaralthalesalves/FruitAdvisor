import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fruitadvisor/auth/auth_service.dart';

class FruitView extends StatefulWidget {
  final String fruitName;

  FruitView({required this.fruitName});

  @override
  _FruitViewState createState() => _FruitViewState();
}

class _FruitViewState extends State<FruitView> {
  List<dynamic> recipes = [];
  final SupabaseClient supabaseClient = SupabaseClient(
    'https://vvmdsjzgtiunuybqbsqh.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2bWRzanpndGl1bnV5YnFic3FoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3ODYzMDIsImV4cCI6MjA1MDM2MjMwMn0.AUDxxuJAW-DNF0KVYu4uJEq7wm-uZD16dM8NscQqbmo',
  );
  Map<String, dynamic>? fruitData;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFruitData();
    loadRecipes();
    createHistoryRow();
  }

  // Function to load recipes from the JSON file
  Future<void> loadRecipes() async {
    final String response = await rootBundle.loadString('assets/recipes.json');
    final data = await json.decode(response);
    setState(() {
      recipes = data;
    });
  }
  Future<void> createHistoryRow() async{
    await supabaseClient.from('history').insert({'user_name': '${AuthService().getCurrentDisplayName()}', 'fruit_name': widget.fruitName});
  }

  Future<void> fetchFruitData() async {
    try {
      final response = await supabaseClient
          .from('fruits')
          .select()
          .eq('name', widget.fruitName)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          fruitData = response;
          isLoading = false;
        });
      } else {
        print('No data found for the specified fruit. $response');
      }
    } catch (exception) {
      setState(() {
        print('Failed to fetch data: $exception');
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/fruitImages/apple_bg.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Section
                        
                            ClipRRect(
                              child: Image.asset(
                                'assets/images/fruitImages/${fruitData!['name']}_bg.png', // Replace with your image URL or asset
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                          ),

                          // Recipe Info Section
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, -3),
                                ), // changes position of shadow
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                // Recipe title and time
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${fruitData!['translated_name']}',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                                // Short description
                                Text(
                                  '${fruitData!['description']}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                SizedBox(height: 10),

                                // Nutritional Info
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tabela nutricional',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _buildNutritionInfo(
                                        '${fruitData!['calories']}cal',
                                        'Calorias'),
                                    _buildNutritionInfo(
                                        '${fruitData!['carb']}g',
                                        'Carboidratos'),
                                    _buildNutritionInfo(
                                        '${fruitData!['protein']}g',
                                        'Proteínas'),
                                    _buildNutritionInfo(
                                        '${fruitData!['fiber']}g', 'Fibras'),
                                    _buildNutritionInfo(
                                        '${fruitData!['sugar']}g', 'Açúcares'),
                                    _buildNutritionInfo(
                                        '${fruitData!['fat']}g', 'Gorduras'),
                                    _buildNutritionInfo(
                                        '${fruitData!['sodium']}mg', 'Sódio'),
                                    _buildNutritionInfo(
                                        '${fruitData!['potassium']}g',
                                        'Potássio'),
                                    _buildNutritionInfo(
                                        '${fruitData!['calcium']}mg', 'Cálcio'),
                                    _buildNutritionInfo(
                                        '${fruitData!['iron']}mg', 'Ferro'),
                                    _buildNutritionInfo(
                                        '${fruitData!['vitaminA']}mg',
                                        'Vitamina A'),
                                    _buildNutritionInfo(
                                        '${fruitData!['vitaminC']}mg',
                                        'Vitamina C'),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Receitas com ${fruitData!['translated_name']}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Container(
                                    height: 100, // Adjust the height as needed
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: recipes
                                          .length, // Assuming you have a list of recipes
                                      itemBuilder: (context, index) {
                                        final recipe = recipes[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: _buildRecipesCard(
                                              recipe), // Use the _buildRecipesCard function
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  // Function to create the recipe cards
  Widget _buildRecipesCard(dynamic recipe) {
    if (recipe['fruit_name'] != widget.fruitName) {
      return Container();
    } else {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () {
            _launchURL(recipe['url']);
          },
          child: Container(
            width: 100,
            height: 100, // Make it a square

            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                '${recipe['image']}', // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }
  }

  // Function to launch the URL of the recipes
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
      throw 'Could not launch $url';
    }
  }

  // Nutrition Info Widget
  // Nutrition Info Widget
  Widget _buildNutritionInfo(String value, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$title: ',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black, // Default text color
              ),
              children: <TextSpan>[
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Colors.grey, // Same color as description
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
