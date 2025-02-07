import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FloatingDrawer extends StatefulWidget {
  final VoidCallback onClose;

  const FloatingDrawer({super.key,required this.onClose});

  @override
  State<FloatingDrawer> createState() => _FloatingDrawerState();
}

class _FloatingDrawerState extends State<FloatingDrawer> {
  bool isOpen = false; // Controls drawer state
  bool isEditing = false; // To toggle between text and textfield
  final TextEditingController _controller = TextEditingController();
  bool isHovered = false; // To detect hover effect

  @override
  void initState() {
    super.initState();
    _controller.text = 'Cooketh Flow'; // Initial text
  }

  void toggleDrawer() {
    setState(() {
      isOpen = !isOpen; // Toggle drawer state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background overlay to close the drawer when tapped
        GestureDetector(
          onTap: widget.onClose,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
        // Background overlay (only when open)
        if (isOpen)
          GestureDetector(
            onTap: toggleDrawer, // Close drawer when tapping outside
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0),
            ),
          ),
        
        // Drawer Button (always visible)
        Positioned(
          top: 24,
          left: 24,
          child: GestureDetector(
            onTap: toggleDrawer,
            child: Container(
              width: 250,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: isOpen ? Colors.blue : Colors.white, // Background changes when open
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures even spacing
                children: [
                  Text(
                    "Cooketh Flow",
                    style: TextStyle(
                      fontSize: 20,
                      color: isOpen ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Frederik',
                    ),
                  ),
                  Icon(
                    PhosphorIconsRegular.sidebarSimple,
                    color: isOpen ? Colors.white : Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),


        // Floating drawer (only when open)
        if (isOpen)
          Positioned(
            top: 24,
            left: 24,
            child: Material(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 250,
                height: 630,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          isEditing = !isEditing; // Toggle editing state
                        });
                      },
                      child: MouseRegion(
                        onEnter: (_) => setState(() => isHovered = true),
                        onExit: (_) => setState(() => isHovered = false),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: isEditing
                                ? TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(border: OutlineInputBorder()),
                                    style: TextStyle(
                                      fontFamily: 'Frederik',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onSubmitted: (_) => setState(() => isEditing = false),
                                  )
                                : AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: isHovered
                                          ? Border(bottom: BorderSide(color: Colors.blue, width: 2))
                                          : Border.all(color: Colors.transparent),
                                    ),
                                    child: Text(
                                      _controller.text,
                                      style: TextStyle(
                                        fontFamily: 'Frederik',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(title: Text('Option 1')),
                    ListTile(title: Text('Option 2')),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
