import 'dart:ui';
import 'dart:convert';
import 'dart:math';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/circle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/connector_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/cylinder_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/diamond_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/inverted_triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/parallelogram_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rectangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/rounded_square_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/square_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/sticky_note_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/text_box_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/triangle_object.dart';
import 'package:cookethflow/features/models/canvas_models/user_cursor.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class CanvasPainter extends CustomPainter {
  final Map<String, UserCursor> userCursors;
  final Map<String, CanvasObject> canvasObjects;
  final String? currentlySelectedObjectId;
  final double handleRadius;
  final InteractionMode interactionMode;
  final Color workspaceColor;
  final double connectionPointRadius;
  final String? connectorSourceId;
  final Alignment? connectorSourceAlignment;
  final Offset? connectorDragPosition;

  CanvasPainter({
    required this.userCursors,
    required this.canvasObjects,
    this.currentlySelectedObjectId,
    this.handleRadius = 8.0,
    required this.interactionMode,
    required this.workspaceColor,
    this.connectionPointRadius = 6.0,
    this.connectorSourceId,
    this.connectorSourceAlignment,
    this.connectorDragPosition,
  });

  Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.black;
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.black;
    }
  }

  double _getFontSize(dynamic size) {
    if (size == null) return 14.0;
    if (size is double) return size;
    if (size is int) return size.toDouble();
    if (size is String) {
      switch (size) {
        case 'small':
          return 10.0;
        case 'large':
          return 18.0;
        case 'huge':
          return 22.0;
        default:
          return double.tryParse(size) ?? 14.0;
      }
    }
    return 14.0;
  }

  Color _getContrastColor(Color background) {
    // Always use white text on colored nodes for better visibility
    // Only use black text on very light backgrounds (like white or near-white)
    final luminance = background.computeLuminance();
    return luminance > 0.7 ? Colors.black : Colors.white;
  }

  static const String _defaultFontFamily = 'Frederik';
  static const double _defaultFontSize = 16.0;

  TextStyle _getTextStyle(Map<String, dynamic>? attributes, [Color defaultTextColor = Colors.black]) {
    if (attributes == null) {
      return TextStyle(fontSize: _defaultFontSize, color: defaultTextColor, fontFamily: _defaultFontFamily);
    }

    final isLink = attributes['link'] != null;
    final isCode =
        attributes['code'] == true || attributes['code-block'] == true;
    final headerLevel = attributes['header'];

    double fontSize = _defaultFontSize;
    if (headerLevel == 1) {
      fontSize = 22.0;
    } else if (headerLevel == 2) {
      fontSize = 18.0;
    } else if (attributes['size'] != null) {
      fontSize = _getFontSize(attributes['size']);
    }

    final hasExplicitColor = attributes['color'] != null;

    return TextStyle(
      fontWeight:
          attributes['bold'] == true ? FontWeight.bold : FontWeight.normal,
      fontStyle:
          attributes['italic'] == true ? FontStyle.italic : FontStyle.normal,
      color: isLink ? Colors.blue : (hasExplicitColor ? _parseColor(attributes['color'] as String?) : defaultTextColor),
      fontSize: fontSize,
      fontFamily: isCode ? 'monospace' : (attributes['font'] as String? ?? _defaultFontFamily),
      decoration: attributes['underline'] == true || isLink
          ? TextDecoration.underline
          : TextDecoration.none,
      backgroundColor: attributes['background'] != null
          ? _parseColor(attributes['background'] as String?)
          : (isCode && attributes['code-block'] != true
              ? Colors.grey.shade300
              : null),
    );
  }

  /// Returns the outward direction vector for a given alignment.
  Offset _alignmentDirection(Alignment alignment) {
    if (alignment == Alignment.topCenter) return const Offset(0, -1);
    if (alignment == Alignment.bottomCenter) return const Offset(0, 1);
    if (alignment == Alignment.centerLeft) return const Offset(-1, 0);
    if (alignment == Alignment.centerRight) return const Offset(1, 0);
    return const Offset(0, 1);
  }

  void _drawArrowhead(Canvas canvas, Offset from, Offset to, Paint paint) {
    final double arrowSize = 10;
    final double arrowAngle = 25 * pi / 180;
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);

    final path = Path();
    path.moveTo(to.dx - arrowSize * cos(angle - arrowAngle),
        to.dy - arrowSize * sin(angle - arrowAngle));
    path.lineTo(to.dx, to.dy);
    path.lineTo(to.dx - arrowSize * cos(angle + arrowAngle),
        to.dy - arrowSize * sin(angle + arrowAngle));
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  /// Builds an orthogonal (right-angle) path with rounded corners between two points.
  Path _buildOrthogonalPath(Offset start, Offset end, Alignment sourceAlignment, Alignment targetAlignment) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final sourceDir = _alignmentDirection(sourceAlignment);
    final targetDir = _alignmentDirection(targetAlignment);
    final bool sourceVertical = sourceDir.dy != 0;
    final bool targetVertical = targetDir.dy != 0;

    const double cornerRadius = 16.0;

    if (sourceVertical && !targetVertical) {
      // L-shape: source goes vertical, target comes horizontal
      final bendX = start.dx;
      final bendY = end.dy;
      _drawRoundedLPath(path, start, Offset(bendX, bendY), end, cornerRadius);
    } else if (!sourceVertical && targetVertical) {
      // L-shape: source goes horizontal, target comes vertical
      final bendX = end.dx;
      final bendY = start.dy;
      _drawRoundedLPath(path, start, Offset(bendX, bendY), end, cornerRadius);
    } else if (sourceVertical && targetVertical) {
      // Both vertical: Z-shape with two bends
      final midY = (start.dy + end.dy) / 2;
      final bend1 = Offset(start.dx, midY);
      final bend2 = Offset(end.dx, midY);
      _drawRoundedZPath(path, start, bend1, bend2, end, cornerRadius);
    } else {
      // Both horizontal: Z-shape with two bends
      final midX = (start.dx + end.dx) / 2;
      final bend1 = Offset(midX, start.dy);
      final bend2 = Offset(midX, end.dy);
      _drawRoundedZPath(path, start, bend1, bend2, end, cornerRadius);
    }

    return path;
  }

  void _drawRoundedLPath(Path path, Offset start, Offset bend, Offset end, double radius) {
    final dx1 = bend.dx - start.dx;
    final dy1 = bend.dy - start.dy;
    final dx2 = end.dx - bend.dx;
    final dy2 = end.dy - bend.dy;

    final len1 = sqrt(dx1 * dx1 + dy1 * dy1);
    final len2 = sqrt(dx2 * dx2 + dy2 * dy2);
    final r = min(radius, min(len1 / 2, len2 / 2));

    if (r < 1) {
      path.lineTo(bend.dx, bend.dy);
      path.lineTo(end.dx, end.dy);
      return;
    }

    // Point before the bend
    final beforeBend = Offset(
      bend.dx - (dx1 / len1) * r,
      bend.dy - (dy1 / len1) * r,
    );
    // Point after the bend
    final afterBend = Offset(
      bend.dx + (dx2 / len2) * r,
      bend.dy + (dy2 / len2) * r,
    );

    path.lineTo(beforeBend.dx, beforeBend.dy);
    path.quadraticBezierTo(bend.dx, bend.dy, afterBend.dx, afterBend.dy);
    path.lineTo(end.dx, end.dy);
  }

  void _drawRoundedZPath(Path path, Offset start, Offset bend1, Offset bend2, Offset end, double radius) {
    // First bend
    final dx1 = bend1.dx - start.dx;
    final dy1 = bend1.dy - start.dy;
    final dx2 = bend2.dx - bend1.dx;
    final dy2 = bend2.dy - bend1.dy;
    final dx3 = end.dx - bend2.dx;
    final dy3 = end.dy - bend2.dy;

    final len1 = sqrt(dx1 * dx1 + dy1 * dy1);
    final len2 = sqrt(dx2 * dx2 + dy2 * dy2);
    final len3 = sqrt(dx3 * dx3 + dy3 * dy3);

    final r1 = len1 > 0 && len2 > 0 ? min(radius, min(len1 / 2, len2 / 2)) : 0.0;
    final r2 = len2 > 0 && len3 > 0 ? min(radius, min(len2 / 2, len3 / 2)) : 0.0;

    if (r1 < 1 && r2 < 1) {
      path.lineTo(bend1.dx, bend1.dy);
      path.lineTo(bend2.dx, bend2.dy);
      path.lineTo(end.dx, end.dy);
      return;
    }

    if (len1 > 0 && r1 >= 1) {
      final before1 = Offset(bend1.dx - (dx1 / len1) * r1, bend1.dy - (dy1 / len1) * r1);
      final after1 = Offset(bend1.dx + (dx2 / len2) * r1, bend1.dy + (dy2 / len2) * r1);
      path.lineTo(before1.dx, before1.dy);
      path.quadraticBezierTo(bend1.dx, bend1.dy, after1.dx, after1.dy);
    } else {
      path.lineTo(bend1.dx, bend1.dy);
    }

    if (len3 > 0 && r2 >= 1) {
      final before2 = Offset(bend2.dx - (dx2 / len2) * r2, bend2.dy - (dy2 / len2) * r2);
      final after2 = Offset(bend2.dx + (dx3 / len3) * r2, bend2.dy + (dy3 / len3) * r2);
      path.lineTo(before2.dx, before2.dy);
      path.quadraticBezierTo(bend2.dx, bend2.dy, after2.dx, after2.dy);
    } else {
      path.lineTo(bend2.dx, bend2.dy);
    }

    path.lineTo(end.dx, end.dy);
  }

  /// Gets the last segment direction for arrowhead drawing on orthogonal paths.
  Offset _getLastSegmentStart(Offset start, Offset end, Alignment sourceAlignment, Alignment targetAlignment) {
    final sourceDir = _alignmentDirection(sourceAlignment);
    final targetDir = _alignmentDirection(targetAlignment);
    final bool sourceVertical = sourceDir.dy != 0;
    final bool targetVertical = targetDir.dy != 0;

    if (sourceVertical && !targetVertical) {
      // L-shape: last segment is horizontal
      return Offset(start.dx, end.dy);
    } else if (!sourceVertical && targetVertical) {
      // L-shape: last segment is vertical
      return Offset(end.dx, start.dy);
    } else if (sourceVertical && targetVertical) {
      // Z-shape: last segment is vertical
      return Offset(end.dx, (start.dy + end.dy) / 2);
    } else {
      // Z-shape: last segment is horizontal
      return Offset((start.dx + end.dx) / 2, end.dy);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final shapeObjects =
        canvasObjects.values.where((obj) => obj is! ConnectorObject);
    final connectorObjects = canvasObjects.values.whereType<ConnectorObject>();

    // 1. Draw all connectors first (so they appear behind shapes)
    for (final connector in connectorObjects) {
      final source = canvasObjects[connector.sourceId];
      final target = canvasObjects[connector.targetId];

      if (source != null && target != null) {
        final startPoint = source.getConnectionPoint(connector.sourceAlignment);
        final endPoint = target.getConnectionPoint(connector.targetAlignment);
        
        final connectorPaint = Paint()
          ..color = connector.color
          ..strokeWidth = connector.thickness
          ..style = PaintingStyle.stroke;

        final path = _buildOrthogonalPath(startPoint, endPoint, connector.sourceAlignment, connector.targetAlignment);

        switch (connector.connectionType) {
          case ConnectionType.solid:
            canvas.drawPath(path, connectorPaint);
            break;
          case ConnectionType.dotted:
            canvas.drawPath(
              dashPath(path, dashArray: CircularIntervalList<double>([1.0, 3.0])),
              connectorPaint,
            );
            break;
          case ConnectionType.dashed:
            canvas.drawPath(
              dashPath(path, dashArray: CircularIntervalList<double>([10.0, 5.0])),
              connectorPaint,
            );
            break;
        }

        // Draw arrowhead using last segment direction
        final arrowFrom = _getLastSegmentStart(startPoint, endPoint, connector.sourceAlignment, connector.targetAlignment);
        _drawArrowhead(canvas, arrowFrom, endPoint, connectorPaint);

        final originPaint = Paint()
          ..color = connector.color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(startPoint, 4, originPaint);

        if (currentlySelectedObjectId == connector.id) {
          final selectPaint = Paint()
            ..color = Colors.blue
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;
          canvas.drawPath(
            dashPath(path, dashArray: CircularIntervalList<double>([5.0, 3.0])),
            selectPaint,
          );
        }
      }
    }

    // 2. Draw all shapes and their decorations
    for (final canvasObject in shapeObjects) {
      final fillColor = canvasObject.color;
      final fillPaint = Paint()..color = fillColor;

      Rect rect;

      if (canvasObject is Circle) {
        canvas.drawCircle(canvasObject.center, canvasObject.radius, fillPaint);
        rect =
            Rect.fromCircle(center: canvasObject.center, radius: canvasObject.radius);
      } else if (canvasObject is StickyNoteObject) {
        rect = canvasObject.getBounds();
        final double borderThickness = 2.0;
        final borderPaint = Paint()
          ..color = Color.lerp(canvasObject.color, Colors.black, 0.3)!
          ..strokeWidth = borderThickness
          ..style = PaintingStyle.stroke;

        final bodyRect = Rect.fromLTRB(
            rect.left + borderThickness,
            rect.top + borderThickness,
            rect.right - borderThickness,
            rect.bottom - borderThickness);
        
        final bodyPaint = Paint()..color = canvasObject.color;
        canvas.drawRect(rect, bodyPaint);
        canvas.drawRect(rect, borderPaint);
      } else if (canvasObject is TextBoxObject) {
        rect = canvasObject.getBounds();
        if (canvasObject.color != Colors.transparent) {
          canvas.drawRect(rect, fillPaint);
        }
      } else {
        rect = canvasObject.getBounds();
        const _shapeRadius = Radius.circular(16.0);
        if (canvasObject is Rectangle) {
          canvas.drawRRect(RRect.fromRectAndRadius(rect, _shapeRadius), fillPaint);
        } else if (canvasObject is Square) {
          canvas.drawRRect(RRect.fromRectAndRadius(rect, _shapeRadius), fillPaint);
        } else if (canvasObject is RoundedSquare) {
          canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(canvasObject.cornerRadius)), fillPaint);
        } else if (canvasObject is Diamond) {
          final path = Path()
            ..moveTo(rect.center.dx, rect.top)
            ..lineTo(rect.right, rect.center.dy)
            ..lineTo(rect.center.dx, rect.bottom)
            ..lineTo(rect.left, rect.center.dy)
            ..close();
          canvas.drawPath(path, fillPaint);
        } else if (canvasObject is Triangle) {
          final path = Path()
            ..moveTo(rect.center.dx, rect.top)
            ..lineTo(rect.right, rect.bottom)
            ..lineTo(rect.left, rect.bottom)
            ..close();
          canvas.drawPath(path, fillPaint);
        } else if (canvasObject is InvertedTriangle) {
          final path = Path()
            ..moveTo(rect.left, rect.top)
            ..lineTo(rect.right, rect.top)
            ..lineTo(rect.center.dx, rect.bottom)
            ..close();
          canvas.drawPath(path, fillPaint);
        } else if (canvasObject is Parallelogram) {
          final skew = rect.width * 0.25;
          final path = Path()
            ..moveTo(rect.left + skew, rect.top)
            ..lineTo(rect.right, rect.top)
            ..lineTo(rect.right - skew, rect.bottom)
            ..lineTo(rect.left, rect.bottom)
            ..close();
          canvas.drawPath(path, fillPaint);
        } else if (canvasObject is Cylinder) {
          final ellipseHeight = min(rect.height * 0.3, 40.0);
          final bodyRect = Rect.fromLTRB(rect.left,
              rect.top + ellipseHeight / 2, rect.right, rect.bottom - ellipseHeight / 2);

          canvas.drawRect(bodyRect, fillPaint);

          final topEllipseRect = Rect.fromCenter(
              center: bodyRect.topCenter,
              width: rect.width,
              height: ellipseHeight);
          final bottomEllipseRect = Rect.fromCenter(
              center: bodyRect.bottomCenter,
              width: rect.width,
              height: ellipseHeight);

          canvas.drawOval(topEllipseRect, fillPaint);
          canvas.drawOval(bottomEllipseRect, fillPaint);
          
          final borderPaint = Paint()
            ..color = workspaceColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;
          canvas.drawOval(topEllipseRect, borderPaint);
        }
      }

      final bool isEditingText =
          interactionMode == InteractionMode.editingText &&
              currentlySelectedObjectId == canvasObject.id;
      if (canvasObject.textDelta != null &&
          canvasObject.textDelta!.isNotEmpty &&
          !isEditingText) {
        try {
          final List<dynamic> delta = jsonDecode(canvasObject.textDelta!);
          double textPadding = 8.0;
          if (canvasObject is StickyNoteObject) {
            textPadding = 12.0;
          }

          // Determine default text color based on node background brightness
          final defaultTextColor = _getContrastColor(canvasObject.color);

          final List<Map<String, dynamic>> lines = [];
          List<Map<String, dynamic>> currentLineOps = [];
          for (final op in delta) {
            final String text = op['insert'];
            final Map<String, dynamic>? attributes =
                op['attributes'] as Map<String, dynamic>?;
            if (text.contains('\n')) {
              final textLines = text.split('\n');
              for (int i = 0; i < textLines.length; i++) {
                if (textLines[i].isNotEmpty) {
                  currentLineOps
                      .add({'insert': textLines[i], 'attributes': attributes});
                }
                if (i < textLines.length - 1) {
                  lines.add({
                    'ops': List.from(currentLineOps),
                    'attributes': attributes ?? {}
                  });
                  currentLineOps.clear();
                }
              }
            } else {
              currentLineOps.add(op);
            }
          }
          if (currentLineOps.isNotEmpty) {
            lines.add({'ops': currentLineOps, 'attributes': {}});
          }

          // First pass: measure total text height
          final availableWidth = rect.width - (2 * textPadding);
          double totalTextHeight = 0;
          final List<TextPainter> painters = [];
          final List<double> indents = [];
          int orderedListCounter = 1;
          for (final line in lines) {
            final lineOps =
                List<Map<String, dynamic>>.from(line['ops'] as List);
            final blockAttributes = line['attributes'] as Map<String, dynamic>;
            final lineSpans = lineOps
                .map((o) => TextSpan(
                    text: o['insert'],
                    style: _getTextStyle(o['attributes'] as Map<String, dynamic>?, defaultTextColor)))
                .toList();
            String prefix = '';
            double indent = 0;
            if (blockAttributes['list'] == 'bullet') {
              prefix = '• ';
              indent = 10.0;
              orderedListCounter = 1;
            } else if (blockAttributes['list'] == 'ordered') {
              prefix = '$orderedListCounter. ';
              indent = 10.0;
              orderedListCounter++;
            } else {
              orderedListCounter = 1;
            }
            if (blockAttributes['blockquote'] == true) {
              indent = 20.0;
            }
            final textPainter = TextPainter(
              text: TextSpan(children: [
                TextSpan(text: prefix, style: _getTextStyle(blockAttributes, defaultTextColor)),
                ...lineSpans
              ]),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            );
            final lineAvailableWidth = availableWidth - indent;
            if (lineAvailableWidth > 0) {
              textPainter.layout(maxWidth: lineAvailableWidth);
              totalTextHeight += textPainter.height;
            }
            painters.add(textPainter);
            indents.add(indent);
          }

          // Second pass: draw text vertically centered
          double yOffset = rect.top + (rect.height - totalTextHeight) / 2;
          orderedListCounter = 1;
          for (int i = 0; i < painters.length; i++) {
            final textPainter = painters[i];
            final indent = indents[i];
            final blockAttributes = lines[i]['attributes'] as Map<String, dynamic>;
            final lineAvailableWidth = availableWidth - indent;

            if (blockAttributes['blockquote'] == true) {
              final blockPaint = Paint()
                ..color = Colors.grey.shade300
                ..strokeWidth = 2;
              canvas.drawLine(Offset(rect.left + textPadding, yOffset),
                  Offset(rect.left + textPadding, yOffset + 20), blockPaint);
            }
            if (blockAttributes['code-block'] == true) {
              final blockPaint = Paint()..color = Colors.grey.shade200;
              canvas.drawRect(
                  Rect.fromLTWH(rect.left, yOffset, rect.width, textPainter.height),
                  blockPaint);
            }

            if (lineAvailableWidth > 0) {
              textPainter.paint(
                  canvas,
                  Offset(
                    rect.left + textPadding + indent + (lineAvailableWidth - textPainter.width) / 2,
                    yOffset,
                  ));
              yOffset += textPainter.height;
            }
          }
        } catch (e) {
          print("Error painting text: $e");
        }
      }

      if (canvasObject.id == currentlySelectedObjectId && !isEditingText) {
        // Solid blue selection border
        final borderPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRect(rect, borderPaint);

        // Filled blue square handles at corners
        final double handleSize = handleRadius;
        final handlePaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;
        for (final corner in [rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight]) {
          canvas.drawRect(
            Rect.fromCenter(center: corner, width: handleSize, height: handleSize),
            handlePaint,
          );
        }

        final connectionPointPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        final connectionPointBorderPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        final points = [
          canvasObject.getConnectionPoint(Alignment.topCenter),
          canvasObject.getConnectionPoint(Alignment.bottomCenter),
          canvasObject.getConnectionPoint(Alignment.centerLeft),
          canvasObject.getConnectionPoint(Alignment.centerRight),
        ];

        for (final point in points) {
          canvas.drawCircle(point, connectionPointRadius, connectionPointPaint);
          canvas.drawCircle(
              point, connectionPointRadius, connectionPointBorderPaint);
        }
      }
    }

    if (interactionMode == InteractionMode.drawingConnector &&
        connectorSourceId != null &&
        connectorDragPosition != null) {
      final sourceObject = canvasObjects[connectorSourceId!];
      if (sourceObject != null) {
        final startPoint =
            sourceObject.getConnectionPoint(connectorSourceAlignment!);
        final endPoint = connectorDragPosition!;
        final paint = Paint()
          ..color = Colors.blue
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

        // Use orthogonal preview path based on source alignment
        // Guess target alignment as opposite of source direction
        final Alignment guessedTarget;
        if (connectorSourceAlignment == Alignment.topCenter) {
          guessedTarget = Alignment.bottomCenter;
        } else if (connectorSourceAlignment == Alignment.bottomCenter) {
          guessedTarget = Alignment.topCenter;
        } else if (connectorSourceAlignment == Alignment.centerLeft) {
          guessedTarget = Alignment.centerRight;
        } else {
          guessedTarget = Alignment.centerLeft;
        }
        final path = _buildOrthogonalPath(startPoint, endPoint, connectorSourceAlignment!, guessedTarget);
        canvas.drawPath(
            dashPath(path, dashArray: CircularIntervalList<double>([5.0, 3.0])),
            paint);
        final arrowFrom = _getLastSegmentStart(startPoint, endPoint, connectorSourceAlignment!, guessedTarget);
        _drawArrowhead(canvas, arrowFrom, endPoint, paint);
      }
    }

    for (final userCursor in userCursors.values) {
      final position = userCursor.position;
      final paint = Paint()
        ..color = userCursor.color
        ..strokeWidth = 2;
      final path = Path()
        ..moveTo(position.dx, position.dy)
        ..lineTo(position.dx, position.dy + 20)
        ..lineTo(position.dx + 5, position.dy + 15)
        ..moveTo(position.dx, position.dy + 20)
        ..lineTo(position.dx + 10, position.dy + 20)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldPainter) {
    return oldPainter.userCursors != userCursors ||
        oldPainter.canvasObjects.length != canvasObjects.length ||
        oldPainter.currentlySelectedObjectId != currentlySelectedObjectId ||
        oldPainter.interactionMode != interactionMode ||
        oldPainter.workspaceColor != workspaceColor ||
        _hasCanvasObjectsChanged(oldPainter.canvasObjects, canvasObjects) ||
        oldPainter.connectorDragPosition != connectorDragPosition;
  }

  bool _hasCanvasObjectsChanged(
      Map<String, CanvasObject> oldObjects, Map<String, CanvasObject> newObjects) {
    if (oldObjects.length != newObjects.length) return true;
    for (final id in newObjects.keys) {
      final newObj = newObjects[id];
      final oldObj = oldObjects[id];
      if (oldObj == null || newObj == null) return true;
      if (newObj.color != oldObj.color) return true;
      if (newObj.getBounds() != oldObj.getBounds()) return true;
      if (newObj.textDelta != oldObj.textDelta) return true;
      if (newObj.runtimeType != oldObj.runtimeType) return true;
      if (newObj is ConnectorObject && oldObj is ConnectorObject) {
        if (newObj.color != oldObj.color ||
            newObj.thickness != oldObj.thickness ||
            newObj.connectionType != oldObj.connectionType) {
          return true;
        }
      }
    }
    return false;
  }
}