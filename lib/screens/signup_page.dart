import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qsb/enums/e_pages.dart';
import 'package:qsb/ui_elements/info_hover_card.dart';

import '../util.dart';

class SignupScreen extends StatefulWidget {
  final Function(EPages page) switchPage;
  const SignupScreen({super.key, required this.switchPage});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();

  bool showPasswordPasswordField = false;
  bool showPasswordPassphraseField = false;

  Uint8List? _publicKeyBytes;
  String? _publicKeyFileName;

  bool _isLoading = false;
  String? _error;

  Future<void> _pickPublicKeyFile() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['txt', 'pem', 'key'],withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _publicKeyBytes = result.files.single.bytes!;
        _publicKeyFileName = result.files.single.name;
      });
    }
  }
// Helper function to generate salt (random bytes)


  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final passphrase = _passphraseController.text.trim();

    if (username.isEmpty ||
        password.isEmpty ||
        passphrase.isEmpty ||
        _publicKeyBytes == null) {
      setState(() {
        _error = "All fields are required.";
        _isLoading = false;
      });
      return;
    }

    final usernameSalt = generateSalt();
    final passwordSalt = generateSalt();
    final passphraseSalt = generateSalt();

    final encodedUsername = hashWithSalt(username, usernameSalt);
    final encodedPassword = hashWithSalt(password, passwordSalt);
    final encodedPassphrase = hashWithSalt(passphrase, passphraseSalt);


    final publicKey = utf8.decode(_publicKeyBytes!);

    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/accounts/create_account"),
        // change if needed
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": encodedUsername,
          "password": encodedPassword,
          "passphrase": encodedPassphrase,
          "public_key": publicKey,
          "username_salt" : usernameSalt,
          "password_salt" : passwordSalt,
          "passphrase_salt" : passphraseSalt
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created. Please log in.")),
        );
        widget.switchPage(EPages.login);
      } else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _error = responseBody['message'] ?? "Signup failed.";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Network error: $e";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Timer? _hideTimerPassword;

  void handlePressPassword(bool shouldShowPassword) {
    setState(() {
      showPasswordPasswordField = shouldShowPassword;
    });
  }

  void togglePressPassword(bool shouldShowPassword) {
    setState(() {
      showPasswordPasswordField = shouldShowPassword;
    });
    if (showPasswordPasswordField) {
      _hideTimerPassword?.cancel();
      _hideTimerPassword = Timer(const Duration(seconds: 10), () {
        if (showPasswordPasswordField) {
          handlePressPassword(false);
        }
      });
    }
  }

  Timer? _hideTimerPassphrase;

  void handlePressPassphrase(bool shouldShowPassword) {
    setState(() {
      showPasswordPassphraseField = shouldShowPassword;
    });
  }

  void togglePressPassphrase(bool shouldShowPassword) {
    setState(() {
      showPasswordPassphraseField = shouldShowPassword;
    });
    if (showPasswordPassphraseField) {
      _hideTimerPassphrase?.cancel();
      _hideTimerPassphrase = Timer(const Duration(seconds: 10), () {
        if (showPasswordPassphraseField) {
          handlePressPassphrase(false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Signup",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          decoration:
                              const InputDecoration(labelText: "Username"),
                          validator: (value) =>
                              value!.isEmpty ? "Required" : null,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !showPasswordPasswordField,
                          decoration: InputDecoration(
                              labelText: "Password",
                              suffixIcon: GestureDetector(
                                onTapDown: (_) => handlePressPassword(true),
                                onTapUp: (_) => handlePressPassword(false),
                                onTapCancel: () => handlePressPassword(false),
                                onSecondaryTapDown: (_) => togglePressPassword(
                                    !showPasswordPasswordField),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(showPasswordPasswordField
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                              )),
                          validator: (value) =>
                              value!.isEmpty ? "Required" : null,
                        ),
                        TextFormField(
                          controller: _passphraseController,
                          obscureText: !showPasswordPassphraseField,
                          decoration: InputDecoration(
                              labelText: "Passphrase",
                              suffixIcon: GestureDetector(
                                onTapDown: (_) => handlePressPassphrase(true),
                                onTapUp: (_) => handlePressPassphrase(false),
                                onTapCancel: () => handlePressPassphrase(false),
                                onSecondaryTapDown: (_) =>
                                    togglePressPassphrase(
                                        !showPasswordPassphraseField),
                                child: IconButton(
                                    onPressed: () => {},
                                    icon: Icon(showPasswordPassphraseField
                                        ? Icons.visibility
                                        : Icons.visibility_off)),
                              )),
                          validator: (value) =>
                              value!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label:
                              Text(_publicKeyFileName ?? "Upload Public Key"),
                          onPressed: _pickPublicKeyFile,
                        ),
                        if (_publicKeyBytes != null)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text("✅ Public key file loaded",
                                style: TextStyle(color: Colors.green)),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Create Account"),
                        ),
                        const SizedBox(height: 10),
                        if (_error != null)
                          Text(_error!,
                              style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
                top: 0,
                right: 20,
                child: Padding(
                    padding: EdgeInsets.all(16), child: InfoHoverCard())),
          ],
        ),
      ),
    );
  }
}
