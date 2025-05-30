import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/COMPONENTS/menu_delete.dart';
import 'package:toplyke/COMPONENTS/Post/post_report_service.dart';
import 'package:toplyke/COMPONENTS/Post/post_save_service.dart';

class PostMenu extends StatefulWidget {
  final String postId;
  final String userId;

  const PostMenu({
    Key? key,
    required this.postId,
    required this.userId,
  }) : super(key: key);

  @override
  State<PostMenu> createState() => _PostMenuState();
}

class _PostMenuState extends State<PostMenu> {
  bool _isReported = false;
  bool _isSaved = false;
  final MenuDelete _deleteService = MenuDelete();
  final PostReportService _reportService = PostReportService();
  final PostSaveService _saveService = PostSaveService();

  @override
  void initState() {
    super.initState();
    _checkIfReported();
    _checkIfSaved();
  }

  Future<void> _checkIfReported() async {
    try {
      final isReported = await _reportService.isPostReportedByUser(widget.postId);
      if (mounted) {
        setState(() {
          _isReported = isReported;
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification du signalement: $e');
    }
  }

  Future<void> _checkIfSaved() async {
    try {
      final isSaved = await _saveService.isPostSaved(widget.postId);
      if (mounted) {
        setState(() {
          _isSaved = isSaved;
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification de la sauvegarde: $e');
    }
  }

  Future<void> _reportPost(BuildContext context) async {
    try {
      // Utiliser la méthode statique qui gère la redirection vers la page de connexion
      final success = await PostReportService.reportWithAuthCheck(
        context,
        widget.postId
      );
      
      if (!mounted) return;
      
      // Mettre à jour l'état local si le signalement a été effectué
      setState(() {
        _isReported = success;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du signalement: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _savePost(BuildContext context) async {
    try {
      // Utiliser la méthode statique qui gère la redirection vers la page de connexion
      final success = await PostSaveService.saveWithAuthCheck(
        context,
        widget.postId
      );
      
      if (!mounted) return;
      
      // Mettre à jour l'état local
      if (success) {
        await _checkIfSaved(); // Vérifier le nouvel état après le toggle
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la sauvegarde: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == widget.userId;
    
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String value) {
        if (value == 'report') {
          _reportPost(context);
        } else if (value == 'delete') {
          _deleteService.deletePost(widget.postId, widget.userId, context);
        } else if (value == 'save') {
          _savePost(context);
        }
      },
      itemBuilder: (BuildContext context) {
        final items = <PopupMenuEntry<String>>[];
        
        // Option de sauvegarde
        items.add(
          PopupMenuItem<String>(
            value: 'save',
            child: Row(
              children: [
                Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: _isSaved ? Colors.blue : const Color(0xFF212121),
                ),
                const SizedBox(width: 8),
                Text(
                  _isSaved ? 'Retirer des sauvegardes' : 'Sauvegarder',
                  style: TextStyle(
                    color: _isSaved ? Colors.blue : const Color(0xFF212121),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );

        // Toujours afficher l'option de signalement
        items.add(
          PopupMenuItem<String>(
            value: 'report',
            child: Row(
              children: [
                Icon(
                  Icons.flag,
                  color: _isReported ? Colors.red : const Color(0xFF212121),
                ),
                const SizedBox(width: 8),
                Text(
                  _isReported ? 'Annuler le signalement' : 'Signaler',
                  style: TextStyle(
                    color: _isReported ? Colors.red : const Color(0xFF212121),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );

        // Afficher l'option de suppression uniquement pour le propriétaire
        if (isOwner) {
          items.add(
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Supprimer',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return items;
      },
    );
  }
}
