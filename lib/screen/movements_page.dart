import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Agregar Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Agregar Firestore

class MovementsPage extends StatefulWidget {
  @override
  _MovementsPageState createState() => _MovementsPageState();
}

class _MovementsPageState extends State<MovementsPage> {
  final List<Map<String, dynamic>> movements = [
    {"date": "September 11, 2024", "time": "03:24 PM", "amount": -1.00},
    {"date": "August 23, 2024", "time": "04:51 PM", "amount": -3.00},
    {"date": "August 23, 2024", "time": "04:46 PM", "amount": -3.50},
    {"date": "August 23, 2024", "time": "04:45 PM", "amount": -1.00},
    {"date": "August 23, 2024", "time": "04:45 PM", "amount": -1.50},
    {"date": "August 23, 2024", "time": "04:45 PM", "amount": -1.50},
    {"date": "August 23, 2024", "time": "04:44 PM", "amount": -3.50},
    {"date": "August 23, 2024", "time": "04:44 PM", "amount": -1.00},
    {"date": "August 23, 2024", "time": "04:43 PM", "amount": -3.50},
    {"date": "August 23, 2024", "time": "04:42 PM", "amount": -1.00},
    {"date": "August 23, 2024", "time": "04:41 PM", "amount": -1.50},
    {"date": "August 23, 2024", "time": "04:41 PM", "amount": -1.50},
    {"date": "August 23, 2024", "time": "04:39 PM", "amount": -1.50},
    {"date": "August 23, 2024", "time": "04:38 PM", "amount": -4.00},
  ];

  String _username = '';
  double _saldo = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar el username y saldo desde Firestore y SharedPreferences
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      // Cargar username desde SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _username = prefs.getString('username') ?? 'Usuario';
      });

      // Cargar saldo desde Firestore usando el UID del usuario autenticado
      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            _saldo = double.tryParse(userDoc['saldo'].toString()) ?? 0.0;
          });
        } else {
          setState(() {
            _saldo = 0.0; // Si no existe el saldo en Firestore
          });
        }
      } catch (error) {
        print("Error obteniendo saldo: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.lightBlue),
                const SizedBox(width: 5),
                Text(
                  _username,
                  style: const TextStyle(color: Colors.lightBlue),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    'S/ ${_saldo.toStringAsFixed(2)}', // Mostrar el saldo con dos decimales
                    style: const TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: movements.length,
        itemBuilder: (context, index) {
          final movement = movements[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con la fecha si es el primer elemento o si cambia la fecha
              if (index == 0 ||
                  movement['date'] != movements[index - 1]['date'])
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  width: double.infinity,
                  color: Colors.blue,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      width: double.infinity,
                      color: Colors.blue,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                20), // Ajusta el valor según sea necesario
                          ),
                          padding: const EdgeInsets.all(
                              8.0), // Añade padding interno si es necesario
                          child: Text(
                            movement['date'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // El contenido de cada movimiento
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pago',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          movement['time'],
                          style: const TextStyle(
                              fontSize: 12.0, color: Colors.grey),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          movement['amount'].toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: movement['amount'] < 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Línea divisoria
              Divider(
                color: Colors.grey.shade300,
                height: 10,
                thickness: 1,
              ),
            ],
          );
        },
      ),
    );
  }
}
