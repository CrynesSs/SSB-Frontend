import 'dart:math';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome to SecureShareBox",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                "Your secure storage and identity solution",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              const Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  FeatureCard(
                    title: "Login",
                    description: "Access your account securely using your credentials and public key.",
                  ),
                  FeatureCard(
                    title: "Signup",
                    description: "Create a new secure account by uploading your public key.",
                  ),
                  FeatureCard(
                    title: "Keygen",
                    description: "Generate RSA key pairs locally for secure authentication.",
                  ),
                  FeatureCard(
                    title: "About",
                    description: "Learn more about how SecureShareBox protects your data and identity.",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _iconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'login':
        return Icons.login;
      case 'signup':
        return Icons.app_registration;
      case 'keygen':
        return Icons.vpn_key;
      case 'about':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _toggleCard,
      child: SizedBox(
        width: 160,
        height: 200,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final angle = _controller.value * pi;
            final isFrontVisible = angle <= (pi / 2);

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(angle),
              child: isFrontVisible
                  ? _buildFrontCard(theme, isDark)
                  : Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: _buildBackCard(theme, isDark),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontCard(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: isDark ? Colors.black54 : Colors.black12,
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_iconForTitle(widget.title), size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text("Tap to flip", style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildBackCard(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.indigo[700] : Colors.indigo[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: isDark ? Colors.black54 : Colors.black12,
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          widget.description,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
