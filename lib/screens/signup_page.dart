import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  final String appBarTitle;

  final isBiometricOn = false;
  SignUpPage(this.appBarTitle, {String title});

  @override
  State<StatefulWidget> createState() {
    return _SignUpPage(this.appBarTitle);
  }
}

class _SignUpPage extends State<SignUpPage> {
  String appBarTitle;
  _SignUpPage(this.appBarTitle);

  // var _userPasswordController;
  bool _passwordVisible = false;

  void _toggle() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: Theme.of(context).textTheme.headline5,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                style: (TextStyle(
                  fontSize: 16,
                )),
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  icon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "* Required";
                  } else
                    return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                style: (TextStyle(
                  fontSize: 16,
                )),
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  icon: Icon(Icons.lock_outline),
                ),
                obscureText: !_passwordVisible,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value.isEmpty) {
                    return "* Required";
                  } else if (value.length < 7) {
                    return "Password should be at least 7 characters";
                  } else if (value.length > 25) {
                    return "Password should not be greater than 25 characters";
                  } else
                    return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                style: (TextStyle(
                  fontSize: 16,
                )),
                decoration: InputDecoration(
                  hintText: "Enter your password again",
                  icon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _toggle,
                  ),
                ),
                obscureText: !_passwordVisible,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: MaterialButton(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 40.0, right: 40.0),
                  child: Text(
                    "Sign Up",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                onPressed: () {
                  signUp(context);
                },
                color: Colors.blue,
                padding: EdgeInsets.all(5.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 40.0, right: 40.0),
                  child: Text(
                    "Cancel",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                padding: EdgeInsets.all(5.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.blue, width: 2.0)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//TODO: Add sign up logic here
void signUp(BuildContext context) {
  // final response = http.post(
  //   'http://localhost:8080/api/v1/users/signup',
  // );

  final snackBar = SnackBar(
    content: const Text(
      'Sign Up Successful! You can now login.',
      style: TextStyle(color: Colors.white),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  Navigator.pop(context, true);
}
