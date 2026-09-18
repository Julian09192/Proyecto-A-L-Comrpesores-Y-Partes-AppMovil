import 'package:flutter/material.dart';
import '../models/products/producto_model.dart';
import '../services/products/favoritos_service.dart';

class ProductoCard extends StatefulWidget {
  final ProductoModel producto;
  final VoidCallback? onTap;

  const ProductoCard({
    super.key,
    required this.producto,
    this.onTap,
  });

  @override
  State<ProductoCard> createState() => _ProductoCardState();
}

class _ProductoCardState extends State<ProductoCard> {
  bool _esFavorito = false;
  final FavoritosService _favoritosService = FavoritosService();

  @override
  void initState() {
    super.initState();
    _cargarEstadoFavorito();
  }

  Future<void> _cargarEstadoFavorito() async {
    // Leemos directo desde la base de datos de Supabase
    final estado = await _favoritosService.esFavorito(widget.producto.id!);
    if (mounted) {
      setState(() {
        _esFavorito = estado;
      });
    }
  }

  Future<void> _toggleFavorito() async {
    // Cambio visual inmediato para que se sienta súper rápido
    setState(() => _esFavorito = !_esFavorito);

    try {
      // Intentamos procesarlo en Supabase
      await _favoritosService.toggleFavorito(widget.producto.id!);
    } catch (e) {
      // Si falla, revertimos el color del corazón
      setState(() => _esFavorito = !_esFavorito);

      if (e.toString().contains('no_auth')) {
        _mostrarModalRegistro();
      } else if (e.toString().contains('no_cliente')) {
        _mostrarAvisoRol();
      }
    }
  }

  // 🚀 EL MODAL PARA INVITAR A REGISTRARSE
  void _mostrarModalRegistro() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDB913).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded, color: Color(0xFFFDB913), size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Guarda tus equipos favoritos!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F2537)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Crea una cuenta gratuita o inicia sesión para guardar productos y acceder a ellos desde cualquier dispositivo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF7A837E), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Asegúrate de que esta sea la ruta de tu login
                    Navigator.pushNamed(context, '/login'); 
                  },
                  child: const Text('INICIAR SESIÓN / REGISTRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ahora no', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              )
            ],
          ),
        );
      },
    );
  }

  // Aviso si un Admin/Empleado intenta guardar favoritos
  void _mostrarAvisoRol() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('La función de favoritos es exclusiva para clientes.'),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap, 
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade100,
                    child: Image.network(
                      widget.producto.imagenUrl ?? '',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.producto.tipo.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 🚀 CORAZÓN INTERACTIVO
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              _esFavorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 22,
                              color: _esFavorito ? Colors.redAccent : Colors.grey.shade400,
                            ),
                            onPressed: _toggleFavorito,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.producto.nombre,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildTag(widget.producto.marca),
                          const SizedBox(width: 6),
                          _buildTag('Stock: ${widget.producto.stockTotal}'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '\$${widget.producto.precio.toStringAsFixed(0)} COP',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}