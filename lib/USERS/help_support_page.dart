import 'package:flutter/material.dart';
import 'community_rules_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  void _showContactInfo(BuildContext context, String title, String info) {
    if (title == 'Règles') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CommunityRulesPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title : $info'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide et support'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          _sectionTitle('Foire aux questions'),
          _buildFaqItem(
            context,
            'Comment créer un sondage ?',
            'Appuie sur le bouton + en bas de l\'écran. Ajoute ensuite 2 à 4 images avec du texte pour chaque option.',
          ),
          _buildFaqItem(
            context,
            'Comment modifier mon profil ?',
            'Va sur ton profil, appuie sur les trois points en haut à droite puis sélectionne "Modifier le profil".',
          ),
          _buildFaqItem(
            context,
            'Comment supprimer un sondage ?',
            'Ouvre ton sondage, appuie sur les trois points en haut, puis sélectionne "Supprimer".',
          ),
          _buildFaqItem(
            context,
            'Puis-je modifier un sondage après publication ?',
            'Non, cela permet de garantir l\'intégrité des votes.',
          ),

          const SizedBox(height: 24),
          _sectionTitle('Nous contacter'),
          _buildContactTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@votelyapp.com',
            onTap: () => _showContactInfo(context, 'Email', 'support@votelyapp.com'),
          ),
          _buildContactTile(
            icon: Icons.language_outlined,
            title: 'Site web',
            subtitle: 'www.votelyapp.com/support',
            onTap: () => _showContactInfo(context, 'Site web', 'www.votelyapp.com/support'),
          ),

          const SizedBox(height: 24),
          _sectionTitle('Informations légales'),
          _buildContactTile(
            icon: Icons.description_outlined,
            title: 'Conditions d\'utilisation',
            onTap: () => _showContactInfo(context, 'Conditions', 'www.votelyapp.com/terms'),
          ),
          _buildContactTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            onTap: () => _showContactInfo(context, 'Confidentialité', 'www.votelyapp.com/privacy'),
          ),
          _buildContactTile(
            icon: Icons.gavel_outlined,
            title: 'Règles de la communauté',
            onTap: () => _showContactInfo(context, 'Règles', ''),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Version de l\'application : 1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Text(answer, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
