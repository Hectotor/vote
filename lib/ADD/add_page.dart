import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vote_app/ADD/texte.dart';
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
  final TextEditingController _descriptionController =
      TextEditingController(); // nouveau controller
  int _numberOfBlocs = 2;
  Timer? _timer;
  List<XFile?> _images = List<XFile?>.filled(4, null);
  List<Color> _imageFilters =
      List<Color>.filled(4, Colors.transparent); // Nouvelle ligne
  List<Widget?> _textWidgets = List<Widget?>.filled(4, null); // Nouveau

  @override
  void initState() {
    super.initState();
  }

  void _showAddBlocDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: true, // Permet de fermer en cliquant à l'extérieur
      builder: (BuildContext dialogContext) {
        // Utilisez un nouveau context
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(dialogContext).pop(); // Ferme le dialogue
            return true;
          },
          child: AddOption(
            onAddText: () {
              Navigator.pop(dialogContext); // Ferme le dialogue
              _addText(index);
            },
            onAddPhoto: () async {
              Navigator.pop(dialogContext); // Ferme le dialogue
              if (!mounted) return; // Vérifiez si le widget est toujours monté
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
              Navigator.pop(dialogContext); // Ferme le dialogue
              if (!mounted) return; // Vérifiez si le widget est toujours monté
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
            onDeleteContent: _images[index] != null
                ? () {
                    setState(() {
                      _images[index] = null;
                      _imageFilters[index] =
                          Colors.transparent; // Réinitialiser le filtre
                    });
                    Navigator.pop(dialogContext); // Ferme le dialogue
                  }
                : null,
            hasImage: _images[index] != null,
            hasText: _textWidgets[index] != null, // Ajout de cette ligne
          ),
        );
      },
    );
  }

  void _addText(int index) {
    print('AddPage - _addText called for index: $index');
    setState(() {
      _textWidgets[index] = TextEditWidget(
        key: Key('textWidget$index'),
        backgroundColor: Colors.transparent,
        onEmpty: () {
          print('AddPage - TextWidget onEmpty callback for index: $index');
          setState(() {
            _textWidgets[index] = null;
          });
        },
      );
    });
  }

  void _addBlocs() {
    print('AddPage - _addBlocs called, current blocks: $_numberOfBlocs');
    if (_numberOfBlocs < 4) {
      setState(() {
        _numberOfBlocs++;
        print('AddPage - New number of blocks: $_numberOfBlocs');
      });
    }
  }

  void _deleteBloc() {
    setState(() {
      if (_numberOfBlocs > 2) {
        _numberOfBlocs--;
      }
    });
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
          'position': {'x': 0, 'y': 0},
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true, // Centre le titre
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
                        numberOfBlocs: _numberOfBlocs,
                        onTap: () => _showAddBlocDialog(0),
                        onDelete: _deleteBloc,
                        images: _images,
                        imageFilters: _imageFilters,
                        onImageChange: (index) => _showAddBlocDialog(index),
                        textWidgets: _textWidgets,
                      ),
                      const SizedBox(height: 25),
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
        floatingActionButton: _numberOfBlocs < 4
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2E2E2E),
                      Color(0xFF1A1A1A),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addBlocs,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
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
