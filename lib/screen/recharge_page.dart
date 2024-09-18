import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class RecargaPage extends StatefulWidget {
  const RecargaPage({Key? key}) : super(key: key);

  @override
  _RecargaPageState createState() => _RecargaPageState();
}

class _RecargaPageState extends State<RecargaPage> {
  bool _isVoucherFormVisible = false;
  File? _voucherImage;
  final TextEditingController _montoController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _voucherImage = File(pickedFile.path);
        });
      } else {
        // El usuario canceló la selección
        print('No se seleccionó ninguna imagen.');
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  void _submitVoucher() {
    if (_voucherImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecciona una imagen del voucher')),
      );
      return;
    }

    if (_montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, ingresa el monto de la recarga')),
      );
      return;
    }

    // Aquí puedes implementar la lógica para enviar el voucher
    // Por ahora, solo mostraremos un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voucher enviado exitosamente')),
    );
    // Limpiar el formulario y volver a la vista inicial
    setState(() {
      _isVoucherFormVisible = false;
      _voucherImage = null;
      _montoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          _isVoucherFormVisible ? _buildVoucherForm() : _buildContent(),
        ],
      ),
      floatingActionButton: _isVoucherFormVisible
          ? null
          : _buildSendVoucherButton(), // Ocultar el botón cuando el formulario está visible
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Fondo degradado
  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // Contenido principal
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Recargar',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          _buildPaymentOptions(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Opciones de pago en tarjetas
  Widget _buildPaymentOptions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                'Instrucciones',
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPaymentOption('assets/yape.png', 'Yape'),
              _buildPaymentOption('assets/plin.png', 'Plin'),
              _buildPaymentOption('assets/pagoefectivo.png', 'PagoEfectivo'),
            ],
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Ver cuentas bancarias',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta de opción de pago
  Widget _buildPaymentOption(String imagePath, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Image.asset(imagePath, width: 60, height: 60),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Botón flotante para enviar el voucher
  Widget _buildSendVoucherButton() {
    return FloatingActionButton.extended(
      backgroundColor: Colors.indigo,
      onPressed: () {
        setState(() {
          _isVoucherFormVisible = true;
        });
      },
      icon: const Icon(Icons.send, color: Colors.white),
      label: const Text(
        'Enviar voucher',
        style: TextStyle(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  // Formulario para enviar el voucher
  Widget _buildVoucherForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        children: [
          const Text(
            'Enviar Voucher',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showImageSourceOptions(),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
                image: _voucherImage != null
                    ? DecorationImage(
                        image: FileImage(_voucherImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _voucherImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo,
                            size: 50, color: Colors.grey[700]),
                        const Text('Toca para seleccionar una imagen'),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _montoController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Monto de la recarga',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _submitVoucher,
            child: const Text(
              'Enviar',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              setState(() {
                _isVoucherFormVisible = false;
                _voucherImage = null;
                _montoController.clear();
              });
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar opciones para elegir imagen usando CupertinoActionSheet
  void _showImageSourceOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Seleccionar imagen'),
        message: const Text('Elige una opción'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Cámara', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Galería', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
