import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../USERS/user_page.dart';
import 'filtered_hashtag_page.dart';
import './filtered_mentions_page.dart';
import 'search_history_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  List<Map<String, dynamic>> _combinedResults = [];

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
appBar: AppBar(
  elevation: 0,
  toolbarHeight: 70,
  backgroundColor: Colors.white,
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
      onChanged: _performSearch,
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

      body: _isSearching
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
                          title: Text(title, style: const TextStyle(color: Color(0xFF212121))),
                          onTap: () {
                            // Sauvegarder la recherche dans l'historique
                            final String query = _searchController.text.trim();
                            
                            if (type == 'profile') {
                              // Sauvegarder la recherche de profil
                              SearchHistoryService.saveSearch(
                                query,
                                'profile',
                                data['userId'] ?? '',
                                data['pseudo'] ?? 'Utilisateur',
                              );
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserPage(
                                    userId: data['userId'],
                                    showLoginButton: false,
                                  ),
                                ),
                              );
                            } else if (type == 'hashtag') {
                              // Sauvegarder la recherche de hashtag
                              SearchHistoryService.saveSearch(
                                query,
                                'hashtag',
                                data['name'] ?? '',
                                '#${data['name'] ?? ''}',
                              );
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FilteredHashtagPage(hashtag: data['name']),
                                ),
                              );
                            } else if (type == 'mention') {
                              // Sauvegarder la recherche de mention
                              SearchHistoryService.saveSearch(
                                query,
                                'mention',
                                data['name'] ?? '',
                                '@${data['name'] ?? ''}',
                              );
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FilteredMentionsPage(mention: data['name']),
                                ),
                              );
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
