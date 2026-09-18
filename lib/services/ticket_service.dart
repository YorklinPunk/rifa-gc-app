import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rifa_gc/models/general.dart';
import 'package:share_plus/share_plus.dart';

import '../models/venta.dart';
import '../widgets/ticket_boleto.dart';

class TicketService {
  /// Muestra el ticket y permite guardarlo o compartirlo.
  static void mostrarTicket(
    BuildContext context,
    Venta venta,
    General informacionSorteo,
  ) {
    final GlobalKey ticketKey = GlobalKey();

    bool cerrando = false;

    void cerrarTicket() {
      if (cerrando) return;

      cerrando = true;

      // Primero cerramos el Dialog del ticket
      Navigator.of(context).pop();

      // Luego cerramos VentaScreen y regresamos a la vista anterior
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // -----------------------------------
              // TODO ESTO ES TU TICKET ORIGINAL
              // -----------------------------------
              Container(
                width: 320,
                constraints: const BoxConstraints(
                  maxWidth: 320,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RepaintBoundary(
                      key: ticketKey,
                      child: TicketBoleto(
                        venta: venta,
                        informacionSorteo: informacionSorteo,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              guardarTicket(
                                context,
                                ticketKey,
                              );
                            },
                            icon: const Icon(
                              Icons.download,
                              size: 18,
                            ),
                            label: const Text('Guardar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              compartirTicket(
                                context,
                                ticketKey,
                                informacionSorteo
                              );
                            },
                            icon: const Icon(
                              Icons.share,
                              size: 18,
                            ),
                            label: const Text('Compartir'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // -----------------------------------
              // X PARA CERRAR
              // -----------------------------------
              Positioned(
                top: -45,
                right: -5,
                child: GestureDetector(
                  onTap: cerrarTicket,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Si se tocó fuera del ticket, también regresamos
      // a la pantalla anterior.
      if (!cerrando && context.mounted) {
        cerrando = true;

        Navigator.of(context).pop(true);
      }
    });
  }

  /// Convierte el widget del ticket en PNG.
  static Future<Uint8List> _capturarTicket(
    GlobalKey ticketKey,
  ) async {
    final boundary = ticketKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(
      pixelRatio: 3.0,
    );

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('No se pudo generar la imagen del ticket');
    }

    return byteData.buffer.asUint8List();
  }

  /// Guarda el ticket en la galería.
  static Future<void> guardarTicket(
    BuildContext context,
    GlobalKey ticketKey,
  ) async {
    try {
      final Uint8List pngBytes = await _capturarTicket(
        ticketKey,
      );

      await Gal.putImageBytes(
        pngBytes,
        name: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ticket guardado en la galería.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar el ticket: $e',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Comparte el ticket como imagen PNG.
  static Future<void> compartirTicket(
    BuildContext context,
    GlobalKey ticketKey,
    General informacionSorteo,
  ) async {
    try {
      final Uint8List pngBytes = await _capturarTicket(
        ticketKey,
      );

      final tempDir = await getTemporaryDirectory();

      final file = File(
        '${tempDir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [
          XFile(file.path),
        ],
        text: '${informacionSorteo.mensajeSorteo}\n${informacionSorteo.subMensajeSorteo}\n${informacionSorteo.urlEnlaceSorteo}',
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo compartir el ticket: $e',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// class _TicketExitoDialog extends StatefulWidget {
//   final GlobalKey ticketKey;
//   final Venta venta;
//   final String titulo;
//   final String mensaje;

//   const _TicketExitoDialog({
//     required this.ticketKey,
//     required this.venta,
//     required this.titulo,
//     required this.mensaje,
//   });

//   @override
//   State<_TicketExitoDialog> createState() => _TicketExitoDialogState();
// }

// class _TicketExitoDialogState extends State<_TicketExitoDialog> {
//   bool mostrarExito = true;

//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(const Duration(milliseconds: 1800), () {
//       if (!mounted) return;

//       setState(() {
//         mostrarExito = false;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // --------------------------------
//           // TICKET
//           // --------------------------------
//           Container(
//             width: 320,
//             constraints: const BoxConstraints(
//               maxWidth: 320,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 RepaintBoundary(
//                   key: widget.ticketKey,
//                   child: TicketBoleto(
//                     venta: widget.venta,
//                     informacionSorteo: null,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Flexible(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           TicketService.guardarTicket(
//                             context,
//                             widget.ticketKey,
//                           );
//                         },
//                         icon: const Icon(
//                           Icons.download,
//                           size: 18,
//                         ),
//                         label: const Text('Guardar'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepOrange,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(width: 8),

//                     Flexible(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           TicketService.compartirTicket(
//                             context,
//                             widget.ticketKey,
//                             widget.informacionSorteo,
//                           );
//                         },
//                         icon: const Icon(
//                           Icons.share,
//                           size: 18,
//                         ),
//                         label: const Text('Compartir'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // --------------------------------
//           // MENSAJE DE ÉXITO
//           // --------------------------------
//           IgnorePointer(
//             ignoring: true,
//             child: AnimatedOpacity(
//               opacity: mostrarExito ? 1.0 : 0.0,
//               duration: const Duration(milliseconds: 800),
//               curve: Curves.easeOut,
//               child: Container(
//                 width: 280,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 28,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: const [
//                     BoxShadow(
//                       blurRadius: 20,
//                       color: Colors.black26,
//                       offset: Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.check_circle,
//                       color: exito,
//                       size: 64,
//                     ),

//                     const SizedBox(height: 12),

//                     Text(
//                       widget.titulo,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     Text(
//                       widget.mensaje,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }