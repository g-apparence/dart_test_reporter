
/// A [Specification] contains 1..N [Scenario]
/// put this as annotation on functions inside a [Specification] class
/// all of these scenario will be added to the generated documentation
class Scenario {
  final String given, when, then;

  const Scenario({this.given, this.when, this.then});

  @override
  String toString() {
    return 'Scenario{given: $given, when: $when, then: $then}';
  }
}

/// use this on a testing class as annotation
/// this is the main specification of a feature
/// [title] is a short description of the feature
/// [asUser], [want], [that] describes your feature
class Specification {
  final String title;

  final String asUser, want, that;

  const Specification({this.title, this.asUser, this.want, this.that});
}

