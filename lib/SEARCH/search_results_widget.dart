import 'package:flutter/material.dart';
import '../USERS/user_page.dart';
import 'filtered_hashtag_page.dart';
import 'filtered_mentions_page.dart';
import '../COMPONENTS/avatar.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final bool isSearching;

  const SearchResultsWidget({
    super.key,
    required this.results,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSearching) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 200,
      ),
      child: results.isEmpty
          ? const Center(
              child: Text('Aucun résultat trouvé'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                final type = result['type'];
                final data = result['data'];

                switch (type) {
                  case 'profile':
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Avatar(
                          userId: data['userId'],
                          radius: 20,
                        ),
                        title: Text(
                          data['pseudo'] ?? 'Utilisateur',
                          style: const TextStyle(color: Color(0xFF212121)),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserPage(userId: data['userId']),
                            ),
                          );
                        },
                      ),
                    );

                  case 'hashtag':
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.tag, color: Colors.purple),
                        title: Text(
                          '#${data['name']}',
                          style: const TextStyle(color: Color(0xFF212121)),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilteredHashtagPage(
                                hashtag: data['name'],
                              ),
                            ),
                          );
                        },
                      ),
                    );

                  case 'mention':
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.alternate_email, color: Colors.green),
                        title: Text(
                          '@${data['name']}',
                          style: const TextStyle(color: Color(0xFF212121)),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilteredMentionsPage(
                                mention: data['name'],
                              ),
                            ),
                          );
                        },
                      ),
                    );

                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
    );
  }
}
