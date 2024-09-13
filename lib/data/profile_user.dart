import 'package:code_projectv1/data/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/card_container.dart';


class UserProfilePage extends StatelessWidget {
  final String username;

  UserProfilePage({required this.username});

Future<void> _signOut(BuildContext context) async {
  // Limpiar SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // Cerrar sesión de Firebase
  await FirebaseAuth.instance.signOut();

  // Redirigir a HomePage y eliminar todas las rutas anteriores
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => HomePage()),
    (Route<dynamic> route) => false,
  );
}



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors
              .white, // Cambia el color de la flecha de retroceso a blanco
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar o icono que represente al usuario
            const SizedBox(height: 50),
            CardContainer(
              backgroundColor: Colors.white,
              width: size.width * 0.40,
              height: size.width * 0.40,
              child: Center(
                child: Icon(
                  Icons.perm_identity,
                  size: (size.width * 0.32) > 100 ? 100 : 50,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Username',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            // Mostrar el nombre de usuario
            Text(
              username,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 40),

            // Botón de cerrar sesión
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _signOut(context);
                },
                icon: const Icon(
                  Icons.exit_to_app_outlined,
                  size: 18,
                  color: Colors.black,
                ),
                label: const Text(
                  "Cerrar sesión",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
