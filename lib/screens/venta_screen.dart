import 'package:flutter/material.dart';
import 'package:rifa_gc/constants/app_colors.dart';
import 'package:rifa_gc/models/general.dart';
import 'package:rifa_gc/models/vendedor.dart';
import 'package:rifa_gc/models/venta.dart';
import 'package:rifa_gc/services/api_service.dart';
import 'package:rifa_gc/widgets/numero_rifa.dart';
import 'package:rifa_gc/services/ticket_service.dart';
import 'package:rifa_gc/widgets/selector_vendedor.dart';

class VentaScreen extends StatefulWidget {
  final List<int> numerosSeleccionados;
  final Venta? venta;

  const VentaScreen({
    super.key,
    required this.numerosSeleccionados,
    this.venta,
  });

  bool get esEdicion => venta != null;

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController clienteController =
      TextEditingController();

  final TextEditingController telefonoController =
      TextEditingController();

  String? vendedorSeleccionado;
  String? idVendedorSeleccionado;
  bool guardando = false;
  Set<int> numerosSeleccionados = {};
  Set<int> numerosVendidos = {};
  List<Vendedor> vendedores = [];
  // General? informacionSorteo;
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

    if (widget.venta != null) {
      idVendedorSeleccionado = widget.venta!.idVendedor;
      vendedorSeleccionado = widget.venta!.vendedor;
      clienteController.text = widget.venta!.cliente;
      telefonoController.text = widget.venta!.telefono;
      numerosSeleccionados = widget.venta!.numeros.toSet();
    } else {
      numerosSeleccionados = widget.numerosSeleccionados.toSet();
    }

    cargarNumerosVendidos();
    cargarVendedores();
    cargarInformacionSorteo();
  }

  @override
  void dispose() {
    clienteController.dispose();
    telefonoController.dispose();
    super.dispose();
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
      print('Error: $e');
    }
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (vendedorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un vendedor.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    if (numerosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes seleccionar al menos un número.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      if (widget.esEdicion) {
        await ApiService.actualizarVenta(
          id: widget.venta!.id,
          idVendedor: idVendedorSeleccionado!,
          vendedor: vendedorSeleccionado!,
          cliente: clienteController.text.trim(),
          telefono: telefonoController.text.trim(),
          numeros: numerosSeleccionados.toList()..sort(),
        );

        if (!mounted) return;

        setState(() {
          guardando = false;
        });
        Navigator.pop(context, true);
      } else {
        final venta = await ApiService.guardarVenta(
          idVendedor: idVendedorSeleccionado!,
          vendedor: vendedorSeleccionado!,
          cliente: clienteController.text.trim(),
          telefono: telefonoController.text.trim(),
          numeros: numerosSeleccionados.toList()..sort(),
        );

        if (!mounted) return;

        setState(() {
          guardando = false;
        });

        TicketService.mostrarTicket(
          context,
          venta,
          informacionSorteo
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      final mensaje = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.error,
              color: Colors.red,
              size: 50,
            ),
            title: const Text('Error'),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> cargarNumerosVendidos() async {
    try {
      final ventas = await ApiService.obtenerVentas();

      final Set<int> vendidos = {};

      for (final venta in ventas) {
        // En edición no bloqueamos los números
        // pertenecientes a la venta actual.
        if (widget.venta != null &&
            venta.id == widget.venta!.id) {
          continue;
        }

        vendidos.addAll(venta.numeros);
      }

      if (!mounted) return;

      setState(() {
        numerosVendidos = vendidos;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudieron cargar los números vendidos.',
          ),
        ),
      );
    }
  }
  
  Future<void> cargarVendedores() async {
    try {
      final resultado = await ApiService.obtenerVendedores();      

      setState(() {
        vendedores = resultado;
      });
    } catch (e) {
      print('Error: $e');
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

  Widget construirNumeros() {
    if (widget.esEdicion) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),
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
            onTap: () {
              seleccionarNumero(numero);
            },
          );
        },
      );
    }

    final numeros = numerosSeleccionados.toList()..sort();

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: numeros.map(
            (numero) => Chip(
              label: Text(
                numero
                    .toString()
                    .padLeft(2, '0'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              avatar: const Icon(
                Icons.confirmation_number,
                size: 20,
              ),
            ),
          ).toList(),
        ),
      ),
    );
  }

  void cancelar() {
    numerosSeleccionados.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.esEdicion
              ? 'Editar venta'
              : 'Registrar venta',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // =========================================================
              // CAMPOS FIJOS
              // =========================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  0,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // -------------------------
                    // VENDEDOR
                    // -------------------------
                    const Text(
                      'Vendedor',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 8),

                    SelectorVendedor(
                      vendedores: vendedores,
                      idSeleccionado: idVendedorSeleccionado,
                      onSeleccionado: (vendedor) {
                        setState(() {
                          vendedorSeleccionado = vendedor.nombreVendedor;
                          idVendedorSeleccionado = vendedor.idVendedor;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // -------------------------
                    // CLIENTE
                    // -------------------------
                    const Text(
                      'Cliente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: clienteController,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Nombre del cliente',
                        prefixIcon: const Icon(
                          Icons.person,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Ingresa el nombre del cliente';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // -------------------------
                    // TELÉFONO
                    // -------------------------
                    const Text(
                      'Teléfono',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: telefonoController,
                      keyboardType:
                          TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Número de teléfono',
                        prefixIcon: const Icon(
                          Icons.phone,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Ingresa el teléfono';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // =========================================================
              // TÍTULO DE NÚMEROS
              // =========================================================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 20,
                      color: terracota,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      widget.esEdicion
                          ? 'Selecciona tus números'
                          : 'Números seleccionados',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: texto,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =========================================================
              // NÚMEROS
              // =========================================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: construirNumeros(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20,
          ),
          child: Row(
            children: [

              // CANCELAR
              Expanded(
                child: OutlinedButton(
                  onPressed: cancelar,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text(
                    'Cancelar',
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // GUARDAR / ACTUALIZAR
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: guardando ? null : guardar,
                  icon: guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),

                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),

                  label: Text(
                    guardando
                        ? 'Guardando...'
                        : widget.esEdicion
                            ? 'Actualizar'
                            : 'Guardar',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}