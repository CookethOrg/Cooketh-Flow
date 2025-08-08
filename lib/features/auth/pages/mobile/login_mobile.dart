import 'package:cookethflow/features/auth/widgets/login_form.dart';
import 'package:cookethflow/features/auth/widgets/slider2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginMobile extends StatelessWidget {
  const LoginMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 0.35.sh, child: SliderStart2()),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: LoginForm(),
          ),
        ],
      ),
    );
  }
}
