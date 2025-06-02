import 'package:flutter/material.dart';
import '../../theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _register() {
    // TODO: Firebase auth register işlemi
    print("Kayıt: \${_emailController.text}");
  }

  void _goToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Kayıt Ol', style: AppTextStyles.headline),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  style: AppTextStyles.input,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.email, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  style: AppTextStyles.input,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Şifre',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.lock, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _confirmPasswordController,
                  style: AppTextStyles.input,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Şifre (Tekrar)',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: Text('Kayıt Ol', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Zaten hesabın var mı?", style: AppTextStyles.subhead),
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
