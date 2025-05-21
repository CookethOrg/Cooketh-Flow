import "package:flutter/material.dart";
import "package:provider/provider.dart";

// Light Mode
const Color backgroundColor = Color(0xFFE0EFFF);
const Color textColor = Colors.black;
const Color transparent = Colors.transparent;
const Color deleteButtons = Colors.red;
const Color white = Colors.white;
const Color mainOrange = Colors.orange;
const Color selectedItems = Colors.blue;
const Color gridCol = Colors.grey;

List<Color> nodeColors = [
  Color(0xFFFFD8A8), // Existing
  Colors.lightGreen.shade200, // Existing
  Colors.purple.shade200, // Existing
  Colors.lightBlue.shade200, // Existing
  Color(0xffF9B9B7), // Existing
  Color(0xFFA7C7E7), // Existing
  Color(0xffA9DFBF), // Existing
  Color(0xFFE0E0E0), // Existing

  // 50 New Colors
  Color(0xFFF5CBA7), // Light peach
  Colors.teal.shade100, // Soft teal
  Color(0xFFD5F5E3), // Pale green
  Colors.pink.shade100, // Light pink
  Color(0xFFBFC9CA), // Soft gray
  Color(0xFFFADBD8), // Pale rose
  Colors.amber.shade100, // Light amber
  Color(0xFFD4E6F1), // Sky blue
  Color(0xFFE8DAEF), // Light lavender
  Colors.orange.shade100, // Soft orange
  Color(0xFFB2EBF2), // Cyan tint
  Color(0xFFF9E79F), // Pale yellow
  Colors.deepPurple.shade100, // Light purple
  Color(0xFFD7CCC8), // Muted brown
  Color(0xFFC8E1E9), // Light aqua
  Colors.lime.shade100, // Soft lime
  Color(0xFFF2D7D5), // Blush pink
  Color(0xFFE5E8E8), // Cool gray
  Colors.indigo.shade100, // Light indigo
  Color(0xFFF5B7B1), // Coral tint
  Color(0xFFDDE4E6), // Frosty blue
  Colors.red.shade100, // Light red
  Color(0xFFE8F8F5), // Minty green
  Color(0xFFF7DC6F), // Soft mustard
  Colors.blueGrey.shade100, // Pale blue-gray
  Color(0xFFD2B4DE), // Lilac
  Color(0xFFF8C1CC), // Baby pink
  Colors.green.shade100, // Light green
  Color(0xFFB9FBC0), // Spring green
  Color(0xFFE6B0FA), // Pastel purple
  Color(0xFFF5E6CC), // Creamy beige
  Colors.cyan.shade100, // Light cyan
  Color(0xFFD9E6F2), // Ice blue
  Color(0xFFF9A8D4), // Candy pink
  Colors.yellow.shade100, // Pale yellow
  Color(0xFFC4E4E9), // Seafoam
  Color(0xFFE9F7EF), // Mint cream
  Color(0xFFD5DBDB), // Light slate
  Colors.deepOrange.shade100, // Soft coral
  Color(0xFFF2E8D5), // Warm ivory
  Color(0xFFB8E8FC), // Light sky
  Colors.brown.shade100, // Light taupe
  Color(0xFFF1C1D1), // Rose quartz
  Color(0xFFD8F0D3), // Pale lime
  Color(0xFFECEFF1), // Off-white gray
  Colors.purpleAccent.shade100, // Light purple accent
  Color(0xFFF7C6A3), // Apricot
  Color(0xFFC9D6DF), // Powder blue
  Color(0xFFE2C2C6), // Dusty rose
  Color(0xFFDFF9FB), // Frosty cyan
  Color(0xFFF5F5DC), // Beige
];
