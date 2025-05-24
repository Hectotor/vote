import 'package:flutter/material.dart';

class CommunityRulesPage extends StatelessWidget {
  const CommunityRulesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Règles de la communauté'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenue sur Vote 👋',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Text(
              'Ici, chacun peut donner son avis, mais toujours dans le respect.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            
            // Section Positive
            const Text(
              '✅ Ce qu’on aime :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildRuleItem('Les débats d\'idées 🔥'),
            _buildRuleItem('Le respect des autres ✌️'),
            _buildRuleItem('La créativité et l\'humour 🎨😂'),
            const SizedBox(height: 32),
            
            // Section Negative
            const Text(
              '🚫 Ce qu’on ne tolère pas :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            _buildRuleItem('La haine, les insultes ou le harcèlement 🙅‍♂️'),
            _buildRuleItem('Les contenus choquants, violents ou sexuels ❌'),
            _buildRuleItem('Le spam, les faux comptes ou les triches 🛑'),
            const SizedBox(height: 32),
            
            // Section Modération
            const Text(
              '🛠️ Modération :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'On peut retirer un post, suspendre un compte ou intervenir à tout moment si une règle est cassée. Tu peux aussi signaler un contenu en 1 clic 👀',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            
            // Section Acceptation
            const Text(
              '📣 En utilisant Vote, tu acceptes ces règles.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Text(
              'Merci de garder cet espace cool et safe 💙',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            
            // Section Lien
            const Text(
              '🔗 Pour plus de détails, consulte nos Conditions d\'utilisation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black45),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
