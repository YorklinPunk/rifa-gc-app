import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rifa_gc/constants/app_colors.dart';
import 'package:rifa_gc/models/general.dart';

import '../models/venta.dart';

class TicketBoleto extends StatelessWidget {
  final Venta venta;
  final General informacionSorteo;

  const TicketBoleto({super.key, required this.venta, required this.informacionSorteo});

  @override
  Widget build(BuildContext context) {
    final numerosOrdenados = List<int>.from(venta.numeros)..sort();

    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.confirmation_number, color: terracotaOscuro),
              const SizedBox(width: 8),
              Text(
                'RIFA GC',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: terracotaOscuro,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'COMPROBANTE DE COMPRA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: terracota,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 16),
          _lineaPunteada(),
          const SizedBox(height: 16),

          _dato('Cliente', venta.cliente),
          _dato('Teléfono', venta.telefono),
          _dato('Vendedor', venta.vendedor),
          _dato(
            'Fecha del sorteo',
            DateFormat('dd/MM/yyyy - hh:mm a').format(informacionSorteo.fechaHoraSorteo),
          ),

          const SizedBox(height: 12),

          Text(
            'NÚMEROS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: terracotaOscuro,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: numerosOrdenados.map((n) {
              return Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: beige,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: terracota, width: 1.2),
                ),
                child: Text(
                  n.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: terracotaOscuro,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          _lineaPunteada(),
          const SizedBox(height: 10),

          Center(
            child: Text(
              'Ticket N.º ${venta.id.toString().padLeft(5, '0')}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          Center(
            child: Text(
              'Emitido: ${DateFormat('dd/MM/yyyy HH:mm').format(venta.fechaRegistro)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: terracotaOscuro,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineaPunteada() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        final dashCount = (constraints.maxWidth / (dashWidth * 2)).floor();
        return Row(
          children: List.generate(dashCount, (_) {
            return Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: Colors.grey.shade300,
              ),
            );
          }),
        );
      },
    );
  }
}