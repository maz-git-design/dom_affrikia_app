mixin ValidateCrediCardNumberMixin {
  String? validateCrediCardNumberFromMixin(String? value) {
    final RegExp crediCardNumberReg = RegExp(r'^[45](\d{12}|\d{15})$');

    if (value == null || value.isEmpty) {
      return 'Saississez un numéro';
    } else {
      if (!crediCardNumberReg.hasMatch(value)) {
        return 'Le numéro est incorrect';
      }
    }
    return null;
  }
}
