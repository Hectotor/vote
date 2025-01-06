import 'package:flutter/material.dart';
import 'package:vote_app/main.dart';
import 'package:vote_app/navBar.dart';
import 'comment.dart';
import 'bloc.dart';
import 'addoption.dart'; // Importer le nouveau fichier
import 'package:image_picker/image_picker.dart';
import 'description.dart'; // Ajouter l'import
import 'date.dart'; // Import the new file
import 'package:flutter_localizations/flutter_localizations.dart'; // Import localization package
import 'dart:async'; // Import the dart:async package for Timer
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore

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
                padding: const EdgeInsets.only(right: 10.0),
                child: TextButton(
                  onPressed: _addBlocs,
                  child: const Text(
                    'Ajouter',
                    style: TextStyle(
                      color: Color(0xFF4B6CB7),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AvenirNext', // Set font family
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: TextButton(
                onPressed: () {
                  // Logique pour enregistrer
                },
                child: const Text(
                  'Sauvegarder',
                  style: TextStyle(
                    color: Color(0xFF4B6CB7),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'AvenirNext', // Set font family
                  ),
                ),
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'AvenirNext', // Set font family
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align to the start
              children: [
                CommentField(
                  controller: _controller,
                ),
                BlocGrid(
                  numberOfBlocs: _numberOfBlocs,
                  onTap: _showAddBlocDialog,
                  onDelete: _deleteBloc,
                ),
                const SizedBox(height: 30),
                Description(
                  controller: _descriptionController,
                ),
                const SizedBox(height: 30),
                DateSelector(
                  selectedDate: null, // Pass the initial selected date
                  formatDuration: (duration) {
                    String twoDigits(int n) => n.toString().padLeft(2, '0');
                    final days = duration.inDays;
                    final hours = duration.inHours.remainder(24);
                    final minutes = duration.inMinutes.remainder(60);
                    final seconds = duration.inSeconds.remainder(60);
                    return '${days}j - ${twoDigits(hours)}h-${twoDigits(minutes)}m-${twoDigits(seconds)}s';
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    _controller.dispose();
    _descriptionController.dispose(); // dispose le nouveau controller
    super.dispose();
  }
}
