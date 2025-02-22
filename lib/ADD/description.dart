import 'package:flutter/material.dart';

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
  List<String> _hashtags = [];
  List<String> _mentions = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_extractTags);
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

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'What\'s Happening?',
        hintStyle: TextStyle(
          color: Colors.grey.shade200,
          fontSize: 16,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 12,
        ),
        counterText: '',
      ),
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        //fontWeight: FontWeight.bold,
      ),
      cursorColor: Colors.blue,
      maxLines: null,
      maxLength: 280,
      keyboardType: TextInputType.multiline,
      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_extractTags);
    super.dispose();
  }
}
