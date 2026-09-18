import 'package:flutter/material.dart';

class NumeroRifa extends StatelessWidget {
  final int numero;
  final bool vendido;
  final bool seleccionado;
  final VoidCallback? onTap;

  const NumeroRifa({
    super.key,
    required this.numero,
    required this.vendido,
    required this.seleccionado,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const terracota = Color(0xFFD99A84);
    const fondo = Color(0xFFFFFDF8);
    const vendidoColor = Color(0xFFE4DED4);
    const texto = Color(0xFF4A3B35);

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (vendido) {
      backgroundColor = vendidoColor;
      textColor = const Color(0xFF9A8B80);
      borderColor = const Color(0xFFD8CEC3);
    } else if (seleccionado) {
      backgroundColor = terracota;
      textColor = Colors.white;
      borderColor = terracota;
    } else {
      backgroundColor = fondo;
      textColor = texto;
      borderColor = const Color(0xFFE2D8CC);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: vendido ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: seleccionado ? 2 : 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                numero.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (vendido)
                Positioned(
                  right: 3,
                  top: 3,
                  child: Icon(
                    Icons.lock_outline,
                    size: 10,
                    color: textColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}