import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../../services/supabase/supabase_service.dart';

class EmpleadoDashboard extends StatefulWidget {
  const EmpleadoDashboard({super.key});

  @override
  State<EmpleadoDashboard> createState() => _EmpleadoDashboardState();
}

class _EmpleadoDashboardState extends State<EmpleadoDashboard> {
  // Cliente de Supabase obtenido a través de tu SupabaseService
  final SupabaseClient _supabase = SupabaseService.client;

  bool _cargando = true;
  int _totalProductos = 0;
  int _unidadesTotales = 0;
  int _alertasStock = 0;
  List<Map<String, dynamic>> _ultimosProductos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosDashboard();
  }

  // --- CONSULTA A SUPABASE ---
  Future<void> _cargarDatosDashboard() async {
    setState(() => _cargando = true);
    try {
      // Consulta a la tabla de productos ordenados por fecha de creación
      final response = await _supabase
          .from('productos')
          .select()
          .order('created_at', ascending: false)
          .limit(10);

      final lista = List<Map<String, dynamic>>.from(response);

      int stockAcumulado = 0;
      int bajoStock = 0;

      for (var item in lista) {
        // Tolerancia a nombres de columna en Supabase ('stock' o 'cantidad')
        final stock = (item['stock'] ?? item['cantidad'] ?? 0) as int;
        stockAcumulado += stock;
        if (stock <= 5) {
          bajoStock++;
        }
      }

      if (mounted) {
        setState(() {
          _ultimosProductos = lista;
          _totalProductos = lista.length;
          _unidadesTotales = stockAcumulado;
          _alertasStock = bajoStock;
          _cargando = false;
        });
      }
    } catch (e) {
      debugPrint('Aviso/Error consultando Supabase en EmpleadoDashboard: $e');
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }
  Future<void> _cerrarSesion() async {
    try {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text(
          'Panel de Control - Empleado',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: 'Sincronizar Datos',
            onPressed: _cargarDatosDashboard,
          )
        ],
      ),
      drawer: _construirMenuLateral(context),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : RefreshIndicator(
              onRefresh: _cargarDatosDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Últimas novedades del inventario y productos',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    
                    // Tarjetas métricas operativas
                    _construirTarjetasMetricas(),
                    
                    const SizedBox(height: 30),
                    
                    // Encabezado de la lista
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Últimos productos agregados',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Sincronizado con Supabase',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.amber),
                          onPressed: _cargarDatosDashboard,
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // Lista dinámica de productos
                    _construirListaProductos(),
                  ],
                ),
              ),
            ),
    );
  }

  // --- MENÚ LATERAL (EXCLUSIVO DE EMPLEADO) ---
  Widget _construirMenuLateral(BuildContext context) {
    final emailUsuario = _supabase.auth.currentUser?.email ?? 'empleado@aylcompresores.com';

    return Drawer(
      backgroundColor: const Color(0xFF1E1E24),
      child: Column(
        children: [
          // Encabezado del usuario
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            color: Colors.black26,
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emailUsuario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Rol Operativo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // Opciones de navegación (se omitió la vista de Usuarios)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _itemMenu(Icons.dashboard, 'Dashboard', activo: true, onTap: () {
                  Navigator.pop(context);
                }),
                _itemMenu(Icons.inventory_2, 'Productos', onTap: () {
                  Navigator.pop(context);
                  // Si deseas abrir la pantalla del catálogo de productos:
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductosScreen()));
                }),
                _itemMenu(Icons.book, 'Bitácora', onTap: () {
                  Navigator.pop(context);
                }),
                _itemMenu(Icons.bar_chart, 'Reportes', onTap: () {
                  Navigator.pop(context);
                }),
                _itemMenu(Icons.notifications, 'Notificaciones', onTap: () {
                  Navigator.pop(context);
                }),
                _itemMenu(Icons.settings, 'Mi Perfil', onTap: () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          
          const Divider(color: Colors.white24),
          
          // Botón de Cierre de Sesión
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
            onTap: _cerrarSesion,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _itemMenu(IconData icono, String titulo,
      {bool activo = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icono, color: activo ? Colors.amber : Colors.grey),
      title: Text(
        titulo,
        style: TextStyle(
          color: activo ? Colors.amber : Colors.grey,
          fontWeight: activo ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: activo ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
      onTap: onTap,
    );
  }

  Widget _construirTarjetasMetricas() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _tarjeta('CATÁLOGO GENERAL', '$_totalProductos', Icons.inventory, Colors.amber),
        _tarjeta('UNIDADES DISPONIBLES', '$_unidadesTotales', Icons.layers, Colors.black),
        _tarjeta('ALERTAS DE STOCK', '$_alertasStock', Icons.warning_amber_rounded, Colors.orange),
      ],
    );
  }

  Widget _tarjeta(String titulo, String valor, IconData icono, Color colorIcono) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(icono, size: 20, color: colorIcono),
            ],
          ),
          const SizedBox(height: 10),
          Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- LISTA DE PRODUCTOS DINÁMICA ---
  Widget _construirListaProductos() {
    if (_ultimosProductos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text(
            'No hay productos registrados en la base de datos.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: _ultimosProductos.map((prod) {
        final nombre = prod['nombre'] ?? prod['titulo'] ?? 'Producto sin nombre';
        final referencia = prod['referencia'] ?? prod['codigo'] ?? 'S/R';
        final stock = (prod['stock'] ?? prod['cantidad'] ?? 0) as int;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Ref: $referencia  •  $stock und.',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stock <= 5 ? Colors.redAccent : Colors.black,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  stock <= 5 ? 'Stock Bajo' : 'Disponible',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}