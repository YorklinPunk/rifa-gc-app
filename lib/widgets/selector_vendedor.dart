import 'package:flutter/material.dart';
import 'package:rifa_gc/models/vendedor.dart';

class SelectorVendedor extends StatefulWidget {
  final List<Vendedor> vendedores;
  final String? idSeleccionado;
  final ValueChanged<Vendedor> onSeleccionado;

  const SelectorVendedor({
    super.key,
    required this.vendedores,
    required this.idSeleccionado,
    required this.onSeleccionado,
  });

  @override
  State<SelectorVendedor> createState() => _SelectorVendedorState();
}

class _SelectorVendedorState extends State<SelectorVendedor> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void deactivate() {
    _cerrarMenuInmediato();
    super.deactivate();
  }

  @override
  void dispose() {
    _cerrarMenuInmediato();
    super.dispose();
  }
  
  void _cerrarMenuInmediato() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _cerrarMenu();
    } else {
      _abrirMenu();
    }
  }

  void _abrirMenu() {
    final renderBox =
        _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final width = renderBox.size.width;
    final height = renderBox.size.height;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Barrera invisible para cerrar el menú al tocar afuera
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _cerrarMenu,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, height + 4),
            child: SizedBox(
              width: width,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 4 * 48.0, // ~4 ítems visibles
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.vendedores.length,
                    itemBuilder: (context, index) {
                      final vendedor = widget.vendedores[index];
                      final seleccionado =
                          vendedor.idVendedor == widget.idSeleccionado;

                      return ListTile(
                        title: Text(
                          vendedor.nombreVendedor,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: seleccionado,
                        onTap: () {
                          widget.onSeleccionado(vendedor);
                          _cerrarMenu();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _cerrarMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final coincidencias = widget.vendedores
        .where((v) => v.idVendedor == widget.idSeleccionado)
        .toList();
    final texto =
        coincidencias.isNotEmpty ? coincidencias.first.nombreVendedor : null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _fieldKey,
        onTap: _toggleMenu,
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: 'Seleccionar vendedor',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: Icon(
              _overlayEntry != null
                  ? Icons.arrow_drop_up
                  : Icons.arrow_drop_down,
            ),
          ),
          child: Text(
            texto ?? 'Seleccionar vendedor',
            style: TextStyle(
              color: texto == null ? Colors.grey.shade600 : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}