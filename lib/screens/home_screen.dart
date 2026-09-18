import 'package:flutter/material.dart';
import 'package:rifa_gc/constants/app_colors.dart';
import 'package:rifa_gc/services/api_service.dart';

import '../widgets/numero_rifa.dart';
import 'venta_screen.dart';
import 'ventas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<int> numerosSeleccionados = {};

  Set<int> numerosVendidos = {};

  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarNumerosVendidos();
  }

  Future<void> cargarNumerosVendidos() async {
    try {
      final numeros = await ApiService.obtenerNumerosVendidos();

      if (!mounted) return;

      setState(() {
        numerosVendidos = numeros.toSet();
        cargando = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        error = e.toString();
      });
    }
  }

  void seleccionarNumero(int numero) {
    if (numerosVendidos.contains(numero)) {
      return;
    }

    setState(() {
      if (numerosSeleccionados.contains(numero)) {
        numerosSeleccionados.remove(numero);
      } else {
        numerosSeleccionados.add(numero);
      }
    });
  }

  Future<void> irAVenta() async {
    if (numerosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona al menos un número.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VentaScreen(
          numerosSeleccionados:
              numerosSeleccionados.toList()..sort(),
        ),
      ),
    );

    // La venta fue guardada correctamente
    // if (resultado == true) {
      // Limpiamos la selección
      setState(() {
        numerosSeleccionados.clear();
      });

      // Volvemos a consultar los números vendidos
      await cargarNumerosVendidos();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.confirmation_number),
            SizedBox(width: 8),
            Text(
              'Rifa GC',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ventas',
            icon: const Icon(Icons.receipt_long),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VentasScreen(),
                ),
              );

              setState(() {
                numerosSeleccionados.clear();
              });

              await cargarNumerosVendidos();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: cargando
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : error != null
                ? _buildError()
                : _buildContenido(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            const Text(
              'No se pudieron cargar las ventas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error!,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: cargarNumerosVendidos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    return Column(
      children: [
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: terracota, size: 18),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: terracota, width: 1.5),
              ),
              child: Icon(
                Icons.confirmation_number,
                color: terracotaOscuro,
                size: 26,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.auto_awesome, color: terracota, size: 18),
          ],
        ),

        const SizedBox(height: 8),

        // Título principal
        Text(
          '¡ELIGE TUS NÚMEROS!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: terracotaOscuro,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 6),

        // Subtítulo con hojas decorativas
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, color: terracota, size: 16),
            const SizedBox(width: 6),
            Text(
              'Cada número te acerca a ganar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: terracota,
              ),
            ),
            const SizedBox(width: 6),
            Transform.flip(
              flipX: true,
              child: Icon(Icons.eco, color: terracota, size: 16),
            ),
          ],
        ),

        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  // shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  physics: const BouncingScrollPhysics(),
                  itemCount: 200,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final numero = index + 1;

                    return NumeroRifa(
                      numero: numero,
                      vendido:
                          numerosVendidos.contains(numero),
                      seleccionado:
                          numerosSeleccionados.contains(numero),
                      onTap: () =>
                          seleccionarNumero(numero),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            0,
            24,
            0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: beige,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  color: terracota,
                ),
                const SizedBox(width: 8),
                Text(
                  'Seleccionados: ${numerosSeleccionados.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: terracotaOscuro,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            0,
            24,
            20,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: irAVenta,
              icon: const Icon(
                Icons.shopping_cart_outlined,
              ),
              label: const Text(
                'Vender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: terracota,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}