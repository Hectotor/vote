import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dernière mise à jour : 23 mai 2025',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bienvenue sur Vote !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'En accédant à notre application ou en l\'utilisant, vous acceptez les présentes Conditions d\'utilisation. Veuillez les lire attentivement.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: '1. Objet',
              content: 'Vote est une application de sondages visuels permettant à ses utilisateurs de créer, partager et voter sur des contenus communautaires.',
            ),
            _buildSection(
              title: '2. Accès et inscription',
              content: 'Vous devez avoir au moins 13 ans (ou l\'âge minimum légal dans votre pays) pour utiliser Vote.\nVous vous engagez à fournir des informations exactes lors de l\'inscription.\nVous êtes responsable de la sécurité de votre compte.',
            ),
            _buildSection(
              title: '3. Utilisation acceptable',
              content: 'Vous vous engagez à ne pas utiliser Vote pour :\n\n• publier des contenus violents, haineux, discriminatoires, sexuels ou illégaux\n• harceler ou menacer d\'autres utilisateurs\n• tricher dans les votes ou manipuler les résultats\n• créer des faux comptes ou usurper une identité\n• envoyer du spam ou de la publicité non autorisée\n\nVote se réserve le droit de suspendre ou supprimer tout compte ne respectant pas ces règles.',
            ),
            _buildSection(
              title: '4. Propriété intellectuelle',
              content: 'Vous conservez la propriété des contenus que vous publiez.\nEn publiant sur Vote, vous nous accordez une licence non exclusive, mondiale et gratuite pour afficher, distribuer et promouvoir vos contenus sur notre plateforme.\nVous ne devez pas publier de contenus dont vous n\'avez pas les droits (ex. : photos volées, vidéos sans autorisation, etc.).',
            ),
            _buildSection(
              title: '5. Modération',
              content: 'Nous nous réservons le droit de modérer, masquer ou supprimer tout contenu contraire aux présentes Conditions ou à nos Règles de la communauté.\nLes utilisateurs peuvent signaler un contenu via l\'application.',
            ),
            _buildSection(
              title: '6. Limitation de responsabilité',
              content: 'Vote ne garantit pas que l\'app fonctionnera sans erreur ou interruption.\nL\'utilisation de Vote se fait à vos risques et périls.\nNous ne sommes pas responsables des contenus publiés par les utilisateurs.',
            ),
            _buildSection(
              title: '7. Résiliation',
              content: 'Vous pouvez supprimer votre compte à tout moment.\nNous pouvons également suspendre ou supprimer un compte en cas de non-respect des présentes Conditions.',
            ),
            _buildSection(
              title: '8. Modifications',
              content: 'Ces Conditions peuvent être mises à jour. En continuant à utiliser Vote après une modification, vous acceptez les nouvelles conditions.',
            ),
            _buildSection(
              title: '9. Contact',
              content: 'Pour toute question, vous pouvez nous contacter à l\'adresse suivante :\n📧 contact@votelyapp.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
