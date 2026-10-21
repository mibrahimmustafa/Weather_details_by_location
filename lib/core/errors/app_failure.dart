/// A single, transport-agnostic failure type used across the app.
///
/// The presentation layer maps [FailureKind] to a localized message, so the
/// data layer never needs to know about `BuildContext` or translations.
enum FailureKind {
  network,
  timeout,
  server,
  rateLimited,
  malformed,
  noCity,
  locationDenied,
  locationDeniedForever,
  locationServiceDisabled,
  locationTimeout,
  locationFailed,
  unknown,
}

class AppFailure implements Exception {
  const AppFailure(this.kind, {this.debugMessage});

  final FailureKind kind;
  final String? debugMessage;

  @override
  String toString() =>
      'AppFailure(${kind.name}${debugMessage == null ? '' : ': $debugMessage'})';
}
