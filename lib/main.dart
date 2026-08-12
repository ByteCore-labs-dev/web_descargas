import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter/foundation.dart'; // INDISPENSABLE: Para usar kIsWeb y detectar PC


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ByteCore-labs-dev',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Estética limpia de la referencia Suprema.
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // CONTROLADORES DE DESPLAZAMIENTO Y REFERENCIAS DE SECCIONES (ANCLAS)
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _seccionDescargasKey = GlobalKey();
  final GlobalKey _seccionQuienesSomosKey = GlobalKey();
  final GlobalKey _seccionContactoKey = GlobalKey();

  List<dynamic> _items = [];
  int _pantallaActiva = 0; // Sincroniza los indicadores de color (0=Home, 1=Descargas, 2=Nosotros, 3=Contacto)

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    try {
      final String response = await rootBundle.loadString('assets/catalog.json');
      final data = await json.decode(response);
      setState(() {
        _items = data;
      });
    } catch (e) {
      debugPrint("Error al cargar JSON: $e");
    }
  }

  // MANEJO DE SCROLL SUAVE INTEGRADO
  void _hacerScrollASeccion(GlobalKey llaveSeccion, int indiceMenu) {
    setState(() {
      _pantallaActiva = indiceMenu;
    });
    
    if (llaveSeccion.currentContext != null) {
      Scrollable.ensureVisible(
        llaveSeccion.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _descargarArchivo(String ruta, String titulo) async {
    final Uri url = Uri.parse(ruta);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando descarga: $titulo'),
        backgroundColor: Colors.black,
      ),
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir la ruta de descarga: $ruta');
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columnas = screenWidth > 1200 ? 4 : (screenWidth > 700 ? 2 : 1);
    double alturaTarjeta = screenWidth > 700 ? 520 : 480;

    return Scaffold(
      backgroundColor: Colors.white,
      
      // BOTÓN FLOTANTE ÚNICO RECTANGULAR URBANO PARA TODAS LAS SECCIONES
      floatingActionButton: _pantallaActiva != 0 
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() => _pantallaActiva = 0);
                _scrollController.animateTo(0, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
              },
              backgroundColor: Colors.black,
              elevation: 5,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 16),
              label: const Text(
                'REGRESAR AL INICIO', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
              ),
            )
          : null,

      body: Column(
        children: [
          // =========================================================
          // ENCABEZADO FIJO (NAVBAR CORE) - SE QUEDA INMÓVIL ARRIBA
          // =========================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: Colors.white, // El color vive dentro de la decoración sin conflictos
              border: Border(
                bottom: BorderSide(color: const Color(0xFFEFEFEF), width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    setState(() => _pantallaActiva = 0);
                    _scrollController.animateTo(0, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: const Text(
                    'ByteCore-labs-dev.',
                    style: TextStyle(
                      color: Colors.black, 
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                if (screenWidth > 700)
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() => _pantallaActiva = 0);
                          _scrollController.animateTo(0, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
                        },
                        child: _buildNavLink('Home', activo: _pantallaActiva == 0),
                      ),
                      InkWell(
                        onTap: () => _hacerScrollASeccion(_seccionDescargasKey, 1),
                        child: _buildNavLink('Descargas', activo: _pantallaActiva == 1),
                      ),
                      InkWell(
                        onTap: () => _hacerScrollASeccion(_seccionQuienesSomosKey, 2),
                        child: _buildNavLink('Quiénes Somos', activo: _pantallaActiva == 2),
                      ),
                      InkWell(
                        onTap: () => _hacerScrollASeccion(_seccionContactoKey, 3),
                        child: _buildNavLink('Contacto', activo: _pantallaActiva == 3),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // =========================================================
          // ÁREA DE CONTENIDO CON SCROLLER MAESTRO (SPA)
          // =========================================================
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECCIÓN HÉROE CENTRAL LIMPIA (BOTÓN REMOVIDO)
                  Stack(
                    children: [
                      Container(
                        height: 550,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/imagenes/img01.jpg'), 
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(color: Colors.black.withValues(alpha: 0.55)),
                      ),
                      const Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Descubre\nNuevas Aplicaciones.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontSize: 52, 
                                    fontWeight: FontWeight.bold, 
                                    height: 1.1,
                                    letterSpacing: -1,
                                        // --- NUEVO: Sombra de alto impacto para separar la letra del fondo ---
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        offset: Offset(0, 4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  width: 500,
                                                                child: Text(
                                "Una experiencia de descarga diseñada para tu comodidad: aplicaciones Android verificadas listas para instalar en un solo clic.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white, // Pasado a blanco puro para más contraste
                                  fontSize: 15, 
                                  height: 1.5,
                                  // CORREGIDO: shadows ahora vive felizmente DENTRO de las propiedades del TextStyle
                                  shadows:  [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),

                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // REJILLA DE PRODUCTOS (CATÁLOGO OFICIAL)
                  Container(
                    key: _seccionDescargasKey,
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "REPOSITORIO OFICIAL",
                          style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Herramientas y Aplicaciones",
                          style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 12),
                        Container(width: 60, height: 3, color: Colors.black),
                        const SizedBox(height: 45),
                        
                        _items.isEmpty
                            ? const Center(child: CircularProgressIndicator(color: Colors.black))
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columnas,
                                  crossAxisSpacing: 30,
                                  mainAxisSpacing: 40,
                                  mainAxisExtent: alturaTarjeta,
                                ),
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return _buildSupremaProductCard(item);
                                },
                              ),
                      ],
                    ),
                  ),
                  // =========================================================
                  // SECCIÓN ANCLA: QUIÉNES SOMOS (TEXTO + CONTENEDOR FOTO)
                  // =========================================================
                  Container(
                    key: _seccionQuienesSomosKey,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
                    color: const Color(0xFFFAFAFA), // Fondo sutil para separar secciones
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Wrap(
                          spacing: 40,
                          runSpacing: 40,
                          alignment: WrapAlignment.center,
                                                    crossAxisAlignment: WrapCrossAlignment.center, // CORREGIDO

                          children: [
                            // BLOQUE DE TEXTOS
                            SizedBox(
                              width: screenWidth > 900 ? 550 : double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("QUIÉNES SOMOS.", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -1.5)),
                                  const SizedBox(height: 12),
                                  Container(width: 60, height: 3, color: Colors.black),
                                  const SizedBox(height: 35),
                                  const Text(
                                     "bytecore-labs-dev es mi tienda personal de aplicaciones, un espacio exclusivo desarrollado para centralizar y facilitar el acceso a mis herramientas digitales.",
                                    style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                     "Diseñada pensando estrictamente en la comodidad de mis usuarios, esta plataforma garantiza descargas directas, inmediatas y seguras de ejecutables nativos, eliminando intermediarios y optimizando tu experiencia.\n\nIng. Felix Vargas",
                                    style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.6),
                                  ),
                                ],
                              ),
                            ),
                            // CONTENEDOR AJUSTADO PARA LA FOTO DE INFRAESTRUCTURA
                            Container(
                              width: screenWidth > 900 ? 450 : double.infinity,
                              height: 320,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFEFEFEF), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  'assets/imagenes/quienes_somos.jpeg', // Tu asset fotográfico local
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image_outlined, color: Colors.black26, size: 48),
                                          SizedBox(height: 10),
                                          Text("FOTO DE INFRAESTRUCTURA", style: TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                                    // =========================================================
                  // SECCIÓN ANCLA: CONTACTO (DATOS REALES INTEGRADOS)
                  // =========================================================
                  Container(
                    key: _seccionContactoKey,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
                    color: Colors.white,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("CONTACTO.", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -1.5)),
                            const SizedBox(height: 12),
                            Container(width: 60, height: 3, color: Colors.black),
                            const SizedBox(height: 35),
                            const Text("Canales oficiales de asistencia técnica y comunidad:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                            const SizedBox(height: 25),



                                                        // =========================================================
                            // CANAL 1: CORREO ELECTRÓNICO (SOLUCIÓN DE INGENIERÍA PC + MÓVIL)
                            // =========================================================
                            InkWell(
                              onTap: () async {
                                final Uri emailUri = Uri.parse("mailto:felixvargassoluciones@gmail.com");
                                try {
                                  // SOLUCIÓN PC: En web de escritorio usamos platformDefault para evitar que Chrome
                                  // levante una pestaña en blanco (_blank) si el usuario no tiene Outlook configurado.
                                  await launchUrl(
                                    emailUri,
                                    mode: screenWidth < 750 ? LaunchMode.externalApplication : LaunchMode.platformDefault,
                                  );
                                } catch (e) {
                                  debugPrint("Error al abrir correo: $e");
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9F9),
                                  border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.email_outlined, color: Colors.black, size: 22),
                                    SizedBox(width: 15),
                                    Text("felixvargassoluciones@gmail.com", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // CANALES RESPONSIVOS: WHATSAPP
                            Wrap(
                              spacing: 15,
                              runSpacing: 15,
                              children: [
                                // =========================================================
                                // CANAL 2: WHATSAPP (SOLUCIÓN DE INGENIERÍA ADAPTATIVA REAL)
                                // =========================================================
                                InkWell(
                                  onTap: () async {
                                    const String telefono = "527201494833";
                                    
                                    // DETECCIÓN FIABLE: Evaluamos si el ancho de pantalla corresponde a un Celular
                                    bool esDispositivoMovil = screenWidth < 750;

                                    final Uri whatsappUrl = esDispositivoMovil 
                                        ? Uri.parse("whatsapp://send?phone=$telefono") // Esquema nativo exclusivo para celulares
                                        : Uri.parse("https://whatsapp.com"); // URL de escritorio para PC

                                    try {
                                      await launchUrl(
                                        whatsappUrl,
                                        mode: esDispositivoMovil 
                                            ? LaunchMode.externalNonBrowserApplication // Fuerza al celular a abrir tu selector de doble WhatsApp
                                            : LaunchMode.externalApplication, // Abre una pestaña limpia de WhatsApp Web en la PC
                                      );
                                    } catch (e) {
                                      // Desvío universal de emergencia
                                      await launchUrl(
                                        Uri.parse("https://whatsapp.com"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: screenWidth > 750 ? 392 : double.infinity,
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9F9),
                                      border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.forum_outlined, color: Colors.black, size: 22), 
                                        SizedBox(width: 15),
                                        Text(
                                          "+52 720 149 4833", 
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ), // Cierre

                          ],
                        ), // Cierre de Column interna
                      ), // Cierre de ConstrainedBox
                    ), // Cierre de Center
                  ), // Cierre de Container principal de Contacto
                                ], // Línea 492: Cierre de la lista de secciones dentro del scroll
              ), // Línea 493: Cierre de la Column del SingleChildScrollView
            ), // Línea 494: Cierre del SingleChildScrollView
          ), // Línea 495: Cierre del Expanded
        ], // Línea 496: Cierre de la lista de hijos del body principal
      ), // Línea 497: Cierre de la Column principal del body
    ); // Línea 498: Cierre del Scaffold
  } // Línea 499: Cierre definitivo del método build


  // COMPONENTE DE TEXTO RESPONSIVO PARA ENLACES INDIVIDUALES DEL NAVBAR
  Widget _buildNavLink(String texto, {bool activo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Text(
        texto,
        style: TextStyle(
          color: activo ? Colors.cyan : Colors.black87,
          fontWeight: activo ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  // CONSTRUCTOR DEL COMPONENTE DE TARJETA ESTILO URBANO SUPREMA.
  Widget _buildSupremaProductCard(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF7F7F7),
                child: Image.asset(
                  item['ruta_imagen'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.insert_drive_file_outlined, color: Colors.black38, size: 40));
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            (item['titulo'] ?? item['nombre'] ?? 'SIN TÍTULO').toString().toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                (item['descripcion'] ?? '').toString().replaceAll('\\n', '\n'),
                 maxLines: 200, // <-- MODIFICA AQUÍ: Cambia el número por la cantidad de líneas que desees
                overflow: TextOverflow.ellipsis, // Recorta con puntos suspensivos (...) si el texto supera el límite
                style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20), 
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () => _descargarArchivo(
                item['ruta_descarga'] ?? '', 
                item['titulo'] ?? item['nombre'] ?? 'Archivo',
              ),
              child: const Text(
                'DOWNLOAD NOW',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
