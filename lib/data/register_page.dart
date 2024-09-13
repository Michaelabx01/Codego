import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // Necesario para el hash
import 'package:crypto/crypto.dart'; // Necesario para el hash

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final passNotifier = ValueNotifier<double>(0.0);

  String email = '';
  String password = '';
  String confirmPassword = '';
  String username = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUsernameValid =
      true; // Nueva variable para el estado de la validación del nombre de usuario

  // Función para generar el hash de la contraseña
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convierte la contraseña en bytes
    var hashedPassword =
        sha256.convert(bytes); // Aplica el algoritmo de hash (SHA-256)
    return hashedPassword.toString(); // Devuelve el hash como una cadena
  }

  // Función para validar si el nombre de usuario tiene letras y números
  bool _validateUsername(String username) {
    final hasLetters =
        RegExp(r'[a-zA-Z]').hasMatch(username); // Contiene letras
    final hasNumbers = RegExp(r'[0-9]').hasMatch(username); // Contiene números
    return hasLetters && hasNumbers;
  }

  // En lugar de usar el Snackbar predeterminado de Flutter, usarás el AwesomeSnackbarContent.
// Aquí hay un ejemplo de cómo implementar un snackbar usando esa librería.

  _buildAwesomeSnackBar(
      BuildContext context, String message, ContentType contentType) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: contentType == ContentType.success ? 'Éxito' : 'Error',
        message: message,
        contentType: contentType,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors
              .white, // Cambia el color de la flecha de retroceso a blanco
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de usuario (avatar)
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black,
                    child:
                        Icon(Icons.person_add, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  // Caja central de registro
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Campo de Nombre de Usuario
                        _buildUsernameField(),
                        if (!_isUsernameValid) // Mostrar advertencia si el nombre de usuario no es válido
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'El nombre de usuario debe contener letras y números.',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        const SizedBox(height: 20),
                        // Campo de Email
                        _buildTextField(
                          label: 'Email',
                          icon: Icons.email,
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        // Campo de Password con barra de fortaleza personalizada
                        _buildPasswordField(
                          label: 'Contraseña',
                          icon: Icons.lock,
                          obscureText: !_isPasswordVisible,
                          isPasswordField: true,
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                            passNotifier.value = _calculatePasswordStrength(
                                value); // Calcula la fortaleza
                          },
                          toggleVisibility: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          isPasswordVisible: _isPasswordVisible,
                        ),
                        const SizedBox(height: 10),
                        // Barra de progreso personalizada para la fortaleza de la contraseña
                        ValueListenableBuilder<double>(
                          valueListenable: passNotifier,
                          builder: (context, value, child) {
                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: SizedBox(
                                    width: 300.0,
                                    height: 10.0,
                                    child: LinearProgressIndicator(
                                      value: value,
                                      backgroundColor: Colors.grey[300],
                                      color: value < 0.5
                                          ? Colors.red
                                          : value < 0.75
                                              ? Colors.orange
                                              : Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Texto que indica la fortaleza de la contraseña
                                Text(
                                  _getPasswordStrengthText(
                                      value), // Obtén el texto en español
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Campo de Confirmación de Contraseña con ícono de ojito
                        _buildPasswordField(
                          label: 'Confirmar Contraseña',
                          icon: Icons.lock_outline,
                          obscureText: !_isConfirmPasswordVisible,
                          isPasswordField: true,
                          onChanged: (value) {
                            setState(() {
                              confirmPassword = value;
                            });
                          },
                          toggleVisibility: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          isPasswordVisible: _isConfirmPasswordVisible,
                        ),
                        const SizedBox(height: 20),
                        // Botón de Registro
                        _buildButton(
                          text: 'Registrar',
                          onPressed: () async {
                            setState(() {
                              _isUsernameValid = _validateUsername(username);
                            });

                            if (email.isEmpty ||
                                password.isEmpty ||
                                confirmPassword.isEmpty ||
                                username.isEmpty ||
                                !_isUsernameValid) {
                              _buildAwesomeSnackBar(
                                  context,
                                  'Por favor, completa todos los campos.',
                                  ContentType.failure);
                              return;
                            }

                            if (password != confirmPassword) {
                              _buildAwesomeSnackBar(
                                  context,
                                  'Las contraseñas no coinciden.',
                                  ContentType.warning);
                              return;
                            }

                            if (!_validatePassword(password)) {
                              _buildAwesomeSnackBar(
                                context,
                                'La contraseña debe tener al menos 6 caracteres, una mayúscula, un número y un carácter especial.',
                                ContentType.warning,
                              );
                              return;
                            }

                            try {
                              UserCredential userCredential =
                                  await _auth.createUserWithEmailAndPassword(
                                email: email.trim(),
                                password: password.trim(),
                              );

                              String passwordHash = hashPassword(password);

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userCredential.user?.uid)
                                  .set({
                                'username': username,
                                'email': email.trim(),
                                'password': password,
                                'passwordHash': passwordHash,
                                'createdAt': Timestamp.now(),
                              });

                              _buildAwesomeSnackBar(context, 'Registro exitoso',
                                  ContentType.success);

                              Navigator.pop(context);
                            } catch (e) {
                              _buildAwesomeSnackBar(
                                  context,
                                  'Error: ${e.toString()}',
                                  ContentType.failure);
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Nueva función para el campo de Nombre de Usuario
  Widget _buildUsernameField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          username = value;
          _isUsernameValid = _validateUsername(
              username); // Actualiza la validación en tiempo real
        });
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Nombre de Usuario',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        prefixIcon: const Icon(Icons.person, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Campo de texto reutilizable
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    bool obscureText = false,
  }) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        prefixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Campo de texto para contraseñas con botón de visibilidad (ojito)
  Widget _buildPasswordField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    required bool obscureText,
    required bool isPasswordField,
    required bool isPasswordVisible,
    required VoidCallback toggleVisibility,
  }) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Botón de registro
  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue, Colors.lightBlue.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue.withOpacity(0.6),
          shadowColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Función para calcular la fortaleza de la contraseña
  double _calculatePasswordStrength(String password) {
    double strength = 0.0;

    if (password.length >= 6) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]')))
      strength += 0.25; // Tiene una letra mayúscula
    if (password.contains(RegExp(r'[0-9]')))
      strength += 0.25; // Tiene un número
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
      strength += 0.25; // Tiene un carácter especial

    return strength;
  }

  // Función para obtener el texto de fortaleza de la contraseña en español
  String _getPasswordStrengthText(double strength) {
    if (strength < 0.25) {
      return 'Débil';
    } else if (strength < 0.5) {
      return 'Media';
    } else if (strength < 0.75) {
      return 'Fuerte';
    } else {
      return 'Muy segura';
    }
  }

  // Función para validar la contraseña con reglas estrictas
  bool _validatePassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasMinLength = password.length >= 6;

    return hasUppercase && hasDigits && hasSpecialCharacters && hasMinLength;
  }
}
