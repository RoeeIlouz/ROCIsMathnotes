// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mathnotes/core/theme/font_awesome4_icons.dart';
import 'package:mathnotes/core/theme/nerdfont_symbols_icons.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/rendering.dart';
import 'package:mathnotes/l10n/app_localizations.dart';
import 'package:mathnotes/features/tags/data/models/tag_model.dart';
import 'package:mathnotes/features/notes/data/models/note_model.dart';
import '../../../notes/presentation/providers/notes_provider.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/rich_text_editor.dart';

// Import drawing types from drawing_canvas
export '../widgets/drawing_canvas.dart' show PenType, DrawingTool, ShapeType, DrawingStroke;

enum NoteTemplate {
  blank,
  lined,
  dotted,
  grid,
  graph,
}

// Define paper sizes with their aspect ratios
enum PaperSize {
  free,       // Free form (no fixed aspect ratio)
  letter,     // US Letter (8.5 x 11 inches) - aspect ratio 1:1.29
  a4,         // A4 (210 x 297 mm) - aspect ratio 1:1.41
  a5,         // A5 (148 x 210 mm) - aspect ratio 1:1.41
  a3,         // A3 (297 x 420 mm) - aspect ratio 1:1.41
  widescreen, // 16:9 aspect ratio
}

// Extension to get aspect ratio values
extension PaperSizeExtension on PaperSize {
  double get aspectRatio {
    switch (this) {
      case PaperSize.free:
        return 0.0; // No fixed aspect ratio
      case PaperSize.letter:
        return 8.5 / 11.0;
      case PaperSize.a4:
      case PaperSize.a5:
      case PaperSize.a3:
        return 1.0 / 1.41;
      case PaperSize.widescreen:
        return 16.0 / 9.0;
    }
  }

  String get displayName {
    switch (this) {
      case PaperSize.free:
        return 'Free';
      case PaperSize.letter:
        return 'Letter';
      case PaperSize.a4:
        return 'A4';
      case PaperSize.a5:
        return 'A5';
      case PaperSize.a3:
        return 'A3';
      case PaperSize.widescreen:
        return 'Widescreen';
    }
  }
}

class NoteEditorPage extends ConsumerStatefulWidget {
  final String? noteId;
  final String? initialTitle;
  final String? initialContent;
  final List<TagModel>? initialTags;

  const NoteEditorPage({
    super.key,
    this.noteId,
    this.initialTitle,
    this.initialContent,
    this.initialTags,
  });

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  
  List<TagModel> _selectedTags = [];
  bool _isDrawingMode = false;
  bool _showColorPicker = false;
  bool _showBackgroundOptions = false;
  
  // Drawing state
  DrawingTool _currentDrawingTool = DrawingTool.pen;
  PenType _currentPenType = PenType.pen;
  ShapeType? _currentShapeType;
  Color _currentColor = Colors.black;
  double _strokeWidth = 2.0;
  List<DrawingStroke> _drawnPaths = [];
  List<DrawingStroke> _undoStack = [];
  
  // Background state
  NoteTemplate _currentTemplate = NoteTemplate.blank;
  PaperSize _currentPaperSize = PaperSize.free;
  Color _backgroundColor = Colors.white;
  
  // Text formatting state
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  TextAlign _textAlignment = TextAlign.left;
  double _globalFontSize = 16.0;
  
