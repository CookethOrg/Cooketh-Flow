import 'package:cookethflow/models/connection.dart';
import 'package:flutter/material.dart';
import 'package:cookethflow/core/theme/colors.dart';

enum NodeType { rectangular, parallelogram, diamond, database }

class FlowNode {
  Offset position;
  final TextEditingController data;
  NodeType type;
  final String id;
  Color colour;
  bool isSelected;
  final Map<ConnectionPoint, Set<Connection>> connections;
  Size size;
  bool isBold;
  bool isItalic;
  bool isUnderlined;
  bool isStrikeThrough;

  FlowNode({
    required this.id,
    this.isSelected = false,
    required this.type,
    required this.position,
    this.colour = const Color(0xFFFFD8A8),
    this.size = const Size(150, 75),
    this.isBold = false,
    this.isItalic = false,
    this.isUnderlined = false,
    this.isStrikeThrough = false,
  })  : connections = {
          for (var point in ConnectionPoint.values) point: <Connection>{}
        },
        data = TextEditingController(text: 'Node $id');

  // Check if a connection point is available
  bool isConnectionPointAvailable(ConnectionPoint point) {
    return connections[point]!.isEmpty; // Example: one connection per point
  }

  FlowNode copy() {
    FlowNode newNode = FlowNode(
      id: id,
      type: type,
      colour: colour,
      position: Offset(position.dx, position.dy),
      size: Size(size.width, size.height),
      isSelected: isSelected,
      isBold: isBold,
      isItalic: isItalic,
      isStrikeThrough: isStrikeThrough,
      isUnderlined: isUnderlined
    );
    newNode.data.text = data.text;
    return newNode;
  }

  Rect get bounds {
    const padding = 20.0;
    return Rect.fromLTWH(
      position.dx - padding,
      position.dy - padding,
      size.width + (padding * 2),
      size.height + (padding * 2),
    );
  }

  void addConnection(Connection connection) {
    if (connection.sourceNodeId == id) {
      connections[connection.sourcePoint]!.add(connection);
    } else if (connection.targetNodeId == id) {
      connections[connection.targetPoint]!.add(connection);
    }
  }

  void removeConnection(Connection connection) {
    if (connection.sourceNodeId == id) {
      connections[connection.sourcePoint]!.remove(connection);
    } else if (connection.targetNodeId == id) {
      connections[connection.targetPoint]!.remove(connection);
    }
  }

  // For serialization
  Map<String, dynamic> toJson() {
    Map<String, dynamic> connectionsJson = {};
    connections.forEach((point, conns) {
      connectionsJson[point.index.toString()] =
          conns.map((conn) => conn.toJson()).toList();
    });

    return {
      "id": id,
      "text": data.text,
      "type": type.index,
      "position": {"dx": position.dx, "dy": position.dy},
      "size": {"width": size.width, "height": size.height},
      "colour": colour.toString(), // Stored as string
      "connections": connectionsJson,
      "isBold": isBold,
      "isItalic": isItalic,
      "isStrikeThrough": isStrikeThrough,
      "isUnderlined": isUnderlined
    };
  }

  // For deserialization
  factory FlowNode.fromJson(Map<String, dynamic> json) {
    FlowNode node = FlowNode(
      id: json["id"],
      type: NodeType.values[json["type"]],
      position: Offset(
        json["position"]["dx"].toDouble(),
        json["position"]["dy"].toDouble(),
      ),
      size: Size(
        json["size"]["width"].toDouble(),
        json["size"]["height"].toDouble(),
      ),
      // Parse the color string into a Color object
      colour: _parseColor(json["colour"]) ??
          const Color(0xFFFFD8A8), // Default color if parsing fails
      isBold: json["isBold"] ?? false,
      isItalic: json["isItalic"] ?? false,
      isUnderlined: json["isUnderlined"] ?? false,
      isStrikeThrough: json["isUnderlined"] ?? false,
    );

    // Set text content
    if (json["text"] != null) {
      node.data.text = json["text"];
    }

    // Add connections if available
    if (json["connections"] != null) {
      Map<String, dynamic> connsJson = json["connections"];
      connsJson.forEach((pointKey, connsData) {
        ConnectionPoint point = ConnectionPoint.values[int.parse(pointKey)];
        List<dynamic> connsList = connsData as List<dynamic>;

        for (var connData in connsList) {
          Connection conn = Connection.fromJson(connData);
          node.connections[point]!.add(conn);
        }
      });
    }

    return node;
  }

  // Helper method to parse the color string
  static Color? _parseColor(String? colorString) {
    if (colorString == null || !colorString.startsWith("Color(")) {
      return null;
    }

    try {
      // Extract the part inside "Color(...)"
      String values = colorString.substring(6, colorString.length - 1);

      // Regular expressions to extract alpha, red, green, blue values
      final alphaRegExp = RegExp(r'alpha: (\d\.\d+)');
      final redRegExp = RegExp(r'red: (\d\.\d+)');
      final greenRegExp = RegExp(r'green: (\d\.\d+)');
      final blueRegExp = RegExp(r'blue: (\d\.\d+)');

      // Find matches
      final alphaMatch = alphaRegExp.firstMatch(values);
      final redMatch = redRegExp.firstMatch(values);
      final greenMatch = greenRegExp.firstMatch(values);
      final blueMatch = blueRegExp.firstMatch(values);

      // Convert to int values (0-255 range)
      int alpha =
          ((double.tryParse(alphaMatch?.group(1) ?? '1.0') ?? 1.0) * 255)
              .round();
      int red =
          ((double.tryParse(redMatch?.group(1) ?? '0.0') ?? 0.0) * 255).round();
      int green =
          ((double.tryParse(greenMatch?.group(1) ?? '0.0') ?? 0.0) * 255)
              .round();
      int blue = ((double.tryParse(blueMatch?.group(1) ?? '0.0') ?? 0.0) * 255)
          .round();

      return Color.fromARGB(alpha, red, green, blue);
    } catch (e) {
      print("Error parsing color: $e");
      return null;
    }
  }
}
