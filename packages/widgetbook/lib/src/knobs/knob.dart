import '../fields/field.dart';

/// This allows stories to have dynamically adjustable parameters.
abstract class Knob<T> {
  Knob({
    required this.label,
    required this.value,
    this.description,
    this.isNull = false,
  });

  /// This is the current value the knob is set to
  T value;

  /// This is a description the user can put on the knob
  final String? description;

  /// This is the label that's put above a knob
  final String label;

  bool isNull;

  bool get isNullable => null is T;

  @override
  bool operator ==(Object other) {
    return other is Knob<T> &&
        other.value == value &&
        other.label == label &&
        other.description == description;
  }

  @override
  int get hashCode => label.hashCode;

  List<Field> get fields;
}
