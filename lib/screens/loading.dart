import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/providers/loading_provider.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Consumer<LoadingProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  provider.currentImage,
                  height: 200,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${(provider.progress * 100).toInt()}%",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Frederik'),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 20,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: provider.progress,
                              backgroundColor: Colors.white,
                              color: const Color(0xFF3F79FF),
                              minHeight: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  provider.currentTooltip,
                  style: const TextStyle(fontSize: 20, fontFamily: 'Frederik'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
