import 'package:flutter/material.dart';
import 'package:proyecto_ayl_compresores_app_movil/models/user/usuario_model.dart';
import 'package:proyecto_ayl_compresores_app_movil/services/user/usuario_service.dart';

class AdminUsuariosView extends StatefulWidget {
  const AdminUsuariosView({super.key});

  @override
  State<AdminUsuariosView> createState() => _AdminUsuariosViewState();
}

class _AdminUsuariosViewState extends State<AdminUsuariosView> {
  List<Usuario> usuarios = [];
  List<Usuario> usuariosFiltrados = [];
  bool isLoading = true;
  
  // Controladores y filtros
  final TextEditingController _searchController = TextEditingController();
  String _filtroRolSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => isLoading = true);
    try {
      final data = await UsuarioService.obtenerUsuarios();
      setState(() {
        usuarios = data;
        usuariosFiltrados = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión con la API', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }

  // Lógica de filtrado por texto y por rol
  void _filtrarUsuarios(String query) {
    setState(() {
      usuariosFiltrados = usuarios.where((usuario) {
        final coincideTexto = usuario.nombre.toLowerCase().contains(query.toLowerCase()) ||
                              usuario.correo.toLowerCase().contains(query.toLowerCase());
        
        if (_filtroRolSeleccionado == 'Todos') {
          return coincideTexto;
        } else if (_filtroRolSeleccionado == 'Admin') {
          return coincideTexto && ['admin', 'administrador'].contains(usuario.rol.toLowerCase());
        } else if (_filtroRolSeleccionado == 'Empleado') {
          return coincideTexto && usuario.rol.toLowerCase() == 'empleado';
        } else if (_filtroRolSeleccionado == 'Cliente') {
          return coincideTexto && usuario.rol.toLowerCase() == 'cliente';
        }
        return coincideTexto;
      }).toList();
    });
  }

  Future<void> _cambiarEstadoUsuario(Usuario usuario, String nuevoRol, bool estaSuspendido) async {
    setState(() {
      usuario.rol = nuevoRol;
      usuario.suspendido = estaSuspendido;
    });

    final exito = await UsuarioService.actualizarUsuario(usuario.id, nuevoRol, estaSuspendido);
    
    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario ${usuario.nombre} actualizado'), backgroundColor: Colors.green),
      );
    } else {
      _cargarUsuarios(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar permisos'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Control de Usuarios', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF1E1E24),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.sync), onPressed: _cargarUsuarios),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : Column(
            children: [
              _construirCarruselMetricas(),
              
              // --- BARRA DE BÚSQUEDA Y FILTROS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _filtrarUsuarios,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o correo...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Filtros rápidos por botones horizontales
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Todos', 'Admin', 'Empleado', 'Cliente'].map((rol) {
                          bool seleccionado = _filtroRolSeleccionado == rol;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(rol),
                              selected: seleccionado,
                              selectedColor: Colors.amber,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(color: seleccionado ? Colors.black : Colors.grey.shade700, fontWeight: FontWeight.bold),
                              onSelected: (bool selected) {
                                setState(() {
                                  _filtroRolSeleccionado = rol;
                                  _filtrarUsuarios(_searchController.text);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // --- LISTA DE USUARIOS FILTRADOS ---
              Expanded(
                child: usuariosFiltrados.isEmpty
                  ? const Center(child: Text('No se encontraron usuarios', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: usuariosFiltrados.length,
                      itemBuilder: (context, index) {
                        return _construirTarjetaUsuario(usuariosFiltrados[index]);
                      },
                    ),
              ),
            ],
          ),
    );
  }

  Widget _construirCarruselMetricas() {
    int total = usuarios.length;
    int activos = usuarios.where((u) => !u.suspendido).length;
    int admin = usuarios.where((u) => ['admin', 'administrador'].contains(u.rol.toLowerCase())).length;

    return Container(
      height: 110,
      margin: const EdgeInsets.only(top: 15),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          _tarjetaMetrica('TOTAL', total.toString(), Colors.black),
          _tarjetaMetrica('ACTIVOS', activos.toString(), Colors.green),
          _tarjetaMetrica('SUSPENDIDOS', (total - activos).toString(), Colors.red),
          _tarjetaMetrica('ADMINS', admin.toString(), Colors.amber.shade700),
        ],
      ),
    );
  }

  Widget _tarjetaMetrica(String titulo, String valor, Color colorValor) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(titulo, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorValor)),
        ],
      ),
    );
  }

  Widget _construirTarjetaUsuario(Usuario usuario) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: usuario.suspendido ? Colors.red.shade100 : Colors.amber.shade100,
                  child: Text(usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : 'U', style: TextStyle(color: usuario.suspendido ? Colors.red : Colors.amber.shade900, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(usuario.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(usuario.correo, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 35,
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: ['admin', 'administrador'].contains(usuario.rol.toLowerCase()) ? 'Administrador' : 
                             usuario.rol.toLowerCase() == 'empleado' ? 'Empleado' : 'Cliente',
                      style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w600),
                      items: ['Administrador', 'Empleado', 'Cliente'].map((String rol) {
                        return DropdownMenuItem<String>(value: rol, child: Text(rol));
                      }).toList(),
                      onChanged: (nuevoRol) {
                        if (nuevoRol != null) {
                          _cambiarEstadoUsuario(usuario, nuevoRol.toLowerCase(), usuario.suspendido);
                        }
                      },
                    ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: usuario.suspendido ? Colors.green : Colors.red,
                    backgroundColor: usuario.suspendido ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  ),
                  icon: Icon(usuario.suspendido ? Icons.check_circle : Icons.block, size: 16),
                  label: Text(usuario.suspendido ? 'Activar' : 'Deshabilitar', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    _cambiarEstadoUsuario(usuario, usuario.rol, !usuario.suspendido);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}