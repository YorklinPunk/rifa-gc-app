import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rifa_gc/models/general.dart';
import 'package:rifa_gc/screens/venta_screen.dart';
import 'package:rifa_gc/services/api_service.dart';
import 'package:rifa_gc/constants/app_colors.dart';
import 'package:rifa_gc/models/venta.dart';
import 'package:rifa_gc/services/ticket_service.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<Venta> ventas = [];
  bool cargando = true;
  String? error;
  General informacionSorteo = General(
    id: '',
    fechaRegistro: DateTime.now(),
    fechaHoraSorteo: DateTime.utc(2026, DateTime.september, 20),
    urlEnlaceSorteo: '',
    mensajeSorteo: '¡Aquí está tu ticket de Rifa! 🎟️',
    subMensajeSorteo: 'Te esperamos!!',
  );

  @override  
  void initState() {
    super.initState();
    cargarVentas();
    cargarInformacionSorteo();
  }

  String formatoFecha(DateTime fecha) {
    return DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(fecha);
  }

  Future<void> cargarInformacionSorteo() async {
    try {
      final general = await ApiService.obtenerInformacion();

      if (!mounted) return;

      setState(() {
        informacionSorteo = general;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> cargarVentas() async {
    try {
      final resultado = await ApiService.obtenerVentas();

      if (!mounted) return;

      setState(() {
        ventas = resultado;
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

  Future<void> eliminarVenta(int index) async {
    final venta = ventas[index];

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar venta'),
          content: Text(
            '¿Estás seguro de eliminar la venta de '
            '${venta.cliente}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await ApiService.eliminarVenta(venta.id);

      if (!mounted) return;

      setState(() {
        ventas.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Venta eliminada correctamente.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Indicamos a HomeScreen que hubo un cambio
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final mensaje = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ventas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: cargarVentas,
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
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
                onPressed: () {
                  setState(() {
                    cargando = true;
                    error = null;
                  });

                  cargarVentas();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (ventas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'No hay ventas registradas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ventas.length,
      itemBuilder: (context, index) {
        final venta = ventas[index];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        venta.cliente
                            .substring(0, 1)
                            .toUpperCase(),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            venta.cliente,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            venta.telefono,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 25),

                Text(
                  'Vendedor: ${venta.vendedor}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Números:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: venta.numeros
                      .map(
                        (numero) => Chip(
                          label: Text(
                            numero
                                .toString()
                                .padLeft(2, '0'),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 5),

                Text(
                  formatoFecha(
                    venta.fechaRegistro,
                  ),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Generar ticket',
                      onPressed: () => TicketService.mostrarTicket(context, venta, informacionSorteo),
                      icon: const Icon(Icons.confirmation_number_outlined),
                      color: terracota,
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VentaScreen(
                              venta: venta,
                              numerosSeleccionados:
                                  List<int>.from(venta.numeros),
                            ),
                          ),
                        );

                        if (resultado == true) {
                          await cargarVentas();
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),

                    TextButton.icon(
                      onPressed: () => eliminarVenta(index),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Eliminar', style: TextStyle(color: Colors.red))
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}