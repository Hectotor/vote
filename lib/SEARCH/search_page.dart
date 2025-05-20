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
      body: Column(
        children: [
          if (!_isSearching)
            FutureBuilder(
              future: SearchHistoryService.getSearchHistory().first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final itemName = data['itemName'];
                      final query = itemName.replaceAll(RegExp(r'^[@#]'), '');

                      IconData icon;
                      Color iconColor;
                      
                      if (itemName.startsWith('@')) {
                        icon = Icons.alternate_email;
                        iconColor = Colors.green;
                      } else if (itemName.startsWith('#')) {
                        icon = Icons.tag;
                        iconColor = Colors.purple;
                      } else {
                        icon = Icons.person;
                        iconColor = Colors.blue;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: Icon(icon, color: iconColor),
                            title: Text(itemName, style: const TextStyle(color: Color(0xFF212121))),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () {
                                SearchHistoryService.deleteHistoryEntry(doc.id);
                                setState(() {});
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
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          if (_isSearching)
            Expanded(
              child: _combinedResults.isEmpty
                  ? const Center(
                      child: Text('Aucun résultat trouvé'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _combinedResults.length,
                      itemBuilder: (context, index) {
                        final result = _combinedResults[index];
                        final type = result['type'];
                        final data = result['data'];

                        String title = '';
                        IconData icon = Icons.person;
                        Color iconColor = Colors.grey;

                        if (type == 'profile') {
                          title = '${data['pseudo']}';
                          icon = Icons.person;
                          iconColor = Colors.blue;
                        } else if (type == 'hashtag') {
                          title = '${data['name']}';
                          icon = Icons.tag;
                          iconColor = Colors.purple;
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
                                if (type == 'profile') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserPage(userId: data['userId']),
                                    ),
                                  );
                                } else if (type == 'hashtag') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FilteredHashtagPage(hashtag: data['name']),
                                    ),
                                  );
                                } else if (type == 'mention') {
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
                    ),
            ),
        ],
      ),
    );
  }
}
