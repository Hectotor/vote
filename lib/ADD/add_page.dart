import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toplyke/navBar.dart';
import 'description.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import localization package
import 'dart:async'; // Import the dart:async package for Timer
import 'publish.dart';
import 'poll_grid.dart';
import 'bottom_add_bloc.dart';

class Post {
  final User user;
  final List<XFile?> images;
  final List<Map<String, dynamic>> texts;
  final List<Color> filters;
  final String description;
  final List<String> hashtags;
  final List<String> mentions;

  Post({
    required this.user,
    required this.images,
    required this.texts,
    required this.filters,
    this.description = '',
    this.hashtags = const [],
    this.mentions = const [],
  });
}

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
  final PublishService _publishService = PublishService();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Timer? _timer;
  List<XFile?> _images = [];
  List<Color> _imageFilters = [];
  List<Widget?> _textWidgets = [];
  List<TextEditingController> textControllers = [];
  List<String> _hashtags = [];
  List<String> _mentions = [];

  @override
  void initState() {
    super.initState();
    // Initialiser deux contrôleurs de texte dès le début
    textControllers = [
      TextEditingController(),
      TextEditingController(),
    ];
    
    // Initialiser les listes d'images et de filtres avec la même longueur que textControllers
    _images = List.generate(textControllers.length, (index) => null);
    _imageFilters = List.generate(textControllers.length, (index) => Colors.transparent);
  }

  Future<void> _publishContent() async {
    final description = _descriptionController.text;
    
    try {
      // Use PublishService to publish content
      final success = await _publishService.publishContent(
        description: description,
        images: _images,
        imageFilters: _imageFilters,
        textControllers: textControllers,
        hashtags: _hashtags, // Add hashtags to the method call
        mentions: _mentions, // Add mentions to the method call
        context: context,
      );

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publication réussie')),
        );

        // Reset fields
        _descriptionController.clear();
        setState(() {
          _textWidgets.fillRange(0, _textWidgets.length, null);
          _images.fillRange(0, _images.length, null);
          _imageFilters.fillRange(0, _imageFilters.length, Colors.transparent);
          _hashtags.clear(); // Clear hashtags after publishing
          _mentions.clear(); // Clear mentions after publishing
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la publication')),
        );
      }
    } catch (e) {
      // Handle any errors during publishing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  void _cancel() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const NavBar()), // Navigate back to NavBar
    );
  }

  void _updateImageState(int index) {
    setState(() {
      // Trigger a state update
    });
  }

  bool _canPublish() {
    // La description est maintenant optionnelle
    final hasDescription = true;
    
    // Utiliser la nouvelle méthode de validation des images
    final publishService = PublishService();
    final hasValidBlocs = publishService.canPublish(images: _images);

    // Afficher des informations de débogage détaillées
    print('Description non vide : $hasDescription');
    print('Images valides : $hasValidBlocs');
    print('Liste des images : $_images');
    print('Images non nulles : ${_images.where((img) => img != null).toList()}');

    return hasDescription && hasValidBlocs;
  }

  void _addBloc() {
    setState(() {
      if (textControllers.length < 4) {
        textControllers.add(TextEditingController());
        _images.add(null);
        _imageFilters.add(Colors.transparent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: _cancel,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: TextButton(
              onPressed: _canPublish() ? () {
                print('Publish button pressed'); // Debug print
                _publishContent();
              } : null,
              style: TextButton.styleFrom(
                foregroundColor: _canPublish() ? const Color(0xFF3498DB) : Colors.white70,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Publier',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DescriptionField(
                      controller: _descriptionController,
                      onTagsChanged: (hashtags, mentions) {
                        setState(() {
                          _hashtags = hashtags;
                          _mentions = mentions;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    PollGrid(
                      images: _images,
                      imageFilters: _imageFilters,
                      numberOfBlocs: textControllers.length,
                      textControllers: textControllers,
                      onImageChange: (index) {
                        _updateImageState(index);
                      },
                      onBlocRemoved: (index) {
                        setState(() {
                          // Supprimer uniquement le bloc à l'index spécifié
                          if (index >= 2 && index < textControllers.length) {
                            // Supprimer les éléments associés
                            textControllers.removeAt(index);
                            _images.removeAt(index);
                            _imageFilters.removeAt(index);
                          }
                        });
                      },
                      onStateUpdate: () {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 26),
                    BottomAddBloc(
                      showPoll: true,
                      numberOfPollBlocs: textControllers.length,
                      onPressed: _addBloc,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _descriptionController.dispose();
    for (var controller in textControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
