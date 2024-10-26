mixin ValidationMixin {
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de usuario es requerido';
    }
    if (value.length < 4 || value.length > 50) {
      return 'El nombre de usuario debe tener entre 4 y 50 caracteres';
    }
    final usernameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!usernameRegExp.hasMatch(value)) {
      return 'El nombre de usuario solo debe contener letras';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido';
    }
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
      return 'El formato del correo no es válido';
    }
    if (value.length < 6 || value.length > 50) {
      return 'El correo debe tener entre 6 y 50 caracteres';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 10 || value.length > 60) {
      return 'La contraseña debe tener entre 10 y 60 caracteres';
    }
    final passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%&*~.]).{10,}$');
    if (!passwordRegExp.hasMatch(value)) {
      return 'La contraseña debe tener una mayúscula, minúscula, \nnúmero y carácter especial';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de teléfono es obligatorio';
    }

    final phoneRegExp = RegExp(r'^[+0-9\s]+$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Ingresa un número de teléfono válido';
    }

    return null;
  }
}
