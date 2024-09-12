import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'profile_user.dart';
import 'qr_view.dart';
import 'recharge_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _username = 'Iniciar sesión';

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Cargar el nombre de usuario almacenado en SharedPreferences
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Iniciar sesión';
    });
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
        _buildLoginButton(),
      ],
    ),
    body: _getBodyContent(_currentIndex),
    bottomNavigationBar: _buildBottomNavigationBar(),
  );
}

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey,
            width: 2,
          ),
        ),
        child: TextButton(
          onPressed: () {
            if (_username == 'Iniciar sesión') {
              // Redirige a la pantalla de Login si no ha iniciado sesión
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            } else {
              // Redirige a la página de perfil del usuario
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(username: _username),
                ),
              );
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.person,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                _username, // Mostrar el nombre de usuario o "Iniciar sesión"
                style: const TextStyle(
                  color: Colors.lightBlue,
                ),
              ),
            ],
          ),
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
            'assets/qr.png', // Ruta de tu imagen
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
