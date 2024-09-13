import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../service/dni_serivce.dart';

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
  String dni = ''; // Nueva variable para el DNI
  Map<String, dynamic>? dniData; // Datos obtenidos por el servicio
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUsernameValid = true;
  bool _isLoading = false; // Nueva variable para manejar el estado de carga

  // Función para generar el hash de la contraseña
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var hashedPassword = sha256.convert(bytes);
    return hashedPassword.toString();
  }

  // Función para validar si el nombre de usuario tiene letras y números
  bool _validateUsername(String username) {
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(username);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(username);
    return hasLetters && hasNumbers;
  }

  // Verificar si el nombre de usuario o DNI ya existen en Firestore
  Future<bool> _isUsernameOrDniTaken(String username, String dni) async {
    // Verificar nombre de usuario
    final usernameSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    // Verificar DNI
    final dniSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('dni', isEqualTo: dni)
        .get();

    if (usernameSnapshot.docs.isNotEmpty) {
      _buildAwesomeSnackBar(context, 'El nombre de usuario ya existe', ContentType.warning);
      return true;
    }

    if (dniSnapshot.docs.isNotEmpty) {
      _buildAwesomeSnackBar(context, 'El DNI ya existe', ContentType.warning);
      return true;
    }

    return false; // Si ninguno existe, se puede proceder
  }

  // Función para buscar los datos por DNI
  Future<void> _fetchDniData(String dni) async {
    final data = await ApiService.getdni(dni);
    if (data != null) {
      setState(() {
        dniData = data; // Guardar los datos obtenidos
      });
    } else {
      setState(() {
        dniData = null; // Limpiar datos si no se encuentran
      });
    }
  }

  // Snackbar para mostrar mensajes
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
          color: Colors.white,
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
                  const SizedBox(height: 30),
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
                        _buildUsernameField(),
                        if (!_isUsernameValid)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'El nombre de usuario debe contener letras y números.',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        const SizedBox(height: 20),
                        // Nuevo campo de DNI
                        _buildDniField(),
                        const SizedBox(height: 20),

                        // Mostrar los datos obtenidos por el servicio
                        if (dniData != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${dniData?['nombres']}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                Text(
                                  "${dniData?['apellidoPaterno']}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                Text(
                                  "${dniData?['apellidoMaterno']}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        // Campo de email y contraseña
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
                         // Mostrar CircleIndicator mientras se carga
                        if (_isLoading)
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ), // Mostrar indicador de carga
                        
                        if (!_isLoading) // Si no está cargando, muestra el botón de registro
                          _buildButton(
                            text: 'Registrar',
                            onPressed: () async {
                              setState(() {
                                _isUsernameValid = _validateUsername(username);
                                _isLoading = true; // Activar indicador de carga
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
                                setState(() {
                                  _isLoading = false; // Desactivar indicador de carga
                                });
                                return;
                              }

                              if (password != confirmPassword) {
                                _buildAwesomeSnackBar(
                                    context,
                                    'Las contraseñas no coinciden.',
                                    ContentType.warning);
                                setState(() {
                                  _isLoading = false; // Desactivar indicador de carga
                                });
                                return;
                              }

                              if (!_validatePassword(password)) {
                                _buildAwesomeSnackBar(
                                  context,
                                  'La contraseña debe tener al menos 6 caracteres, una mayúscula, un número y un carácter especial.',
                                  ContentType.warning,
                                );
                                setState(() {
                                  _isLoading = false; // Desactivar indicador de carga
                                });
                                return;
                              }

                              bool isTaken = await _isUsernameOrDniTaken(username, dni);
                              if (isTaken) {
                                setState(() {
                                  _isLoading = false; // Desactivar indicador de carga
                                });
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
                                'dni': dni,
                                'nombres': dniData, // Guardar nombres obtenidos del DNI
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

  // Campo de Nombre de Usuario
  Widget _buildUsernameField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          username = value;
          _isUsernameValid = _validateUsername(username);
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

  // Campo de DNI
  Widget _buildDniField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          dni = value;
        });
        if (dni.length == 8) {
          _fetchDniData(
              dni); // Llamar al servicio cuando el DNI tenga 8 dígitos
        } else {
          setState(() {
            dniData = null; // Limpiar los datos si el DNI es incorrecto
          });
        }
      },
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'DNI',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        prefixIcon: const Icon(Icons.credit_card, color: Colors.white),
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

  // Campo de texto para contraseñas con botón de visibilidad
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
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

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
