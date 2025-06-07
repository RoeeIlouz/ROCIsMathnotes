// ignore_for_file: unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show TextDirection;

class RichTextEditor extends StatefulWidget {
  final String? initialText;
  final Function(String) onTextChanged;
  final Function(bool, bool, bool, Color)? onFormattingChanged;
  final double fontSize;
  final TextAlign textAlign;
  final double? lineHeight;

  const RichTextEditor({
    super.key,
    this.initialText,
    required this.onTextChanged,
    this.onFormattingChanged,
    this.fontSize = 16.0,
    this.textAlign = TextAlign.left,
    this.lineHeight,
  });

  @override
  State<RichTextEditor> createState() => RichTextEditorState();
}

class RichTextEditorState extends State<RichTextEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  List<CharacterFormat> _characterFormats = [];
  TextSelection _lastSelection = const TextSelection.collapsed(offset: 0);
  
  // Current formatting state for new characters
  bool _currentBold = false;
  bool _currentItalic = false;
  bool _currentUnderline = false;
  Color _currentColor = Colors.black;
  Color? _currentBackgroundColor;
  double _currentFontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    
    // Load initial content
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      // Try to load as JSON first, fallback to plain text
      try {
        final data = jsonDecode(widget.initialText!);
        if (data is Map && data.containsKey('text') && data.containsKey('formats')) {
          loadContent(widget.initialText!);
        } else {
          _controller.text = widget.initialText!;
          _initializeFormats();
        }
      } catch (e) {
        // Not JSON, treat as plain text
        _controller.text = widget.initialText!;
        _initializeFormats();
      }
    } else {
      _initializeFormats();
    }
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onSelectionChanged);
  }

  void _initializeFormats() {
    final text = _controller.text;
    _characterFormats = List.generate(
      text.length,
      (index) => CharacterFormat(),
    );
  }

  void _onTextChanged() {
    final text = _controller.text;
    final selection = _controller.selection;
    
    // Adjust character formats when text changes
    if (text.length > _characterFormats.length) {
      // Text was added
      final addedCount = text.length - _characterFormats.length;
      // Ensure insertPosition is never negative
      final insertPosition = math.max(0, selection.start - addedCount);
      
      for (int i = 0; i < addedCount; i++) {
        final insertIndex = math.min(insertPosition + i, _characterFormats.length);
        _characterFormats.insert(
          insertIndex,
          CharacterFormat(
            isBold: _currentBold,
            isItalic: _currentItalic,
            isUnderline: _currentUnderline,
            color: _currentColor,
            backgroundColor: _currentBackgroundColor,
            fontSize: _currentFontSize,
          ),
        );
      }
    } else if (text.length < _characterFormats.length) {
      // Text was removed
      final removedCount = _characterFormats.length - text.length;
      final removePosition = math.min(selection.start, _characterFormats.length - 1);
      
      for (int i = 0; i < removedCount; i++) {
        final removeIndex = math.max(0, removePosition - i);
        if (removeIndex < _characterFormats.length) {
          _characterFormats.removeAt(removeIndex);
        }
      }
    }
    
    _lastSelection = selection;
    
    // Trigger rebuild to update the visual display
    setState(() {});
    
    // Notify parent of content change
    widget.onTextChanged(_serializeContent());
  }

  void _onSelectionChanged() {
    if (_focusNode.hasFocus) {
      final selection = _controller.selection;
      if (selection.start >= 0) {
        if (selection.start < _characterFormats.length) {
          // Update current formatting based on character at cursor
          final format = _characterFormats[selection.start];
          setState(() {
            _currentBold = format.isBold;
            _currentItalic = format.isItalic;
            _currentUnderline = format.isUnderline;
            _currentColor = format.color;
            _currentBackgroundColor = format.backgroundColor;
            _currentFontSize = format.fontSize ?? widget.fontSize;
          });
        } else if (selection.start > 0 && _characterFormats.isNotEmpty) {
          // Cursor is at the end, use formatting from the last character
          final format = _characterFormats[_characterFormats.length - 1];
          setState(() {
            _currentBold = format.isBold;
            _currentItalic = format.isItalic;
            _currentUnderline = format.isUnderline;
            _currentColor = format.color;
            _currentBackgroundColor = format.backgroundColor;
            _currentFontSize = format.fontSize ?? widget.fontSize;
          });
        }
        // Notify parent of formatting change
        widget.onFormattingChanged?.call(_currentBold, _currentItalic, _currentUnderline, _currentColor);
      }
    }
  }

  String _serializeContent() {
    return jsonEncode({
      'text': _controller.text,
      'formats': _characterFormats.map((f) => f.toJson()).toList(),
    });
  }

  void loadContent(String serializedContent) {
    try {
      final data = jsonDecode(serializedContent);
      final text = data['text'] as String;
      final formats = (data['formats'] as List)
          .map((f) => CharacterFormat.fromJson(f))
          .toList();
      
      setState(() {
        _controller.text = text;
        _characterFormats = formats;
      });
    } catch (e) {
      // Fallback to plain text
      setState(() {
        _controller.text = serializedContent;
        _initializeFormats();
      });
    }
  }

  void applyFormatting({
    bool? bold,
    bool? italic,
    bool? underline,
    Color? color,
  }) {
    final selection = _controller.selection;
    
    if (selection.isValid) {
      final start = selection.start;
      final end = selection.end;
      
      // Apply formatting to selected text
      for (int i = start; i < end && i < _characterFormats.length; i++) {
        setState(() {
          if (bold != null) _characterFormats[i].isBold = bold;
          if (italic != null) _characterFormats[i].isItalic = italic;
          if (underline != null) _characterFormats[i].isUnderline = underline;
          if (color != null) _characterFormats[i].color = color;
        });
      }
    }
    
    // Update current formatting for new text
    setState(() {
      if (bold != null) _currentBold = bold;
      if (italic != null) _currentItalic = italic;
      if (underline != null) _currentUnderline = underline;
      if (color != null) _currentColor = color;
    });
    
    widget.onTextChanged(_serializeContent());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            // Text input layer (always present for input handling)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: _controller.text.isEmpty ? 'Start writing...' : null,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12.0),
                ),
                style: TextStyle(
                  fontSize: widget.fontSize,
                  color: _hasFormatting() ? Colors.transparent : Theme.of(context).colorScheme.onSurface,
                  height: widget.lineHeight != null ? widget.lineHeight! / widget.fontSize : 1.3,
                ),
                textAlign: _detectTextAlign(),
                textDirection: _detectTextDirection(),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            // Rich text display layer (only show when text is not empty and has formatting)
            if (_controller.text.isNotEmpty && _hasFormatting())
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        maxWidth: constraints.maxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _buildMultiLineRichText(
                          constraints.maxWidth - 24.0, // Account for padding
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Build multi-line rich text with per-line alignment and direction
  Widget _buildMultiLineRichText(double maxWidth) {
    final text = _controller.text;
    if (text.isEmpty || _characterFormats.isEmpty) {
      return const SizedBox.shrink();
    }

    final lines = text.split('\n');
    final List<Widget> lineWidgets = [];
    int textPosition = 0;

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      final lineLength = line.length;
      
      // Determine alignment and direction for this specific line
      final isRTL = _isRTLText(line);
      final textAlign = isRTL ? TextAlign.right : TextAlign.left;
      final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;
      
      // Build TextSpan for this line
      final lineSpan = _buildLineTextSpan(
        line,
        textPosition,
        TextStyle(
          fontSize: widget.fontSize,
          color: Colors.black87,
          height: widget.lineHeight != null ? widget.lineHeight! / widget.fontSize : 1.3,
        ),
      );
      
      // Create RichText widget for this line
      lineWidgets.add(
        SizedBox(
          width: maxWidth,
          child: RichText(
            text: lineSpan,
            textAlign: textAlign,
            textDirection: textDirection,
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ),
      );
      
      textPosition += lineLength + 1; // +1 for newline character
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: lineWidgets,
    );
  }

  // Build TextSpan for a specific line
  TextSpan _buildLineTextSpan(String lineText, int startPosition, TextStyle? baseStyle) {
    if (lineText.isEmpty) {
      return TextSpan(text: '\n', style: baseStyle); // Preserve empty lines
    }

    final List<TextSpan> spans = [];
    int currentStart = 0;
    CharacterFormat? currentFormat;

    for (int i = 0; i <= lineText.length; i++) {
      final globalPosition = startPosition + i;
      final format = globalPosition < _characterFormats.length ? _characterFormats[globalPosition] : null;
      
      if (format != currentFormat || i == lineText.length) {
        if (currentStart < i) {
          final spanText = lineText.substring(currentStart, i);
          final spanStyle = baseStyle?.copyWith(
            fontWeight: currentFormat?.isBold == true ? FontWeight.bold : FontWeight.normal,
            fontStyle: currentFormat?.isItalic == true ? FontStyle.italic : FontStyle.normal,
            decoration: currentFormat?.isUnderline == true ? TextDecoration.underline : TextDecoration.none,
            color: currentFormat?.color ?? Colors.black87,
            backgroundColor: currentFormat?.backgroundColor,
            fontSize: currentFormat?.fontSize ?? baseStyle?.fontSize,
            fontFamily: currentFormat?.fontFamily ?? baseStyle?.fontFamily,
          );
          
          spans.add(TextSpan(text: spanText, style: spanStyle));
        }
        currentStart = i;
        currentFormat = format;
      }
    }

    return TextSpan(children: spans.isNotEmpty ? spans : [TextSpan(text: lineText, style: baseStyle)]);
  }

  TextSpan _buildRichTextSpan(String text, TextStyle? baseStyle) {
    if (text.isEmpty || _characterFormats.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final List<TextSpan> spans = [];
    int currentStart = 0;
    CharacterFormat? currentFormat;

    for (int i = 0; i <= text.length; i++) {
      final format = i < _characterFormats.length ? _characterFormats[i] : null;
      
      if (format != currentFormat || i == text.length) {
        if (currentStart < i) {
          final spanText = text.substring(currentStart, i);
          final spanStyle = baseStyle?.copyWith(
            fontWeight: currentFormat?.isBold == true ? FontWeight.bold : FontWeight.normal,
            fontStyle: currentFormat?.isItalic == true ? FontStyle.italic : FontStyle.normal,
            decoration: currentFormat?.isUnderline == true ? TextDecoration.underline : TextDecoration.none,
            color: currentFormat?.color ?? Colors.black87,
            backgroundColor: currentFormat?.backgroundColor,
            fontSize: currentFormat?.fontSize ?? baseStyle?.fontSize,
            fontFamily: currentFormat?.fontFamily ?? baseStyle?.fontFamily,
          );
          
          spans.add(TextSpan(text: spanText, style: spanStyle));
        }
        currentStart = i;
        currentFormat = format;
      }
    }

    return TextSpan(children: spans);
  }

  // Getters for current formatting state
  bool get currentBold => _currentBold;
  bool get currentItalic => _currentItalic;
  bool get currentUnderline => _currentUnderline;
  Color get currentColor => _currentColor;
  double get currentFontSize => _currentFontSize;

  // Public methods for external control
  void toggleBold() {
    setState(() {
      _currentBold = !_currentBold;
    });
    _applyCurrentFormatting();
    widget.onFormattingChanged?.call(_currentBold, _currentItalic, _currentUnderline, _currentColor);
  }

  void toggleItalic() {
    setState(() {
      _currentItalic = !_currentItalic;
    });
    _applyCurrentFormatting();
    widget.onFormattingChanged?.call(_currentBold, _currentItalic, _currentUnderline, _currentColor);
  }

  void toggleUnderline() {
    setState(() {
      _currentUnderline = !_currentUnderline;
    });
    _applyCurrentFormatting();
    widget.onFormattingChanged?.call(_currentBold, _currentItalic, _currentUnderline, _currentColor);
  }

  void setTextColor(Color color) {
    setState(() {
      _currentColor = color;
    });
    _applyCurrentFormatting();
    widget.onFormattingChanged?.call(_currentBold, _currentItalic, _currentUnderline, _currentColor);
  }

  void setHighlight(Color? color) {
    setState(() {
      _currentBackgroundColor = color;
    });
    _applyCurrentFormatting();
  }

  void removeHighlight() {
    setHighlight(null);
  }

  void setTextAlign(TextAlign align) {
    // Text alignment is handled by the parent widget
    // This method is kept for compatibility
  }

  void setFontSize(double fontSize) {
    setState(() {
      _currentFontSize = fontSize;
    });
    _applyCurrentFormatting();
  }

  void increaseFontSize() {
    final newSize = (_currentFontSize + 2).clamp(8.0, 72.0);
    setFontSize(newSize);
  }

  void decreaseFontSize() {
    final newSize = (_currentFontSize - 2).clamp(8.0, 72.0);
    setFontSize(newSize);
  }

  String getFormattedContent() {
    return _serializeContent();
  }

  void _applyCurrentFormatting() {
    final selection = _controller.selection;
    if (selection.isValid) {
      if (!selection.isCollapsed) {
        // Apply formatting to selected text
        for (int i = selection.start; i < selection.end; i++) {
          if (i < _characterFormats.length) {
            _characterFormats[i] = CharacterFormat(
              isBold: _currentBold,
              isItalic: _currentItalic,
              isUnderline: _currentUnderline,
              color: _currentColor,
              backgroundColor: _currentBackgroundColor,
              fontSize: _currentFontSize,
            );
          }
        }
      }
      // Always update the current state for new text
      setState(() {});
    }
    widget.onTextChanged(_serializeContent());
  }

  // Detect if text contains RTL characters
  bool _isRTLText(String text) {
    if (text.isEmpty) return false;
    
    // Hebrew Unicode range: U+0590 to U+05FF
    // Arabic Unicode range: U+0600 to U+06FF
    final rtlPattern = RegExp(r'[\u0590-\u05FF\u0600-\u06FF]');
    return rtlPattern.hasMatch(text);
  }
  
  // Detect text direction based on content
  TextDirection _detectTextDirection() {
    final text = _controller.text;
    if (text.isEmpty) {
      return Directionality.of(context);
    }
    
    // Check the current line where cursor is positioned
    final lines = text.split('\n');
    final selection = _controller.selection;
    
    if (selection.start >= 0) {
      int currentPos = 0;
      for (String line in lines) {
        if (currentPos + line.length >= selection.start) {
          // This is the current line - detect direction for this specific line
          return _isRTLText(line) ? TextDirection.rtl : TextDirection.ltr;
        }
        currentPos += line.length + 1; // +1 for newline
      }
    }
    
    // Fallback: use default direction
    return TextDirection.ltr;
  }
  
  // Detect text alignment based on current line content
  TextAlign _detectTextAlign() {
    final text = _controller.text;
    if (text.isEmpty) {
      return widget.textAlign;
    }
    
    // Check the current line where cursor is positioned
    final lines = text.split('\n');
    final selection = _controller.selection;
    
    if (selection.start >= 0) {
      int currentPos = 0;
      for (String line in lines) {
        if (currentPos + line.length >= selection.start) {
          // This is the current line - detect alignment for this specific line
          if (_isRTLText(line)) {
            return TextAlign.right;
          } else {
            return TextAlign.left;
          }
        }
        currentPos += line.length + 1; // +1 for newline
      }
    }
    
    return widget.textAlign;
  }
  
  // Check if text has any formatting applied
  bool _hasFormatting() {
    if (_characterFormats.isEmpty) return false;
    
    // Check if any character has non-default formatting
    for (final format in _characterFormats) {
      if (format.isBold || 
          format.isItalic || 
          format.isUnderline || 
          format.color != Colors.black || 
          format.backgroundColor != null) {
        return true;
      }
    }
    
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class CharacterFormat {
  bool isBold;
  bool isItalic;
  bool isUnderline;
  Color color;
  Color? backgroundColor;
  double? fontSize;
  String? fontFamily;

  CharacterFormat({
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.color = Colors.black,
    this.backgroundColor,
    this.fontSize,
    this.fontFamily,
  });

  Map<String, dynamic> toJson() {
    return {
      'bold': isBold,
      'italic': isItalic,
      'underline': isUnderline,
      'color': color.value,
      'backgroundColor': backgroundColor?.value,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
    };
  }

  factory CharacterFormat.fromJson(Map<String, dynamic> json) {
    return CharacterFormat(
      isBold: json['bold'] ?? false,
      isItalic: json['italic'] ?? false,
      isUnderline: json['underline'] ?? false,
      color: Color(json['color'] ?? Colors.black.value),
      backgroundColor: json['backgroundColor'] != null ? Color(json['backgroundColor']) : null,
      fontSize: json['fontSize']?.toDouble(),
      fontFamily: json['fontFamily'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CharacterFormat &&
        other.isBold == isBold &&
        other.isItalic == isItalic &&
        other.isUnderline == isUnderline &&
        other.color == color &&
        other.backgroundColor == backgroundColor &&
        other.fontSize == fontSize &&
        other.fontFamily == fontFamily;
  }

  @override
  int get hashCode {
    return Object.hash(isBold, isItalic, isUnderline, color, backgroundColor, fontSize, fontFamily);
  }
}