import 'package:flutter/material.dart';
import 'package:notes_app/screens/signup_page.dart';

class LogInPage extends StatefulWidget {
  final String appBarTitle;

  final isBiometricOn = false;
  LogInPage(this.appBarTitle, {String title});

  @override
  State<StatefulWidget> createState() {
    return _LogInPage(this.appBarTitle);
  }
}

class _LogInPage extends State<LogInPage> {
  String appBarTitle;
  _LogInPage(this.appBarTitle);
  var _userPasswordController;
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
                controller: _userPasswordController,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  icon: const Icon(Icons.lock_outline),
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
              padding: const EdgeInsets.all(20.0),
              child: MaterialButton(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 40.0, right: 40.0),
                  child: Text(
                    "Log In",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                onPressed: () {
                  logIn(context);
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignUpPage("Sign up")),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 40.0, right: 40.0),
                  child: Text(
                    "Sign Up",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                padding: EdgeInsets.all(5.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.blue, width: 2.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
bool LoginState = !LoginState ?? false;

//TODO: Add login logic to the app.
void logIn(BuildContext context) {
  final snackBar = SnackBar(
    content: const Text(
      'Logged in successfully',
      style: TextStyle(color: Colors.white),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  Navigator.pop(context, LoginState = true);
  // return isLogin = true;
}
