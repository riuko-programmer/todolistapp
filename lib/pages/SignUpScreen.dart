// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:nuli/dbservices.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late bool _passwordVisible1;
  late bool _passwordVisible2;
  bool _submitted = false;

  String? get _errorEmail {
    if (_emailController.text.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
        .hasMatch(_emailController.text)) {
      return 'Email is invalid';
    }
    return null;
  }

  String? get _errorFullname {
    if (_fullnameController.text.isEmpty) {
      return 'Fullname is required';
    }
    return null;
  }

  String? get _errorPassword {
    if (_passwordController.text.isEmpty) {
      return 'Password is required';
    }
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? get _errorConfirmPassword {
    if (_confirmPasswordController.text.isEmpty) {
      return 'Confirm password is required';
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      return 'Confirm password must be same with password';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible1 = false;
    _passwordVisible2 = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullnameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          const SizedBox(
            height: 30,
          ),
          const Image(
            image: AssetImage("assets/nuli/images/signup-image.png"),
            height: 200,
          ),
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Hello! Sign up to get started",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Image.asset(
                      "assets/nuli/images/ic_sharp-alternate-email.png",
                      width: 30,
                    ),
                    labelText: "E-mail",
                    errorText: _submitted ? _errorEmail : null,
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                TextField(
                  controller: _fullnameController,
                  decoration: InputDecoration(
                    icon: Image.asset(
                      "assets/nuli/images/la_user.png",
                      width: 30,
                    ),
                    labelText: "Full Name",
                    errorText: _submitted ? _errorFullname : null,
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    icon: Image.asset(
                      "assets/nuli/images/fluent_lock-closed-16-regular.png",
                      width: 30,
                    ),
                    labelText: "Password",
                    errorText: _submitted ? _errorPassword : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible1
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible1 = !_passwordVisible1;
                        });
                      },
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                  obscureText: !_passwordVisible1,
                ),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    icon: Image.asset(
                      "assets/nuli/images/fluent_lock-closed-16-regular.png",
                      width: 30,
                    ),
                    labelText: "Confirm Password",
                    errorText: _submitted ? _errorConfirmPassword : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible2
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible2 = !_passwordVisible2;
                        });
                      },
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                  obscureText: !_passwordVisible2,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade900,
                    shadowColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: _emailController.text.isNotEmpty &&
                          _fullnameController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty &&
                          _confirmPasswordController.text.isNotEmpty
                      ? () async {
                          setState(() {
                            _submitted = true;
                          });
                          if (_errorEmail == null ||
                              _errorFullname == null ||
                              _errorPassword == null ||
                              _errorConfirmPassword == null) {
                            dynamic result = await UserService.signUp(
                              email: _emailController.text,
                              fullname: _fullnameController.text,
                              password: _passwordController.text,
                              context: context,
                            );
                            if (result != null) {
                              setState(() {
                                _submitted = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Sign up success"),
                                  duration: Duration(seconds: 5),
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Sign up failed"),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      : null,
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
