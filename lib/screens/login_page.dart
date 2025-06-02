import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qsb/globals.dart';

import '../ui_elements/info_hover_card.dart';
import '../util.dart';

class LoginScreen extends StatefulWidget {
  final Function() login;

  const LoginScreen({super.key, required this.login});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();

  bool showPasswordPasswordField = false;
  bool showPasswordPassphraseField = false;

  String? _error;
  bool _isLoading = false;

  Uint8List? _publicKeyBytes;
  String? _publicKeyFileName;


  Future<Uint8List> sha256Digest(List<int> input) async {
    final digest = sha256.convert(input);
    return Uint8List.fromList(digest.bytes);
  }

  Future<void> _pickPublicKeyFile() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pem', 'key'],
        withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _publicKeyBytes = result.files.single.bytes!;
        _publicKeyFileName = result.files.single.name;
      });
    }
  }

  Future<void> _login() async {
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

    final publicKey = utf8.decode(_publicKeyBytes!);

    final salts = await http.post(Uri.parse("$serverAddress/login/salts"), headers: {"Content-Type": "application/json"}, body: jsonEncode({
      "public_key": publicKey,
    }),);
    if(salts.statusCode == 200){
      try {
        final Map<String,dynamic> data = jsonDecode(salts.body);
        final usernameSalt = data["username_salt"];
        final passwordSalt = data["password_salt"];
        final passphraseSalt = data["passphrase_salt"];

        final encodedUsername = hashWithSalt(username, usernameSalt);
        final encodedPassword = hashWithSalt(password, passwordSalt);
        final encodedPassphrase = hashWithSalt(passphrase, passphraseSalt);

        final response = await http.post(
          Uri.parse("$serverAddress/login/"),
          // change if needed
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "username": encodedUsername,
            "password": encodedPassword,
            "passphrase": encodedPassphrase,
            "public_key": publicKey,
          }),
        );
        if (!mounted) return;
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully Logged in")),
          );
          sessionCookie = response.headers['set-cookie']!.split(';').first;
          isLoggedIn = true;
          widget.login();
        } else {
          final responseBody = jsonDecode(response.body);
          setState(() {
            _error = responseBody['message'] ?? "Login Failed.";
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _error = "Network error: $e";
        });
      }
    }

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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passphraseController.dispose();
    super.dispose();
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
                        const Text("Login",
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
                                        : Icons.visibility_off)),
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
                                    onPressed: () {},
                                    icon: Icon(showPasswordPassphraseField
                                        ? Icons.visibility
                                        : Icons.visibility_off)),
                              )),
                          validator: (value) =>
                              value!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _pickPublicKeyFile,
                          icon: const Icon(Icons.upload_file),
                          label:
                              Text(_publicKeyFileName ?? "Upload Public Key"),
                        ),
                        if (_publicKeyBytes != null)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text("✅ Public key file loaded",
                                style: TextStyle(color: Colors.green)),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Login"),
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
