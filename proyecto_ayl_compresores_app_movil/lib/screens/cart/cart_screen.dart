import 'package:flutter/material.dart';
import '../../services/products/cart_service.dart';
import 'pasarela_pago_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return ListenableBuilder(
      listenable: cartService,
      builder: (context, _) {
        final items = cartService.items;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF222222), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Carrito de Compras',
              style: TextStyle(
                color: Color(0xFF0F2537),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            centerTitle: true,
            actions: [
              if (items.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                  tooltip: 'Vaciar carrito',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        title: const Text('¿Vaciar el carrito?', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F2537))),
                        content: const Text('Se eliminarán todos los equipos seleccionados de tu lista actual.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade800,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              cartService.clear();
                            },
                            child: const Text('Vaciar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDB913).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 54,
                            color: Color(0xFFFDB913),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Tu carrito está vacío',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F2537),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Explora nuestro catálogo industrial y añade equipos o repuestos para cotizar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.5, color: Color(0xFF7A837E)),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 48,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF222222),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Explorar catálogo',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Miniatura del producto
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 75,
                                    height: 75,
                                    color: Colors.grey.shade100,
                                    child: item.imagenUrl.isNotEmpty
                                        ? Image.network(
                                            item.imagenUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => const Icon(
                                              Icons.image_not_supported_outlined,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Nombre, marca y precio
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.marca.toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFFE59819),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.nombre,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F2537),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '\$${item.precio.toStringAsFixed(0)} COP',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF222222),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Controles de cantidad modernos
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () => cartService.increment(index),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.add, size: 16, color: Color(0xFF222222)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          '${item.cantidad}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                            color: Color(0xFF0F2537),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => cartService.decrement(index),
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.remove, size: 16, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Resumen inferior corporativo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total estimado:',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF7A837E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '\$${cartService.totalAmount.toStringAsFixed(0)} COP',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F2537),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFDB913),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PasarelaPagoScreen(
                                        itemsCarrito: cartService.items,
                                        totalPagar: cartService.totalAmount,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Continuar Cotización / Compra',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    letterSpacing: 0.5,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}