/// Definition Type Entity
///
/// Represents a type/category of value definitions (e.g., USER_ROLES, ORGANIZATION_USER_STATUS)
class DefinitionType {
  final int id;
  final String definitionType;
  final String description;
  final String active;

  const DefinitionType({
    required this.id,
    required this.definitionType,
    required this.description,
    required this.active,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefinitionType &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          definitionType == other.definitionType;

  @override
  int get hashCode => id.hashCode ^ definitionType.hashCode;

  @override
  String toString() => 'DefinitionType(id: $id, type: $definitionType, description: $description)';
}

/// Value Definition Entity
///
/// Represents a configurable value definition that can vary by environment.
/// Used for roles, statuses, and other dynamic configuration values.
class ValueDefinition {
  final int id;
  final String valueDefinition;
  final String description;
  final String active;
  final int definitionTypeId;
  final DefinitionType definitionType;

  const ValueDefinition({
    required this.id,
    required this.valueDefinition,
    required this.description,
    required this.active,
    required this.definitionTypeId,
    required this.definitionType,
  });

  /// Check if this definition is active
  bool get isActive => active == '1';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueDefinition && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ValueDefinition(id: $id, value: $valueDefinition, type: ${definitionType.definitionType})';
}
