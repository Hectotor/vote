import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comment.dart';
import 'bloc.dart';
import 'addoption.dart'; // Importer le nouveau fichier
import 'package:image_picker/image_picker.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _numberOfBlocs = 2;

  Future<void> _saveComment() async {
    if (_controller.text.isNotEmpty) {
      await _firestore.collection('comments').add({
        'text': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  void _showAddBlocDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddOption(
          onAddText: _addText,
          onAddPhoto: _addPhoto,
          onTakePhoto: _takePhoto,
          onDeleteContent: _hasContent()
              ? _deleteContent
              : null, // Show delete button only if there is content
        );
      },
    );
  }

  bool _hasContent() {
    // Logique pour vérifier si le bloc a du contenu
    // Retourner true si le bloc a du contenu, sinon false
    // Exemple de logique : vérifier si le contrôleur de texte n'est pas vide
    return _controller.text.isNotEmpty;
  }

  void _addText() {
    Navigator.pop(context);
    // Logique pour ajouter un texte
  }

  void _addPhoto() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Logique pour ajouter une photo
    }
  }

  void _takePhoto() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // Logique pour prendre une photo
    }
  }

  void _deleteContent() {
    Navigator.pop(context);
    // Logique pour supprimer le contenu
  }

  void _addBlocs() {
    setState(() {
      if (_numberOfBlocs < 4) {
        _numberOfBlocs++;
      }
    });
  }

  void _deleteBloc() {
    setState(() {
      if (_numberOfBlocs > 2) {
        _numberOfBlocs--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50, // Reduce the height of the AppBar
        backgroundColor: Colors.white, // Set AppBar background color to white
        title: const Align(
          alignment: Alignment.centerLeft,
          //child: Text('Créer ton post'),
        ),
        actions: [
          if (_numberOfBlocs < 4)
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  size: 30, color: Color(0xFF949494)), // Increase icon size
              onPressed: _addBlocs,
            ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
            vertical: 0, horizontal: 16), // Update padding
        color: Colors.white, // Set background color to white
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CommentField(
              controller: _controller,
            ),
            BlocGrid(
              numberOfBlocs: _numberOfBlocs,
              onTap: _showAddBlocDialog,
              onDelete: _deleteBloc,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white, // Set background color to white
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _saveComment,
          child: const Text('Sauvegarder'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
