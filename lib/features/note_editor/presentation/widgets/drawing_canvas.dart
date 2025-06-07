// ignore_for_file: unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:vector_math/vector_math_64.dart' as vm hide Colors;

import 'package:mathnotes/core/theme/font_awesome5_icons.dart';

class DrawingCanvas extends StatefulWidget {
  final String? initialDrawingData;
  final Function(String) onDrawingChanged;
  final Color strokeColor;
  final double strokeWidth;
  final PenType penType;
  final double opacity;
  final bool isEnabled;
  final DrawingTool currentTool;
  final ShapeType? currentShapeType;
  final Color? backgroundColor;

  const DrawingCanvas({
    super.key,
    this.initialDrawingData,
    required this.onDrawingChanged,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
    this.penType = PenType.pen,
    this.opacity = 1.0,
    this.isEnabled = true,
    this.currentTool = DrawingTool.pen,
    this.currentShapeType,
    this.backgroundColor,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<DrawingStroke> strokes = [];
  DrawingStroke? currentStroke;
  Set<DrawingStroke> selectedStrokes = {};
  DrawingStroke? lassoStroke;
  bool isMovingSelection = false;
  Offset? lastPanPosition;
  // Cache for loaded images
  final Map<String, ui.Image> _imageCache = {};
  
  // Zoom and pan state
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  final double _minScale = 0.5;
  final double _maxScale = 5.0;
  final TransformationController _transformationController = TransformationController();
  
  // Keys
  final GlobalKey _customPaintKey = GlobalKey();
  final GlobalKey _interactiveViewerKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _loadInitialDrawing();
  }

  void _loadInitialDrawing() {
    print('_loadInitialDrawing called with initialDrawingData: ${widget.initialDrawingData}');
    if (widget.initialDrawingData != null && widget.initialDrawingData!.isNotEmpty) {
      try {
        print('Loading initial drawing data length: ${widget.initialDrawingData!.length}');
        print('First 100 chars: ${widget.initialDrawingData!.substring(0, widget.initialDrawingData!.length > 100 ? 100 : widget.initialDrawingData!.length)}');
        final data = jsonDecode(widget.initialDrawingData!);
        if (data is List) {
          strokes = data.map((strokeData) => DrawingStroke.fromJson(strokeData)).toList();
          print('Loaded ${strokes.length} strokes from initial data');
          setState(() {});
        }
      } catch (e) {
        print('Error loading drawing data: $e');
        strokes = [];
        setState(() {});
      }
    } else {
      print('No initial drawing data provided or empty string');
      strokes = [];
      setState(() {});
    }
  }

  String? getDrawingData() {
    if (strokes.isEmpty) {
      return null;
    }
    
    try {
      final drawingData = jsonEncode(strokes.map((stroke) => stroke.toJson()).toList());
      print('Getting drawing data: $drawingData'); // Debug log
      return drawingData;
    } catch (e) {
      print('Error getting drawing data: $e');
      return null;
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isEnabled) {
      print('_onPanStart: Drawing is not enabled, ignoring');
      return;
    }
    
    print('_onPanStart: Starting new stroke, current strokes count: ${strokes.length}');
    
    // Use the global position directly with _transformPosition
    // which will handle the conversion to local coordinates
    final transformedPosition = _transformPosition(details.globalPosition);
    
    // Handle different tools
    switch (widget.currentTool) {
      case DrawingTool.eraser:
        _handleEraserStart(transformedPosition);
        break;
      case DrawingTool.shapes:
        _handleShapeStart(transformedPosition);
        break;
      case DrawingTool.lasso:
        _handleLassoStart(transformedPosition);
        break;
      case DrawingTool.pen:
      default:
        _handlePenStart(transformedPosition);
        break;
    }
  }

  void _handlePenStart(Offset position) {
    currentStroke = DrawingStroke(
      points: [position],
      color: widget.strokeColor,
      strokeWidth: widget.strokeWidth,
      penType: widget.penType,
      opacity: widget.opacity,
    );
    
    setState(() {
      strokes.add(currentStroke!);
      print('_handlePenStart: Added stroke, new strokes count: ${strokes.length}');
    });
  }

  void _handleEraserStart(Offset position) {
    // For eraser, we'll remove strokes that intersect with the eraser path
    _eraseAtPosition(position);
  }

  void _handleShapeStart(Offset position) {
    if (widget.currentShapeType == null) return;
    
    currentStroke = DrawingStroke(
      points: [position],
      color: widget.strokeColor,
      strokeWidth: widget.strokeWidth,
      penType: widget.penType,
      opacity: widget.opacity,
      isShape: true,
      shapeType: widget.currentShapeType,
    );
    
    setState(() {
      strokes.add(currentStroke!);
    });
  }

  void _handleLassoStart(Offset position) {
    // Check if we're clicking on an already selected area to move it
    if (selectedStrokes.isNotEmpty && _isPointInSelectedArea(position)) {
      isMovingSelection = true;
      lastPanPosition = position;
      return;
    }
    
    // Clear previous selection
    selectedStrokes.clear();
    
    // Start new lasso selection
    currentStroke = DrawingStroke(
      points: [position],
      color: Colors.blue,
      strokeWidth: 2.0,
      penType: PenType.pen,
      opacity: 1.0,
      isLassoSelection: true,
    );
    
    setState(() {
      // Remove previous lasso stroke if exists
      strokes.removeWhere((stroke) => stroke.isLassoSelection);
      strokes.add(currentStroke!);
      lassoStroke = currentStroke;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isEnabled) return;
    
    // Use the global position directly with _transformPosition
    // which will handle the conversion to local coordinates
    final transformedPosition = _transformPosition(details.globalPosition);
    
    switch (widget.currentTool) {
      case DrawingTool.eraser:
        _eraseAtPosition(transformedPosition);
        break;
      case DrawingTool.shapes:
        if (currentStroke != null) {
          setState(() {
            // For shapes, we only need start and end points
            if (currentStroke!.points.length == 1) {
              currentStroke!.points.add(transformedPosition);
            } else {
              currentStroke!.points[1] = transformedPosition;
            }
          });
        }
        break;
      case DrawingTool.lasso:
        if (isMovingSelection && selectedStrokes.isNotEmpty) {
          _moveSelectedStrokes(transformedPosition);
        } else if (currentStroke != null) {
          setState(() {
            currentStroke!.points.add(transformedPosition);
          });
        }
        break;
      case DrawingTool.pen:
      default:
        if (currentStroke != null) {
          setState(() {
            currentStroke!.points.add(transformedPosition);
          });
        }
        break;
    }
  }

  void _eraseAtPosition(Offset position) {
    const double eraserRadius = 20.0;
    
    try {
      setState(() {
        final strokesToRemove = <DrawingStroke>[];
        
        for (final stroke in strokes) {
          if (stroke.isLassoSelection) continue; // Don't erase lasso selections
          
          try {
            // Check if any point in the stroke is within eraser radius
            bool shouldErase = false;
            for (final point in stroke.points) {
              final distance = (point - position).distance;
              if (distance <= eraserRadius) {
                shouldErase = true;
                break;
              }
            }
            
            if (shouldErase) {
              strokesToRemove.add(stroke);
            }
          } catch (e) {
            print('Error checking stroke for erasing: $e');
            // Skip this stroke if there's an error
          }
        }
        
        // Remove the strokes that should be erased
        for (final stroke in strokesToRemove) {
          strokes.remove(stroke);
        }
        
        print('Erased ${strokesToRemove.length} strokes, ${strokes.length} remaining');
      });
      
      // Trigger callback to save changes
      try {
        final drawingData = getDrawingData();
        if (drawingData != null) {
          widget.onDrawingChanged(drawingData);
        } else {
          // If no drawing data, send empty string
          widget.onDrawingChanged('');
        }
      } catch (e) {
        print('Error saving drawing data after erase: $e');
        // Send empty string as fallback
        widget.onDrawingChanged('');
      }
    } catch (e, stackTrace) {
      print('Error in _eraseAtPosition: $e');
      print('Stack trace: $stackTrace');
      // Don't crash the app, just log the error
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isEnabled) {
      print('_onPanEnd: Drawing is not enabled, ignoring');
      return;
    }
    
    if (widget.currentTool == DrawingTool.lasso) {
      if (isMovingSelection) {
        isMovingSelection = false;
        lastPanPosition = null;
      } else if (currentStroke != null && currentStroke!.isLassoSelection) {
        // Complete lasso selection
        _completeSelection();
      }
    }
    
    print('_onPanEnd: Ending stroke, strokes count: ${strokes.length}');
    currentStroke = null;
    _saveDrawing();
  }

  void _saveDrawing() {
    print('_saveDrawing called with ${strokes.length} strokes');
    if (strokes.isEmpty) {
      print('_saveDrawing: strokes is empty, sending empty string');
      widget.onDrawingChanged('');
      return;
    }
    
    try {
      final drawingData = jsonEncode(strokes.map((stroke) => stroke.toJson()).toList());
      print('_saveDrawing: Saving drawing data length: ${drawingData.length}');
      if (drawingData.length > 100) {
        print('_saveDrawing: First 100 chars: ${drawingData.substring(0, 100)}');
      } else {
        print('_saveDrawing: Full data: $drawingData');
      }
      widget.onDrawingChanged(drawingData);
    } catch (e) {
      print('Error saving drawing data: $e');
      widget.onDrawingChanged('');
    }
  }

  void clearCanvas() {
    setState(() {
      strokes.clear();
      currentStroke = null;
    });
    widget.onDrawingChanged('');
  }

  void undoLastStroke() {
    if (strokes.isNotEmpty) {
      setState(() {
        strokes.removeLast();
      });
      _saveDrawing();
    }
  }

  bool _isPointInSelectedArea(Offset point) {
    if (selectedStrokes.isEmpty) return false;
    
    // Check if point is near any selected stroke
    for (final stroke in selectedStrokes) {
      for (final strokePoint in stroke.points) {
        if ((strokePoint - point).distance < 30.0) {
          return true;
        }
      }
    }
    return false;
  }

  void _moveSelectedStrokes(Offset currentPosition) {
    if (lastPanPosition == null) return;
    
    final delta = currentPosition - lastPanPosition!;
    
    setState(() {
      for (final stroke in selectedStrokes) {
        for (int i = 0; i < stroke.points.length; i++) {
          stroke.points[i] = stroke.points[i] + delta;
        }
      }
    });
    
    lastPanPosition = currentPosition;
  }

  void _completeSelection() {
    if (lassoStroke == null || lassoStroke!.points.length < 3) {
      // Remove incomplete lasso
      setState(() {
        strokes.removeWhere((stroke) => stroke.isLassoSelection);
      });
      return;
    }
    
    // Find strokes inside the lasso
    selectedStrokes.clear();
    
    for (final stroke in strokes) {
      if (stroke.isLassoSelection) continue;
      
      // Check if any point of the stroke is inside the lasso
      bool isInside = false;
      for (final point in stroke.points) {
        if (_isPointInPolygon(point, lassoStroke!.points)) {
          isInside = true;
          break;
        }
      }
      
      if (isInside) {
        selectedStrokes.add(stroke);
      }
    }
    
    // Keep the lasso visible if we have selected strokes
    if (selectedStrokes.isEmpty) {
      setState(() {
        strokes.removeWhere((stroke) => stroke.isLassoSelection);
        lassoStroke = null;
      });
    }
  }

  bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;
    
    bool inside = false;
    int j = polygon.length - 1;
    
    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].dx;
      final yi = polygon[i].dy;
      final xj = polygon[j].dx;
      final yj = polygon[j].dy;
      
      if (((yi > point.dy) != (yj > point.dy)) &&
          (point.dx < (xj - xi) * (point.dy - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
      j = i;
    }
    
    return inside;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Zoom controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: _zoomOut,
                tooltip: 'Zoom Out',
              ),
              Text('${(_scale * 100).round()}%'),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: _zoomIn,
                tooltip: 'Zoom In',
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.center_focus_strong),
                onPressed: _resetZoom,
                tooltip: 'Reset Zoom',
              ),
            ],
          ),
        ),
        // Drawing area with zoom
        Expanded(
          child: InteractiveViewer(
            key: _interactiveViewerKey,
            transformationController: _transformationController,
            minScale: _minScale,
            maxScale: _maxScale,
            onInteractionUpdate: (details) {
              // Only update the scale state, don't modify the transformation
              final currentScale = _transformationController.value.getMaxScaleOnAxis();
              if ((currentScale - _scale).abs() > 0.01) {
                setState(() {
                  _scale = currentScale;
                });
              }
            },
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: LayoutBuilder(
                builder: (context, constraints) => CustomPaint(
                  key: _customPaintKey,
                  painter: DrawingPainter(
                    strokes, 
                    selectedStrokes, 
                    _imageCache, 
                    () => setState(() {}),
                    widget.backgroundColor,
                  ),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  child: Container(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  void _zoomIn() {
    final newScale = (_scale * 1.2).clamp(_minScale, _maxScale);
    _updateZoom(newScale);
  }
  
  void _zoomOut() {
    final newScale = (_scale / 1.2).clamp(_minScale, _maxScale);
    _updateZoom(newScale);
  }
  
  void _resetZoom() {
    _updateZoom(1.0);
  }
  
  void _updateZoom(double newScale) {
    // Clamp the scale to min and max values
    newScale = newScale.clamp(_minScale, _maxScale);
    
    // Create a new transformation matrix with the scale
    final Matrix4 newMatrix = Matrix4.identity()..scale(newScale);
    
    // Update the controller
    _transformationController.value = newMatrix;
    
    // Update the scale state variable
    setState(() {
      _scale = newScale;
    });
  }
  
  // Reference to the CustomPaint's RenderBox
  RenderBox? _customPaintBox;
  
  // Method to get the CustomPaint's RenderBox
  RenderBox? _getCustomPaintBox() {
    if (_customPaintBox != null) return _customPaintBox;
    
    // Find the CustomPaint widget's RenderBox
    final RenderObject? renderObject = _customPaintKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      _customPaintBox = renderObject;
      return _customPaintBox;
    }
    return null;
  }
  
  // Keys are declared at the top of the class
  
  Offset _transformPosition(Offset screenPosition) {
    try {
      // Get the InteractiveViewer's RenderBox
      final RenderObject? interactiveViewerObject = _interactiveViewerKey.currentContext?.findRenderObject();
      if (interactiveViewerObject is! RenderBox) {
        print('InteractiveViewer RenderBox is null');
        return screenPosition;
      }
      
      // Get the CustomPaint's RenderBox
      final RenderBox? customPaintBox = _getCustomPaintBox();
      if (customPaintBox == null) {
        print('CustomPaint RenderBox is null');
        return screenPosition;
      }
      
      // First convert the screen position to the local coordinate system of the InteractiveViewer
      final interactiveViewerPosition = interactiveViewerObject.globalToLocal(screenPosition);
      
      // Get the current transformation matrix
      final Matrix4 transform = _transformationController.value;
      
      // Create a copy of the transformation matrix to avoid modifying the original
      final Matrix4 invertedTransform = Matrix4.copy(transform);
      
      try {
        // Try to invert the matrix
        invertedTransform.invert();
        
        // Transform the InteractiveViewer position to canvas coordinates
        final vm.Vector3 localVector = vm.Vector3(interactiveViewerPosition.dx, interactiveViewerPosition.dy, 0.0);
        final vm.Vector3 canvasVector = invertedTransform.transform3(localVector);
        
        // Print debug information
        print('Screen position: $screenPosition');
        print('InteractiveViewer position: $interactiveViewerPosition');
        print('Canvas position: ${Offset(canvasVector.x, canvasVector.y)}');
        print('Scale: ${transform.getMaxScaleOnAxis()}');
        
        return Offset(canvasVector.x, canvasVector.y);
      } catch (e) {
        // If matrix inversion fails, fall back to manual calculation
        print('Matrix inversion failed, falling back to manual calculation: $e');
        
        // Extract scale and translation from the transformation matrix
        final double scale = transform.getMaxScaleOnAxis();
        final double translateX = transform.getTranslation().x;
        final double translateY = transform.getTranslation().y;
        
        // Apply the inverse transformation to get canvas coordinates
        final double canvasX = (interactiveViewerPosition.dx - translateX) / scale;
        final double canvasY = (interactiveViewerPosition.dy - translateY) / scale;
        
        print('Fallback canvas position: ${Offset(canvasX, canvasY)}');
        print('Scale: $scale, TranslateX: $translateX, TranslateY: $translateY');
        
        return Offset(canvasX, canvasY);
      }
    } catch (e) {
      // If transformation fails, return the original position
      print('Error transforming position: $e');
      return screenPosition;
    }
  }
}

enum PenType {
  pen,
  highlighter,
  marker,
  pencil,
  brush,
  eraser,
}

enum DrawingTool {
  pen,
  eraser,
  shapes,
  lasso,
  hand,
  image,
}

enum ShapeType {
  rectangle,
  circle,
  line,
  arrow,
  triangle,
  ellipse,
  diamond,
  pentagon,
  hexagon,
  star,
  coordinateAxes,
}

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final PenType penType;
  final double opacity;
  final ShapeType? shapeType;
  final bool isShape;
  final bool isLassoSelection;
  final bool isImage;
  final String? imagePath;
  final Size? imageSize;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.penType = PenType.pen,
    this.opacity = 1.0,
    this.shapeType,
    this.isShape = false,
    this.isLassoSelection = false,
    this.isImage = false,
    this.imagePath,
    this.imageSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': color.value,
      'strokeWidth': strokeWidth,
      'penType': penType.index,
      'opacity': opacity,
      'shapeType': shapeType?.index,
      'isShape': isShape,
      'isLassoSelection': isLassoSelection,
      'isImage': isImage,
      'imagePath': imagePath,
      'imageSize': imageSize != null ? {'width': imageSize!.width, 'height': imageSize!.height} : null,
    };
  }

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    final pointsData = json['points'] as List;
    final points = pointsData.map((p) => Offset(p['x'], p['y'])).toList();
    
    Size? imageSize;
    if (json['imageSize'] != null) {
      final sizeData = json['imageSize'] as Map<String, dynamic>;
      imageSize = Size(sizeData['width'], sizeData['height']);
    }
    
    return DrawingStroke(
      points: points,
      color: Color(json['color']),
      strokeWidth: json['strokeWidth'],
      penType: PenType.values[json['penType'] ?? 0],
      opacity: json['opacity'] ?? 1.0,
      shapeType: json['shapeType'] != null ? ShapeType.values[json['shapeType']] : null,
      isShape: json['isShape'] ?? false,
      isLassoSelection: json['isLassoSelection'] ?? false,
      isImage: json['isImage'] ?? false,
      imagePath: json['imagePath'],
      imageSize: imageSize,
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final Set<DrawingStroke> selectedStrokes;
  final Map<String, ui.Image> _imageCache;
  final VoidCallback _onImageLoaded;
  final Color? backgroundColor;

  DrawingPainter(
    this.strokes, 
    this.selectedStrokes, 
    this._imageCache, 
    this._onImageLoaded,
    this.backgroundColor,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Paint background color if provided
    if (backgroundColor != null) {
      final backgroundPaint = Paint()..color = backgroundColor!;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    }
    
    for (final stroke in strokes) {
      // Allow image strokes with just 1 point (position), but require 2+ points for regular strokes
      if (stroke.points.length < 2 && !stroke.isImage) continue;
      if (stroke.points.isEmpty) continue;
      
      _drawStroke(canvas, stroke);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    // Handle image drawing
    if (stroke.isImage) {
      _drawImage(canvas, stroke);
      return;
    }
    
    // Highlight selected strokes
    final isSelected = selectedStrokes.contains(stroke);
    if (isSelected && !stroke.isLassoSelection) {
      // Draw selection highlight first
      final highlightPaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.3)
        ..strokeWidth = stroke.strokeWidth + 4
        ..style = PaintingStyle.stroke;
      
      final path = Path();
      path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, highlightPaint);
    }
    
    final paint = Paint()
      ..color = stroke.color.withValues(alpha: stroke.opacity)
      ..strokeWidth = stroke.strokeWidth
      ..style = PaintingStyle.stroke;

    switch (stroke.penType) {
      case PenType.pen:
        paint
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        break;
      case PenType.highlighter:
        paint
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.miter
          ..color = stroke.color.withValues(alpha: 0.4)
          ..strokeWidth = stroke.strokeWidth * 2;
        break;
      case PenType.marker:
        paint
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.miter
          ..color = stroke.color.withValues(alpha: 0.2);
        break;
      case PenType.pencil:
        paint
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = stroke.color.withValues(alpha: 0.8);
        break;
      case PenType.brush:
        paint
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = stroke.color.withValues(alpha: 0.9);
        break;
      case PenType.eraser:
        paint
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..blendMode = BlendMode.clear;
        break;
    }

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    
    // Handle different drawing types
    if (stroke.isShape && stroke.shapeType != null) {
      _drawShape(canvas, stroke, paint);
    } else if (stroke.isLassoSelection) {
      _drawLassoSelection(canvas, stroke, paint);
    } else if (stroke.penType == PenType.brush) {
      _drawBrushStroke(canvas, stroke, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawBrushStroke(Canvas canvas, DrawingStroke stroke, Paint paint) {
    // Create a more organic brush effect with varying width
    for (int i = 0; i < stroke.points.length - 1; i++) {
      final p1 = stroke.points[i];
      final p2 = stroke.points[i + 1];
      
      // Vary the width slightly for brush effect
      final widthVariation = (i % 3) * 0.5;
      final currentPaint = Paint()
        ..color = paint.color
        ..strokeWidth = paint.strokeWidth + widthVariation
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(p1, p2, currentPaint);
    }
  }

  void _drawShape(Canvas canvas, DrawingStroke stroke, Paint paint) {
    if (stroke.points.length < 2) return;
    
    final startPoint = stroke.points.first;
    final endPoint = stroke.points.last;
    
    switch (stroke.shapeType!) {
      case ShapeType.rectangle:
        final rect = Rect.fromPoints(startPoint, endPoint);
        canvas.drawRect(rect, paint..style = PaintingStyle.stroke);
        break;
      case ShapeType.circle:
        final center = Offset(
          (startPoint.dx + endPoint.dx) / 2,
          (startPoint.dy + endPoint.dy) / 2,
        );
        final radius = (endPoint - startPoint).distance / 2;
        canvas.drawCircle(center, radius, paint..style = PaintingStyle.stroke);
        break;
      case ShapeType.line:
        canvas.drawLine(startPoint, endPoint, paint);
        break;
      case ShapeType.arrow:
        _drawArrow(canvas, startPoint, endPoint, paint);
        break;
      case ShapeType.triangle:
        _drawTriangle(canvas, startPoint, endPoint, paint);
        break;
      case ShapeType.ellipse:
        _drawEllipse(canvas, startPoint, endPoint, paint);
        break;
      case ShapeType.diamond:
        _drawDiamond(canvas, startPoint, endPoint, paint);
        break;
      case ShapeType.pentagon:
        _drawPentagon(canvas, startPoint, endPoint, paint);
        break;
      case ShapeType.hexagon:
        _drawHexagon(canvas, startPoint, endPoint, paint);
        break;
      case ShapeType.star:
        _drawStar(canvas, startPoint, endPoint, paint);
        break;
      case ShapeType.coordinateAxes:
        _drawCoordinateAxes(canvas, startPoint, endPoint, paint);
        break;
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
    
    // Draw arrowhead
    final direction = (end - start).direction;
    final arrowLength = 15.0;
    final arrowAngle = 0.5;
    
    final arrowPoint1 = end + Offset(
      arrowLength * math.cos(direction + math.pi - arrowAngle),
      arrowLength * math.sin(direction + math.pi - arrowAngle),
    );
    final arrowPoint2 = end + Offset(
      arrowLength * math.cos(direction + math.pi + arrowAngle),
      arrowLength * math.sin(direction + math.pi + arrowAngle),
    );
    
    canvas.drawLine(end, arrowPoint1, paint);
    canvas.drawLine(end, arrowPoint2, paint);
  }

  void _drawTriangle(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    final center = Offset((start.dx + end.dx) / 2, start.dy);
    path.moveTo(center.dx, center.dy);
    path.lineTo(start.dx, end.dy);
    path.lineTo(end.dx, end.dy);
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void _drawEllipse(Canvas canvas, Offset start, Offset end, Paint paint) {
    final rect = Rect.fromPoints(start, end);
    canvas.drawOval(rect, paint..style = PaintingStyle.stroke);
  }

  void _drawDiamond(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;
    
    path.moveTo(centerX, start.dy); // Top
    path.lineTo(end.dx, centerY);   // Right
    path.lineTo(centerX, end.dy);   // Bottom
    path.lineTo(start.dx, centerY); // Left
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void _drawPentagon(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;
    final radius = (end - start).distance / 2;
    
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void _drawHexagon(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;
    final radius = (end - start).distance / 2;
    
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void _drawStar(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;
    final outerRadius = (end - start).distance / 2;
    final innerRadius = outerRadius * 0.4;
    
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - math.pi / 2;
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void _drawCoordinateAxes(Canvas canvas, Offset start, Offset end, Paint paint) {
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;
    final width = (end.dx - start.dx).abs();
    final height = (end.dy - start.dy).abs();
    
    // Draw X-axis
    canvas.drawLine(
      Offset(start.dx, centerY),
      Offset(end.dx, centerY),
      paint,
    );
    
    // Draw Y-axis
    canvas.drawLine(
      Offset(centerX, start.dy),
      Offset(centerX, end.dy),
      paint,
    );
    
    // Draw arrow heads for X-axis
    final arrowSize = 8.0;
    canvas.drawLine(
      Offset(end.dx, centerY),
      Offset(end.dx - arrowSize, centerY - arrowSize / 2),
      paint,
    );
    canvas.drawLine(
      Offset(end.dx, centerY),
      Offset(end.dx - arrowSize, centerY + arrowSize / 2),
      paint,
    );
    
    // Draw arrow heads for Y-axis
    canvas.drawLine(
      Offset(centerX, start.dy),
      Offset(centerX - arrowSize / 2, start.dy + arrowSize),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, start.dy),
      Offset(centerX + arrowSize / 2, start.dy + arrowSize),
      paint,
    );
    
    // Draw grid lines
    final gridSpacing = math.min(width, height) / 8;
    for (double x = start.dx; x <= end.dx; x += gridSpacing) {
      if ((x - centerX).abs() > 5) {
        canvas.drawLine(
          Offset(x, centerY - 3),
          Offset(x, centerY + 3),
          paint,
        );
      }
    }
    
    for (double y = start.dy; y <= end.dy; y += gridSpacing) {
      if ((y - centerY).abs() > 5) {
        canvas.drawLine(
          Offset(centerX - 3, y),
          Offset(centerX + 3, y),
          paint,
        );
      }
    }
  }

  void _drawLassoSelection(Canvas canvas, DrawingStroke stroke, Paint paint) {
    if (stroke.points.length < 3) return;
    
    // Draw dashed selection outline
    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    path.close();
    
    // Create dashed effect
    final dashedPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    _drawDashedPath(canvas, path, dashedPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      
      while (distance < pathMetric.length) {
        final length = draw ? dashWidth : dashSpace;
        final nextDistance = distance + length;
        
        if (draw) {
          final extractPath = pathMetric.extractPath(distance, nextDistance);
          canvas.drawPath(extractPath, paint);
        }
        
        distance = nextDistance;
        draw = !draw;
      }
    }
  }

  void _drawImage(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty || stroke.imagePath == null) return;
    
    final position = stroke.points.first;
    final size = stroke.imageSize ?? const Size(100, 100);
    
    final rect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );
    
    // Check if image is already cached
    final cachedImage = _imageCache[stroke.imagePath!];
    if (cachedImage != null) {
      // Draw the cached image
      canvas.drawImageRect(
        cachedImage,
        Rect.fromLTWH(0, 0, cachedImage.width.toDouble(), cachedImage.height.toDouble()),
        rect,
        Paint(),
      );
      return;
    }
    
    // If image is not cached, load it asynchronously
    _loadImage(stroke.imagePath!);
    
    // Draw placeholder while loading
    final imagePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(rect, imagePaint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawRect(rect, borderPaint);
    
    // Draw loading icon in center
    final iconSize = 24.0;
    final iconRect = Rect.fromCenter(
      center: rect.center,
      width: iconSize,
      height: iconSize,
    );
    
    final iconPaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.fill;
    
    // Simple loading icon representation
    canvas.drawRect(iconRect, iconPaint);
  }
  
  Future<void> _loadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return;
      
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      
      _imageCache[imagePath] = frame.image;
      
      // Trigger a repaint to show the loaded image
      _onImageLoaded();
    } catch (e) {
      developer.log('Error loading image: $e');
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawingToolbar extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onUndo;
  final Color selectedColor;
  final double selectedStrokeWidth;
  final PenType selectedPenType;
  final double selectedOpacity;
  final Function(Color) onColorChanged;
  final Function(double) onStrokeWidthChanged;
  final Function(PenType) onPenTypeChanged;
  final Function(double) onOpacityChanged;

  const DrawingToolbar({
    super.key,
    required this.onClear,
    required this.onUndo,
    required this.selectedColor,
    required this.selectedStrokeWidth,
    required this.selectedPenType,
    required this.selectedOpacity,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onPenTypeChanged,
    required this.onOpacityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pen type selector
            _buildPenTypeSelector(),
            
            const SizedBox(width: 16),
            
            // Color picker
            _buildColorPicker(colors),
            
            const SizedBox(width: 16),
            
            // Custom color button
            GestureDetector(
              onTap: () => _showColorPicker(context),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.blue, Colors.green],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade600, width: 1),
                ),
                child: Icon(Icons.palette, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Stroke width
            Text('Size: ${selectedStrokeWidth.toInt()}'),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: Slider(
                value: selectedStrokeWidth,
                min: 1,
                max: 20,
                divisions: 19,
                onChanged: onStrokeWidthChanged,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Opacity
            Text('Opacity: ${(selectedOpacity * 100).toInt()}%'),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: Slider(
                value: selectedOpacity,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: onOpacityChanged,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Tools
            IconButton(
              onPressed: onUndo,
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
            ),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenTypeSelector() {
    return Row(
      children: PenType.values.map((penType) {
        IconData icon;
        String tooltip;
        
        switch (penType) {
          case PenType.pen:
            icon = Icons.edit;
            tooltip = 'Pen';
            break;
          case PenType.marker:
            icon = FontAwesome5.marker;
            tooltip = 'Marker';
            break;
          case PenType.pencil:
            icon = Icons.create;
            tooltip = 'Pencil';
            break;
          case PenType.brush:
            icon = Icons.format_paint;
            tooltip = 'Brush';
            break;
          case PenType.eraser:
            icon = FontAwesome5.eraser;
            tooltip = 'Eraser';
            break;
          case PenType.highlighter:
            icon = FontAwesome5.highlighter;
            tooltip = 'Highlighter';
        }
        
        return Container(
          margin: const EdgeInsets.only(right: 4),
          child: IconButton(
            onPressed: () => onPenTypeChanged(penType),
            icon: Icon(icon),
            tooltip: tooltip,
            style: IconButton.styleFrom(
              backgroundColor: selectedPenType == penType 
                  ? Colors.blue.withValues(alpha: 0.2) 
                  : Colors.transparent,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPicker(List<Color> colors) {
    return Row(
      children: colors.map((color) => GestureDetector(
        onTap: () => onColorChanged(color),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selectedColor == color ? Colors.grey.shade600 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      )).toList(),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 64,
            itemBuilder: (context, index) {
              final hue = (index % 8) * 45.0;
              final saturation = ((index ~/ 8) + 1) * 0.125;
              final color = HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
              
              return GestureDetector(
                onTap: () {
                  onColorChanged(color);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}