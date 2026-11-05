import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';

class PinChangeScreen extends StatefulWidget {
  const PinChangeScreen({super.key});

  @override
  State<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends State<PinChangeScreen> {
  final _pinController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _savePin(MoodProvider provider) {
    if (_pinController.text.length != 4) {
      setState(() {
        _errorText = "El PIN debe tener exactamente 4 dígitos";
      });
      return;
    }
    provider.setPin(_pinController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PIN guardado correctamente")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Configurar PIN")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Ingrese PIN de 4 dígitos",
                border: const OutlineInputBorder(),
                errorText: _errorText,
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () => _savePin(provider),
              child: const Text("GUARDAR"),
            ),
            if (provider.pin != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  provider.clearPin();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PIN eliminado")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("QUITAR PIN", style: TextStyle(color: Colors.red)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}