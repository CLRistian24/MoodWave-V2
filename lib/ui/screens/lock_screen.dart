import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _input = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Fonn",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "INTRODUCE TU PIN",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _input.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                String label = "";
                if (index < 9) label = "${index + 1}";
                if (index == 10) label = "0";
                if (index == 11) label = "⌫";

                if (label.isEmpty) return const SizedBox();

                return InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    setState(() {
                      if (label == "⌫") {
                        if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
                      } else if (_input.length < 4) {
                        _input += label;
                        if (_input.length == 4) {
                          if (provider.pin == null || _input == provider.pin) {
                            provider.setUnlocked(true);
                          } else {
                            _input = '';
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("PIN Incorrecto")),
                            );
                          }
                        }
                      }
                    });
                  },
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}