import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../COMPONENTS/avatar.dart';
import 'user_page.dart';

class FollowersPage extends StatefulWidget {
  final String userId;
  final String type; // 'followers' ou 'following'
  final String title;

  const FollowersPage({
    Key? key,
    required this.userId,
    required this.type,
    required this.title,
  }) : super(key: key);

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _filteredUsers = List<String>.from(data[widget.type] ?? []);
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      // Réinitialiser la liste
      _loadUsers();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // D'abord, obtenir la liste complète des utilisateurs suivis/followers
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      
      final List<String> allUsers = List<String>.from(userDoc.data()?[widget.type] ?? []);
      
      // Ensuite, chercher les utilisateurs dont le pseudo correspond à la requête
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('pseudo', isGreaterThanOrEqualTo: query)
          .where('pseudo', isLessThan: query + 'z')
          .get();
      
      // Filtrer pour ne garder que ceux qui sont dans la liste des suivis/followers
      final List<String> filtered = [];
      for (var doc in querySnapshot.docs) {
        if (allUsers.contains(doc.id)) {
          filtered.add(doc.id);
        }
      }
      
      setState(() {
        _filteredUsers = filtered;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(color: Color(0xFF212121)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF212121)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
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
                onChanged: _searchUsers,
                style: const TextStyle(color: Color(0xFF212121)),
                cursorColor: Colors.blue[800],
                decoration: InputDecoration(
                  hintText: 'Rechercher un pseudo',
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _loadUsers();
                        },
                      )
                    : null,
                ),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - 200, // Hauteur ajustable
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun utilisateur trouvé',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(_filteredUsers[index])
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return ListTile(

              
                                );
                              }

                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const ListTile(
                                  title: Text('Utilisateur non trouvé'),
                                );
                              }

                              final userData = snapshot.data!.data() as Map<String, dynamic>;
                              final userId = snapshot.data!.id;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Avatar(
                                    userId: userId,
                                    radius: 20,
                                  ),
                                  title: Text(
                                    userData['pseudo'] ?? 'Utilisateur',
                                    style: const TextStyle(color: Color(0xFF212121)),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserPage(userId: userId),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
          ],
        ),
      ),
    );
  }
}