import 'package:flutter/material.dart';
// ¡IMPORTANTE! Asegúrate de que esta ruta coincida con dónde guardaste el archivo
import 'admin_usuarios_view.dart'; 

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E24), 
        title: const Text('Panel de Control', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: () {
              // Botón de sincronizar que tienes arriba a la derecha
            },
          )
        ],
      ),
      drawer: _construirMenuLateral(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Últimas novedades del inventario y estado global', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            
            _construirTarjetasMetricas(),
            
            const SizedBox(height: 30),
            
            const Text('Últimos 10 productos agregados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Mostrando resultados recientes', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 15),
            
            _construirListaProductosPlaceholder(),
          ],
        ),
      ),
    );
  }

  // --- EL MENÚ HAMBURGUESA (DRAWER) ---
  Widget _construirMenuLateral(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E24), 
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            color: Colors.black26,
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.shield, color: Colors.black),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Admin A&L', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                      child: const Text('Nivel Máster', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _itemMenu(Icons.dashboard, 'Dashboard', activo: true, onTap: () {
                  Navigator.pop(context); // Cierra el menú lateral
                }),
                _itemMenu(Icons.inventory_2, 'Productos', onTap: () {}),
                _itemMenu(Icons.book, 'Bitácora', onTap: () {}),
                
                // AQUÍ CONECTAMOS LA VISTA DE USUARIOS
                _itemMenu(Icons.people, 'Usuarios', onTap: () {
                  Navigator.pop(context); // Primero cierra el menú lateral
                  Navigator.push( // Luego navega a la nueva vista
                    context, 
                    MaterialPageRoute(builder: (context) => const AdminUsuariosView())
                  );
                }),
                
                _itemMenu(Icons.bar_chart, 'Reportes', onTap: () {}),
                _itemMenu(Icons.notifications, 'Notificaciones', onTap: () {}),
                _itemMenu(Icons.settings, 'Mi Perfil', onTap: () {}),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- WIDGET DE ITEM DE MENÚ MODIFICADO ---
  // Ahora recibe un "onTap" como parámetro para que cada botón haga algo distinto
  Widget _itemMenu(IconData icono, String titulo, {bool activo = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icono, color: activo ? Colors.amber : Colors.grey),
      title: Text(titulo, style: TextStyle(color: activo ? Colors.amber : Colors.grey, fontWeight: activo ? FontWeight.bold : FontWeight.normal)),
      tileColor: activo ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
      onTap: onTap, // Le pasamos la acción aquí
    );
  }

  // --- TARJETAS DE MÉTRICAS GLOBALES ---
  Widget _construirTarjetasMetricas() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _tarjeta('CATÁLOGO GENERAL', '20', Icons.inventory, Colors.amber),
        _tarjeta('UNIDADES DISPONIBLES', '243', Icons.layers, Colors.black),
        _tarjeta('VALOR DEL INVENTARIO', '\$31.4M', Icons.attach_money, Colors.black),
        _tarjeta('ALERTAS DE STOCK', '9', Icons.warning_amber_rounded, Colors.orange),
      ],
    );
  }

  Widget _tarjeta(String titulo, String valor, IconData icono, Color colorIcono) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(titulo, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
              Icon(icono, size: 20, color: colorIcono),
            ],
          ),
          const SizedBox(height: 10),
          Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- ÁREA PARA TU COMPAÑERO (LISTA DE PRODUCTOS) ---
  Widget _construirListaProductosPlaceholder() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filtro Separador FS-19732', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Ref: FS-19732-001  •  8 und.', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
                child: const Text('Stock Crítico', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      }),
    );
  }
}