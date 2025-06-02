import 'package:flutter/material.dart';

class InfoHoverCard extends StatefulWidget {
  const InfoHoverCard({super.key});

  @override
  State<InfoHoverCard> createState() => _InfoHoverCardState();
}

class _InfoHoverCardState extends State<InfoHoverCard> with SingleTickerProviderStateMixin {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),

          // Animated popup card
          Positioned(
            top: -110,
            right: -10,
            child: AnimatedOpacity(
              opacity: _hovering ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: _hovering ? Offset.zero : const Offset(0, 0.1),
                child: MouseRegion( // Prevent early exit when hovering over card itself
                  onEnter: (_) => setState(() => _hovering = true),
                  onExit: (_) => setState(() => _hovering = false),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF1E1E2E), // Dark card background
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🔒 Password Visibility', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('• Tap to show briefly', style: TextStyle(color: Colors.white70)),
                          Text('• Right-click to show for 10s', style: TextStyle(color: Colors.white70)),
                          Text('• Auto-hides after 10s', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
