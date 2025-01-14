import 'package:flutter/material.dart';
import 'package:fruitadvisor/auth/auth_service.dart';
import 'package:fruitadvisor/pages/register.dart';
import 'package:fruitadvisor/colors.dart'; // Import your colors

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Auth service
  final authService = AuthService();
  //text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //login button action
  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    try {
      await authService.signIn(email, password);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao realizar login: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 50),
            Center(
              child: Image.asset(
                'assets/images/logo_wo_background_dark.png',
                width: 150,
                height: 150,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Login',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            //email field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
              ),
            ),
            SizedBox(height: 20),
            //password field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                labelText: 'Senha',
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),
            //button
            ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18, color: AppColors.background),
              ),
              child:
                  Text('Login', style: TextStyle(color: AppColors.background)),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  )),
              child: const Center(child: Text("Não tem uma conta?")),
            ),
          ],
        ),
      ),
    );
  }
}
