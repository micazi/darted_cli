extension ListExtension<E> on List<E> {
  bool containsAll(List<E> otherList) {
    List<bool> checks = [];
    //
    for (E thisElement in otherList) {
      checks.add(contains(thisElement));
    }
    return !checks.contains(false);
  }
}
