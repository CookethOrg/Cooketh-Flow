import 'package:cookethflow/features/auth/widgets/signup_form.dart';
import 'package:flutter/material.dart';

class SignupMobile extends StatelessWidget {
  const SignupMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SignUpForm(),
      ),
    );
  }
}
