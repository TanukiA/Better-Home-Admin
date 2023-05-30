import 'package:better_home_admin/controllers/login_controller.dart';
import 'package:better_home_admin/views/text_field_container.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.controller}) : super(key: key);
  final LoginController controller;

  @override
  StateMVC<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends StateMVC<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isAllValid = false;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      setState(() {
        if (widget.controller.validEmailFormat(_emailController.text) == true &&
            _emailController.text.isNotEmpty) {
          _isEmailValid = true;
          if (_isPasswordValid) {
            _isAllValid = true;
          }
        } else {
          _isEmailValid = false;
          _isAllValid = false;
        }
      });
    });

    _passwordController.addListener(() {
      setState(() {
        if (_passwordController.text.isNotEmpty) {
          _isPasswordValid = true;
          if (_isEmailValid) {
            _isAllValid = true;
          }
        } else {
          _isPasswordValid = false;
          _isAllValid = false;
        }
      });
    });
  }

  void loginBtnClicked() {
    widget.controller.processAuthentication(
        _emailController.text, _passwordController.text, context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle loginBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      disabledForegroundColor: Colors.white,
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.8, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
      shadowColor: Colors.grey[400],
    );

    MaterialStateProperty<Color?> backgroundColor =
        MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey;
        }
        return Colors.black;
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/betterhome_logo.png',
                height: 130,
                width: 130,
              ),
              const SizedBox(height: 30),
              const Text(
                'ADMIN PORTAL',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(350, 30, 350, 30),
                padding: const EdgeInsets.fromLTRB(150, 35, 150, 35),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    TextFieldContainer(
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Email address',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (widget.controller
                            .validEmailFormat(_emailController.text) ==
                        false)
                      SizedBox(
                        width: size.width * 0.65,
                        height: 15,
                        child: const Text(
                          'Invalid email format',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextFieldContainer(
                      child: TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isAllValid ? loginBtnClicked : null,
                      style: loginBtnStyle.copyWith(
                        backgroundColor: backgroundColor,
                      ),
                      child: const Text('Login'),
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
}
