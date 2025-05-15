mixin ValidateCvvMixin{
  String? validateCvvFromMixin(String? value) {
    RegExp cvvReg = RegExp('^[0-9]{3}\$');

    if (value == null || value.isEmpty) {
      return 'Requis';
    } else {
      if (!cvvReg.hasMatch(value)) {
        return 'Invalide';
      }
    }
    return null;
  }
}