  // Canvas key for drawing
  final GlobalKey _canvasKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController = TextEditingController(text: widget.initialContent ?? '');
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    _selectedTags = widget.initialTags ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? l10n.newNote : l10n.editNote),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          // Mode toggle buttons
          ToggleButtons(
            isSelected: [!_isDrawingMode, _isDrawingMode],
            onPressed: (index) {
              setState(() {
                _isDrawingMode = index == 1;
                _showColorPicker = false;
                _showBackgroundOptions = false;
              });
            },
            borderRadius: BorderRadius.circular(8),
            constraints: const BoxConstraints(minWidth: 60, minHeight: 32),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('Text', style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('Drawing', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(width: 8),
          
          // Mode-specific actions
          if (_isDrawingMode) ..._buildDrawingAppBarActions(),
          if (!_isDrawingMode) ..._buildTextAppBarActions(),
          
          const SizedBox(width: 8),
          
          // Save button
          IconButton(
            onPressed: _saveNote,
            icon: const Icon(Icons.save),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            tooltip: l10n.save,
          ),
          
          // Export button
          IconButton(
            onPressed: _exportToPdf,
            icon: const Icon(Icons.picture_as_pdf),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
            ),
            tooltip: 'Export to PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // Title input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              decoration: InputDecoration(
                hintText: l10n.noteTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: theme.textTheme.titleLarge,
            ),
          ),
          
          // Tags section
          _buildTagsSection(),
          
          // Main content area
          Expanded(
            child: _isDrawingMode ? _buildDrawingArea() : _buildTextEditor(),
          ),
        ],
      ),
    );
  }

  // App bar actions for drawing mode
  List<Widget> _buildDrawingAppBarActions() {
    return [
      // Drawing tool selector
      PopupMenuButton<DrawingTool>(
        icon: Icon(_getDrawingToolIcon(_currentDrawingTool), size: 20),
        tooltip: 'Drawing Tools',
        onSelected: (tool) {
          setState(() {
            _currentDrawingTool = tool;
            if (tool != DrawingTool.shapes) {
              _currentShapeType = null;
            } else if (_currentShapeType == null) {
              _currentShapeType = ShapeType.rectangle;
            }
          });
          if (tool == DrawingTool.image) {
            _pickImage();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: DrawingTool.pen,
            child: Row(
              children: [
                Icon(Icons.edit, size: 16),
                SizedBox(width: 8),
                Text('Pen'),
              ],
            ),
          ),
          PopupMenuItem(
            value: DrawingTool.eraser,
            child: Row(
              children: [
                Icon(FontAwesome4.eraser, size: 16),
                SizedBox(width: 8),
                Text('Eraser'),
              ],
            ),
          ),
          PopupMenuItem(
            value: DrawingTool.shapes,
            child: Row(
              children: [
                Icon(Icons.crop_square, size: 16),
                SizedBox(width: 8),
                Text('Shapes'),
              ],
            ),
          ),
          PopupMenuItem(
            value: DrawingTool.lasso,
            child: Row(
              children: [
                Icon(Icons.gesture, size: 16),
                SizedBox(width: 8),
                Text('Lasso'),
              ],
            ),
          ),
          PopupMenuItem(
            value: DrawingTool.hand,
            child: Row(
              children: [
                Icon(FontAwesome4.hand_grab_o, size: 16),
                SizedBox(width: 8),
                Text('Hand'),
              ],
            ),
          ),
          PopupMenuItem(
            value: DrawingTool.image,
            child: Row(
              children: [
                Icon(Icons.image, size: 16),
                SizedBox(width: 8),
                Text('Image'),
              ],
            ),
          ),
        ],
      ),
      
      // Color picker
      IconButton(
        onPressed: () => setState(() => _showColorPicker = !_showColorPicker),
        icon: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _currentColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        tooltip: 'Color',
      ),
      
      // Stroke width
      SizedBox(
        width: 60,
        child: Slider(
          value: _strokeWidth,
          min: 1.0,
          max: 10.0,
          divisions: 9,
          onChanged: (value) => setState(() => _strokeWidth = value),
        ),
      ),
      
      // Clear drawing
      IconButton(
        onPressed: _clearDrawing,
        icon: Icon(Icons.clear, size: 20),
        tooltip: 'Clear',
      ),
      
      // Undo
      IconButton(
        onPressed: _drawnPaths.isNotEmpty ? _undoLastPath : null,
        icon: Icon(Icons.undo, size: 20),
        tooltip: 'Undo',
      ),
      
      // Shape selector (only show when shapes tool is selected)
      if (_currentDrawingTool == DrawingTool.shapes)
        PopupMenuButton<ShapeType>(
          icon: Icon(_getShapeIcon(_currentShapeType), size: 20),
          tooltip: 'Shape Type',
          onSelected: (shapeType) {
            setState(() {
              _currentShapeType = shapeType;
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ShapeType.rectangle,
              child: Row(
                children: [
                  Icon(Icons.crop_square, size: 16),
                  SizedBox(width: 8),
                  Text('Rectangle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ShapeType.circle,
              child: Row(
                children: [
                  Icon(Icons.circle_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Circle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ShapeType.ellipse,
              child: Row(
                children: [
                  Icon(Icons.circle_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Ellipse'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ShapeType.line,
              child: Row(
                children: [
                  Icon(Icons.remove, size: 16),
                  SizedBox(width: 8),
                  Text('Line'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ShapeType.arrow,
              child: Row(
                children: [
                  Icon(Icons.arrow_forward, size: 16),
                  SizedBox(width: 8),
                  Text('Arrow'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ShapeType.triangle,
              child: Row(
                children: [
                  Icon(Icons.change_history, size: 16),
                  SizedBox(width: 8),
                  Text('Triangle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ShapeType.diamond,
              child: Row(
                children: [
                  Icon(Icons.diamond_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Diamond'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ShapeType.pentagon,
              child: Row(
                children: [
                  Icon(Icons.pentagon_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Pentagon'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ShapeType.hexagon,
              child: Row(
                children: [
                  Icon(Icons.hexagon_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Hexagon'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ShapeType.star,
              child: Row(
                children: [
                  Icon(Icons.star_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Star'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ShapeType.coordinateAxes,
              child: Row(
                children: [
                  Icon(Icons.grid_on, size: 16),
                  SizedBox(width: 8),
                  Text('X-Y Graph'),
                ],
              ),
            ),
          ],
        ),
      
      // Background color picker
      PopupMenuButton<Color>(
        icon: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        tooltip: 'Background Color',
        onSelected: (color) {
          setState(() {
            _backgroundColor = color;
          });
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                SizedBox(width: 8),
                Text('White'),
              ],
            ),
          ),
          PopupMenuItem(
            value: Colors.grey.shade100,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                SizedBox(width: 8),
                Text('Light Grey'),
              ],
            ),
          ),
          PopupMenuItem(
            value: Colors.yellow.shade50,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                SizedBox(width: 8),
                Text('Light Yellow'),
              ],
            ),
          ),
          PopupMenuItem(
            value: Colors.blue.shade50,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                SizedBox(width: 8),
                Text('Light Blue'),
              ],
            ),
          ),
          PopupMenuItem(
            value: Colors.green.shade50,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                SizedBox(width: 8),
                Text('Light Green'),
              ],
            ),
          ),
        ],
      ),
      
      // Template selector
      PopupMenuButton<NoteTemplate>(
        icon: Icon(Icons.grid_on, size: 20),
        tooltip: 'Template',
        onSelected: (template) {
          setState(() {
            _currentTemplate = template;
          });
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: NoteTemplate.blank,
            child: Row(
              children: [
                Icon(Icons.crop_portrait, size: 16),
                SizedBox(width: 8),
                Text('Blank'),
              ],
            ),
          ),
          PopupMenuItem(
            value: NoteTemplate.lined,
            child: Row(
              children: [
                Icon(Icons.format_line_spacing, size: 16),
                SizedBox(width: 8),
                Text('Lined'),
              ],
            ),
          ),
          PopupMenuItem(
            value: NoteTemplate.dotted,
            child: Row(
              children: [
                Icon(Icons.more_horiz, size: 16),
                SizedBox(width: 8),
                Text('Dotted'),
              ],
            ),
          ),
          PopupMenuItem(
            value: NoteTemplate.grid,
            child: Row(
              children: [
                Icon(Icons.grid_4x4, size: 16),
                SizedBox(width: 8),
                Text('Grid'),
              ],
            ),
          ),
          PopupMenuItem(
            value: NoteTemplate.graph,
            child: Row(
              children: [
                Icon(Icons.show_chart, size: 16),
                SizedBox(width: 8),
                Text('Graph'),
              ],
            ),
          ),
        ],
      ),
      
      // Aspect ratio selector
      PopupMenuButton<PaperSize>(
        icon: Icon(Icons.aspect_ratio, size: 20),
        tooltip: 'Aspect Ratio',
        onSelected: (paperSize) {
          setState(() {
            _currentPaperSize = paperSize;
          });
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: PaperSize.free,
            child: Row(
              children: [
                Icon(Icons.crop_free, size: 16),
                SizedBox(width: 8),
                Text('Free'),
              ],
            ),
          ),
          PopupMenuItem(
            value: PaperSize.letter,
            child: Row(
              children: [
                Icon(Icons.description, size: 16),
                SizedBox(width: 8),
                Text('Letter'),
              ],
            ),
          ),
          PopupMenuItem(
            value: PaperSize.a4,
            child: Row(
              children: [
                Icon(Icons.description, size: 16),
                SizedBox(width: 8),
                Text('A4'),
              ],
            ),
          ),
          PopupMenuItem(
            value: PaperSize.a5,
            child: Row(
              children: [
                Icon(Icons.description, size: 16),
                SizedBox(width: 8),
                Text('A5'),
              ],
            ),
          ),
          PopupMenuItem(
            value: PaperSize.a3,
            child: Row(
              children: [
                Icon(Icons.description, size: 16),
                SizedBox(width: 8),
                Text('A3'),
              ],
            ),
          ),
          PopupMenuItem(
            value: PaperSize.widescreen,
            child: Row(
              children: [
                Icon(Icons.tv, size: 16),
                SizedBox(width: 8),
                Text('Widescreen'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // App bar actions for text mode
  List<Widget> _buildTextAppBarActions() {
    return [
      // Bold
      IconButton(
        onPressed: _toggleBold,
        icon: Icon(Icons.format_bold, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: _isBold ? Theme.of(context).colorScheme.primary : null,
          foregroundColor: _isBold ? Theme.of(context).colorScheme.onPrimary : null,
        ),
        tooltip: 'Bold',
      ),
      
      // Italic
      IconButton(
        onPressed: _toggleItalic,
        icon: Icon(Icons.format_italic, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: _isItalic ? Theme.of(context).colorScheme.primary : null,
          foregroundColor: _isItalic ? Theme.of(context).colorScheme.onPrimary : null,
        ),
        tooltip: 'Italic',
      ),
      
      // Underline
      IconButton(
        onPressed: _toggleUnderline,
        icon: Icon(Icons.format_underlined, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: _isUnderlined ? Theme.of(context).colorScheme.primary : null,
          foregroundColor: _isUnderlined ? Theme.of(context).colorScheme.onPrimary : null,
        ),
        tooltip: 'Underline',
      ),
      
      // Text alignment
      PopupMenuButton<TextAlign>(
        icon: Icon(_getAlignmentIcon(_textAlignment), size: 20),
        tooltip: 'Alignment',
        onSelected: (alignment) => setState(() => _textAlignment = alignment),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: TextAlign.left,
            child: Row(
              children: [
                Icon(Icons.format_align_left, size: 16),
                SizedBox(width: 8),
                Text('Left'),
              ],
            ),
          ),
          PopupMenuItem(
            value: TextAlign.center,
            child: Row(
              children: [
                Icon(Icons.format_align_center, size: 16),
                SizedBox(width: 8),
                Text('Center'),
              ],
            ),
          ),
          PopupMenuItem(
            value: TextAlign.right,
            child: Row(
              children: [
                Icon(Icons.format_align_right, size: 16),
                SizedBox(width: 8),
                Text('Right'),
              ],
            ),
          ),
        ],
      ),
      
      // Font size
      SizedBox(
        width: 80,
        child: DropdownButton<double>(
          value: _globalFontSize,
          isExpanded: true,
          underline: Container(),
          items: [12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 28.0, 32.0]
              .map((size) => DropdownMenuItem(
                    value: size,
                    child: Text('${size.toInt()}', style: TextStyle(fontSize: 12)),
                  ))
              .toList(),
          onChanged: (size) {
            if (size != null) {
              setState(() => _globalFontSize = size);
            }
          },
        ),
      ),
    ];
  }

  IconData _getDrawingToolIcon(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.pen:
        return Icons.edit;
      case DrawingTool.eraser:
        return FontAwesome4.eraser;
      case DrawingTool.shapes:
        return Icons.crop_square;
      case DrawingTool.lasso:
        return Icons.gesture;
      case DrawingTool.hand:
        return Icons.pan_tool;
      case DrawingTool.image:
        return Icons.image;
    }
  }

  IconData _getShapeIcon(ShapeType? shapeType) {
    if (shapeType == null) return Icons.crop_square;
    switch (shapeType) {
      case ShapeType.rectangle:
        return Icons.crop_square;
      case ShapeType.circle:
        return Icons.circle_outlined;
      case ShapeType.ellipse:
        return Icons.circle_outlined;
      case ShapeType.line:
        return Icons.remove;
      case ShapeType.arrow:
        return Icons.arrow_forward;
      case ShapeType.triangle:
        return Icons.change_history;
      case ShapeType.diamond:
        return Icons.diamond_outlined;
      case ShapeType.pentagon:
        return Icons.pentagon_outlined;
      case ShapeType.hexagon:
        return Icons.hexagon_outlined;
      case ShapeType.star:
        return Icons.star_outline;
      case ShapeType.coordinateAxes:
        return Icons.grid_on;
    }
  }

  IconData _getAlignmentIcon(TextAlign alignment) {
    switch (alignment) {
      case TextAlign.left:
        return Icons.format_align_left;
      case TextAlign.center:
        return Icons.format_align_center;
      case TextAlign.right:
        return Icons.format_align_right;
      case TextAlign.justify:
        return Icons.format_align_justify;
      default:
        return Icons.format_align_left;
    }
  }

  Widget _buildTagsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tags:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _showTagPicker,
                icon: const Icon(Icons.add),
                iconSize: 20,
              ),
            ],
          ),
          if (_selectedTags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: _selectedTags.map((tag) => Chip(
                label: Text(tag.name),
                backgroundColor: Color(tag.color ?? 0xFF2196F3),
                onDeleted: () {
                  setState(() {
                    _selectedTags.remove(tag);
                  });
                },
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawingArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(
                template: _currentTemplate,
                backgroundColor: _backgroundColor,
              ),
            ),
          ),
          
          // Drawing canvas
          Positioned.fill(
            child: DrawingCanvas(
              key: _canvasKey,
              initialDrawingData: _drawnPaths.isNotEmpty ? jsonEncode(_drawnPaths.map((path) => path.toJson()).toList()) : null,
              onDrawingChanged: (drawingData) {
                // Handle drawing data changes
                if (drawingData.isNotEmpty) {
                  try {
                    final List<dynamic> pathsJson = jsonDecode(drawingData);
                    setState(() {
                      _drawnPaths = pathsJson.map((json) => DrawingStroke.fromJson(json)).toList();
                    });
                  } catch (e) {
                    print('Error parsing drawing data: $e');
                  }
                } else {
                  setState(() {
                    _drawnPaths.clear();
                  });
                }
              },
              strokeColor: _currentColor,
              strokeWidth: _strokeWidth,
              penType: _currentPenType,
              currentTool: _currentDrawingTool,
              currentShapeType: _currentShapeType,
              backgroundColor: _backgroundColor,
            ),
          ),
          
          // Color picker overlay
          if (_showColorPicker)
            Positioned(
              top: 60,
              right: 16,
              child: _buildColorPicker(),
            ),
        ],
      ),
    );
  }

  Widget _buildTextEditor() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(
                template: _currentTemplate,
                backgroundColor: _backgroundColor,
              ),
            ),
          ),
          
          // Text editor
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: RichTextEditor(
                initialText: _contentController.text,
                onTextChanged: (text) {
                  _contentController.text = text;
                },
                fontSize: _globalFontSize,
                textAlign: _textAlignment,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.pink,
      Colors.grey,
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: colors.map((color) => GestureDetector(
          onTap: () {
            setState(() {
              _currentColor = color;
              _showColorPicker = false;
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: _currentColor == color ? Colors.blue : Colors.grey,
                width: _currentColor == color ? 2 : 1,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
  }

  void _toggleUnderline() {
    setState(() {
      _isUnderlined = !_isUnderlined;
    });
  }

  void _clearDrawing() {
    setState(() {
      _undoStack.addAll(_drawnPaths);
      _drawnPaths.clear();
    });
  }

  void _undoLastPath() {
    if (_drawnPaths.isNotEmpty) {
      setState(() {
        final lastPath = _drawnPaths.removeLast();
        _undoStack.add(lastPath);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // Handle image insertion logic here
      // This would typically involve adding the image to the drawing canvas
    }
  }

  void _showTagPicker() {
    // Implementation for tag picker dialog
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty && _drawnPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note cannot be empty')),
      );
      return;
    }

    try {
      if (widget.noteId == null) {
        // Creating a new note
        await ref.read(notesProvider.notifier).createNote(
          title: title.isEmpty ? 'Untitled' : title,
          content: content,
          tagIds: _selectedTags.map((tag) => tag.id).toList(),
          drawingData: _drawnPaths.isNotEmpty ? jsonEncode(_drawnPaths.map((path) => path.toJson()).toList()) : null,
        );
      } else {
         // Updating existing note - need to get existing note first
         final existingNotes = ref.read(notesProvider).value ?? [];
         final existingNote = existingNotes.firstWhere((n) => n.id == widget.noteId);
         
         final note = NoteModel(
           id: widget.noteId!,
           title: title.isEmpty ? 'Untitled' : title,
           content: content,
           notebookId: existingNote.notebookId,
           createdAt: existingNote.createdAt,
           updatedAt: DateTime.now(),
           tagIds: _selectedTags.map((tag) => tag.id).toList(),
           hasDrawing: _drawnPaths.isNotEmpty,
           drawingData: _drawnPaths.isNotEmpty ? jsonEncode(_drawnPaths.map((path) => path.toJson()).toList()) : null,
         );
         await ref.read(notesProvider.notifier).updateNote(note);
       }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }

  Future<void> _exportToPdf() async {
    // Implementation for PDF export
  }
}

class BackgroundPainter extends CustomPainter {
  final NoteTemplate template;
  final Color backgroundColor;

  BackgroundPainter({
    required this.template,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final linePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    switch (template) {
      case NoteTemplate.lined:
        _drawLines(canvas, size, linePaint);
        break;
      case NoteTemplate.dotted:
        _drawDots(canvas, size, linePaint);
        break;
      case NoteTemplate.grid:
        _drawGrid(canvas, size, linePaint);
        break;
      case NoteTemplate.graph:
        _drawGraph(canvas, size, linePaint);
        break;
      case NoteTemplate.blank:
        break;
    }
  }

  void _drawLines(Canvas canvas, Size size, Paint paint) {
    const spacing = 24.0;
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    const spacing = 20.0;
    paint.style = PaintingStyle.fill;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    const spacing = 20.0;
    
    // Vertical lines
    for (double x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Horizontal lines
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawGraph(Canvas canvas, Size size, Paint paint) {
    const spacing = 20.0;
    const majorSpacing = 100.0;
    
    final majorPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    
    // Minor grid
    for (double x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Major grid
    for (double x = majorSpacing; x < size.width; x += majorSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
    }
    for (double y = majorSpacing; y < size.height; y += majorSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! BackgroundPainter ||
        oldDelegate.template != template ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}