/// Example usage file for AnimatedStatusBadge widgets
///
/// This file demonstrates different ways to use the status badge components
/// and is NOT meant to be imported - it's for reference only.
library;

import 'package:flutter/material.dart';
import 'animated_status_badge.dart';

/// EXAMPLE 1: Basic usage with default settings (RECOMMENDED)
/// This is the implementation currently used in main_page.dart
class BasicUsageExample extends StatelessWidget {
  const BasicUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedStatusBadge(
      isActive: true, // Agent is active
      child: Icon(Icons.person),
    );
  }
}

/// EXAMPLE 2: Custom offset positioning
/// Use this if you need to adjust the badge position
class CustomOffsetExample extends StatelessWidget {
  const CustomOffsetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedStatusBadge(
      isActive: true,
      offset: Offset(12, -12), // More corner positioning
      child: Icon(Icons.person),
    );
  }
}

/// EXAMPLE 3: Ring pulse effect (Alternative, more subtle)
/// Replace AnimatedStatusBadge with AnimatedStatusBadgeRing in main_page.dart
class RingEffectExample extends StatelessWidget {
  const RingEffectExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedStatusBadgeRing(
      isActive: true,
      child: Icon(Icons.person),
    );
  }
}

/// EXAMPLE 4: Inactive state
class InactiveStateExample extends StatelessWidget {
  const InactiveStateExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedStatusBadge(
      isActive: false, // Agent is inactive - shows red, no animation
      child: Icon(Icons.person),
    );
  }
}

/// EXAMPLE 5: In a different context (not BottomNavigationBar)
class AlternativeContextExample extends StatelessWidget {
  const AlternativeContextExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: AnimatedStatusBadge(
        isActive: true,
        offset: Offset(8, -8),
        child: CircleAvatar(
          child: Text('JD'),
        ),
      ),
      title: Text('John Doe'),
      subtitle: Text('Active Agent'),
    );
  }
}

/// COMPARISON WIDGET: Shows both variants side by side
/// Useful for testing and deciding which style to use
class ComparisonExample extends StatelessWidget {
  const ComparisonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            AnimatedStatusBadge(
              isActive: true,
              child: Icon(Icons.person, size: 40),
            ),
            SizedBox(height: 8),
            Text('Pulse Effect', style: TextStyle(fontSize: 12)),
          ],
        ),
        Column(
          children: [
            AnimatedStatusBadgeRing(
              isActive: true,
              child: Icon(Icons.person, size: 40),
            ),
            SizedBox(height: 8),
            Text('Ring Effect', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

/// IMPLEMENTATION NOTES:
///
/// To switch to the ring effect variant in main_page.dart:
///
/// Simply replace:
///   AnimatedStatusBadge(
///     isActive: isActive,
///     child: Icon(...),
///   )
///
/// With:
///   AnimatedStatusBadgeRing(
///     isActive: isActive,
///     child: Icon(...),
///   )
///
/// Both widgets have the same API and can be swapped without any other changes.
