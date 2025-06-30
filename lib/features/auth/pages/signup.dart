import 'package:cookethflow/features/auth/widgets/login_form.dart';
import 'package:cookethflow/features/auth/widgets/signup_form.dart';
import 'package:cookethflow/features/auth/widgets/slider.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF8F8F8),
      body: MediaQuery.of(context).size.width < 800
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: SliderStart(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: SignUpForm(),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 64,
                        ),
                        child: SignUpForm(),
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 1, child: SliderStart()),
              ],
            ),
    );
  }
}