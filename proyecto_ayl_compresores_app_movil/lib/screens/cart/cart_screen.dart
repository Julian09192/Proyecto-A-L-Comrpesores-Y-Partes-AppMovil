import 'package:flutter/material.dart';
import '../../services/products/cart_service.dart';
<<<<<<< HEAD
import 'pasarela_pago_screen.dart';
=======
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChange);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChange);
    super.dispose();
  }

  void _onCartChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mi Carrito de Compras',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                _cartService.clear();
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tu carrito está vacío',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      elevation: 0,
                    ),
                    child: const Text(
                      'Explorar catálogo',
<<<<<<< HEAD
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
=======
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
<<<<<<< HEAD
=======
                            // Miniatura del producto
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 70,
                                height: 70,
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
<<<<<<< HEAD
                                    : const Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
=======
                                    : const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Nombre, marca y precio
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.marca.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item.nombre,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.precio.toStringAsFixed(0)} COP',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
<<<<<<< HEAD
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _cartService.decrement(index),
=======

                            // Controles de cantidad (+ / -)
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () => _cartService.decrement(index),
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
                                ),
                                Text(
                                  '${item.cantidad}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                IconButton(
<<<<<<< HEAD
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _cartService.increment(index),
=======
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () => _cartService.increment(index),
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
<<<<<<< HEAD
=======

                // Resumen inferior
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
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
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '\$${_cartService.totalAmount.toStringAsFixed(0)} COP',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
<<<<<<< HEAD
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PasarelaPagoScreen(
                                    itemsCarrito: _cartService.items,
                                    totalPagar: _cartService.totalAmount,
                                  ),
=======
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Procediendo a la cotización / compra...'),
                                  backgroundColor: Colors.black87,
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
                                ),
                              );
                            },
                            child: const Text(
                              'Continuar Cotización / Compra',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
