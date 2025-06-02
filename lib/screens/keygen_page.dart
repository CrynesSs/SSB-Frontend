import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart'
    show
        RSAPrivateKey,
        RSAPublicKey,
        RSAKeyGenerator,
        RSAKeyGeneratorParameters,
        SecureRandom,
        KeyParameter,
        ParametersWithRandom;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';

import 'dart:math';

class KeygenScreen extends StatefulWidget {
  const KeygenScreen({super.key});

  @override
  State<KeygenScreen> createState() => _KeygenScreenState();
}

class _KeygenScreenState extends State<KeygenScreen> {
  String? _privateKey;
  String? _publicKey;
  bool _isGenerating = false;
  int _keySize = 2048;

  final ScrollController _privateKeyScrollController = ScrollController();
  final ScrollController _publicKeyScrollController =
      ScrollController(); // optional for public key

  final List<int> _keySizes = [2048, 4096, 8192];

  void _generateKeys() async {
    setState(() {
      _isGenerating = true;
      _privateKey = null;
      _publicKey = null;
    });

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.from(65537), _keySize, 64),
        _secureRandom(),
      ));

    final pair = keyGen.generateKeyPair();
    final privateKey = pair.privateKey;
    final publicKey = pair.publicKey;

    setState(() {
      _privateKey = _encodePrivateKeyToPem(privateKey);
      _publicKey = _encodePublicKeyToPem(publicKey);
      _isGenerating = false;
    });
  }

  SecureRandom _secureRandom() {
    final secureRandom = FortunaRandom();
    final seed = Uint8List.fromList(
        List<int>.generate(32, (i) => Random.secure().nextInt(256)));
    secureRandom.seed(KeyParameter(seed));
    return secureRandom;
  }

  String _encodePrivateKeyToPem(RSAPrivateKey key) {
    final encoded = base64Encode(_bigIntToBytes(key.privateExponent!));
    return '''-----BEGIN PRIVATE KEY-----\n$encoded\n-----END PRIVATE KEY-----''';
  }

  String _encodePublicKeyToPem(RSAPublicKey key) {
    final encoded = base64Encode(_bigIntToBytes(key.modulus!));
    return '''-----BEGIN PUBLIC KEY-----\n$encoded\n-----END PUBLIC KEY-----''';
  }

  Uint8List _bigIntToBytes(BigInt number) {
    final hex = number.toRadixString(16);
    final normalized = hex.length % 2 == 1 ? "0$hex" : hex;
    return Uint8List.fromList([
      for (var i = 0; i < normalized.length; i += 2)
        int.parse(normalized.substring(i, i + 2), radix: 16),
    ]);
  }

  Future<void> _saveKey(String content, String filename) async {
    await FileSaver.instance.saveFile(
      name: filename,
      bytes: Uint8List.fromList(utf8.encode(content)),
      ext: "pem",
      mimeType: MimeType.text,
    );
  }

  @override
  void dispose() {
    _privateKeyScrollController.dispose();
    _publicKeyScrollController.dispose(); // if used
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Generate RSA Key Pair",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _keySize,
                  decoration:
                      const InputDecoration(labelText: "Select Key Size"),
                  items: _keySizes
                      .map((size) => DropdownMenuItem(
                            value: size,
                            child: Text("$size-bit"),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _keySize = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.vpn_key),
                  label: _isGenerating
                      ? const Text("Generating...")
                      : const Text("Generate Keys"),
                  onPressed: _isGenerating ? null : _generateKeys,
                ),
                const SizedBox(height: 24),
                if (_privateKey != null) ...[
                  const Text("Private Key",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: Scrollbar(
                        controller: _privateKeyScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _privateKeyScrollController,
                          physics: const ClampingScrollPhysics(),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                  widthFactor: 0.95,
                                  child: SelectableText(_privateKey!))),
                        )),
                  ),
                  const SizedBox(height: 8,),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Download Private Key"),
                    onPressed: () => _saveKey(_privateKey!, "private_key"),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_publicKey != null) ...[
                  const Text("Public Key",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: Scrollbar(
                        controller: _publicKeyScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                            controller: _publicKeyScrollController,
                            child: Align(alignment: Alignment.centerLeft,child: FractionallySizedBox(widthFactor: 0.95,child: SelectableText(_publicKey!))))),
                  ),
                  const SizedBox(height: 8,),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Download Public Key"),
                    onPressed: () => _saveKey(_publicKey!, "public_key"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
