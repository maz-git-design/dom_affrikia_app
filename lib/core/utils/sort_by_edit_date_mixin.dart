mixin SortByEditDate {
  int sortByEditDate(s1, s2) =>
      s1.edited != null && s2.edited != null ? -s1.edited.compareTo(s2.edited!) : 1;
}
