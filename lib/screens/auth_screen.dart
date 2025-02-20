import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  late final AnimationController _backgroundAnimationController;
  late final Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Background animation setup
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.deepPurpleAccent,
    ).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _backgroundAnimationController.forward();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _toggleFormType() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final token = await AuthApiService.loginUser(_email, _password);
        if (token != null) {
          Navigator.pushReplacementNamed(context, '/main-menu');
        }
      } else {
        final success = await AuthApiService.registerUser(_email, _password);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please log in.')),
          );
          setState(() {
            _isLogin = true;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = _isLogin ? 'Login' : 'Sign Up';
    final toggleText = _isLogin
        ? "Don't have an account? Sign Up"
        : "Already have an account? Login";

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _backgroundAnimation.value ?? Colors.black,
                  Colors.deepPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo (Scales Based on Screen Size)
                AnimatedOpacity(
                  opacity: 0.9,
                  duration: const Duration(seconds: 2),
                  child: Image.asset(
                    'assets/ss_logo_nobg.png',
                    width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
                    height: MediaQuery.of(context).size.width * 0.4, // Keep square aspect ratio
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 20),

                // Auth Card
                Card(
                  color: Colors.white.withOpacity(0.15), // Translucent card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isLogin ? 'Welcome Back!' : 'Create an Account',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) => _email = value!.trim(),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) => _password = value!.trim(),
                          ),
                          const SizedBox(height: 24),

                          // Loading Indicator or Submit Button
                          _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _submitForm,
                                    child: Text(
                                      buttonText,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 5,
                                    ),
                                  ),
                                ),

                          const SizedBox(height: 10),

                          // Toggle between login & signup
                          TextButton(
                            onPressed: _toggleFormType,
                            child: Text(
                              toggleText,
                              style: const TextStyle(color: Colors.white70),
                            ),
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
      ),
    );
  }
}
