mixin NotEmptyMixin {
  isNotEmpty(String? value) {
    return value != null && value.isNotEmpty;
  }
}
