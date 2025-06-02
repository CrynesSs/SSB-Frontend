import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qsb/globals.dart';

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

  String? _error;
  bool _isLoading = false;

  Uint8List? _publicKeyBytes;
  String? _publicKeyFileName;

  Future<String> _hashAndEncode(String input) async {
    final bytes = utf8.encode(input);
    final digest = await sha256Digest(bytes);
    return base64Encode(digest);
  }
  Future<Uint8List> sha256Digest(List<int> input) async {
    final digest = sha256.convert(input);
    return Uint8List.fromList(digest.bytes);
  }

  Future<void> _pickPublicKeyFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'pem', 'key'],withData: true);
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

    if (username.isEmpty || password.isEmpty || passphrase.isEmpty ||
        _publicKeyBytes == null) {
      setState(() {
        _error = "All fields are required.";
        _isLoading = false;
      });
      return;
    }

    final encodedUsername = await _hashAndEncode(username);
    final encodedPassword = await _hashAndEncode(password);
    final encodedPassphrase = await _hashAndEncode(passphrase);
    final publicKey = utf8.decode(_publicKeyBytes!);

    try {
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
      if(!mounted)return;
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
          _error = responseBody['message'] ?? "Signup failed.";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Network error: $e";
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
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    const Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: "Username"),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password"),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    TextFormField(
                      controller: _passphraseController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Passphrase"),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickPublicKeyFile,
                      icon: const Icon(Icons.upload_file),
                      label:Text(_publicKeyFileName ?? "Upload Public Key"),
                    ),
                    if (_publicKeyBytes != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text("✅ Public key file loaded", style: TextStyle(color: Colors.green)),
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
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
