import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ZoomControlButton extends StatefulWidget {
  const ZoomControlButton({super.key});

  @override
  State<ZoomControlButton> createState() => _ZoomControlButtonState();
}

class _ZoomControlButtonState extends State<ZoomControlButton> {
  late TextEditingController _textController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitZoom(CanvasProvider canvasProvider) {
    final text = _textController.text.replaceAll('%', '').trim();
    final value = double.tryParse(text);
    if (value != null) {
      canvasProvider.setZoomPercentage(value);
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CanvasProvider, SupabaseService>(
      builder: (context, canvasProvider, suprovider, child) {
        return ListenableBuilder(
          listenable: canvasProvider.transformationController,
          builder: (context, child) {
            final zoomPercent = canvasProvider.currentZoomPercentage.round();
            final isDark = suprovider.isDark;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color.fromRGBO(48, 48, 48, 1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color.fromRGBO(75, 75, 75, 1) : const Color(0xFFD9D9D9),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom percentage (editable)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditing = true;
                        _textController.text = '$zoomPercent';
                        _textController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _textController.text.length,
                        );
                      });
                    },
                    child: SizedBox(
                      width: 70,
                      height: 36,
                      child: _isEditing
                          ? TextField(
                              controller: _textController,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Frederik',
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                isDense: true,
                              ),
                              onSubmitted: (_) => _submitZoom(canvasProvider),
                              onTapOutside: (_) => _submitZoom(canvasProvider),
                            )
                          : Center(
                              child: Text(
                                '$zoomPercent%',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Frederik',
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                    ),
                  ),
                  _divider(isDark),
                  // Zoom in
                  IconButton(
                    onPressed: () => canvasProvider.zoomIn(),
                    icon: Icon(
                      PhosphorIconsRegular.plus,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  _divider(isDark),
                  // Zoom out
                  IconButton(
                    onPressed: () => canvasProvider.zoomOut(),
                    icon: Icon(
                      PhosphorIconsRegular.minus,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      width: 1,
      height: 24,
      color: isDark ? const Color.fromRGBO(75, 75, 75, 1) : const Color(0xFFD9D9D9),
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}
