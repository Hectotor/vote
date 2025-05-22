import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'search_results_widget.dart';
import 'search_history_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _isFocused = false;

  List<Map<String, dynamic>> _combinedResults = [];
  
  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isFocused = _searchFocusNode.hasFocus;
      });
    });
  }
  
  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String rawQuery) async {
    final query = rawQuery.trim().replaceAll(RegExp(r'^[@#]'), ''); // Supprimer # ou @
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _combinedResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _combinedResults = [];
    });

    // Note: L'historique est maintenant sauvegardé au moment du clic sur un résultat
    // pour pouvoir enregistrer l'ID de l'élément sélectionné

    // Profils (pseudo)
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('pseudo', isGreaterThanOrEqualTo: query)
        .where('pseudo', isLessThan: '${query}z')
        .get();

    // Hashtags
    final hashtagsSnapshot = await FirebaseFirestore.instance
        .collection('hashtags')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .get();

    // Mentions
    final mentionsSnapshot = await FirebaseFirestore.instance
        .collection('mentions')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .get();

    final results = <Map<String, dynamic>>[];

    for (var doc in usersSnapshot.docs) {
      final userData = doc.data();
      userData['userId'] = doc.id;
      results.add({'type': 'profile', 'data': userData, 'docId': doc.id});
    }
    for (var doc in hashtagsSnapshot.docs) {
      results.add({'type': 'hashtag', 'data': doc.data()});
    }
    for (var doc in mentionsSnapshot.docs) {
      results.add({'type': 'mention', 'data': doc.data()});
    }

    setState(() {
      _combinedResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          AnimatedSlide(
            offset: Offset(_isFocused ? 0.0 : 1.0, 0.0),
            duration: const Duration(milliseconds: 250),
            child: AnimatedOpacity(
              opacity: _isFocused ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isFocused ? 80 : 0,
                child: _isFocused ? TextButton(
                  onPressed: () {
                    _searchFocusNode.unfocus();
                    setState(() {
                      _searchController.clear();
                      _isSearching = false;
                      _combinedResults = [];
                    });
                  },
                  child: const Text('Annuler', style: TextStyle(color: Color(0xFF212121))),
                ) : null,
              ),
            ),
          ),
        ],
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() {
                  _isSearching = false;
                  _combinedResults = [];
                });
              } else {
                _performSearch(value);
              }
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _performSearch(value);
              }
            },
            style: const TextStyle(color: Color(0xFF212121)),
            cursorColor: Colors.blue[800],
            decoration: InputDecoration(
              hintText: 'Rechercher un pseudo, # ou @',
              hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!_isSearching && _isFocused)
              SearchHistoryWidget(),
            if (_isSearching)
              SearchResultsWidget(
                results: _combinedResults,
                isSearching: _isSearching,
              ),
            if (_isSearching)
              SearchResultsWidget(
                results: _combinedResults,
                isSearching: _isSearching,
              ),
          ],
        ),
      ),
    );
  }
}
