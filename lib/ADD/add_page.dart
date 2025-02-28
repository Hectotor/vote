import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:votely/navBar.dart';
import 'description.dart';
import 'bloc.dart';
import 'addoption.dart'; // Importer le nouveau fichier
import 'package:image_picker/image_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import localization package
import 'dart:async'; // Import the dart:async package for Timer
import 'image.dart'; // Import the new image.dart file
import 'poll_button.dart'; // Importer le PollButton
import 'poll_grid.dart'; // Importer le PollGrid
import 'bottom_add_bloc.dart'; // Ajout de l'import
import 'publish.dart';

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
  final List<XFile?> _images = List.filled(2, null);
  final List<Color> _imageFilters = List.filled(2, Colors.transparent);
  final List<Widget?> _textWidgets = List.filled(2, null);
  final List<bool> _isEditing = List.filled(2, false);
  bool _showPoll = false;
  int _numberOfPollBlocs = 2;
  final List<TextEditingController> textControllers = List.generate(4, (index) => TextEditingController());
  List<String> _hashtags = [];
  List<String> _mentions = [];

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

  void _togglePoll() {
    setState(() {
      _showPoll = !_showPoll;
    });
  }

  Future<void> _publishContent() async {
    final description = _descriptionController.text;
    
    final success = await _publishService.publishContent(
      description: description,
      isPoll: _showPoll,
      pollOptions: textControllers.map((c) => c.text).toList(),
      blocContent: _showPoll ? null : _textWidgets.whereType<Widget>().toList(),
      context: context,
    );

    if (success) {
      // Réinitialiser les champs
      _descriptionController.clear();
      for (var controller in textControllers) {
        controller.clear();
      }
      setState(() {
        _showPoll = false;
        _textWidgets.fillRange(0, _textWidgets.length, null);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publication réussie!')),
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
                    _showPoll
                        ? PollGrid(
                            numberOfBlocs: _numberOfPollBlocs,
                            textControllers: textControllers,
                            onBlocRemoved: (index) {
                              setState(() {
                                _numberOfPollBlocs--;
                              });
                            },
                          )
                        : BlocGrid(
                            images: _images,
                            imageFilters: _imageFilters,
                            textWidgets: _textWidgets,
                            onImageChange: _showAddBlocDialog,
                            numberOfBlocs: 2,
                            isEditing: _isEditing,
                          ),
                          SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          BottomAddBloc(
                            showPoll: _showPoll,
                            numberOfPollBlocs: _numberOfPollBlocs,
                            onPressed: () {
                              setState(() {
                                _numberOfPollBlocs++;
                              });
                            },
                          ),
                          PollButton(
                            onPressed: _togglePoll,
                          ),
                        ],
                      ),
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
    super.dispose();
  }
}
