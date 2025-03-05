import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailConfirmationService {
  static Future<bool> sendVerificationEmail({
    required BuildContext context,
    required String email,
    required String verificationCode,
  }) async {
    try {
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
      final message = Message()
        ..from = Address(smtpEmail, 'TopLyke')
        ..recipients.add(email)
        ..subject = '🔐 Votre code de vérification Toplyke'
        ..text = 'Votre code de vérification est : $verificationCode'
        ..html = '''
          <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
              <h2>🎉 Bienvenue dans l'univers de Toplyke !</h2>
              <p>Votre code de vérification est : <strong>$verificationCode</strong></p>
              <p style="text-align: center; margin-top: 20px; margin-bottom: 20px;"><strong>$verificationCode</strong></p>
              <p>Utilisez-le pour débloquer votre compte et commencer l'aventure avec nous ! 🚀</p>
              <p>Attention, ce code est comme un super-héros : il expire dans 15 minutes ! ⏳</p>
            </body>
          </html>
        ''';

      try {
        final sendReport = await send(message, server);
        print('Email envoyé: ${sendReport.toString()}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email de vérification envoyé'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } catch (error) {
        print('Erreur lors de l\'envoi de l\'email : $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'envoyer l\'email de vérification'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (error) {
      // Gérer les erreurs de configuration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de configuration : $error'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  // Méthode pour générer un code de vérification
  static String generateVerificationCode() {
    return List.generate(6, (_) => (Random().nextInt(9) + 1).toString()).join();
  }
}
