class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

class MissingRequiredFieldException extends ValidationException {
  MissingRequiredFieldException(String fieldKey)
      : super('Missing required field: $fieldKey');
}

class TypeMismatchException extends ValidationException {
  TypeMismatchException(String fieldKey, String expectedType, String actualType)
      : super(
            'Type Mismatch: $fieldKey must be a $expectedType, but got $actualType');
}

class InvalidValueException extends ValidationException {
  InvalidValueException(String fieldKey, String message)
      : super('Invalid Value: $fieldKey. $message');
}

class InvalidSchemaException extends ValidationException {
  InvalidSchemaException(String fieldKey, String message)
      : super('Invalid Schema: $fieldKey. $message');
}
