import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ImageEditDialog extends StatefulWidget {
  final Function(File, Color, double) onImageSelected;
  final File? initialImage;
  final int currentBlockIndex;

  const ImageEditDialog({
    Key? key,
    required this.onImageSelected,
    this.initialImage,
    required this.currentBlockIndex,
  }) : super(key: key);

  @override
  State<ImageEditDialog> createState() => _ImageEditDialogState();
}

class _ImageEditDialogState extends State<ImageEditDialog>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  Color _selectedFilter = Colors.transparent;
  double _filterOpacity = 0.0;
  bool _isLoading = true;
  bool _initialized = false;

  final List<Color> _filterColors = [
    Colors.transparent,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  late AnimationController _animationController;
  late Animation<double> _filterSelectorAnimation;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _buttonsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      if (widget.initialImage != null && widget.initialImage!.existsSync()) {
        _selectedImage = widget.initialImage;
        _isLoading = false;
        _animationController.forward();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSourceSelectionDialog();
        });
      }
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _filterSelectorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    ));

    _imageScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _buttonsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));
  }

  Future<void> _showSourceSelectionDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text(
            '',
            textAlign: TextAlign.center, // Ajouté par précaution
          ),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSourceButton(
              onTap: () => Navigator.pop(context, ImageSource.camera),
              icon: Icons.camera_alt_rounded,
              label: 'Caméra',
              color: Colors.blue[700]!,
            ),
            _buildSourceButton(
              onTap: () => Navigator.pop(context, ImageSource.gallery),
              icon: Icons.photo_library_rounded,
              label: 'Galerie',
              color: Colors.green[700]!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54, // Couleur du texte
            ),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (source == null) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    await _processImageSelection(source);
  }

  Widget _buildSourceButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processImageSelection(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: source == ImageSource.camera
                  ? 'Ajuster la photo'
                  : 'Ajuster l\'image',
              toolbarColor: Colors.transparent,
              toolbarWidgetColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            IOSUiSettings(
              title: source == ImageSource.camera
                  ? 'Ajuster la photo'
                  : 'Ajuster l\'image',
              doneButtonTitle: 'Terminer',
              cancelButtonTitle: 'Annuler',
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _selectedImage = File(croppedFile.path);
            _isLoading = false;
          });
          _animationController.forward();
        } else {
          if (!mounted) return;
          Navigator.pop(context);
        }
      } else {
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Erreur lors de la sélection/capture d\'image: $e');
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _handleTerminer() {
    if (_selectedImage != null) {
      widget.onImageSelected(
        _selectedImage!,
        _selectedFilter,
        _filterOpacity,
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une image avant de terminer.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFilterSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedFilter != Colors.transparent)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Slider(
                  value: _filterOpacity,
                  onChanged: (value) {
                    setState(() {
                      _filterOpacity = value;
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                  activeColor: _selectedFilter,
                  inactiveColor: _selectedFilter.withOpacity(0.3),
                ),
              ],
            ),
          ),
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filterColors.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final color = _filterColors[index];
              final isSelected = color == _selectedFilter;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = color;
                    _filterOpacity = color == Colors.transparent ? 0.0 : 0.3;
                  });
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Stack(
                      children: [
                        if (_selectedImage != null)
                          Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                          ),
                        Container(
                          color: color.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: _selectedImage != null
                    ? ScaleTransition(
                        scale: _imageScaleAnimation,
                        child: Stack(
                          children: [
                            Image.file(
                              _selectedImage!,
                              fit: BoxFit.contain,
                            ),
                            Positioned.fill(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                color:
                                    _selectedFilter.withOpacity(_filterOpacity),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Text(
                        'Aucune image sélectionnée',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(_filterSelectorAnimation),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                          Colors.black,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFilterSelector(),
                        FadeTransition(
                          opacity: _buttonsAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(
                                      context), // Retourne à AddScreen
                                  child: const Text(
                                    'Annuler',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _handleTerminer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Terminer',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
