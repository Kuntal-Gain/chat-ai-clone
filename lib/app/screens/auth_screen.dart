import 'package:chat_app/app/screens/home_screen.dart';
import 'package:chat_app/app/widgets/text_field.dart';
import 'package:chat_app/data/datasource/user_db.dart';
import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // loaders
  bool isHidden = true;
  bool isLogin = false;
  bool isLoading = false;

  // services
  final _auth = AuthServices();
  final db = UserDb();

  // dispose
  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;

    setState(() {
      isLoading = !isLoading;
    });

    try {
      await _auth.signUp(email, password);

      final user = UserModel(
        email: email,
        chatIds: [],
        createdAt: DateTime.now(),
        fullName: username,
        avatarUrl: username[0],
      );

      await db.createUser(user);
      // Navigator.pop(context);
    } on AuthException catch (error) {
      setState(() {
        isLoading = false;
      });
      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      isLoading = !isLoading;
    });

    try {
      await _auth.signIn(email, password);

      // Navigator.pop(context);
    } on AuthException catch (error) {
      setState(() {
        isLoading = false;
      });
      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.asset('assets/6184159_3094352.jpg')),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Username
                if (!isLogin)
                  textFieldWidget(
                      controller: _usernameController, label: "Username"),
                const SizedBox(height: 16),

                // Email
                textFieldWidget(controller: _emailController, label: "Email"),
                const SizedBox(height: 16),

                // Password
                passwordFieldWidget(
                    controller: _passwordController,
                    label: "Password",
                    isHidden: isHidden,
                    onTap: () {
                      setState(() {
                        isHidden = !isHidden;
                      });
                    }),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: isLogin
                                ? "Don't Have an Account ? "
                                : "Already Have an Account ? ",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            )),
                        TextSpan(
                            text: !isLogin ? "Login" : "Create Account",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              }),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    isLogin ? login() : signUp();

                    if (Supabase.instance.client.auth.currentSession != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    // margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 26, 25, 25),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              isLogin ? "Login" : "Create Account",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
