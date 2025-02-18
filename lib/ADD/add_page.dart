import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vote_app/navBar.dart';
import 'comment.dart';
import 'bloc.dart';
import 'addoption.dart'; // Importer le nouveau fichier
import 'package:image_picker/image_picker.dart';
import 'description.dart'; // Ajouter l'import
import 'package:flutter_localizations/flutter_localizations.dart'; // Import localization package
import 'dart:async'; // Import the dart:async package for Timer
import 'image.dart'; // Import the new image.dart file
import '../services/firestore_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('fr', 'FR'), // Add French locale
      ],
      home: const AddPage(),
    );
  }
}

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Timer? _timer;
  final List<XFile?> _images = List.filled(2, null);
  final List<Color> _imageFilters = List.filled(2, Colors.transparent);
  final List<Widget?> _textWidgets = List.filled(2, null);
  final List<bool> _isEditing = List.filled(2, false);

  void _showAddBlocDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AddOption(
          onAddPhoto: () async {
            Navigator.pop(dialogContext);
            await addPhoto(
              index,
              _images,
              setState,
              context,
              (index, color) {
                setState(() {
                  _imageFilters[index] = color;
                });
              },
            );
          },
          onTakePhoto: () async {
            Navigator.pop(dialogContext);
            await takePhoto(
              index,
              _images,
              setState,
              context,
              (index, color) {
                setState(() {
                  _imageFilters[index] = color;
                });
              },
            );
          },
          onAddText: () {
            Navigator.pop(dialogContext);
            setState(() {
              _isEditing[index] = true;
            });
          },
          hasImage: _images[index] != null,
          hasText: _textWidgets[index] != null,
        );
      },
    );
  }

  Future<void> _publishPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final hashtags = _descriptionController.text
          .split(' ')
          .where((word) => word.startsWith('#'))
          .toList();

      final texts = _textWidgets.map((widget) {
        if (widget == null) return null;
        return {
          'content': widget.toString(),
          'fontSize': 16.0,
        };
      }).toList();

      await _firestoreService.createPost(
        userId: user.uid,
        title: _controller.text,
        images: _images,
        texts: texts.whereType<Map<String, dynamic>>().toList(),
        filters: _imageFilters,
        description: _descriptionController.text,
        hashtags: hashtags,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavBar()),
      );
    } catch (e) {
      print('Erreur lors de la publication: $e');
      // Gérer l'erreur...
    }
  }

  void _cancel() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const NavBar()), // Navigate back to NavBar
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Crée ton vote',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white54,
            size: 20,
          ),
          onPressed: _cancel,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ElevatedButton(
              onPressed: _publishPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white70),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Publier',
                  style:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.1), // Ligne de séparation simplifiée
            ),
            height: 0.5,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Ajout de cette ligne
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 120), // Augmenté pour éviter le chevauchement
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommentField(
                      controller: _controller,
                    ),
                    const SizedBox(height: 20),
                    BlocGrid(
                      images: _images,
                      imageFilters: _imageFilters,
                      onImageChange: (index) => _showAddBlocDialog(index),
                      textWidgets: _textWidgets,
                      numberOfBlocs: 2,
                      isEditing: _isEditing,
                    ),
                    const SizedBox(height: 80),
                    Description(
                      controller: _descriptionController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
