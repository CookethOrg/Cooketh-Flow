import 'package:cookethflow/features/auth/widgets/login_form.dart';
import 'package:cookethflow/features/auth/widgets/slider.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        child: LoginForm(),
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
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: 32,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height - 64,
                            ),
                            child: LoginForm(),
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