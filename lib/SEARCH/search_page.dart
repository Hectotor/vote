import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _showPosts = true;
  bool _isSearching = false;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 90,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                    _isSearching = _searchQuery.isNotEmpty;
                  });
                  _performSearch();
                },
                decoration: InputDecoration(
                  hintText: "Rechercher un post ou un profil...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _isSearching = false;
                              _searchQuery = '';
                              _searchResults.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
        
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _isSearching && _searchQuery.isNotEmpty
              ? _searchResults.isEmpty
                  ? const Center(child: Text("Aucun résultat", style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 100),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];

                      },
                    )
              : const Center(
                  child: Text(
                    'Commencez à rechercher...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
    );
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('hashtags', arrayContainsAny: [_searchQuery])
          .get();

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('pseudo', isGreaterThanOrEqualTo: _searchQuery)
          .where('pseudo', isLessThan: _searchQuery + 'z')
          .get();

      setState(() {
        _searchResults = _showPosts
            ? postsSnapshot.docs.map((doc) => doc.data()).toList().cast<Map<String, dynamic>>()
            : usersSnapshot.docs.map((doc) => doc.data()).toList().cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Erreur recherche: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
