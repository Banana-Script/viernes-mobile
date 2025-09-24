/// A utility class representing either a left value (typically error) or right value (typically success)
abstract class Either<L, R> {
  const Either();

  /// Returns true if this is a Left
  bool get isLeft => this is Left<L, R>;

  /// Returns true if this is a Right
  bool get isRight => this is Right<L, R>;

  /// Fold this Either into a single value
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR);

  /// Get the left value, or throw if this is Right
  L get left {
    if (this is Left<L, R>) {
      return (this as Left<L, R>).value;
    }
    throw Exception('Called left on Right');
  }

  /// Get the right value, or throw if this is Left
  R get right {
    if (this is Right<L, R>) {
      return (this as Right<L, R>).value;
    }
    throw Exception('Called right on Left');
  }

  /// Map over the right value
  Either<L, T> map<T>(T Function(R right) fn) {
    return fold<Either<L, T>>(
      (left) => Left(left),
      (right) => Right(fn(right)),
    );
  }

  /// Flat map over the right value
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) fn) {
    return fold<Either<L, T>>(
      (left) => Left(left),
      (right) => fn(right),
    );
  }

  /// Get the right value or return a default
  R getOrElse(R Function() defaultValue) {
    return fold((_) => defaultValue(), (right) => right);
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR) {
    return fnL(value);
  }

  @override
  bool operator ==(Object other) {
    return other is Left<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR) {
    return fnR(value);
  }

  @override
  bool operator ==(Object other) {
    return other is Right<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}