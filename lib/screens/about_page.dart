import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('About'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Card(
          elevation: 8,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.blueGrey.shade700
                        : Colors.blueGrey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_outline,
                      size: 96,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Secure Data with Public-Private Key Encryption",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FractionallySizedBox(
                  widthFactor: 0.2,
                  child: Text(
                    "Our app uses advanced public-private key encryption to protect your sensitive information. "
                    "When you create a key pair, your private key remains securely on your device, "
                    "while the public key is used to safely encrypt data sent to you. "
                    "This means only you can decrypt and access your data, ensuring maximum privacy and security.\n\n"
                    "This method prevents unauthorized access, even if the data is intercepted, "
                    "because the private key needed to unlock the information never leaves your device. "
                    "Trust in cryptographic security built into our platform.",
                    style:
                        TextStyle(fontSize: 16, height: 1.5, color: textColor),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
