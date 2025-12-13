import 'dart:convert';

import 'package:flutter/foundation.dart';

enum ScaleType {
  fixed,
}

enum ScaleInteractionMode {
  selection,
  input,
}

enum ScaleDataType {
  text,
  number,
}

ScaleType _parseScaleType(String? typeStr) {
  switch ((typeStr ?? 'fixed').toLowerCase()) {
    case 'fixed':
      return ScaleType.fixed;
    default:
      return ScaleType.fixed;
  }
}

ScaleInteractionMode _parseInteractionMode(
  String? modeStr, {
  required bool hasOptions,
}) {
  switch ((modeStr ?? '').toLowerCase()) {
    case 'selection':
      return ScaleInteractionMode.selection;
    case 'input':
      return ScaleInteractionMode.input;
  }

  // Backward compatible default:
  // - legacy templates that have options -> selection
  // - otherwise -> input
  return hasOptions
      ? ScaleInteractionMode.selection
      : ScaleInteractionMode.input;
}

ScaleDataType _parseDataType(String? typeStr) {
  switch ((typeStr ?? '').toLowerCase()) {
    case 'number':
      return ScaleDataType.number;
    case 'text':
    default:
      return ScaleDataType.text;
  }
}

class ScaleTemplatePlain {
  final String id;
  final String title;
  final ScaleType type;
  final ScaleInteractionMode interactionMode;
  final ScaleDataType dataType;
  final List<String> options;
  final bool hasUnit;
  final String unit;

  const ScaleTemplatePlain({
    required this.id,
    required this.title,
    required this.type,
    required this.interactionMode,
    required this.dataType,
    required this.options,
    required this.hasUnit,
    required this.unit,
  });

  factory ScaleTemplatePlain.fromMetadata({
    required String id,
    required Map<String, dynamic> metadata,
  }) {
    final title = (metadata['title'] ?? '') as String;
    final typeStr = (metadata['type'] ?? 'fixed') as String;
    final interactionModeStr = metadata['interaction_mode'];
    final dataTypeStr = metadata['data_type'];
    final optionsRaw = metadata['options'];

    final hasUnitRaw = metadata['has_unit'];
    final unitRaw = metadata['unit'];

    final type = _parseScaleType(typeStr);

    final options = <String>[];
    if (optionsRaw is List) {
      for (final o in optionsRaw) {
        if (o is String && o.trim().isNotEmpty) options.add(o.trim());
      }
    }

    final interactionMode = _parseInteractionMode(
      interactionModeStr is String ? interactionModeStr : null,
      hasOptions: options.isNotEmpty,
    );
    final dataType = _parseDataType(dataTypeStr is String ? dataTypeStr : null);

    final unit = unitRaw is String ? unitRaw.trim() : '';
    final hasUnit = hasUnitRaw is bool ? hasUnitRaw : unit.isNotEmpty;

    return ScaleTemplatePlain(
      id: id,
      title: title,
      type: type,
      interactionMode: interactionMode,
      dataType: dataType,
      options: options,
      hasUnit: hasUnit,
      unit: hasUnit ? unit : '',
    );
  }
}

class ScaleInstance {
  final String title;
  final ScaleType type;
  final ScaleInteractionMode interactionMode;
  final ScaleDataType dataType;
  final List<String> options;
  final bool hasUnit;
  final String unit;
  String? currentValue;

  ScaleInstance({
    required this.title,
    required this.type,
    required this.interactionMode,
    required this.dataType,
    required this.options,
    required this.hasUnit,
    required this.unit,
    this.currentValue,
  });

  factory ScaleInstance.fromTemplate(ScaleTemplatePlain template) {
    // Deep copy: do NOT store only template id.
    return ScaleInstance(
      title: template.title,
      type: template.type,
      interactionMode: template.interactionMode,
      dataType: template.dataType,
      options: List<String>.from(template.options),
      hasUnit: template.hasUnit,
      unit: template.hasUnit ? template.unit : '',
      currentValue: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type.name,
      'interaction_mode': interactionMode.name,
      'data_type': dataType.name,
      'options': options,
      'has_unit': hasUnit,
      'unit': unit,
      'current_value': currentValue,
    };
  }

