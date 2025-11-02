import 'package:flutter/material.dart';

/// Customer UI Model
///
/// Represents a customer in the UI layer. This is a simplified model
/// for UI rendering purposes only. The actual domain model will be
/// created when implementing the business logic layer.
class CustomerUIModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String segment;
  final String purchaseIntention;
  final String? preAssignedAgent;
  final DateTime dateCreated;
  final DateTime? lastInteraction;

  const CustomerUIModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.segment,
    required this.purchaseIntention,
    this.preAssignedAgent,
    required this.dateCreated,
    this.lastInteraction,
  });

  /// Get the first letter of the name for avatar
  String get avatarInitial {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Get color for segment badge
  Color get segmentColor {
    switch (segment.toLowerCase()) {
      case 'vip':
        return const Color(0xFF9333EA); // Purple
      case 'premium':
        return const Color(0xFF0EA5E9); // Blue
      case 'standard':
        return const Color(0xFF16A34A); // Green
      case 'basic':
        return const Color(0xFF64748B); // Gray
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Get color for purchase intention badge
  Color get purchaseIntentionColor {
    switch (purchaseIntention.toLowerCase()) {
      case 'high':
        return const Color(0xFF16A34A); // Green
      case 'medium':
        return const Color(0xFFE2A03F); // Yellow/Orange
      case 'low':
        return const Color(0xFFE7515A); // Red
      default:
        return const Color(0xFF64748B); // Gray
    }
  }

  /// Mock data for development
  static List<CustomerUIModel> getMockCustomers() {
    return [
      CustomerUIModel(
        id: '1',
        name: 'Ana García',
        email: 'ana.garcia@example.com',
        phone: '+34 612 345 678',
        segment: 'VIP',
        purchaseIntention: 'High',
        preAssignedAgent: 'Juan Pérez',
        dateCreated: DateTime.now().subtract(const Duration(days: 30)),
        lastInteraction: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CustomerUIModel(
        id: '2',
        name: 'Carlos Rodríguez',
        email: 'carlos.rodriguez@example.com',
        phone: '+34 623 456 789',
        segment: 'Premium',
        purchaseIntention: 'Medium',
        preAssignedAgent: 'María López',
        dateCreated: DateTime.now().subtract(const Duration(days: 15)),
        lastInteraction: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CustomerUIModel(
        id: '3',
        name: 'Isabel Martínez',
        email: 'isabel.martinez@example.com',
        phone: '+34 634 567 890',
        segment: 'Standard',
        purchaseIntention: 'Low',
        preAssignedAgent: null,
        dateCreated: DateTime.now().subtract(const Duration(days: 7)),
        lastInteraction: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CustomerUIModel(
        id: '4',
        name: 'David Fernández',
        email: 'david.fernandez@example.com',
        phone: '+34 645 678 901',
        segment: 'VIP',
        purchaseIntention: 'High',
        preAssignedAgent: 'Juan Pérez',
        dateCreated: DateTime.now().subtract(const Duration(days: 45)),
        lastInteraction: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CustomerUIModel(
        id: '5',
        name: 'Laura Sánchez',
        email: 'laura.sanchez@example.com',
        phone: '+34 656 789 012',
        segment: 'Basic',
        purchaseIntention: 'Medium',
        preAssignedAgent: null,
        dateCreated: DateTime.now().subtract(const Duration(days: 3)),
        lastInteraction: null,
      ),
      CustomerUIModel(
        id: '6',
        name: 'Miguel Torres',
        email: 'miguel.torres@example.com',
        phone: '+34 667 890 123',
        segment: 'Premium',
        purchaseIntention: 'High',
        preAssignedAgent: 'María López',
        dateCreated: DateTime.now().subtract(const Duration(days: 60)),
        lastInteraction: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CustomerUIModel(
        id: '7',
        name: 'Carmen Ruiz',
        email: 'carmen.ruiz@example.com',
        phone: '+34 678 901 234',
        segment: 'Standard',
        purchaseIntention: 'Low',
        preAssignedAgent: 'Juan Pérez',
        dateCreated: DateTime.now().subtract(const Duration(days: 20)),
        lastInteraction: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CustomerUIModel(
        id: '8',
        name: 'Francisco Jiménez',
        email: 'francisco.jimenez@example.com',
        phone: '+34 689 012 345',
        segment: 'VIP',
        purchaseIntention: 'High',
        preAssignedAgent: 'María López',
        dateCreated: DateTime.now().subtract(const Duration(days: 90)),
        lastInteraction: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}

/// Customer Filter Model
///
/// Represents the current filter state in the UI
class CustomerFilterModel {
  final List<String> selectedAgents;
  final List<String> selectedSegments;
  final DateTimeRange? dateCreatedRange;
  final DateTimeRange? lastInteractionRange;

  const CustomerFilterModel({
    this.selectedAgents = const [],
    this.selectedSegments = const [],
    this.dateCreatedRange,
    this.lastInteractionRange,
  });

  /// Get the count of active filters
  int get activeFilterCount {
    int count = 0;
    if (selectedAgents.isNotEmpty) count++;
    if (selectedSegments.isNotEmpty) count++;
    if (dateCreatedRange != null) count++;
    if (lastInteractionRange != null) count++;
    return count;
  }

  /// Check if any filters are active
  bool get hasActiveFilters => activeFilterCount > 0;

  /// Clear all filters
  CustomerFilterModel clear() {
    return const CustomerFilterModel();
  }

  /// Copy with new values
  CustomerFilterModel copyWith({
    List<String>? selectedAgents,
    List<String>? selectedSegments,
    DateTimeRange? dateCreatedRange,
    DateTimeRange? lastInteractionRange,
    bool clearDateCreated = false,
    bool clearLastInteraction = false,
  }) {
    return CustomerFilterModel(
      selectedAgents: selectedAgents ?? this.selectedAgents,
      selectedSegments: selectedSegments ?? this.selectedSegments,
      dateCreatedRange: clearDateCreated ? null : (dateCreatedRange ?? this.dateCreatedRange),
      lastInteractionRange: clearLastInteraction ? null : (lastInteractionRange ?? this.lastInteractionRange),
    );
  }
}
