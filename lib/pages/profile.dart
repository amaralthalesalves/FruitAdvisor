import 'package:flutter/material.dart';
import 'package:fruitadvisor/auth/auth_service.dart';
import '../colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> articles = [];
  int _currentIndex = 4; // Index para indicar pagina atual para navbar
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final displayName = AuthService()
      .getCurrentDisplayName(); // Request para o supabase retornar nome do usuário// Request para o supabase retornar nome do usuário
  //String com rotas do aplicativo
  final List<String> _routes = [
    '/home',
    '/search',
    '/camera',
    '/profile',
    '/settings',
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
  }

  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //Construção da página
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/images/logo_wo_background_dark.png',
                  width: 200,
                  height: 200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Center(child: Column(
                    children: [
                      Text(
                        'Olá, $displayName!',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          textStyle: TextStyle(
                              fontSize: 18, color: AppColors.background),
                        ),
                        onPressed: () {
                          AuthService().signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(style: TextStyle(color: AppColors.background), 'Sair'),
                      ),
                    ],
                  ),
                ),
              ),
          ),],
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
}
