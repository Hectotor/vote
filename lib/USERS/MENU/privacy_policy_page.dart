import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔐 Politique de confidentialité – Vote',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dernière mise à jour : 23 mai 2025',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: '1. 📲 Quelles données sont collectées ?',
              content: '''
Lorsque vous utilisez Vote, nous pouvons collecter les données suivantes :

• Données que vous fournissez :
  - Pseudo, email, sexe, date de naissance
  - Images, textes et votes que vous publiez
  - Messages ou signalements envoyés à notre support

• Données collectées automatiquement :
  - Identifiant de l'appareil
  - Adresse IP
  - Langue et pays
  - Données d'usage (ex. : temps passé sur l'app, interactions)
''',
            ),
            _buildSection(
              title: '2. 🛠️ À quoi servent ces données ?',
              content: '''
Nous utilisons vos données pour :

• Créer et gérer votre compte
• Améliorer l'expérience utilisateur
• Afficher des contenus pertinents
• Lutter contre les abus ou comportements interdits
• Vous contacter en cas de besoin (par ex. support ou mises à jour)
''',
            ),
            _buildSection(
              title: '3. 📤 Partage des données',
              content: '''
Nous ne vendons jamais vos données.
Certaines données peuvent être partagées avec :

• Des prestataires techniques (hébergement, email, analytics)
• Des autorités, en cas d'obligation légale
''',
            ),
            _buildSection(
              title: '4. 🌍 Où sont stockées vos données ?',
              content: '''
Les données sont hébergées de manière sécurisée, principalement via Firebase (Google).
Nous faisons tout pour garantir leur sécurité.
''',
            ),
            _buildSection(
              title: '5. ⏱️ Combien de temps sont-elles conservées ?',
              content: '''
Nous conservons vos données :

• Tant que votre compte est actif
• Et jusqu'à 12 mois après suppression du compte (pour raisons de sécurité ou de litiges potentiels)
''',
            ),
            _buildSection(
              title: '6. 👤 Vos droits',
              content: '''
Conformément au RGPD, vous avez :

• Le droit d'accéder à vos données
• Le droit de les corriger ou de les supprimer
• Le droit de retirer votre consentement
• Le droit de demander la portabilité

Vous pouvez exercer vos droits en nous contactant :
📧 contact@Votelyapp.com
''',
            ),
            _buildSection(
              title: '7. 🍪 Cookies et suivi',
              content: '''
Nous utilisons des outils comme Firebase Analytics pour comprendre comment l'app est utilisée.
Ces outils utilisent des identifiants anonymes, pas des cookies web classiques.
''',
            ),
            _buildSection(
              title: '8. 🔁 Modifications',
              content: '''
Nous pouvons mettre à jour cette politique à tout moment.
Les modifications importantes seront annoncées via l'app.
''',
            ),
            _buildSection(
              title: '9. 📮 Contact',
              content: '''
Si vous avez une question sur cette politique ou sur vos données :
📧 contact@Votelyapp.com
🌐 www.Votelyapp.com/confidentialite
''',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
