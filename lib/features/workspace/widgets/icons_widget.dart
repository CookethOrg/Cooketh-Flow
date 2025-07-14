import 'package:flutter/material.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PhosphorIconsWidget extends StatefulWidget {
  const PhosphorIconsWidget({Key? key}) : super(key: key);

  @override
  State<PhosphorIconsWidget> createState() => _PhosphorIconsWidgetState();
}

class _PhosphorIconsWidgetState extends State<PhosphorIconsWidget> {
  String searchQuery = '';

  // Manually define a list of Phosphor icons (example subset)
  late final List<MapEntry<String, IconData>> allIcons;

  @override
  void initState() {
    super.initState();
    allIcons = _getAllPhosphorIcons();
  }

  List<MapEntry<String, IconData>> _getAllPhosphorIcons() {
    // Example: Manually create a list of icons from PhosphorIconsRegular
    final List<MapEntry<String, IconData>> icons = [
      MapEntry('airplane', PhosphorIconsRegular.airplane),
      MapEntry('alarm', PhosphorIconsRegular.alarm),
      MapEntry('anchor', PhosphorIconsRegular.anchor),
      MapEntry('archive', PhosphorIconsRegular.archive),
      MapEntry('arrowDown', PhosphorIconsRegular.arrowDown),
      MapEntry('arrowUp', PhosphorIconsRegular.arrowUp),
      MapEntry('bell', PhosphorIconsRegular.bell),
      MapEntry('book', PhosphorIconsRegular.book),
      MapEntry('calendar', PhosphorIconsRegular.calendar),
      MapEntry('camera', PhosphorIconsRegular.camera),
      MapEntry('chat', PhosphorIconsRegular.chat),
      MapEntry('check', PhosphorIconsRegular.check),
      MapEntry('cloud', PhosphorIconsRegular.cloud),
      MapEntry('copy', PhosphorIconsRegular.copy),
      MapEntry('heart', PhosphorIconsRegular.heart),
      MapEntry('star', PhosphorIconsRegular.star),
      // Add more icons as needed (refer to phosphor_flutter documentation or source)
    ];

    // Sort alphabetically by name
    icons.sort((a, b) => a.key.compareTo(b.key));
    return icons;
  }

  List<MapEntry<String, IconData>> get filteredIcons {
    if (searchQuery.isEmpty) {
      return allIcons;
    }
    return allIcons.where((iconEntry) {
      return iconEntry.key.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Icons',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIconsRegular.x, size: 24, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color:const Color(0xFFD9D9D9), width: 1.2 ),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search for an icon',
                  hintStyle: TextStyle(color: Color(0XFF868686)),
                  prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, color: Colors.grey, size: 20,),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Icons Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 1,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      itemCount: filteredIcons.length,
                      itemBuilder: (context, index) {
                        final iconEntry = filteredIcons[index];
                        return Container(
                          padding: EdgeInsets.all(8),
                          child: Tooltip(
                            message: iconEntry.key,
                            child: Icon(
                              iconEntry.value,
                              size: 24,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(height: 1.2, width: 300, color: Color(0XFFD9D9D9),),
                  const SizedBox(height: 16),
                  
                  // Footer
                  Text(
                    'Phosphor icons',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}