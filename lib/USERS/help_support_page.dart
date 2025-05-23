import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  void _showContactInfo(BuildContext context, String title, String info) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $info'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide et support'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Section FAQ
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Foire aux questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildFaqItem(
            context,
            'Comment créer un sondage ?',
            'Pour créer un sondage, appuyez sur le bouton + en bas de l\'écran. '
            'Ajoutez ensuite au moins 2 images et du texte pour chaque option. '
            'Vous pouvez ajouter jusqu\'à 4 options au total.',
          ),
          _buildFaqItem(
            context,
            'Comment modifier mon profil ?',
            'Accédez à votre profil en appuyant sur l\'icône de profil dans la barre de navigation. '
            'Appuyez ensuite sur le bouton de menu (trois points) et sélectionnez "Modifier le profil".',
          ),
          _buildFaqItem(
            context,
            'Comment supprimer un sondage ?',
            'Accédez au sondage que vous souhaitez supprimer, appuyez sur les trois points '
            'en haut à droite du sondage et sélectionnez "Supprimer".',
          ),
          _buildFaqItem(
            context,
            'Puis-je modifier un sondage après l\'avoir publié ?',
            'Non, une fois qu\'un sondage est publié, il ne peut plus être modifié pour '
            'garantir l\'intégrité des votes.',
          ),

          const Divider(height: 32),

          // Section Contact
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Nous contacter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: const Text('support@toplyke.com'),
            onTap: () => _showContactInfo(context, 'Email', 'support@toplyke.com'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Site web'),
            subtitle: const Text('www.toplyke.com/support'),
            onTap: () => _showContactInfo(context, 'Site web', 'www.toplyke.com/support'),
          ),

          const Divider(height: 32),

          // Section Conditions d'utilisation et Politique de confidentialité
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Informations légales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Conditions d\'utilisation'),
            onTap: () => _showContactInfo(context, 'Conditions', 'www.toplyke.com/terms'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Politique de confidentialité'),
            onTap: () => _showContactInfo(context, 'Confidentialité', 'www.toplyke.com/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Règles de la communauté'),
            onTap: () => _showContactInfo(context, 'Règles', 'www.toplyke.com/community-guidelines'),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Version de l\'application: 1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}
