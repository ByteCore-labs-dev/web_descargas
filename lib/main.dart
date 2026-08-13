import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'; // INDISPENSABLE: Para usar kIsWeb y detectar PC
import 'dart:js_interop'; // Dart 3 JS Interop seguro para plataformas nativas

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ByteCoreLab Store',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Estética limpia Suprema
        fontFamily: '', //'sans-serif'
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

  // NUEVA VARIABLE DE CONTROL: Navegación interna a Pantalla de Detalle Independiente
  dynamic _itemSeleccionado;
  // MAPA DE DATOS INDEPENDIENTES (FUERA DEL JSON)
  // Asocia el título exacto del JSON con sus capturas y descripciones extendidas.
  // Si una app no está en este mapa, el sistema usará su portada por defecto.
  final Map<String, Map<String, dynamic>> _datosExtendidosApps = {
    "BUNKER EPP v1.7": { 
      "descripcion_larga": "DIGITALIZA TU OBRA CON BUNKER EPP 🛡️📱\n\n¿Sigues firmando la entrega de EPP en hojas de papel que terminan manchadas, rotas o perdidas? \n📄❌ Cuando llega una auditoría de la STPS o el IMSS, el papel no te va a salvar.\n Llegó la hora de tomar el control con Bunker EPP, la solución móvil definitiva para constructoras y contratistas, diseñada específicamente para el trabajo rudo de campo.\n ¡Cumple con la NOM-017 de la STPS directamente desde tu celular!. \n\n💥 LO QUE LLEVAS GRATIS (Versión Free):\n* 📶 Control 100% Offline: Registra datos en sótanos, excavaciones o zonas sin señal. Todo se guarda seguro en tu teléfono.\n* ✍️ Firmas Digitales de Conformidad: Captura la firma del trabajador en la pantalla. Tu respaldo legal inmediato ante multas.\n* 💰 Auditoría de Costos: Desglosa e identifica el gasto de insumos por cada frente de trabajo y subcontratista.\n* 📸 Reportes Rápidos: Exporta y comparte las evidencias del día en formato de imagen por WhatsApp o correo.\n\n👑 ¿QUIERES PODER RESTRICTIVO? PASA AL PLAN PREMIUM:\n* ☁️ Respaldo en la Nube Bajo tu Control: Tú eliges el momento exacto para sincronizar el lote de evidencias de forma masiva sin gastar tus datos en la obra.\n* 📊 Descarga Masiva del SUA: Olvídate de registrar trabajadores a mano. Importa el padrón completo del Sistema Único de Autodeterminación desde la computadora en un clic.\n* 📄 Generador Avanzado de PDF: Crea bitácoras oficiales y hojas de control en PDF en segundos, listas para enviar a gerencia.\n📉 El EPP que no se registra, es dinero que regalas. Protege a tu empresa ante costosas multas laborales, reduce tiempos de administración en campo y mantén tus costos bajo control estricto.\n📲 ¿LISTO PARA PROBAR LA VERSIÓN GRATUITA?\n\n ⚠️ NOTA IMPORTANTE DE INSTALACIÓN (Para cualquier teléfono Android):Al ser un software industrial de distribución directa (fuera de Play Store), cuando abras el archivo en tu celular, el sistema operativo te mostrará una alerta de seguridad de Aplicación Desconocida. No te preocupes, el archivo está 100% verificado por nuestro equipo y libre de riesgos. Sigue estos 3 pasos rápidos para instalarlo en cualquier dispositivo:\n 1️⃣ Presiona el archivo descargado. Si aparece el bloqueo, dale clic en Configuración o Ajustes. \n 2️⃣ Activa el interruptor que dice Permitir desde esta fuente o Autorizar aplicaciones desconocidas. \n 3️⃣ Regresa a tu pantalla y dale clic en Instalar. ¡Listo! Ya puedes usar BUNKER EPP 100% Offline.\n🚀 ¡Descárgala hoy mismo y toma el control total de tu seguridad industrial! ",
      "imagenes_capturas": [
        "assets/imagenes/img01bunker.jpeg",
        "assets/imagenes/img02bunker.jpeg",
        "assets/imagenes/img03bunker.jpeg",
        "assets/imagenes/img04bunker.jpeg",

      ],
    },
    //"TITULO_DE_TU_APP_EJEMPLO_2": {
      //"descripcion_larga": "Descripción extendida para la segunda aplicación de tu catálogo...",
      //"imagenes_capturas": [
       // "assets/imagenes/app1_ss1.jpg",
        //"assets/imagenes/app1_ss2.jpg",
        //"assets/imagenes/app1_ss3.jpg",
        //"assets/imagenes/app1_ss4.jpg",
        
      //],
    //},
  };

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
    // Si hay un detalle abierto, lo cerramos para permitir el scroll en la SPA maestra
    if (_itemSeleccionado != null) {
      setState(() {
        _itemSeleccionado = null;
      });
    }

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

  /// Interceptor de correo para PC Desktop mediante asignación directa al DOM.
  void _launchMailtoDesktopBypass(String email) {
    try {
      final String mailtoUrl = 'mailto:$email';
      (globalContext as dynamic).location.href = mailtoUrl;
    } catch (e) {
      debugPrint('Bypass JS Interop falló: $e.');
      launchUrl(Uri.parse("mailto:$email"), mode: LaunchMode.platformDefault);
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columnas = screenWidth > 1200 ? 4 : (screenWidth > 700 ? 2 : 1);
    double alturaTarjeta = screenWidth > 700 ? 420 : 390;

    return Scaffold(
      backgroundColor: Colors.white,
      
      // BOTÓN FLOTANTE ÚNICO RECTANGULAR URBANO PARA TODAS LAS SECCIONES
      floatingActionButton: _pantallaActiva != 0 
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _itemSeleccionado = null;
                  _pantallaActiva = 0;
                });
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
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFEFEFEF), width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _itemSeleccionado = null;
                      _pantallaActiva = 0;
                    });
                    _scrollController.animateTo(0, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: const Text(
                    'ByteCoreLab Store.',
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
                          setState(() {
                            _itemSeleccionado = null;
                            _pantallaActiva = 0;
                          });
                          _scrollController.animateTo(0, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
                        },
                        child: _buildNavLink('Home', activo: _pantallaActiva == 0 && _itemSeleccionado == null),
                      ),
                      InkWell(
                        onTap: () => _hacerScrollASeccion(_seccionDescargasKey, 1),
                        child: _buildNavLink('Descargas', activo: _pantallaActiva == 1 || _itemSeleccionado != null),
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
          // ÁREA DE CONTENIDO CON NAVEGACIÓN DE ESTADO (SPA INTERNA)
          // =========================================================
          Expanded(
          child: _itemSeleccionado != null
                ? SingleChildScrollView(
                    key: const ValueKey('DetalleAppScroll'),
                    physics: const BouncingScrollPhysics(), // Scroll suave para navegadores de escritorio
                    child: Container(
                      // Forzamos al contenedor a ser tan alto como sus hijos lo requieran de forma infinita
                      constraints: const BoxConstraints(minHeight: 0, maxHeight: double.infinity),
                      child: _buildPantallaDetalleApp(_itemSeleccionado, screenWidth),
                    ),
                  )
                : SingleChildScrollView(
                    controller: _scrollController,
                    key: const ValueKey('SPAMaestraScroll'),
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
                                            color: Colors.white, 
                                            fontSize: 15, 
                                            height: 1.5,
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
                          color: const Color(0xFFFAFAFA), 
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1100),
                              child: Wrap(
                                spacing: 40,
                                runSpacing: 40,
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center, 
                                children: [
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
                                          "ByteCoreLab Store es mi tienda personal de aplicaciones, un espacio exclusivo desarrollado para centralizar y facilitar el acceso a mis herramientas digitales.",
                                          style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
                                        ),
                                        const SizedBox(height: 15),
                                                  const Text(
            "Diseñada pensando estrictamente en la comodidad de mis usuarios, esta plataforma garantiza descargas directas, inmediatas y seguras de ejecutables nativos, eliminando intermediarios y optimizando tu experiencia.",
            style: TextStyle(
              fontSize: 15, 
              color: Colors.black87, 
              height: 1.6,
              fontWeight: FontWeight.w600, // Hace el párrafo más negrita (Semi-Bold)
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Ing. Felix Vargas",
            style: TextStyle(
              fontSize: 16, 
              color: Colors.black, // Negro absoluto
              height: 1.6,
              fontWeight: FontWeight.bold, // Negrita fuerte para tu firma
              letterSpacing: 0.5,
            ),
          ),

                                      ],
                                    ),
                                  ),
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
                                        'assets/imagenes/quienes_somos.jpeg', 
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

                                  // CANAL 1: CORREO ELECTRÓNICO (INTERACTIVO ADAPTATIVO PC/MÓVIL)
                                  InkWell(
                                    onTap: () async {
                                      const String correoDestino = "felixvargassoluciones@gmail.com";
                                      if (kIsWeb && MediaQuery.of(context).size.width > 750) {
                                        _launchMailtoDesktopBypass(correoDestino);
                                      } else {
                                        final Uri urlCorreoMovil = Uri.parse("mailto:$correoDestino");
                                        await launchUrl(urlCorreoMovil, mode: LaunchMode.externalNonBrowserApplication);
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
                                          Icon(Icons.mail_outline, color: Colors.black, size: 22),
                                          SizedBox(width: 15),
                                          Text(
                                            "felixvargassoluciones@gmail.com", 
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 15),

                                  // CANAL 2: ACCESO DIRECTO A WHATSAPP (CON ARREGLO DE VARIABLE INLINE PARA EL LINTER)
                                  InkWell(
                                   onTap: () async {
                                     const String identificadorChat = "527201494833";
                                
                                if (MediaQuery.of(context).size.width >= 750)  {
                                  final Uri urlPC = Uri.parse("https://whatsapp.com");
                                  await launchUrl(urlPC, mode: LaunchMode.externalApplication);
                                } else {
                                  bool esCelular = screenWidth < 750;
                                  final Uri urlDestino = esCelular 
                                      ? Uri.parse("whatsapp://send?phone=$identificadorChat") 
                                      : Uri.parse("https://whatsapp.com");
                                  try {
                                    await launchUrl(
                                      urlDestino,
                                      mode: esCelular ? LaunchMode.externalNonBrowserApplication : LaunchMode.externalApplication,
                                    );
                                  } catch (e) {
                                    await launchUrl(
                                      Uri.parse("https://whatsapp.com"),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
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

  // CONSTRUCTOR DEL COMPONENTE DE TARJETA ESTILO URBANO REFACTORIZADO
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
                (item['descripcion'] ?? '').toString().replaceAll('\\n', ' '),
                maxLines: 50, 
                overflow: TextOverflow.ellipsis, 
                style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
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
              onPressed: () {
                setState(() {
                  _itemSeleccionado = item;
                });
              },
              child: const Text(
                'VER DETALLES',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET AUTÓNOMO DE LA VISTA DETALLADA (PÁGINA NUEVA SIN SCROLL LARGO)
  Widget _buildPantallaDetalleApp(dynamic item, double screenWidth) {
    final String tituloKey = (item['titulo'] ?? item['nombre'] ?? '').toString();
    
    // Consultamos de forma segura el diccionario de datos independientes
    final Map<String, dynamic>? datosExtendidos = _datosExtendidosApps[tituloKey];
    
    // Resolución de descripción de respaldo si la clave no existe en el mapa interno
    final String descripcionCompleta = datosExtendidos?['descripcion_larga'] ?? 
        (item['descripcion'] ?? '').toString().replaceAll('\\n', '\n');

    // Resolución de capturas de pantalla independientes de respaldo
    final List<String> capturas = List<String>.from(datosExtendidos?['imagenes_capturas'] ?? [
      item['ruta_imagen'] ?? '',
      item['ruta_imagen'] ?? '',
      item['ruta_imagen'] ?? '',
      item['ruta_imagen'] ?? '',
      

    ]);

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 900 ? 60.0 : 20.0, 
        vertical: 20.0
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BOTÓN DE REGRESO DIRECTO AL REPOSITORIO GENERAL
          TextButton.icon(
                    onPressed: () {
          setState(() {
            _itemSeleccionado = null;
            _pantallaActiva = 1; // Sincroniza la barra de navegación en Descargas
          });
          // Espera a que el DOM maestro cargue antes de activar el scroll
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_seccionDescargasKey.currentContext != null) {
              Scrollable.ensureVisible(
                _seccionDescargasKey.currentContext!,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
              );
            }
          });
        },

            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
            label: const Text(
              "VOLVER AL REPOSITORIO",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 40),
          
          // CABECERA DE DISEÑO: ÍCONO, TÍTULO Y ACCIÓN DE DESCARGA
          Wrap(
            spacing: 30,
            runSpacing: 20,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFEFEFEF), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    item['ruta_imagen'] ?? '', 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.android, size: 40, color: Colors.black26)),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tituloKey.toUpperCase(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Desarrollador Verificado • Ejecutable Nativo Android",
                    style: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 200,
                    height: 45,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () => _descargarArchivo(
                        item['ruta_descarga'] ?? '', 
                        item['titulo'] ?? item['nombre'] ?? 'Archivo',
                      ),
                      icon: const Icon(Icons.download_for_offline, size: 20),
                      label: const Text(
                        'DOWNLOAD NOW',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 50),
          const Text(
            "CAPTURAS DE PANTALLA EN ENTORNO REAL",
            style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 15),
          
          // GALERÍA VISUAL DE SCREENSHOTS DE LA APP
          SizedBox(
            height: 400,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: capturas.length,
              itemBuilder: (context, idx) {
                return Container(
                  width: 190, 
                  height: 400, 
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEFEFEF), width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      capturas[idx],
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.phone_android, color: Colors.black12, size: 48),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 50),
          const Text(
            "DESCRIPCIÓN OPERATIVA COMPLETA",
            style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 15),
          Container(width: 40, height: 3, color: Colors.cyan),
          const SizedBox(height: 25),
          
          // DESCRIPCIÓN ENRIQUECIDA SIN RESTRICCIONES DE TAMAÑO
                   Text(
            descripcionCompleta,
            maxLines: null,
            softWrap: true,
            style: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.7, letterSpacing: 0.2),
          ),

const SizedBox(height: 200),
],),);}}






