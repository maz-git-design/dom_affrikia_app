mixin ValidateCardExpiryYearMixin{
  String? validateCardExpiryYearFromMixin(String? value) {
    RegExp ExpiryYearReg = RegExp(r'^20(2[2-9]|3[0-9])$');

    if (value == null || value.isEmpty) {
      return 'Requis';
    } else {
      if (!ExpiryYearReg.hasMatch(value)) {
        return 'Année incorrecte';
      }
      // if (value.length < 9 ||
      //     10 < valuef.length) {

      // }
    }
    return null;
  }
}