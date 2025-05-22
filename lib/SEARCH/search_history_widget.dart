import 'package:flutter/material.dart';
import '../USERS/user_page.dart';
import '../SEARCH/filtered_hashtag_page.dart';
import '../SEARCH/filtered_mentions_page.dart';
import '../COMPONENTS/avatar.dart';
import 'search_history_service.dart';

class SearchHistoryWidget extends StatelessWidget {
  const SearchHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
                child: ListTile(
                  leading: !itemName.startsWith('@') && !itemName.startsWith('#') ? Avatar(userId: data['itemId'], radius: 20) : Icon(icon, color: iconColor),
                  title: Text(itemName.replaceAll(RegExp(r'^[@#]'), ''), style: const TextStyle(color: Color(0xFF212121))),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      SearchHistoryService.deleteHistoryEntry(doc.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Historique supprimé')),
                        );
                      }
                    },
                  ),
                  onTap: () {
                    if (itemName.startsWith('@')) {
                      // C'est une mention
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilteredMentionsPage(
                            mention: itemName.substring(1),
                          ),
                        ),
                      );
                    } else if (itemName.startsWith('#')) {
                      // C'est un hashtag
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilteredHashtagPage(
                            hashtag: itemName.substring(1),
                          ),
                        ),
                      );
                    } else {
                      // C'est un profil
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserPage(
                            userId: data['itemId'],
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
