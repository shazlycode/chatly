import 'package:flutter/material.dart';
import 'package:schooler_chat/constants/constants.dart';
import 'package:schooler_chat/main_screen.dart';
import 'package:schooler_chat/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const new({super.key});

  static const String id = "/registerScreen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? email, password = "";

  bool isLoading = false;

  GlobalKey<FormState> formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Center(
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: Image.asset("assets/images/logo.png"),
                ),
              ),
              Text("Register", style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              CustomTextField(
                validate: (v) {
                  if (v!.isEmpty || !v.contains("@")) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
                onChanged: (data) {
                  email = data;
                },
                labelText: "Username",
                iconData: Icons.person,
              ),
              SizedBox(height: 10),
              CustomTextField(
                validate: (v) {
                  if (v!.isEmpty || v.length < 6) {
                    return "Enter a valid password";
                  }
                  return null;
                },
                onChanged: (data) {
                  password = data;
                },
                labelText: "Password",
                iconData: Icons.remove_red_eye,
              ),
              SizedBox(height: 20),

              Center(
                child: SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        UserCredential user = await auth
                            .createUserWithEmailAndPassword(
                              email: email!,
                              password: password!,
                            );

                        debugPrint(user.user?.email);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("No user found for that email."),
                              ),
                            );
                          }
                        } else if (e.code == 'wrong-password') {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Wrong password provided for that user.",
                                ),
                              ),
                            );
                          }
                        }
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text("Register"),
                  ),
                ),
              ),
              Row(
                children: [
                  Text("already have account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, MainScreen.id);
                    },
                    child: Text("Login"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
