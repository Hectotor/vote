import 'package:flutter/material.dart';
import 'package:vote_app/ADD/texte.dart';
import 'package:vote_app/main.dart';
import 'package:vote_app/navBar.dart';
import 'comment.dart';
import 'bloc.dart';
import 'addoption.dart'; // Importer le nouveau fichier
import 'package:image_picker/image_picker.dart';
import 'description.dart'; // Ajouter l'import
import 'package:flutter_localizations/flutter_localizations.dart'; // Import localization package
import 'dart:async'; // Import the dart:async package for Timer
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore
import 'image.dart'; // Import the new image.dart file

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
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(); // nouveau controller
  int _numberOfBlocs = 2;
  Timer? _timer; // Add a Timer variable
  DateTime? _selectedDate; // Add a DateTime variable
  List<XFile?> _images = List<XFile?>.filled(4, null); // List to store images
  List<Color> _imageFilters =
      List<Color>.filled(4, Colors.transparent); // Nouvelle ligne
  bool _isChronoActive = false; // Pour suivre l'état du chrono
  List<Widget?> _textWidgets = List<Widget?>.filled(4, null); // Nouveau

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
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
    setState(() {
      _textWidgets[index] = TextEditWidget(
        backgroundColor: Colors
            .transparent, // La couleur est maintenant gérée dans bloc.dart
        onEmpty: () {
          setState(() {
            _textWidgets[index] = null;
          });
        },
      );
    });
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

  void _publishPost() {
    _saveHashtags(); // Save hashtags when publishing the post
    // Logique pour publier le post
  }

  void _saveHashtags() {
    final text = _descriptionController.text;
    final hashtags =
        text.split(' ').where((word) => word.startsWith('#')).toList();
    for (var hashtag in hashtags) {
      FirebaseFirestore.instance.collection('hashtags').add({
        'hashtag': hashtag,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        print('Hashtag saved to Firebase: $hashtag');
      }).catchError((error) {
        print('Failed to save hashtag: $error');
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

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF4B6CB7), // Couleur principale
              onPrimary:
                  Colors.white, // Couleur du texte sur le bouton sélectionné
              surface: const Color(0xFF1D1D2C), // Couleur de fond du dialogue
              onSurface: Colors.white, // Couleur du texte sur le fond
            ),
            dialogBackgroundColor: const Color(0xFF24243E), // Fond du dialogue
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFF4B6CB7),
                onPrimary: Colors.white,
                surface: const Color(0xFF1D1D2C),
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: const Color(0xFF24243E),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        final selectedDateTime = DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
        if (selectedDateTime.isAfter(DateTime.now())) {
          setState(() {
            _selectedDate = selectedDateTime; // Set the selected date
          });
        } else {
          // Logique pour gérer une date invalide
        }
      }
    }
  }

  void _clearSelectedDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF4B6CB7),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleChrono() {
    setState(() {
      _isChronoActive = !_isChronoActive;
      _showSnackBar(_isChronoActive ? 'Chrono activé' : 'Chrono désactivé');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Set scaffold background color to transparent
        appBar: AppBar(
          toolbarHeight: 50, // Reduce the height of the AppBar
          backgroundColor:
              Colors.transparent, // Set AppBar background color to transparent
          elevation: 0, // Remove app bar shadow
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.withOpacity(0.2),
              height: 0.5,
            ),
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF4B6CB7),
                size: 20,
              ),
              onPressed: _cancel,
            ),
          ),
          actions: [
            if (_numberOfBlocs < 4)
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF4B6CB7),
                  ),
                  onPressed: _addBlocs,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                icon: _isChronoActive
                    ? const Text(
                        '5s',
                        style: TextStyle(
                          color: Color(0xFF4B6CB7),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : const Icon(
                        Icons.timer_sharp,
                        color: Color(0xFF4B6CB7),
                      ),
                onPressed: _toggleChrono,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF4B6CB7),
                ),
                onPressed: _showDatePicker,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                icon: const Icon(
                  Icons.save,
                  color: Color(0xFF4B6CB7),
                ),
                onPressed: () {
                  // Logique pour enregistrer
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ElevatedButton(
                onPressed: _publishPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B6CB7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Publier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    //fontFamily: 'AvenirNext', // Set font family
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 5),
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align to the start
              children: [
                CommentField(
                  controller: _controller,
                ),
                const SizedBox(height: 40),
                BlocGrid(
                  numberOfBlocs: _numberOfBlocs,
                  onTap: () => _showAddBlocDialog(0),
                  onDelete: _deleteBloc,
                  images: _images, // Pass images to BlocGrid
                  imageFilters: _imageFilters, // Ajouter cette ligne
                  onImageChange: (index) => _showAddBlocDialog(index),
                  textWidgets:
                      _textWidgets, // Passez _textWidgets au lieu d'une liste vide
                ),
                if (_selectedDate != null)
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_selectedDate!.isAfter(DateTime.now()) ? "Vote ouvert" : "Vote fermé"} -  ${_formatDuration(_selectedDate!.difference(DateTime.now()))}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'AvenirNext',
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear,
                              size: 15, color: Colors.white),
                          onPressed: _clearSelectedDate,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 25),
                Description(
                  controller: _descriptionController,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final parts = [
      if (duration.inDays > 0) '${duration.inDays}j',
      if (duration.inHours.remainder(24) > 0)
        '${duration.inHours.remainder(24)}h',
      if (duration.inMinutes.remainder(60) > 0)
        '${duration.inMinutes.remainder(60)}m',
      if (duration.inSeconds.remainder(60) > 0)
        '${duration.inSeconds.remainder(60)}s',
    ];

    return parts.join(' ');
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    _controller.dispose();
    _descriptionController.dispose(); // dispose le nouveau controller
    super.dispose();
  }
}
