import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Agregar Firestore
import 'login_page.dart';
import 'movements_page.dart';
import 'profile_user.dart';
import 'qr_view.dart';
import 'recharge_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Autenticación Firebase

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _username = 'Iniciar sesión';
  double _saldo = 0.0; // Nueva variable para el saldo

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar el username y saldo
  }

  // Cargar username y saldo de Firestore basado en el UID del usuario autenticado
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Obtener el username desde SharedPreferences o Firestore si es necesario
      setState(() {
        _username =
            prefs.getString('username') ?? user.displayName ?? 'Usuario';
      });

      // Obtener el saldo desde Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          setState(() {
            // Convertir el valor del saldo de String a double de forma segura
            _saldo =
                double.tryParse(snapshot.data()!['saldo'].toString()) ?? 0.0;
          });
        } else {
          setState(() {
            _saldo = 0.0; // En caso de que no exista el saldo en Firestore
          });
        }
      }).catchError((error) {
        log("Error obteniendo saldo: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: const Text(
          'CodeGo',
          style: TextStyle(color: Colors.lightBlue),
        ),
        actions: [
          _buildUserInfo(), // Mostrar la info del usuario si ha iniciado sesión
        ],
      ),
      body: _getBodyContent(_currentIndex),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Modificar el botón para incluir el nombre de usuario y mostrar el saldo solo si el usuario ha iniciado sesión
  Widget _buildUserInfo() {
    return Row(
      children: [
        if (_username !=
            'Iniciar sesión') // Solo mostrar si el usuario ha iniciado sesión
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildUserContainer(),
          ),
        if (_username !=
            'Iniciar sesión') // Mostrar saldo solo si ha iniciado sesión
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildSaldoContainer(),
          ),
        if (_username ==
            'Iniciar sesión') // Mostrar el botón de iniciar sesión si no está logueado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildLoginButton(),
          ),
      ],
    );
  }

  Widget _buildUserContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: GestureDetector(
        onTap: () {
          if (_username == 'Iniciar sesión') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(username: _username),
              ),
            );
          }
        },
        child: Row(
          children: [
            const Icon(
              Icons.person,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              _username,
              style: const TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaldoContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MovementsPage()), // Navegar a MovementsPage
          );
        },
        child: Row(
          children: [
            Text(
              'S/ ${_saldo.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Este es el botón que aparece cuando el usuario no ha iniciado sesión
  Widget _buildLoginButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        child: const Row(
          children: [
            Icon(
              Icons.person,
              color: Colors.grey,
            ),
            SizedBox(width: 8),
            Text(
              'Iniciar sesión',
              style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.lightBlue,
      unselectedItemColor: Colors.white,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'QR',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Recarga',
        ),
      ],
    );
  }

  Widget _getBodyContent(int index) {
    if (index == 0) {
      return _buildHomePage();
    } else if (index == 1) {
      return QRViewExample();
    } else if (index == 2) {
      return RecargaPage();
    } else {
      return const Center(child: Text('Pantalla no definida'));
    }
  }

  Widget _buildHomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/qr.png',
            width: 300,
            height: 300,
          ),
          const SizedBox(height: 10),
          const Text(
            'CodeGo',
            style: TextStyle(
              fontSize: 70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
