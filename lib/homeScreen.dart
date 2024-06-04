import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:xchange4me/servicioAPI.dart';

class PantallaPrincipal extends StatefulWidget {
  @override
  _PantallaPrincipalState createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final _controladorMonto = TextEditingController();
  double _tasaCambioDolar = 1.0;
  double _tasaCambioBolivar = 1.0;
  double _tasaCambioEuro = 1.0;
  String _resultadoConversion = '';
  bool _isConnected = false;

  void _checkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        _isConnected = true;
      });
    } else {
      setState(() {
        _isConnected = false;
      });
    }
  }

  void _convertir() async {
    _checkConnection();
    if (_isConnected) {
      
      String montoString = _controladorMonto.text.trim();
      double monto = double.tryParse(montoString) ?? 0.0;

      if (monto == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El campo de monto no puede estar vacío.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      var servicioAPI = ServicioAPI();
      var url = Uri.parse('https://api.exchangerate-api.com/v4/latest/COP');
      var tasasCambio = await servicioAPI.obtenerTasasCambio(url);

      setState(() {
        _tasaCambioDolar = tasasCambio['rates']?['USD'] ?? 1.0;
        _tasaCambioBolivar = tasasCambio['rates']?['VEF'] ?? 1.0;
        _tasaCambioEuro = tasasCambio['rates']?['EUR'] ?? 1.0;
        _resultadoConversion = '''
          Dólares: ${(monto * _tasaCambioDolar).toStringAsFixed(2)}
          Bolívares: ${(monto * _tasaCambioBolivar).toStringAsFixed(2)}
          Euros: ${(monto * _tasaCambioEuro).toStringAsFixed(2)}
        ''';
      });
      
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sin conexión a internet'),
          content: Text('La conversión requiere conexión a internet. Por favor, verifique su conexión e intente nuevamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Aceptar'),
            ),
          ],
        ),
      );

    }
  }

  void _limpiarPantalla() {
    setState(() {
      _controladorMonto.text = '';
      _tasaCambioDolar = 1.0;
      _tasaCambioBolivar = 1.0;
      _tasaCambioEuro = 1.0;
      _resultadoConversion = '';

    });
  }

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversor de Monedas'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Add "Xchange 4 Me" text
            Text(
              'Xchange 4 Me',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _controladorMonto,
              decoration: InputDecoration(
                labelText: 'Monto en Pesos Colombianos',
                fillColor: Colors.green,
                filled: true,
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.attach_money),
                  label: Text('Convertir'),
                  onPressed: _convertir,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.clear),
                  label: Text('Limpiar'),
                  onPressed: _limpiarPantalla,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(_resultadoConversion),
          ],
        ),
      ),
    );
  }
}