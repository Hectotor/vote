import 'package:flutter/material.dart';
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
  DateTime? _selectedDate; // Add a variable to store the selected date
  Timer? _timer; // Add a Timer variable
  String? _errorMessage; // Add a variable to store the error message

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

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'), // Set locale to French
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1A237E), // Set primary color
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
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
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: const Color(0xFF1A237E), // Set primary color
              ),
              buttonTheme: const ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
              ),
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
            _selectedDate = selectedDateTime;
            _errorMessage = null; // Clear the error message
          });
        } else {
          setState(() {
            _errorMessage = 'Veuillez sélectionner une heure valide.';
          });
          Future.delayed(const Duration(seconds: 5), () {
            setState(() {
              _errorMessage = null; // Clear the error message after 4 seconds
            });
          });
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${days}j - ${twoDigits(hours)}h-${twoDigits(minutes)}m-${twoDigits(seconds)}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFDFBFB), // Set scaffold background color to white
      appBar: AppBar(
        toolbarHeight: 50, // Reduce the height of the AppBar
        backgroundColor:
            Color(0xFFFDFBFB), // Set AppBar background color to white
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
              color: Color(0xFF1A237E),
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
                    color: Color(0xFF1A237E),
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
                  color: Color(0xFF1A237E),
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
          color: const Color(0xFFFDFBFB),
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
              const SizedBox(height: 30),
              Description(
                controller: _descriptionController,
              ),
              DateSelector(
                selectedDate: _selectedDate,
                onSelectDate: _showDatePicker,
                formatDuration: _formatDuration,
                onClearDate: () {
                  setState(() {
                    _selectedDate = null; // Clear the selected date
                  });
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.center, // Center the error message
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ),
            ],
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
