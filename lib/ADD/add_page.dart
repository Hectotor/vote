import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'description.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
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
        Locale('fr', 'FR'),
      ],
      home: const AddPage(),
    );
  }
}

class AddPage extends StatefulWidget {
  final int previousIndex;

  const AddPage({super.key, this.previousIndex = 0});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final PublishService _publishService = PublishService();
  final TextEditingController _descriptionController = TextEditingController();
  List<XFile?> _images = [];
  List<Color> _imageFilters = [];
  List<TextEditingController> textControllers = [];
  List<String> _hashtags = [];
  List<String> _mentions = [];
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    textControllers = [TextEditingController(), TextEditingController()];
    _images = List.generate(textControllers.length, (index) => null);
    _imageFilters = List.generate(textControllers.length, (index) => Colors.transparent);
  }

  Future<void> _publishContent() async {
    if (_isLoading.value) return;
    _isLoading.value = true;

    final description = _descriptionController.text;

    try {
      final success = await _publishService.publishContent(
        description: description,
        images: _images,
        imageFilters: _imageFilters,
        textControllers: textControllers,
        context: context,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication réussie')),
        );

        _descriptionController.clear();
        setState(() {
          for (var controller in textControllers) {
            controller.clear();
          }
          _images = List.generate(textControllers.length, (index) => null);
          _imageFilters = List.generate(textControllers.length, (index) => Colors.transparent);
          _hashtags.clear();
          _mentions.clear();
        });

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la publication')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec de la publication')),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  bool _canPublish() {
    final numberOfImages = _images.where((img) => img != null).length;
    return numberOfImages >= 2;
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
    return WillPopScope(
      onWillPop: () async => !_isLoading.value,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: const Text('Crée ton vote', style: TextStyle(fontSize: 18)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isLoading.value ? null : _cancel,
          ),
          actions: [
            TextButton(
              onPressed: _isLoading.value || !_canPublish() ? null : _publishContent,
              style: TextButton.styleFrom(
                foregroundColor: _canPublish() ? const Color(0xFF3498DB) : const Color(0xFF212121),
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
                  color: _isLoading.value ? const Color(0xFF212121) : null,
                ),
              ),
            ),
          ],
        ),
        body: ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, isLoading, child) {
            return Stack(
              children: [
                AbsorbPointer(absorbing: isLoading, child: child!),
                if (isLoading)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
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
                          const SizedBox(height: 8),
                          PollGrid(
                            images: _images,
                            imageFilters: _imageFilters,
                            numberOfBlocs: textControllers.length,
                            textControllers: textControllers,
                            onImageChange: (index) => setState(() {}),
                            onBlocRemoved: (index) {
                              setState(() {
                                if (index >= 2 && index < textControllers.length) {
                                  textControllers.removeAt(index);
                                  _images.removeAt(index);
                                  _imageFilters.removeAt(index);
                                }
                              });
                            },
                            onStateUpdate: () => setState(() {}),
                          ),
                          const SizedBox(height: 26),
                          BottomAddBloc(
                            showPoll: true,
                            numberOfPollBlocs: textControllers.length,
                            onPressed: _isLoading.value ? () {} : _addBloc,
                          ),
                          const SizedBox(height: 100), // Espace en bas pour éviter que le contenu soit caché
                        ],
                      ),
                    ),
                  ),
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
    _descriptionController.dispose();
    for (var controller in textControllers) {
      controller.dispose();
    }
    _isLoading.dispose();
    super.dispose();
  }
}