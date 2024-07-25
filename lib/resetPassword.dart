import 'package:aplikasi_revamp/textfield/textfields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'komponen/style.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final emailController = TextEditingController();

  @override

  void dispose(){
    emailController.dispose();
    super.dispose();
  }

  Future execSendEmail(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 69),
                Text('Reset Password',
                  style: TextStyles.title.copyWith(color: Warna.white, fontSize: 20),
                ),
                const SizedBox(height: 20),

                //bar reset
                MyTextField(
                    textInputType: TextInputType.emailAddress,
                    hint: 'Email',
                    textInputAction: TextInputAction.next,
                    controller: emailController),

                const SizedBox(height: 3),

                Padding(
                  padding: const EdgeInsets.only(left: 50.0),
                  child: InkWell(
                    onTap: () {
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Resent',
                        style: TextStyles.body.copyWith(color: Warna.white, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    execSendEmail(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Warna.green,
                    minimumSize: const Size(100, 40),
                  ),
                  child: Container(
                    width: 200,
                    child: Center(
                      child: Text(
                        'Send',
                        style: TextStyles.title.copyWith(fontSize: 20, color: Colors.white),
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
