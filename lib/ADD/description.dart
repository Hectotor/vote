import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DescriptionField extends StatefulWidget {
  final TextEditingController controller;
  final Function(List<String>, List<String>)? onTagsChanged;

  const DescriptionField({
    Key? key, 
    required this.controller,
    this.onTagsChanged,
  }) : super(key: key);

  @override
  _DescriptionFieldState createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<DescriptionField> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _hashtags = [];
  List<String> _mentions = [];
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _extractTags();
    _showSuggestions();
  }

  void _extractTags() {
    String text = widget.controller.text;

    // Extraire les hashtags
    final hashtagRegex = RegExp(r'#\w+');
    final foundHashtags = hashtagRegex.allMatches(text)
        .map((match) => match.group(0)!)
        .toList();

    // Extraire les mentions
    final mentionRegex = RegExp(r'@\w+');
    final foundMentions = mentionRegex.allMatches(text)
        .map((match) => match.group(0)!)
        .toList();

    // Supprimer les doublons
    final uniqueHashtags = foundHashtags.toSet().toList();
    final uniqueMentions = foundMentions.toSet().toList();

    // Mettre à jour les tags si changement
    if (_hashtags != uniqueHashtags || _mentions != uniqueMentions) {
      setState(() {
        _hashtags = uniqueHashtags;
        _mentions = uniqueMentions;
      });

      // Appeler le callback si défini
      widget.onTagsChanged?.call(_hashtags, _mentions);
    }
  }

  Future<void> _showSuggestions() async {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    
    if (selection.baseOffset != selection.extentOffset) return;

    // Trouver le mot en cours
    final lastWord = _getLastWord(text, selection.baseOffset);
    if (lastWord.isEmpty) {
      _hideSuggestions();
      return;
    }

    if (lastWord.startsWith('#')) {
      final query = lastWord.substring(1).toLowerCase();
      if (query.isEmpty) {
        _hideSuggestions();
        return;
      }

      // Chercher dans Firebase
      final snapshot = await _firestore
          .collection('hashtags')
          .where('name', isGreaterThanOrEqualTo: '#$query')
          .where('name', isLessThan: '#${query}z')
          .limit(5)
          .get();

      setState(() {
        _suggestions = snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
      });
    } else if (lastWord.startsWith('@')) {
      final query = lastWord.substring(1).toLowerCase();
      if (query.isEmpty) {
        _hideSuggestions();
        return;
      }

      // Chercher dans Firebase
      final snapshot = await _firestore
          .collection('mentions')
          .where('name', isGreaterThanOrEqualTo: '@$query')
          .where('name', isLessThan: '@${query}z')
          .limit(5)
          .get();

      setState(() {
        _suggestions = snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
      });
    } else {
      _hideSuggestions();
      return;
    }

    _showOverlay();
  }

  String _getLastWord(String text, int position) {
    if (position == 0) return '';
    
    final textBeforeCursor = text.substring(0, position);
    final words = textBeforeCursor.split(' ');
    return words.last;
  }

  void _showOverlay() {
    _hideSuggestions();

    if (_suggestions.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + renderBox.size.height,
        left: offset.dx,
        width: renderBox.size.width,
        child: Material(
          elevation: 4.0,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_suggestions[index]),
                onTap: () => _onSuggestionSelected(_suggestions[index]),
              );
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onSuggestionSelected(String suggestion) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final lastWord = _getLastWord(text, selection.baseOffset);
    
    if (lastWord.isEmpty) return;

    final newText = text.replaceRange(
      selection.baseOffset - lastWord.length,
      selection.baseOffset,
      suggestion,
    );

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset - lastWord.length + suggestion.length,
      ),
    );

    _hideSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Ajoute une description...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        cursorColor: Colors.white,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
      ),
    );
  }

  @override
  void dispose() {
    _hideSuggestions();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }
}
