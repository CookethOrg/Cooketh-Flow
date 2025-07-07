import 'package:cookethflow/features/auth/widgets/signup_form.dart';
import 'package:cookethflow/features/auth/widgets/slider.dart';
import 'package:flutter/material.dart';

class SignupTablet extends StatelessWidget {
  const SignupTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            );
  }
}