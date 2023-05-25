// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:nuli/dbservices.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          const SizedBox(
            height: 40,
          ),
          const Image(
            image: AssetImage("assets/nuli/images/login-image.png"),
            height: 300,
          ),
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Log In",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Welcome back, you've been missed!",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Image.asset(
                      "assets/nuli/images/ic_sharp-alternate-email.png",
                      width: 30,
                    ),
                    labelText: "Email",
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    icon: Image.asset(
                      "assets/nuli/images/fluent_lock-closed-16-regular.png",
                      width: 30,
                    ),
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Login",
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
                  onPressed: () async {
                    dynamic result = await UserService.signIn(
                        _emailController.text, _passwordController.text);
                    if (result == true) {
                      Navigator.pushReplacementNamed(context, "/tabbarview");
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Login Successful"),
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text("Login Failed. Please check your credentials"),
                      ));
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "New to Nuli?",
                        style: TextStyle(fontSize: 17, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
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
