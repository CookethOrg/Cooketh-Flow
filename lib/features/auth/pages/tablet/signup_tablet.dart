import 'package:cookethflow/features/auth/widgets/signup_form.dart';
import 'package:cookethflow/features/auth/widgets/slider.dart';
import 'package:flutter/material.dart';

class SignupTablet extends StatelessWidget {
  const SignupTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            );
  }
}