  static ScaleInstance? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final title = raw['title'];
    final typeStr = raw['type'];
    final interactionModeStr = raw['interaction_mode'];
    final dataTypeStr = raw['data_type'];
    final optionsRaw = raw['options'];
    final hasUnitRaw = raw['has_unit'];
    final unitRaw = raw['unit'];
    final currentValue = raw['current_value'];
    if (title is! String) return null;

    final type = _parseScaleType(typeStr is String ? typeStr : null);

    final options = <String>[];
    if (optionsRaw is List) {
      for (final o in optionsRaw) {
        if (o is String && o.trim().isNotEmpty) options.add(o.trim());
      }
    }

    final interactionMode = _parseInteractionMode(
      interactionModeStr is String ? interactionModeStr : null,
      hasOptions: options.isNotEmpty,
    );
    final dataType = _parseDataType(dataTypeStr is String ? dataTypeStr : null);

    final unit = unitRaw is String ? unitRaw.trim() : '';
    final hasUnit = hasUnitRaw is bool ? hasUnitRaw : unit.isNotEmpty;

    return ScaleInstance(
      title: title,
      type: type,
      interactionMode: interactionMode,
      dataType: dataType,
      options: options,
      hasUnit: hasUnit,
      unit: hasUnit ? unit : '',
      currentValue: currentValue is String ? currentValue : null,
    );
  }
}

class DocumentModel extends ChangeNotifier {
  List<ScaleInstance> scales;

  DocumentModel({List<ScaleInstance>? scales})
      : scales = List<ScaleInstance>.from(
          scales ?? const <ScaleInstance>[],
          growable: true,
        );

  void _ensureScalesGrowable() {
    // Hot reload does not recreate existing instances. If an old instance
    // captured an unmodifiable list (e.g. `const []`), mutations will throw.
    try {
      scales.addAll(const <ScaleInstance>[]);
    } on UnsupportedError {
      scales = List<ScaleInstance>.from(scales, growable: true);
    }
  }

  void addScaleFromTemplate(ScaleTemplatePlain template) {
    _ensureScalesGrowable();
    scales.add(ScaleInstance.fromTemplate(template));
    notifyListeners();
  }

  void removeScaleAt(int index) {
    if (index < 0 || index >= scales.length) return;
    _ensureScalesGrowable();
    scales.removeAt(index);
    notifyListeners();
  }

  void setScaleValue(int index, String? value) {
    if (index < 0 || index >= scales.length) return;
    _ensureScalesGrowable();
    scales[index].currentValue = value;
    notifyListeners();
  }
}

class ZkDocPayload {
  static const int version = 1;

  /// Rich is the FlutterQuill delta json list.
  static Map<String, dynamic> build({
    required List<dynamic> rich,
    required List<ScaleInstance> scales,
  }) {
    return {
      'v': version,
      'rich': rich,
      'scales': scales.map((s) => s.toJson()).toList(growable: false),
    };
  }

  /// Returns a Quill delta json list from either legacy(List) or new(Map) format.
  static List<dynamic> extractRich(Object? decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['rich'] is List) {
      return List<dynamic>.from(decoded['rich'] as List);
    }
    return const <dynamic>[];
  }

  static List<ScaleInstance> extractScales(Object? decoded) {
    // New minimal format: the whole payload is a JSON List of scale json objects.
    if (decoded is List) {
      final scales = <ScaleInstance>[];
      for (final item in decoded) {
        final inst = ScaleInstance.tryFromJson(item);
        if (inst != null) scales.add(inst);
      }
      return scales;
    }
    if (decoded is Map && decoded['scales'] is List) {
      final rawList = decoded['scales'] as List;
      final scales = <ScaleInstance>[];
      for (final item in rawList) {
        final inst = ScaleInstance.tryFromJson(item);
        if (inst != null) scales.add(inst);
      }
      return scales;
    }
    return const <ScaleInstance>[];
  }

  static Object? tryDecodeJson(String content) {
    if (content.isEmpty) return null;
    try {
      return jsonDecode(content);
    } catch (_) {
      return null;
    }
  }
}
