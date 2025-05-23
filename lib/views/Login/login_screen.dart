import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_ai_chat/views/HomeChat/home.dart';
import 'package:project_ai_chat/views/Register/register_screen.dart';
import 'package:project_ai_chat/constants/colors.dart';
import 'package:project_ai_chat/constants/image_strings.dart';
import 'package:project_ai_chat/constants/sizes.dart';
import 'package:project_ai_chat/constants/text_strings.dart';
import 'package:project_ai_chat/core/Widget/elevated_button.dart';
import 'package:project_ai_chat/core/Widget/outlined_button.dart';
import 'package:project_ai_chat/services/analytics_service.dart';
import 'package:project_ai_chat/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

import '../ForgetPassword/forget_password.dart';
import 'package:project_ai_chat/utils/validators/login_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    // Sử dụng addPostFrameCallback để tránh lỗi khi gọi setState trong build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shouldShowMessage =
          ModalRoute.of(context)?.settings.arguments as bool? ?? false;

      if (shouldShowMessage) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired, please log in again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  String? _validateEmail(String? value) {
    return validateEmail(value);
  }

  String? _validatePassword(String? value) {
    return validatePassword(value);
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final success =
          await Provider.of<AuthViewModel>(context, listen: false).login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      AnalyticsService().logEvent(
        "login",
        {
          "email": _emailController.text,
        },
      );

      if (success && mounted) {
        // Chuyển sang màn hình HomeChat
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeChat()),
        );
      } else if (mounted) {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                Provider.of<AuthViewModel>(context, listen: false).error ??
                    'Đăng nhập thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logInGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'openid',
      ],
    );

    // Get the user after successful sign in
    final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuthentication =
        await googleAccount!.authentication;
    print("token1: ${googleAuthentication.accessToken}");
    print("token2: ${googleAuthentication.idToken}");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDefaultSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(
                  image: AssetImage(tWelcomeScreenImage),
                  height: size.height * 0.2,
                ),
                Text(
                  tLoginTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  tLoginSubTitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Form(
                  key: _formKey,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: tFormHeight - 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          validator: _validateEmail,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_outlined),
                            labelText: tEmail,
                          ),
                        ),
                        const SizedBox(height: tFormHeight - 20),
                        TextFormField(
                          controller: _passwordController,
                          validator: _validatePassword,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.fingerprint),
                            labelText: tPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: tFormHeight - 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgetPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(tForgetPassword),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(),
                              foregroundColor: tWhiteColor,
                              backgroundColor: tSecondaryColor,
                              side: BorderSide(color: tSecondaryColor),
                              padding:
                                  EdgeInsets.symmetric(vertical: tButtonHeight),
                            ),
                            onPressed: context.watch<AuthViewModel>().isLoading
                                ? null
                                : _login,
                            child: context.watch<AuthViewModel>().isLoading
                                ? CircularProgressIndicator()
                                : Text('LOGIN'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("OR"),
                    const SizedBox(height: tFormHeight - 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButtonCustom(
                        icon: Image(
                          image: AssetImage(tGoogleLogoImage),
                          width: 20.0,
                        ),
                        onPressed: _logInGoogle,
                        label: tSignInWithGoogle,
                      ),
                    ),
                    const SizedBox(height: tFormHeight - 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: tDontHaveAnAccount,
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: const [
                            TextSpan(
                              text: " " + tRegister,
                              style: TextStyle(color: Colors.blue),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
