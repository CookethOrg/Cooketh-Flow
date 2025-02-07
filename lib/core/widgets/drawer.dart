import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FloatingDrawer extends StatefulWidget {
  const FloatingDrawer({super.key});

  @override
  State<FloatingDrawer> createState() => _FloatingDrawerState();
}

class _FloatingDrawerState extends State<FloatingDrawer> {
  bool isOpen = false;
  bool isEditing = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = 'Cooketh Flow';
  }

  void toggleDrawer() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  String getTruncatedTitle() {
    String text = _controller.text;
    return text.length > 12 ? text.substring(0, 12) + '...' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isOpen)
          GestureDetector(
            onTap: toggleDrawer,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
            ),
          ),

        Positioned(
          top: 24,
          left: 24,
          child: GestureDetector(
            onTap: toggleDrawer,
            child: Container(
              width: 250,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: isOpen ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTruncatedTitle(),
                    style: TextStyle(
                      fontSize: 20,
                      color: isOpen ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Frederik',
                    ),
                  ),
                  GestureDetector(
                    onTap: toggleDrawer,
                    child: Icon(
                      isOpen ? PhosphorIconsFill.xCircle : PhosphorIconsFill.sidebarSimple,
                      color: isOpen ? Colors.white : Colors.black,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

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
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onDoubleTap: () {
                              setState(() {
                                isEditing = true;
                              });
                            },
                            child: isEditing
                                ? SizedBox(
                                    width: 150,
                                    child: TextField(
                                      controller: _controller,
                                      decoration: InputDecoration(border: OutlineInputBorder()),
                                      style: TextStyle(
                                        fontFamily: 'Frederik',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onSubmitted: (_) {
                                        setState(() {
                                          isEditing = false;
                                        });
                                      },
                                    ),
                                  )
                                : Text(
                                    getTruncatedTitle(),
                                    style: TextStyle(
                                      fontFamily: 'Frederik',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          GestureDetector(
                            onTap: toggleDrawer,
                            child: Icon(
                              PhosphorIconsRegular.sidebarSimple,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
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
