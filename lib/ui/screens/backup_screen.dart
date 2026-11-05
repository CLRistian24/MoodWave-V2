import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import '../../models/mood_entry.dart';
import '../../providers/mood_provider.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _keyController = TextEditingController(text: "1234567890123456");
  final _dataController = TextEditingController();

  void _exportData(MoodProvider provider) {
    if (_keyController.text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La clave debe tener al menos 16 caracteres.")),
      );
      return;
    }
    final keyString = _keyController.text.padRight(16, '0').substring(0, 16);
    final key = encrypt_lib.Key.fromUtf8(keyString);
    final iv = encrypt_lib.IV.fromLength(16);
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));

    final rawJson = jsonEncode(provider.entries.map((e) => e.toMap()).toList());
    final encrypted = encrypter.encrypt(rawJson, iv: iv);

    setState(() {
      _dataController.text = encrypted.base64;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Respaldo cifrado generado en el cuadro de texto")),
    );
  }

  void _importData(MoodProvider provider) async {
    if (_dataController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pega el texto cifrado en el campo de texto.")),
      );
      return;
    }
    try {
      final keyString = _keyController.text.padRight(16, '0').substring(0, 16);
      final key = encrypt_lib.Key.fromUtf8(keyString);
      final iv = encrypt_lib.IV.fromLength(16);
      final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));

      final decryptedJson = encrypter.decrypt64(_dataController.text.trim(), iv: iv);
      final List<dynamic> listMap = jsonDecode(decryptedJson);

      for (var item in listMap) {
        final entry = MoodEntry.fromMap(Map<String, dynamic>.from(item));
        await provider.saveEntry(entry);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Datos descifrados e importados correctamente!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al descifrar: Clave incorrecta o formato inválido.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Respaldo Cifrado (AES-256)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: "Clave de cifrado / descifrado (16 caracteres)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lock),
                    onPressed: () => _exportData(provider),
                    label: const Text("EXPORTAR / CIFRAR"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    icon: const Icon(Icons.lock_open),
                    onPressed: () => _importData(provider),
                    label: const Text("IMPORTAR / DESCIFRAR"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _dataController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: "Datos Cifrados (Base64)",
                hintText: "Pega aquí un texto cifrado para restaurarlo o exporta para ver la salida...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}