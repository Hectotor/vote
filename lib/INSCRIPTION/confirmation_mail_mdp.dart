import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/navBar.dart';
import 'mail_confirm.dart'; // Assurez-vous que le chemin est correct

class ConfirmationMailMdpPage extends StatefulWidget {
  final String email;
  final String verificationCode;

  ConfirmationMailMdpPage({
    Key? key,
    required this.email,
    required this.verificationCode,
  }) : super(key: key);

  @override
  _ConfirmationMailMdpPageState createState() => _ConfirmationMailMdpPageState();
}

class _ConfirmationMailMdpPageState extends State<ConfirmationMailMdpPage> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  String? _errorMessage;
  bool _isLoading = false;

  void _verifyCode() async {
    // Implémentez la logique de vérification du code ici
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF151019),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Entrez le code de vérification',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _codeControllers[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                  ),
                );
              }),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Vérifier'),
            ),
          ],
        ),
      ),
    );
  }
}
