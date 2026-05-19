import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/features/auth/logic/auth_bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthLoginRequested(
            _emailController.text,
            _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final roles = state.user['roles'] as List<dynamic>? ?? [];
          final isInstructor = roles.any((role) => role['name'] == 'instructor');
          if (isInstructor) {
            context.go('/instructor/home');
          } else {
            context.go('/home');
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Silakan masuk dengan akun Anda',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  const Text(
                    'Email Here',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter email' : null,
                  ),
                  const SizedBox(height: 24),

                  // Password Field
                  const Text(
                    'Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter password' : null,
                  ),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(color: Colors.black45),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign In Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003399), // Dark Blue
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: state is AuthLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'MASUK',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Atau masuk dengan', style: TextStyle(color: Colors.black54)),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Facebook Login
                  _buildSocialButton(
                    icon: Icons.facebook,
                    label: 'Masuk dengan Facebook',
                    backgroundColor: const Color(0xFF1877F2),
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 16),

                  // Google Login
                  _buildSocialButton(
                    imagePath: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1200px-Google_\"G\"_logo.svg.png',
                    label: 'Masuk dengan Google',
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    onPressed: () {},
                    hasBorder: true,
                  ),
                  
                  const SizedBox(height: 48),

                  // Sign Up Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun? ', style: TextStyle(color: Colors.black54)),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: const Text(
                          'Daftar di sini',
                          style: TextStyle(
                            color: Color(0xFF003399),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    String? imagePath,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: hasBorder ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 28),
            if (imagePath != null)
              Image.network(
                imagePath,
                height: 24,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_circle,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
