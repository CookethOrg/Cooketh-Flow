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

  TextStyle _getTextStyle(Map<String, dynamic>? attributes) {
    if (attributes == null) {
      return const TextStyle(fontSize: 14.0, color: Colors.black);
    }

    final isLink = attributes['link'] != null;
    final isCode =
        attributes['code'] == true || attributes['code-block'] == true;
    final headerLevel = attributes['header'];

    double fontSize = 14.0;
    if (headerLevel == 1) {
      fontSize = 22.0;
    } else if (headerLevel == 2) {
      fontSize = 18.0;
    } else if (attributes['size'] != null) {
      fontSize = _getFontSize(attributes['size']);
    }

    return TextStyle(
      fontWeight:
          attributes['bold'] == true ? FontWeight.bold : FontWeight.normal,
      fontStyle:
          attributes['italic'] == true ? FontStyle.italic : FontStyle.normal,
      color: isLink ? Colors.blue : _parseColor(attributes['color'] as String?),
      fontSize: fontSize,
      fontFamily: isCode ? 'monospace' : (attributes['font'] as String?),
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

  void _drawArrowhead(Canvas canvas, Offset start, Offset end, Paint paint) {
    final double arrowSize = 12;
    final double arrowAngle = 25 * pi / 180;
    final angle = atan2(end.dy - start.dy, end.dx - start.dx);

    final path = Path();
    path.moveTo(end.dx - arrowSize * cos(angle - arrowAngle),
        end.dy - arrowSize * sin(angle - arrowAngle));
    path.lineTo(end.dx, end.dy);
    path.lineTo(end.dx - arrowSize * cos(angle + arrowAngle),
        end.dy - arrowSize * sin(angle + arrowAngle));
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
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

        final path = Path()..moveTo(startPoint.dx, startPoint.dy)..lineTo(endPoint.dx, endPoint.dy);

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

        _drawArrowhead(canvas, startPoint, endPoint, connectorPaint);

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
        if (canvasObject is Rectangle) {
          canvas.drawRect(rect, fillPaint);
        } else if (canvasObject is Square) {
          canvas.drawRect(rect, fillPaint);
        } else if (canvasObject is RoundedSquare) {
          final rrect = RRect.fromRectAndRadius(
              rect, Radius.circular(canvasObject.cornerRadius));
          canvas.drawRRect(rrect, fillPaint);
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
          double yOffset = rect.top + textPadding;
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
          int orderedListCounter = 1;
          for (final line in lines) {
            final lineOps =
                List<Map<String, dynamic>>.from(line['ops'] as List);
            final blockAttributes = line['attributes'] as Map<String, dynamic>;
            final lineSpans = lineOps
                .map((o) => TextSpan(
                    text: o['insert'],
                    style: _getTextStyle(o['attributes'] as Map<String, dynamic>?)))
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
              final blockPaint = Paint()
                ..color = Colors.grey.shade300
                ..strokeWidth = 2;
              canvas.drawLine(Offset(rect.left + textPadding, yOffset),
                  Offset(rect.left + textPadding, yOffset + 20), blockPaint);
            }
            if (blockAttributes['code-block'] == true) {
              final blockPaint = Paint()..color = Colors.grey.shade200;
              canvas.drawRect(
                  Rect.fromLTWH(rect.left, yOffset, rect.width, 20),
                  blockPaint);
            }
            final textPainter = TextPainter(
              text: TextSpan(children: [
                TextSpan(text: prefix, style: _getTextStyle(blockAttributes)),
                ...lineSpans
              ]),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            );
            final availableWidth = rect.width - (2 * textPadding) - indent;
            if (availableWidth > 0) {
              textPainter.layout(maxWidth: availableWidth);
              textPainter.paint(
                  canvas,
                  Offset(
                    rect.left + textPadding + indent + (availableWidth - textPainter.width) / 2,
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
        final handlePaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(rect.topLeft, handleRadius, handlePaint);
        canvas.drawCircle(rect.topRight, handleRadius, handlePaint);
        canvas.drawCircle(rect.bottomLeft, handleRadius, handlePaint);
        canvas.drawCircle(rect.bottomRight, handleRadius, handlePaint);

        final borderPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        final path = Path()..addRect(rect);
        canvas.drawPath(
            dashPath(path, dashArray: CircularIntervalList<double>([5.0, 3.0])),
            borderPaint);

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

        final path = Path()
          ..moveTo(startPoint.dx, startPoint.dy)
          ..lineTo(endPoint.dx, endPoint.dy);
        canvas.drawPath(
            dashPath(path, dashArray: CircularIntervalList<double>([5.0, 3.0])),
            paint);
        _drawArrowhead(canvas, startPoint, endPoint, paint);
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