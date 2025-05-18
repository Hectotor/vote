import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showHistory = false;

  List<Map<String, dynamic>> _combinedResults = [];
  List<String> _searchHistory = [];

  void _addToHistory(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
    }
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
      _showHistory = false;
      _addToHistory(query);
    });

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
      results.add({'type': 'profile', 'data': doc.data()});
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
      backgroundColor: Colors.black,
appBar: AppBar(
  backgroundColor: Colors.black,
  elevation: 0,
  toolbarHeight: 70,
  title: Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(30),
    ),
    child: TextField(
      controller: _searchController,
      onChanged: _performSearch,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white70,
      decoration: const InputDecoration(
        hintText: 'Rechercher un pseudo, # ou @',
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: Colors.white54),
        contentPadding: EdgeInsets.symmetric(vertical: 15),
      ),
    ),
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.history, color: Colors.white54),
      onPressed: () {
        setState(() {
          _showHistory = !_showHistory;
          _isSearching = false;
        });
      },
    ),
  ],
),

      body: _showHistory
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                final query = _searchHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.white70),
                      title: Text(query, style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _searchHistory.removeAt(index);
                          });
                        },
                      ),
                      onTap: () {
                        _searchController.text = query;
                        _performSearch(query);
                      },
                    ),
                  ),
                );
              },
            )
          : _isSearching
              ? _combinedResults.isEmpty
                  ? const Center(
                      child: Text("Aucun résultat", style: TextStyle(color: Colors.white70)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _combinedResults.length,
                      itemBuilder: (context, index) {
                    final item = _combinedResults[index];
                    final type = item['type'];
                    final data = item['data'];

                    String title = '';
                    IconData icon = Icons.person;
                    Color iconColor = Colors.white;

                    if (type == 'profile') {
                      title = data['pseudo'] ?? 'Utilisateur';
                      icon = Icons.person;
                      iconColor = Colors.orange;
                    } else if (type == 'hashtag') {
                      title = '${data['name']}';
                      icon = Icons.tag;
                      iconColor = Colors.blue;
                    } else if (type == 'mention') {
                      title = '${data['name']}';
                      icon = Icons.alternate_email;
                      iconColor = Colors.green;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          leading: Icon(icon, color: iconColor),
                          title: Text(title, style: const TextStyle(color: Colors.white)),
                          onTap: () {
                            if (type == 'profile') {
                              Navigator.pushNamed(context, '/user', arguments: data['userId']);
                            } else {
                              Navigator.pushNamed(context, '/post', arguments: data['postId']);
                            }
                          },
                        ),
                      ),
                    );
                  },
                )
          : const Center(),
    );
  }
}
