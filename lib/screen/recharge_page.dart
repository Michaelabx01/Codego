import 'package:flutter/material.dart';

class RecargaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Recargar',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            _buildPaymentOptions(),
            const Spacer(),
            _buildSendVoucherButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Instrucciones',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image.asset('assets/yape.png', width: 60, height: 60),
                  const SizedBox(height: 8),
                ],
              ),
              Column(
                children: [
                  Image.asset('assets/plin.png', width: 60, height: 60),
                  const SizedBox(height: 8),
                ],
              ),
              Column(
                children: [
                  Image.asset('assets/pagoefectivo.png', width: 60, height: 60),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Ver cuentas bancarias',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendVoucherButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          // Acción al enviar voucher
        },
        child: const Text(
          'Enviar voucher',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
