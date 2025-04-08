import 'package:cookethflow/core/widgets/forms/signup_form.dart';
import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/dashboard.dart';
import 'package:cookethflow/screens/loading.dart';
import 'package:cookethflow/screens/log_in.dart';
import 'package:cookethflow/screens/slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final bool isMediumScreen =
        screenSize.width >= 600 && screenSize.width < 1200;

    return Consumer<AuthenticationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: isSmallScreen
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      // Slider or Loading screen on top for mobile
                      SizedBox(
                        height: 300,
                        child: provider.isLoading
                            ? ChangeNotifierProvider.value(
                                value: provider.loadingProvider,
                                child: const LoadingScreen(),
                              )
                            : SliderStart(),
                      ),

                      // Form section
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SignupForm(),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: isMediumScreen ? 2 : 1,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              EdgeInsets.all(isMediumScreen ? 40.0 : 100.0),
                          child: SignupForm(),
                        ),
                      ),
                    ),
                    if (provider.isLoading)
                      Expanded(
                        flex: isMediumScreen ? 3 : 1,
                        child: ChangeNotifierProvider.value(
                          value: provider.loadingProvider,
                          child: const LoadingScreen(),
                        ),
                      )
                    else
                      Expanded(
                          flex: isMediumScreen ? 3 : 1, child: SliderStart()),
                  ],
                ),
        );
      },
    );
  }
}
