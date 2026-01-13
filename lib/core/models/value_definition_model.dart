import '../entities/value_definition_entity.dart';

/// Definition Type Model
///
/// Data model for DefinitionType with JSON serialization.
class DefinitionTypeModel extends DefinitionType {
  const DefinitionTypeModel({
    required super.id,
    required super.definitionType,
    required super.description,
    required super.active,
  });

  factory DefinitionTypeModel.fromJson(Map<String, dynamic> json) {
    return DefinitionTypeModel(
      id: json['id'] as int,
      definitionType: json['definition_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      active: json['active'] as String? ?? '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'definition_type': definitionType,
      'description': description,
      'active': active,
    };
  }
}

/// Value Definition Model
///
/// Data model for ValueDefinition with JSON serialization.
class ValueDefinitionModel extends ValueDefinition {
  const ValueDefinitionModel({
    required super.id,
    required super.valueDefinition,
    required super.description,
    required super.active,
    required super.definitionTypeId,
    required super.definitionType,
  });

  factory ValueDefinitionModel.fromJson(Map<String, dynamic> json) {
    return ValueDefinitionModel(
      id: json['id'] as int,
      valueDefinition: json['value_definition'] as String? ?? '',
      description: json['description'] as String? ?? '',
      active: json['active'] as String? ?? '1',
      definitionTypeId: json['definition_type_id'] as int? ?? 0,
      definitionType: json['definition_type'] != null
          ? DefinitionTypeModel.fromJson(json['definition_type'] as Map<String, dynamic>)
          : const DefinitionTypeModel(id: 0, definitionType: '', description: '', active: '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value_definition': valueDefinition,
      'description': description,
      'active': active,
      'definition_type_id': definitionTypeId,
      'definition_type': (definitionType as DefinitionTypeModel).toJson(),
    };
  }
}

/// Value Definitions Response Model
///
/// Represents the paginated response from /values_definitions/ API
class ValueDefinitionsResponse {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final List<ValueDefinitionModel> valueDefinitions;

  const ValueDefinitionsResponse({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.valueDefinitions,
  });

  factory ValueDefinitionsResponse.fromJson(Map<String, dynamic> json) {
    return ValueDefinitionsResponse(
      totalCount: json['total_count'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 0,
      valueDefinitions: (json['value_definitions'] as List<dynamic>?)
              ?.map((e) => ValueDefinitionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
