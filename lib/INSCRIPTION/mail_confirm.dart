import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailConfirmationService {
  // Méthode pour générer un code de vérification
  static String generateVerificationCode() {
    return List.generate(6, (_) => (Random().nextInt(9) + 1).toString()).join();
  }

  static Future<void> sendConfirmationEmail(String email, String verificationCode) async {
    // Récupérer les paramètres SMTP depuis admin/smtpSettings
    final adminDoc = await FirebaseFirestore.instance
        .collection('admin')
        .doc('smtpSettings')
        .get();

    if (!adminDoc.exists) {
      throw Exception('Configuration SMTP non trouvée');
    }

    final smtpData = adminDoc.data() ?? {};
    final smtpEmail = smtpData['smtpEmail'] ?? '';
    final smtpPassword = smtpData['smtpPassword'] ?? '';
    final smtpServer = smtpData['smtpServer'] ?? '';
    final smtpPort = smtpData['smtpPort'] ?? 465;

    if (smtpEmail.isEmpty || smtpPassword.isEmpty || smtpServer.isEmpty) {
      throw Exception('Configuration SMTP incomplète');
    }

    final server = SmtpServer(
      smtpServer,
      port: smtpPort,
      username: smtpEmail,
      password: smtpPassword,
      ssl: true,
    );

    print('Tentative d\'envoi depuis $smtpEmail via $smtpServer:$smtpPort');
    print('Configuration SMTP : $smtpEmail, $smtpServer:$smtpPort');
    final message = Message()
      ..from = Address(smtpEmail, 'TopLyke')
      ..recipients.add(email)
      ..subject = '📨 Votre code de vérification Toplyke'
      ..text = 'Votre code de vérification est : $verificationCode'
      ..html = '''
        <html>
          <body style="font-family: Arial, sans-serif; background-color: #f9f9f9; padding: 20px; max-width: 600px; margin: 0 auto; border-radius: 8px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);">
            <h2 style="color: #3C507F;">👋 Confirmation de votre adresse e-mail</h2>
            <p style="font-size: 18px;">Nous vous avons envoyé ce code pour vérifier votre adresse e-mail :</p>
            <p style="text-align: center; margin: 20px 0; font-size: 48px; font-weight: bold; color: #333; padding: 10px; border: 2px solid #3C507F; border-radius: 5px;"><strong><span style="font-size: 64px;">$verificationCode</span></strong></p>
            <p style="font-size: 16px;">Entrez ce code pour activer votre compte ! 🔓</p>
          </body>
        </html>
      ''';

    try {
      await send(message, server);
      print('Email envoyé avec succès à $email');
    } catch (e) {
      print('Erreur lors de l\'envoi de l\'e-mail : $e');
    }
  }

  static Future<void> newGenerateVerificationCode(String email) async {
    String verificationCode = generateVerificationCode();

    try {
      // Mettre à jour Firestore avec le nouveau code
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'verificationCode': verificationCode,
          });
        }
      });

      // Envoyer l'email avec le nouveau code
      await sendConfirmationEmail(email, verificationCode);
    } catch (e) {
      print('Erreur lors de la génération ou de l\'envoi du code : $e');
    }
  }
}