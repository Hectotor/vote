import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:votely/navBar.dart';
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
  List<bool> _isEditing = [];
  List<TextEditingController> textControllers = [];
  bool _showPoll = true;
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
  }

  Future<void> _publishContent() async {
    final description = _descriptionController.text;
    

    if (mounted) {
      // Réinitialiser les champs
      _descriptionController.clear();
      setState(() {
        _textWidgets.fillRange(0, _textWidgets.length, null);
      });
    }
  }

  void _cancel() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const NavBar()), // Navigate back to NavBar
    );
  }

  bool _canPublish() {
    // Compter le nombre d'images non nulles
    int imageCount = _images.where((image) => image != null).length;
    
    // Compter le nombre de textes non vides
    int textCount = textControllers.where((controller) => controller.text.isNotEmpty).length;
    
    // Retourner true si 2 images ou au moins 2 textes
    return imageCount == 2 || textCount >= 2;
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
              onPressed: _canPublish() ? _publishContent : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: _canPublish() ? Colors.white : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _canPublish() ? Colors.white : Colors.grey),
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
                      numberOfBlocs: textControllers.length,
                      textControllers: textControllers,
                      onBlocRemoved: (index) {
                        setState(() {
                          textControllers.removeAt(index);
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    BottomAddBloc(
                      showPoll: true,
                      numberOfPollBlocs: textControllers.length,
                      onPressed: () {
                        setState(() {
                          if (textControllers.length < 4) {
                            textControllers.add(TextEditingController());
                          }
                        });
                      },
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
