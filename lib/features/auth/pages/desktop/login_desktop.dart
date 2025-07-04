import 'package:cookethflow/features/auth/widgets/login_form.dart';
import 'package:cookethflow/features/auth/widgets/slider.dart';
import 'package:flutter/material.dart';

class LoginDesktop extends StatelessWidget {
  const LoginDesktop({super.key});

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
                          child: LoginForm(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: SliderStart()),
                ],
              );
  }
}