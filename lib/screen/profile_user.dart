import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/card_container.dart';
import 'home_page.dart';

class UserProfilePage extends StatefulWidget {
  final String username;

  UserProfilePage({required this.username});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? nombres; // Variable para almacenar los nombres
  String? apellidoPaterno; // Variable para el apellido paterno
  String? apellidoMaterno; // Variable para el apellido materno

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar los datos del usuario desde Firestore
  }

  Future<void> _loadUserData() async {
    // Obtener el ID del usuario actualmente autenticado
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.providerData.any((provider) => provider.providerId == 'google.com')) {
        // El usuario inició sesión con Google
        // Puedes asumir que el nombre de usuario ya se pasó a esta página
        setState(() {
          nombres = user.displayName;
          apellidoPaterno = '';
          apellidoMaterno = '';
        });
      } else {
        // Consultar Firestore para obtener los datos del usuario
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Si los datos existen, acceder correctamente al subcampo 'nombres'
        if (userSnapshot.exists) {
          final userData = userSnapshot.data() as Map<String, dynamic>;
          final nombresData = userData['nombres'] as Map<String, dynamic>;

          setState(() {
            nombres = nombresData['nombres']; // Nombres del usuario
            apellidoPaterno = nombresData['apellidoPaterno']; // Apellido paterno
            apellidoMaterno = nombresData['apellidoMaterno']; // Apellido materno
          });
        }
      }
    }
  }

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
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
              widget.username,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Mostrar nombres y apellidos si están disponibles
            const Text(
              'Nombre Completo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              '${nombres ?? 'Cargando...'} ${apellidoPaterno ?? ''} ${apellidoMaterno ?? ''}', // Mostrar nombres y apellidos
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
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
