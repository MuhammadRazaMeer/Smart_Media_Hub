import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_media_hub/services/auth_service.dart';
import 'package:smart_media_hub/theme/app_colors.dart';
import 'package:smart_media_hub/widgets/gradient_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  bool isLoading = false;
  bool obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();

  void _handleSubmit() async {
    setState(() => isLoading = true);
    AuthResult result;

    if (isSignIn) {
      result = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      result = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
    }

    setState(() => isLoading = false);

    if (result.errorMessage != null) {
      _showSnackbar(result.errorMessage!, Colors.red);
    } else {
      _showSnackbar(isSignIn ? "Welcome back!" : "Account created!", Colors.green);
      context.go('/');
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Smart Media Hub", style: Theme.of(context).textTheme.headlineMedium),
                      Text("AI-Powered Tools", style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                isSignIn ? "Welcome Back" : "Create Account",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                isSignIn ? "Enter your details to sign in" : "Join us to start creating",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 32),
              if (!isSignIn) ...[
                _buildField("Full Name", Icons.person_outline, _nameController),
                const SizedBox(height: 16),
              ],
              _buildField("Email Address", Icons.email_outlined, _emailController),
              const SizedBox(height: 16),
              _buildField(
                "Password",
                Icons.lock_outline,
                _passwordController,
                isPassword: true,
              ),
              if (isSignIn)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Forgot Password?"),
                  ),
                ),
              const SizedBox(height: 32),
              GradientButton(
                text: isSignIn ? "Sign In" : "Sign Up",
                onPressed: _handleSubmit,
                gradient: AppColors.purpleBlue,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => isSignIn = !isSignIn),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(text: isSignIn ? "Don't have an account? " : "Already have an account? "),
                        TextSpan(
                          text: isSignIn ? "Sign Up" : "Sign In",
                          style: const TextStyle(color: AppColors.purplePrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && obscurePassword,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            hintText: label,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    );
  }
}
