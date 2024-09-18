import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/transition/left_route.dart';
import '../widgets/transition/right_route.dart';
import 'forgot_password.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool rememberMe = false;
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool loading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _loadUserCredentials(); // Cargar credenciales guardadas
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Cargar los datos almacenados
  Future<void> _loadUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        emailController.text = prefs.getString('email') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
      loading = false; // Carga completada
    });
  }

  // Guardar o eliminar las credenciales en SharedPreferences
  void _saveOrRemoveUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
      await prefs.setBool('rememberMe', rememberMe);
    } else {
      // No eliminar todo, solo lo necesario
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', rememberMe);
    }
  }

  // Función para realizar el inicio de sesión
Future<void> _login() async {
  String emailOrUsername = emailController.text.trim();
  String password = passwordController.text.trim();

  if (emailOrUsername.isEmpty || password.isEmpty) {
    const snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: 'Por favor, ingrese su nombre de usuario/correo electrónico y contraseña',
        contentType: ContentType.failure,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    String emailToUse = emailOrUsername;
     String username = emailOrUsername;

    if (!emailOrUsername.contains('@')) {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: emailOrUsername)
          .get();
      if (userSnapshot.docs.isNotEmpty) {
        emailToUse = userSnapshot.docs.first['email'];
        username = userSnapshot.docs.first['username'];
      } else {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Nombre de usuario no encontrado',
        );
      }
    }

    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: emailToUse,
      password: password,
    );

    final user = userCredential.user;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      _showSnackBar(
        'Verifica tu correo antes de iniciar sesión. Se ha enviado un nuevo correo de verificación.',
        ContentType.warning,
      );

      await _auth.signOut();
      return;
    }

    // Redirigir a la pantalla principal si el correo está verificado
     // Obtener el nombre de usuario del Firestore usando el correo
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: emailToUse)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        username = userSnapshot.docs.first['username']; // Obtener el nombre de usuario real
      }

      // Guardar credenciales según el estado del checkbox
      _saveOrRemoveUserCredentials();

      // Guardar el nombre de usuario en SharedPreferences si está activado el checkbox
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);  // Guardar el nombre de usuario en lugar del correo
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  } catch (e) {
    String errorMessage = 'Usuario o contraseña incorrectos';

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'El correo electrónico no es válido';
          break;
        case 'user-not-found':
          errorMessage = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: errorMessage,
        contentType: ContentType.failure,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

void _showSnackBar(String message, ContentType contentType) {
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


Future<void> _signInWithGoogle() async {
  setState(() {
    isLoading = true;
  });

  try {
    // Primero, cerrar sesión en la cuenta de Google actual
    await _googleSignIn.signOut();

    // Luego, iniciar sesión con Google
    final GoogleUser = await _googleSignIn.signIn();
    if (GoogleUser == null) {
      // El usuario canceló el inicio de sesión
      setState(() {
        isLoading = false;
      });
      return;
    }

    final GoogleAuth = await GoogleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: GoogleAuth.accessToken,
      idToken: GoogleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);

    // Obtener el nombre de usuario del Firestore usando el correo
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: GoogleUser.email)
        .get();

    String username = GoogleUser.displayName?.split(' ').first ?? GoogleUser.email;

    if (userSnapshot.docs.isNotEmpty) {
      username = userSnapshot.docs.first['username'];
    }

    // Guardar el nombre de usuario en SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);

    // Navegar a la pantalla de inicio y eliminar todas las rutas anteriores
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false, // Eliminar todas las rutas anteriores
    );
  } catch (e) {
    const snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: 'Error al iniciar sesión con Google. Inténtalo de nuevo.',
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } finally {
    setState(() {
      isLoading = false;
    });
  }
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
      body: loading // Mostrar un indicador de carga mientras se cargan las credenciales
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _buildLoginForm(), // Mostrar el formulario solo cuando la carga se ha completado
    );
  }

  // Construir el formulario de inicio de sesión
  Widget _buildLoginForm() {
    return Container(
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
                Image.asset(
                  'assets/qr.png',
                  fit: BoxFit.cover,
                  width: 160,
                  height: 160,
                ),
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
                      _buildTextField(
                        label: 'Nombre de usuario o Correo',
                        icon: Icons.email,
                        controller: emailController,
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordTextField(
                        label: 'Contraseña',
                        icon: Icons.lock,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 20),
                      _buildLoginButton(
                        text: isLoading ? 'Espere...' : 'Iniciar Sesión',
                        onPressed: isLoading ? null : _login,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      _buildGoogleSignInButton(),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                FocusManager.instance.primaryFocus!.unfocus();
                                Navigator.push(context,
                                    RightRoute(page: ForgotPasswordScreen()));
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '¿Olvidé mi ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    Text(
                                      'Contraseña?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.end,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white,
                          ),
                          const SizedBox(),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                FocusManager.instance.primaryFocus!.unfocus();
                                Navigator.push(context,
                                    LeftRoute(page: const RegisterScreen()));
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Quiero ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    Text(
                                      'Registrarme',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.start,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Campo de texto reutilizable
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
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

  // Campo de contraseña con botón de visibilidad
  Widget _buildPasswordTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.blue,
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

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Iniciar sesión con Google',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
