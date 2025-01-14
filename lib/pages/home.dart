import 'package:flutter/material.dart';
import 'package:fruitadvisor/auth/auth_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> articles = [];
  int _currentIndex = 0; // Index para indicar pagina atual para navbar
  final displayName = AuthService()
      .getCurrentDisplayName(); // Request para o supabase retornar nome do usuário
  //String com rotas do aplicativo
  final List<String> _routes = [
    '/home',
    '/search',
    '/camera',
    '/history',
    '/profile',
  ];
  //Função para navegar entre as páginas na navbar
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  //Funções que devem ser acionadas ao iniciar a página
  @override
  void initState() {
    super.initState();
    loadArticles();
  }

  //Função para carregar artigos do arquivo JSON
  Future<void> loadArticles() async {
    final String response = await rootBundle.loadString('assets/articles.json');
    final data = await json.decode(response);
    setState(() {
      articles = data;
    });
  }

  //Construção da página
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'),
      home: Scaffold(
        backgroundColor: AppColors.primary,

        body: SafeArea(
          child: Container(
            color:
                AppColors.primary, // Set the background color to primaryColor
            child: SingleChildScrollView(
              //Permite que a página seja rolada para que não haja overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      color: AppColors.primary,
                    ), // Set the background color to primaryColor
                    padding: const EdgeInsets.only(
                        bottom: 16.0, left: 16.0, right: 16.0, top: 0.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/logo_wo_background.png',
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bem-vindo, $displayName.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors
                                        .background, // Text color to contrast with primaryColor
                                  ),
                                ),
                                Text(
                                  'Pronto para mais um dia saudável?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureCard(
                              icon: Icons.camera_alt,
                              label: TextSpan(
                                text: 'Escanear\n',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.background,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Frutas por foto',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.background,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/camera');
                              },
                            ),
                            _buildFeatureCard(
                              icon: Icons.search,
                              label: TextSpan(
                                text: 'Pesquisar\n',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.background,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Frutas no sistema',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.background,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/search');
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Container(
                    color: AppColors
                        .background, // Set the background color to white
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Artigos relacionados',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors
                                .primaryText, // Text color to contrast with white background
                          ),
                        ),
                        SizedBox(height: 10),
                        ...articles
                            .map((article) => _buildArticleCard(article))
                            .toList(), //Mapeia os artigos para a função de criação do card
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        //Navbar
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

  //Função que cria os cards de funcionabilidades (escanear e pesquisar)
  Widget _buildFeatureCard(
      {required IconData icon,
      required TextSpan label,
      required VoidCallback onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 150,
          height: 120,
          decoration: BoxDecoration(
            color: Color(0xFF214C38), // Dark green background
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: AppColors.background),
              SizedBox(height: 10),
              Text.rich(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ));
  }

  //Função que cria os cards de artigos
  Widget _buildArticleCard(dynamic article) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: AppColors.background,
      child: InkWell(
        onTap: () {
          _launchURL(article['url']);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  article['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Text(
                article['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Autor: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: article['author'],
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Função para abrir URL dos artigos
  void _launchURL(String url) async {
    print('Attempting to launch URL: $url'); // Debug print
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url'); // Debug print
      throw 'Could not launch $url';
    }
  }
}
