import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';  // <-- ADDED
import 'forgot_password.dart';
import 'sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _emailError;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  /// --------------------------------------------------------------
  /// 🔥 REAL SUPABASE LOGIN FUNCTION – REPLACES YOUR OLD LOGIN CODE
  /// --------------------------------------------------------------
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password are required")),
      );
      return;
    }

    try {
      // Attempt Supabase login
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
        return;
      }

      // Read user role from metadata (optional)
      final role = user.userMetadata?['role'] ?? 'admin';

      if (role != "admin") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unauthorized — Admins only")),
        );
        return;
      }

      // Navigate to admin dashboard
      Navigator.of(context).pushReplacementNamed('/admin/profile');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_passwordFocusNode.hasFocus) {
          _handleLogin();
        } else {
          _passwordFocusNode.requestFocus();
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (_emailFocusNode.hasFocus) {
          _passwordFocusNode.requestFocus();
        } else {
          _emailFocusNode.requestFocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FocusableActionDetector(
        autofocus: true,
        child: KeyboardListener(
          focusNode: _keyboardFocusNode,
          onKeyEvent: _handleKeyEvent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 900;

              if (!narrow) {
                return Stack(
                  children: [
                    _buildBackground(),
                    _buildLeftHeader(),
                    _buildLoginContainer(),
                  ],
                );
              }

              return Stack(
                children: [
                  _buildBackground(),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildLeftHeader(),
                        Center(child: _buildLoginContainer()),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _strokedText(String text, TextStyle style,
      {double strokeWidth = 3.0, Color strokeColor = Colors.black}) {
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(text, style: style),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/background.jpeg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withAlpha(128),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  Widget _buildLeftHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _strokedText(
                        'ANTI-',
                        GoogleFonts.racingSansOne(
                          textStyle: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                        strokeWidth: 6,
                        strokeColor: Colors.black.withAlpha(204),
                      ),
                      _strokedText(
                        'REDTAPE',
                        GoogleFonts.racingSansOne(
                          textStyle: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                        strokeWidth: 6,
                        strokeColor: const Color.fromARGB(230, 187, 0, 0),
                      ),
                      _strokedText(
                        'AUTHORITY',
                        GoogleFonts.racingSansOne(
                          textStyle: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                        strokeWidth: 6,
                        strokeColor: Colors.black.withAlpha(204),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginContainer() {
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 900;

    final containerWidth = narrow
        ? ((width * 0.95) > 700 ? 700 : (width * 0.95))
        : (width * 0.4);

    return Align(
      alignment: narrow ? Alignment.topCenter : Alignment.centerRight,
      child: Container(
       width: containerWidth.toDouble(),
     constraints: BoxConstraints(
          maxWidth: 700,
          minWidth: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCityHeader(),
              const SizedBox(height: 32),
              _buildLoginHeader(),
              const SizedBox(height: 32),
              _buildLoginForm(),
              const SizedBox(height: 40),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/city_logo.png',
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Valenzuela City',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              Text(
                'Local Government',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ADMIN',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 60,
          color: Colors.blue[700],
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email or phone number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorText: _emailError,
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          onSubmitted: (_) {
            _passwordFocusNode.requestFocus();
          },
        ),
        const SizedBox(height: 20),

        Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter password',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (v) => setState(() => _rememberMe = v ?? false),
                ),
                Text(
                  'Remember me',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _showForgotPasswordDialog(),
              child: Text(
                'Forgot password?',
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
          ],
        ),

        const Divider(color: Colors.grey),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Sign in',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?",
                  style: TextStyle(color: Colors.grey[700])),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                ),
                child: Text(
                  'Sign up now',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // REMOVE THIS WHEN LIVE
        ElevatedButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed('/admin/profile'),
          child: const Text('Open Admin (dev)'),
        ),
      ],
    );
  }

  void _showForgotPasswordDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Image.asset(
            'assets/arta_logo.png',
            width: 120,
            height: 40,
          ),
          const SizedBox(height: 8),
          Text(
            '© Valenzuela City',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
