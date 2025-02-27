import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class BackgroundManager extends ChangeNotifier {
  bool _useShapes = true;
  String? _imageUrl;
  String? _localImagePath;
  List<Shape> _shapes = [];
  final Random _random = Random();
  Timer? _shapeTimer;

  bool get useShapes => _useShapes;
  String? get imageUrl => _imageUrl;
  List<Shape> get shapes => _shapes;
  String? get localImagePath => _localImagePath;

  BackgroundManager() {
    _startShapeGeneration();
  }

  void _startShapeGeneration() {
    _shapeTimer?.cancel();
    _shapeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_useShapes) {
        _generateNewShape();
        notifyListeners();
      }
    });
  }

  void _generateNewShape() {
    if (_shapes.length >= 10) {
      _shapes.removeAt(0);
    }

    final shape = Shape(
      type: ShapeType.values[_random.nextInt(ShapeType.values.length)],
      color: Color.fromRGBO(
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
        0.3,
      ),
      position: Offset(
        _random.nextDouble() * 400,
        _random.nextDouble() * 400,
      ),
      size: 50 + _random.nextDouble() * 100,
    );

    _shapes.add(shape);
  }

  Future<void> setBackgroundImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'background_${DateTime.now().millisecondsSinceEpoch}.png';
        final localFile = File('${appDir.path}/backgrounds/$fileName');

        await localFile.parent.create(recursive: true);
        await localFile.writeAsBytes(response.bodyBytes);

        _imageUrl = url;
        _localImagePath = localFile.path;
        _useShapes = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
    }
  }

  void toggleBackgroundMode() {
    _useShapes = !_useShapes;
    if (_useShapes) {
      _startShapeGeneration();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _shapeTimer?.cancel();
    super.dispose();
  }
}

enum ShapeType { circle, square, triangle }

class Shape {
  final ShapeType type;
  final Color color;
  final Offset position;
  final double size;

  Shape({
    required this.type,
    required this.color,
    required this.position,
    required this.size,
  });
}

class BackgroundPainter extends CustomPainter {
  final List<Shape> shapes;

  BackgroundPainter(this.shapes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final shape in shapes) {
      final paint = Paint()
        ..color = shape.color
        ..style = PaintingStyle.fill;

      switch (shape.type) {
        case ShapeType.circle:
          canvas.drawCircle(shape.position, shape.size / 2, paint);
          break;
        case ShapeType.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: shape.position,
              width: shape.size,
              height: shape.size,
            ),
            paint,
          );
          break;
        case ShapeType.triangle:
          final path = Path();
          path.moveTo(shape.position.dx, shape.position.dy - shape.size / 2);
          path.lineTo(shape.position.dx - shape.size / 2,
              shape.position.dy + shape.size / 2);
          path.lineTo(shape.position.dx + shape.size / 2,
              shape.position.dy + shape.size / 2);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}