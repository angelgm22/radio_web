import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:radio_web/play_page.dart';
import 'package:radio_web/screens/article_screen.dart';
import 'package:transition/transition.dart' as trans;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_web/player/PlayingControls.dart';
import 'package:radio_web/player/SongsSelector.dart';
import 'package:radio_web/presentation/bloc/home/home_cubit.dart';
import 'package:radio_web/presentation/bloc/home/home_state.dart';
import 'package:radio_web/weather/screens/location_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
//import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'dart:js' as js;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:blur/blur.dart';
import 'package:googleapis_auth/auth_io.dart';

class VideoList {
  String link;
  String imgURL;
  String name;
  String descripcion;

  VideoList(this.link, this.descripcion, this.imgURL, this.name);
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<VideoList> playList = [];

  late HomeCubit _homeCubit;
  bool RadioLoading = false;
  // AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();

  final List<StreamSubscription> _subscriptions = [];
  // List<Audio> audios = [];

  List _isHovering = [false, false, false, false, false, false, false];
  int _selectedHeaderMenuIndex = 0;
  String _selectedLanguage = 'EN';
  bool _loading = true;

  List<_Highlights> _highlights = [];
  List<ArticleModel> _articleModel0 = [];
  List<ArticleModel> _articleModel1 = [];

  PageController _pageController1 = PageController();
  PageController _pageController2 = PageController();

  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  int _Pagina = 0;
  String _Titulo = '';

  String imgURL =
      'https://firebasestorage.googleapis.com/v0/b/tienda-8e152.appspot.com/o/circularanimation.gif?alt=media&token=5bbbad70-33ee-471a-9849-8b4dbedde90a';
  String title = '';
  String description = '';
  String direccion = '';
  String desde = '';
  String hasta = '';
  String telefono = '';
  bool Loading = false;
  String AvisoText = '';
  String CondicionesText = '';
  bool isSwitched = false;
  int rIndex1 = 0;
  int rIndex2 = 0;
  String frase = '';
  String sub_frase = '';

  Random rnd = new Random();

  @override
  void initState() {
    super.initState();

    _homeCubit = BlocProvider.of<HomeCubit>(context);
    getData();
    getVideoEst();
    RadioLoading = false;
    _pageController1 = PageController(viewportFraction: 0.8);

    // _GetToken();
  }

  void getVideoEst() async {
    final resultVideoEst = FirebaseFirestore.instance.collection('videoest');

    playList = [];

    await resultVideoEst.get().then((query) {
      query.docs.forEach((element) async {
        VideoList _videos = VideoList(
            element['link'].toString(),
            element['descripcion'],
            element['imgURL'].toString(),
            element['name']);

        print('Link ${element['link'].toString()}');
        setState(() {
          playList.add(_videos);
        });
      });
    }).catchError((onError) {
      print('Error $onError');
    });
  }

  @override
  void dispose() {
    // _assetsAudioPlayer.dispose();
    super.dispose();
  }

  /*void getEstaciones() async {
    RadioLoading = true;
    audios = [];

    var resultIEstaciones =
        await FirebaseFirestore.instance.collection('estaciones');

    await resultIEstaciones.get().then((query) {
      query.docs.forEach((element) async {
        Audio _audios = Audio.network(
          element['link']
              .toString(), //'https://cros-anywhere.herokuapp.com/${element['link'].toString()}',
          metas: Metas(
            id: element['id'].toString(),
            title: element['title'].toString(),
            artist: element['artist'].toString(),
            album: element['album'].toString(),
            image: MetasImage.network(element['imageUrl'].toString()),
          ),
        );
        print('Estaciones ${element['title'].toString()}');

        setState(() {
          audios.add(_audios);
        });
      });
    }).catchError((onError) {
      print('Error $onError');
    });

    setState(() {
      _assetsAudioPlayer.playlistAudioFinished.listen((data) {
        print('playlistAudioFinished : $data');
      });
      _assetsAudioPlayer.audioSessionId.listen((sessionId) {
        print('audioSessionId : $sessionId');
      });

      // }
      //  _assetsAudioPlayer.stop();
      _assetsAudioPlayer
          .open(
        //      Playlist(audios: audios, startIndex: 0),
        audios[0],
        showNotification: true,
        autoStart: true,
      )
          .then((value) {
        print('openPlayer ');
      });

      RadioLoading = false;
    });
  }

  Audio find(List<Audio> source, String fromPath) {
    return source.firstWhere((element) => element.path == fromPath);
  }
*/

  getData() async {
    print('Get Data ');
    String kinshortsEndpoint = "";
    _articleModel0 = [];
    _articleModel1 = [];
    _highlights = [];

    var resultINoticias =
        await FirebaseFirestore.instance.collection('noticias');
    await resultINoticias.get().then((query) {
      query.docs.forEach((element) {
        ArticleModel articleModel1 = ArticleModel(
          tipo: 'noticias',
          publishedDate: element['pubDate'].toString(),
          //   publishedTime: element['pubDate'].toString(),
          image: element['image_url'].toString(),
          content: element['content'].toString(),
          fullArticle: element['link'].toString(),
          title: element['title'].toString(),
        );

        setState(() {
          _articleModel0.add(articleModel1);
        });
      });
    });

    var resultAnuncios =
        await FirebaseFirestore.instance.collection('anuncios');

    await resultAnuncios.get().then((query) {
      query.docs.forEach((element) {
        setState(() {
          _Highlights articleModel3 = _Highlights(
              element['image_url'].toString(),
              element['title'].toString(),
              element['content'].toString(),
              element['pubDate'].toString(),
              element['link'].toString());
          _highlights.add(articleModel3);
        });
      });
    });

    int max = _highlights.length - 1;

    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (mounted) {
        setState(() {
          rIndex1 = 0 + rnd.nextInt(max);
          rIndex2 = 0 + rnd.nextInt(max);
        });
      }
    });

    var result =
        await FirebaseFirestore.instance.collection('datos').doc('data').get();

    setState(() {
      imgURL = result.get('imgUrl'); //['imgURL'] ?? ' ';
      title = result.get('titulo'); // documents[0]['titulo'] ?? ' ';
      description =
          result.get('descripcion'); // documents[0]['descrpcion'] ?? ' ';
      direccion = result.get('direccion');
      desde = result.get('desde');
      hasta = result.get('hasta');
      telefono = result.get('telefono');
      frase = result.get('frase');
      sub_frase = result.get('sub_frase');
      print("Nick $title");
      Loading = true;
      AvisoText = '$title con domicilio en $direccion es el responsable del uso y protecci??n de sus datos personales, y al respecto le informamos lo siguiente: \n ' +
          'Los datos personales que recabamos de usted, los utilizaremos para las siguientes finalidades que son necesarias para el servicio que solicita: \n' +
          'Finalidad principal: \n' +
          '$title recaba, utiliza, almacena, transmite o transfiere sus datos personales, en la medida en que la Ley Federal de Protecci??n de Datos en Posesi??n de Particulares lo permite, para cumplir con las obligaciones derivadas de la relaci??n de cliente se cree, as?? como para la administraci??n, pago y cobro de los mismos, contrataci??n de finanzas; auditor??as internas; elaboraci??n de directorio de la empresa; informaci??n en las declaraciones del SAT.\n' +
          '$title podr?? hacer uso de sus datos personales para otras finalidades, siempre y cuando dichas finalidades sean compatibles y puedan considerarse an??logas a las anteriores. Para llevar a cabo las finalidades descritas en el presente aviso de privacidad, utilizaremos los siguientes datos personales:\n' +
          '1. Nombre, tel??fono, correo electr??nico y domicilio para facilitar el proceso de contrataci??n de compra de nuestros productos.\n' +
          '2. Datos financieros como n??mero de tarjeta de d??bito o cr??dito, fecha de vencimiento y c??digo de seguridad para efectuar los pagos de contrataci??n y/o compras correspondientes.\n' +
          '$title podr?? compartir con terceros, nacionales o extranjeros, algunos o todos sus datos personales. Dichos tercerso podr??n ser clientes, auditores y/o afiliados de $title; y/u otros prestadores que ofrezcan servicios, por ejemplo: administraci??n de recursos humanos, provisi??n de seguros y otros beneficios, porte t??cnico, tecnolog??as de la informaci??n, y en general, cualquier tercero que act??e como encargado a nombre y por cuenta de $title.\n' +
          '$title se asegurar?? que dichos terceros mantengan medidas de seguridad, administrativas, t??cnicas y f??sicas adecuadas para resguardar sus datos personales, as?? como que dichos terceros ??nicamente utilicen sus datos personales para finalidades para los cuales fueron recabados y de conformidad con el presente aviso de privacidad.\n' +
          'No obstante, lo anterior, ???$title??? no ceder??, vender?? o transferir?? sus datos personales a terceros no relacionados con $title, salvo en los casos antes citados y previstos respecto a sus datos personales. Usted podr?? ejercer ante $title los derechos de acceso, rectificaci??n, cancelaci??n y oposici??n.\n' +
          'En caso de existir cambio o modificaciones, totales o parciales, en el presente aviso de privacidad, se pondr?? a su disposici??n la versi??n actualizada del mismo a trav??s de esta p??gina de la presenta plataforma.\n';

      CondicionesText = 'El presente documento establece las condiciones mediante las cuales se regir?? el uso de la aplicaci??n m??vil: $title (en adelante la aplicaci??n), la cual es operada por?????$title???, en M??xico y domiciliada en la ciudad de Camargo. \n' +
          'La aplicaci??n funcionar?? como un nuevo canal para la realizaci??n de ciertas actividades descritas m??s adelante con el objeto de facilitar el acceso a los clientes.\n' +
          'El usuario se compromete a leer los t??rminos y condiciones aqu?? establecidos, previamente a la descarga de la aplicaci??n, por tanto, en caso de realizar la instalaci??n se entiende que cuenta con el conocimiento integral de este documento y la consecuente aceptaci??n de la totalidad de sus estipulaciones.' +
          'El Usuario reconoce que el ingreso de su informaci??n personal, y los datos que contiene la aplicaci??n a su disposici??n respecto a los productos activos del negocio $title en Reynosa, Tamaulipas M??xico, la realizan de manera voluntaria, quienes optan por acceder a esta aplicaci??n, lo hacen por iniciativa propia y son responsables del cumplimiento de las leyes locales, en la medida en que dichas leyes sean aplicables en el pa??s. En caso de que se acceda por parte de menores de edad, deben contar con la supervisi??n de un adulto en todo momento desde la descarga y durante el uso de la aplicaci??n, en el evento en que no se cumpla esta condici??n, le agradecemos no hacer uso de la aplicaci??n.\n' +
          'Alcance y uso\n' +
          'El usuario de la aplicaci??n entiende y acepta que, no obstante, es operada por?????$title???, la informaci??n contenida en la misma ser?? la referente a su v??nculo comercial, por tanto, las funcionalidades ofrecidas por la aplicaci??n ser??n entregadas de acuerdo con su vinculaci??n.\n' +
          'En la aplicaci??n se pondr?? a disposici??n del CLIENTE informaci??n y/o permitir?? la realizaci??n de las transacciones determinadas o habilitadas por??$title??para cada producto en particular. $title podr?? adicionar, modificar o eliminar las funcionalidades en cualquier momento, lo cual acepta el usuario mediante la instalaci??n de la aplicaci??n. En todo caso, al momento de realizar dichas modificaciones se notificar??n al usuario a trav??s de la misma aplicaci??n m??vil una vez inicie sesi??n.\n' +
          'El usuario acepta y autoriza que los registros electr??nicos de las actividades mencionadas, que realice en la aplicaci??n constituyen plena prueba de los mismos.\n' +
          'Requisitos de uso\n' +
          'El usuario deber?? contar con un dispositivo m??vil inteligente (Smartphone) o Tableta con sistema operativo Android o IOS, cualquiera de estos con acceso a internet, ambos seguros y confiables.??$title, no ser?? responsable por la seguridad de los equipos Smartphone propiedad de los usuarios utilizados para el acceso al canal, ni por la disponibilidad del servicio en los dispositivos en los cuales se descargue la aplicaci??n.\n' +
          'En la forma permitida por la ley, los materiales de la aplicaci??n se suministran sin garant??a de ning??n g??nero, expresa o impl??cita, incluyendo sin limitaci??n las garant??as de calidad satisfactoria, comerciabilidad, adecuaci??n para un fin particular o no infracci??n, por tanto,??$title??no garantiza el funcionamiento adecuado en los distintos sistemas operativos o dispositivos en los cuales se haga uso de la aplicaci??n.\n' +
          'Para acceder al portal, EL CLIENTE contar?? con Usuario y Contrase??a, que lo identifica en su relaci??n con??$title, los cuales ser??n los mismos utilizados en el portal web.\n' +
          'Obligaciones de los usuarios\n' +
          'El Usuario se obliga a usar la aplicaci??n y los contenidos encontrados en ella de una manera diligente, correcta, l??cita y en especial, se compromete a NO realizar las conductas descritas a continuaci??n:\n' +
          '??? Utilizar los contenidos de forma, con fines o efectos contrarios a la ley, a la moral y a las buenas costumbres generalmente aceptadas o al orden p??blico;\n' +
          '??? Reproducir, copiar, representar, utilizar, distribuir, transformar o modificar los contenidos de la aplicaci??n, por cualquier procedimiento o sobre cualquier soporte, total o parcial, o permitir el acceso del p??blico a trav??s de cualquier modalidad de comunicaci??n p??blica;\n' +
          '??? Utilizar los contenidos de cualquier manera que entra??en un riesgo de da??o o inutilizaci??n de la aplicaci??n o de los contenidos o de terceros;\n' +
          '??? Emplear los contenidos y, en particular, la informaci??n de cualquier clase obtenida a trav??s de la aplicaci??n para distribuir, transmitir, remitir, modificar, rehusar o reportar la publicidad o los contenidos de esta con fines de venta directa o con cualquier otra clase de finalidad comercial, mensajes no solicitados dirigidos a una pluralidad de personas con independencia de su finalidad, as?? como comercializar o divulgar de cualquier modo dicha informaci??n;\n' +
          '??? No permitir que terceros ajenos a usted usen la aplicaci??n m??vil con su clave;\n' +
          '??? Utilizar la aplicaci??n y los contenidos con fines l??citos y/o il??citos, contrarios a lo establecido en estos T??rminos y Condiciones, o al uso mismo de la aplicaci??n, que sean lesivos de los derechos e intereses de terceros, o que de cualquier forma puedan da??ar, inutilizar, sobrecargar o deteriorar la aplicaci??n y los contenidos o impedir la normal utilizaci??n o disfrute de esta y de los contenidos por parte de los usuarios.\n' +
          'Propiedad intelectual\n' +
          'Todo el material inform??tico, gr??fico, publicitario, fotogr??fico, de multimedia, audiovisual y de dise??o, as?? como todos los contenidos, textos y bases de datos puestos a su disposici??n en esta aplicaci??n est??n protegidos por derechos de autor y/o propiedad industrial cuyo titular es $title. Igualmente, el uso en la aplicaci??n de algunos materiales de propiedad de terceros se encuentra expresamente autorizado por la ley o por dichos terceros. Todos los contenidos en la aplicaci??n est??n protegidos por las normas sobre derecho de autor y por todas las normas nacionales e internacionales que le sean aplicables.\n' +
          'Exceptuando lo expresamente estipulado en estos T??rminos y Condiciones, queda prohibido todo acto de copia, reproducci??n, modificaci??n, creaci??n de trabajos derivados, venta o distribuci??n, exhibici??n de los contenidos de esta aplicaci??n, de manera o por medio alguno, incluyendo, m??s no limitado a, medios electr??nicos, mec??nicos, de fotocopiado, de grabaci??n o de cualquier otra ??ndole, sin el permiso previo y por escrito de $title??o del titular de los respectivos derechos.\n' +
          'Licencia para copiar para uso personal\n' +
          'Usted podr?? leer, visualizar, imprimir y descargar el material de sus productos.\n' +
          'Ninguna parte de la aplicaci??n podr?? ser reproducida o transmitida o almacenada en otro sitio web o en otra forma de sistema de recuperaci??n electr??nico.\n' +
          '$title??no interfiere, no toma decisiones, ni garantiza las relaciones que los usuarios lleguen a sostener o las vinculaciones con terceros que pauten y/o promocionen sus productos y servicios. Estas marcas de terceros se utilizan solamente para identificar los productos y servicios de sus respectivos propietarios y el patrocinio o el aval por parte de??$title??no se deben inferir con el uso de estas marcas comerciales.\n' +
          'Responsabilidad de $title\n' +
          '$title??procurar?? garantizar disponibilidad, continuidad o buen funcionamiento de la aplicaci??n. $title??podr?? bloquear, interrumpir o restringir el acceso a esta cuando lo considere necesario para el mejoramiento de la aplicaci??n o por dada de baja de la misma.\n' +
          'Se recomienda al Usuario tomar medidas adecuadas y actuar diligentemente al momento de acceder a la aplicaci??n, como, por ejemplo, contar con programas de protecci??n, antivirus, para manejo de malware, spyware y herramientas similares.\n' +
          '$title??no ser?? responsable por: a) Fuerza mayor o caso fortuito; b) Por la p??rdida, extrav??o o hurto de su dispositivo m??vil que implique el acceso de terceros a la aplicaci??n m??vil; c) Por errores en la digitaci??n o accesos por parte del cliente; d) Por los perjuicios, lucro cesante, da??o emergente, morales, y en general sumas a cargo de??$title, por no procesamiento de informaci??n o suspensi??n del servicio del operador m??vil o da??os en los dispositivos m??viles.\n' +
          'En el Evento en que un Usuario incumpla estos T??rminos y Condiciones, o cualesquiera otras disposiciones que resulten de aplicaci??n,??$title??podr?? suspender su acceso a la aplicaci??n.\n' +
          'T??rminos y condiciones\n' +
          'El Usuario acepta expresamente los T??rminos y Condiciones, siendo condici??n esencial para la utilizaci??n de la aplicaci??n. En el evento en que se encuentre en desacuerdo con estos T??rminos y Condiciones, solicitamos abandonar la aplicaci??n inmediatamente.??$title??podr?? modificar los presentes t??rminos y condiciones, avisando a los usuarios de la aplicaci??n mediante la difusi??n de las modificaciones por alg??n medio electr??nico, redes sociales, SMS y/o correo electr??nico, lo cual se entender?? aceptado por el usuario si ??ste continua con el uso de la aplicaci??n. ???\n' +
          'Uso de informaci??n personal\n' +
          '$title??tambi??n recolecta informaci??n no personal en forma agregada para seguimiento de datos como el n??mero total de descargas de la aplicaci??n. Utilizamos esta informaci??n, que permanece en forma agregada, para entender el comportamiento de la aplicaci??n.\n' +
          'Uso de direcciones IP\n' +
          'Una direcci??n de Protocolo de Internet (IP) es un conjunto de n??meros que se asigna autom??ticamente a su o dispositivo m??vil cuando usted accede a su proveedor de servicios de internet, o a trav??s de la red de ??rea local (LAN) de su organizaci??n o la red de ??rea amplia (WAN). Los servidores web autom??ticamente identifican su dispositivo m??vil por la direcci??n IP asignada a ??l durante su sesi??n en l??nea.\n' +
          '$title??podr??n recolectar direcciones IP para prop??sitos de administraci??n de sistemas y para auditar el uso de nuestro sitio, todo lo anterior de acuerdo con la autorizaci??n de protecci??n de datos que se suscribe para tal efecto. Normalmente no vinculamos la direcci??n IP de un usuario con la informaci??n personal de ese usuario, lo que significa que cada sesi??n de usuario se registra, pero el usuario sigue siendo an??nimo para nosotros. Sin embargo, podemos usar las direcciones IP para identificar a los usuarios de nuestro sitio cuando sea necesario con el objeto de para exigir el cumplimiento de los t??rminos de uso del sitio, o para proteger nuestro servicio, sitio u otros usuarios.\n' +
          'Seguridad\n' +
          '$title??est?? comprometido en la protecci??n de la seguridad de su informaci??n personal.??$title??tiene implementados mecanismos de seguridad que aseguran la protecci??n de la informaci??n personal, as?? como los accesos ??nicamente al personal y sistemas autorizados, tambi??n contra la p??rdida, uso indebido y alteraci??n de sus datos de usuario bajo nuestro control.\n' +
          'Excepto como se indica a continuaci??n, s??lo personal autorizado tiene acceso a la informaci??n que nos proporciona. Adem??s, hemos impuesto reglas estrictas a los empleados de??$title??con acceso a las bases de datos que almacenan informaci??n del usuario o a los servidores que hospedan nuestros servicios.';
    });

    kinshortsEndpoint =
        'https://newsdata.io/api/1/news?apikey=pub_75714c329a6e48a9f8d5ac600f62826fd5eb&language=es&country=mx&q=all';
    try {
      http.Client client = http.Client();
      http.Response response = await client.get(
        Uri.parse(kinshortsEndpoint), /* headers: userHeader*/
      );

      print('kinshortsEndpoint $kinshortsEndpoint');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonData['status'] == "success") {
          jsonData['results'].forEach((element) {
            if (element['image_url'] != null &&
                element['content'] != null &&
                element['link'] != null) {
              ArticleModel articleModel2 = ArticleModel(
                tipo: 'news',
                publishedDate: element['pubDate'].toString(),
                //   publishedTime: element['pubDate'].toString(),
                image: element['image_url'].toString(),
                content: element['content'].toString(),
                fullArticle: element['link'].toString(),
                title: element['title'].toString(),
              );
              /*   if (element['image_url'].toString().contains('ahoramismo') ||
                  element['image_url'].toString().contains('milenio')) {
              } else { */
              setState(() {
                _articleModel1.add(articleModel2);
              });
              //   }
            }
          });
        } else {
          print('ERROR');
        }
      }
    } catch (e) {
      print('Error');
    }
    print(' Article Length ${_articleModel0.length}');
    setState(() {
      _loading = false;
    });
  }

  Widget _buildCounterText() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is UpdatedHomeState) {
          return Text(
            '${state.counter}',
            style: Theme.of(context).textTheme.headline4,
          );
        }
        return Container();
      },
    );
  }

  TextStyle? _getTextStyle() {
    return Theme.of(context).textTheme.subtitle1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: _buildAppBar(context),
      // extendBodyBehindAppBar: true,
      body: _buildBody(context),
    );
  }

/*
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return PreferredSize(
      preferredSize: Size(screenSize.width, 1000),
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Text('EXPLORE'),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeaderMenu('Discover', 0, () {}),
                    SizedBox(width: screenSize.width / 20),
                    _buildHeaderMenu('Contact Us', 1, () {})
                  ],
                ),
              ),
              _buildHeaderMenu('Sign Up', 2, () {}),
              SizedBox(
                width: screenSize.width / 50,
              ),
              _buildHeaderMenu('Login', 3, () {}),
            ],
          ),
        ),
      ),
    );
  } */
// Cuerpo Principal del Sitio
  Widget _buildBody(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    print("ScreenWidth: $_screenWidth");
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildTopBanner(context),
          SizedBox(
            height: 40,
          ),
          !_loading ? _buildHighlights(context) : CircularProgressIndicator(),
          SizedBox(
            height: 40,
          ),
          _buildBottomBanner(context),
        ],
      ),
    );
  }

// reproductor estaciones
/*
  Widget _BuildRadioS(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;

    return /* Neumorphic(
        style: NeumorphicStyle(
          depth: -8,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(9)),
        ),
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.all(4),
        child: */

        ListTile(leading: _assetsAudioPlayer.builderCurrent(
            builder: (context, Playing? playing) {
      return _assetsAudioPlayer.builderLoopMode(
        builder: (context, loopMode) {
          return PlayerBuilder.isPlaying(
              player: _assetsAudioPlayer,
              builder: (context, isPlaying) {
                return PlayingControls(
                  loopMode: loopMode,
                  isPlaying: isPlaying,
                  isPlaylist: true,
                  onStop: () {
                    _assetsAudioPlayer.stop();
                  },
                  toggleLoop: () {
                    _assetsAudioPlayer.toggleLoop();
                  },
                  onPlay: () {
                    _assetsAudioPlayer.playOrPause();
                  },
                  onNext: () {
                    //_assetsAudioPlayer.forward(Duration(seconds: 10));
                    _assetsAudioPlayer.next(
                        keepLoopMode: true /*keepLoopMode: false*/);
                  },
                  onPrevious: () {
                    _assetsAudioPlayer.previous(/*keepLoopMode: false*/);
                  },
                );
              });
        },
      );
    }), title: _assetsAudioPlayer.builderCurrent(
            builder: (BuildContext context, Playing? playing) {
      return SongsSelector(
        audios: audios,
        onPlaylistSelected: (myAudios) {
          _assetsAudioPlayer.open(
            Playlist(audios: myAudios),
            showNotification: true,
            headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplugPlayOnPlug,
            audioFocusStrategy:
                AudioFocusStrategy.request(resumeAfterInterruption: true),
          );
        },
        onSelected: (myAudio) async {
          print('MyAudio');
          try {
            await _assetsAudioPlayer.open(
              myAudio,
              autoStart: true,
              showNotification: true,
              playInBackground: PlayInBackground.enabled,
              audioFocusStrategy: AudioFocusStrategy.request(
                  resumeAfterInterruption: true,
                  resumeOthersPlayersAfterDone: true),
              headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplug,
            );
          } catch (e) {
            print('Error Audios $e');
          }
        },
        playing: playing,
      );
    }));
  }
*/
  //region Top Banner
  // Menu Superior
  Widget _buildTopBanner(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    int minSize = 500;
    bool fontS = _screenWidth < 1024.0;
    bool minS = false;
    minS = _screenWidth <= minSize;

    return Container(
 decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Colors.blue,
              Colors.black,
              Colors.black,
              Colors.purple
            ])),      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Image.asset(
                  "assets/images/fchica.jpg",
                  width: minS ? 150 : 300,
                ),
              ),
              LocationScreen(),
            ],
          ),
          _buildHeaderMenus(),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnimatedSwitcher(context, rIndex1),
              // _Carousel(context),
              !minS ?
              _VideoEsta(context)
              : SizedBox(),
              _AnimatedSwitcher(context, rIndex2),
            ],
          ),
          minS ? _VideoEsta(context) : SizedBox(),
          Text(
            frase,
            style: TextStyle(
                fontSize: minS
                    ? 16
                    : fontS
                        ? 24.0
                        : 46.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Container(
            width: _screenWidth / 2,
            child: Text(
              sub_frase,
              style: TextStyle(
                  fontSize: minS
                      ? 14
                      : fontS
                          ? 18.0
                          : 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          //   !RadioLoading ? _BuildRadioS(context) : CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildBottomBanner(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 16,
              )
            ],
          ),
          SizedBox(
            height: 32,
          ),
          _buildBottomMenus(),
          Container(
            width: _screenWidth / 2,
            child: Text(
              '?? Frontera Chica Communications',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }

/*
  Widget _buildLanguageButton(String text, VoidCallback? onPressed) {
    bool isSelected = text == _selectedLanguage;
    return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.white : Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            side: BorderSide(color: Colors.white, width: 1),
            minimumSize: Size(36, 36)),
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Text(
            text.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(color: isSelected ? Colors.lightGreen : Colors.white),
          ),
        ));
  }

  Widget _buildActionButton(
      String text, bool? isLeft, VoidCallback? onPressed) {
    BorderRadius borderRadius = BorderRadius.zero;
    if (isLeft == true)
      borderRadius = BorderRadius.only(
          topLeft: Radius.circular(8), bottomLeft: Radius.circular(8));
    else if (isLeft == false)
      borderRadius = BorderRadius.only(
          topRight: Radius.circular(8), bottomRight: Radius.circular(8));

    return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            side: BorderSide(color: Colors.white, width: 1),
            minimumSize: Size(120, 36),
            enableFeedback: true),
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: Colors.white),
          ),
        ));
  }
*/

  Widget _buildHeaderMenu(
      String text, int index, GestureTapCallback? tapCallback) {
    bool isSelected = _selectedHeaderMenuIndex == index;
    bool isHovering = _isHovering[index];
    return InkWell(
      onHover: (value) {
        setState(() {
          _isHovering[index] = value;
        });
      },
      onTap: tapCallback,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: _getTextStyle()!.copyWith(
              color: isSelected
                  ? Colors.lightBlue
                  : isHovering
                      ? Colors.white
                      : Colors.white,
            ),
          ),
          SizedBox(height: 8),
          // For showing an underline on hover
          Visibility(
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
            visible: isSelected ? true : isHovering,
            child: Container(
              height: 2,
              width: 60,
              color: isSelected ? Colors.lightBlue : Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderMenus() {
    return Wrap(
      spacing: 16.0,
      children: [
        _buildHeaderMenu('Inicio', 0, () {
          setState(() {
            _Pagina = 0;
            _selectedHeaderMenuIndex = 0;
            _Titulo = 'Inicio';
          });
        }),
        _buildHeaderMenu('Anunciantes', 1, () {
          setState(() {
            _Pagina = 1;
            _selectedHeaderMenuIndex = 1;
            _Titulo = 'Anuncios';
          });
        }),
        _buildHeaderMenu('Noticias', 2, () {
          setState(() {
            _Pagina = 2;
            _selectedHeaderMenuIndex = 2;
            _Titulo = 'Noticias';
          });
        }),
        _buildHeaderMenu('Estaciones', 3, () {
          setState(() {
            _Pagina = 3;
            _selectedHeaderMenuIndex = 3;
            _Titulo = 'Estaciones de radio';
          });
        }),
        _buildHeaderMenu('Acerca de FC Comms', 4, () {
          setState(() {
            _Pagina = 4;
            _selectedHeaderMenuIndex = 4;
            _Titulo = 'Acerca de Frontera Chica Comms';
          });
        }),
      ],
    );
  }

  Widget _buildBottomMenu(
      IconData icon, int index, GestureTapCallback? tapCallback) {
    bool isSelected = _selectedHeaderMenuIndex == index;
    bool isHovering = _isHovering[index];
    return InkWell(
      onHover: (value) {
        setState(() {
          _isHovering[index] = value;
        });
      },
      onTap: tapCallback,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: 8),
          // For showing an underline on hover
          Visibility(
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
            visible: isSelected ? true : isHovering,
            child: Container(
              height: 2,
              width: 60,
              color: isSelected ? Colors.lightBlue : Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomMenus() {
    return Wrap(
      spacing: 16.0,
      children: [
        _buildBottomMenu(FontAwesomeIcons.facebook, 0, () {
          launchUrl(Uri.parse('https://www.facebook.com/fchica.comms'));
        }),
        ElevatedButton(
          child: Image.asset(
            'assets/images/disponibleApple.png',
            width: 150.0,
            fit: BoxFit.fitWidth,
          ),
          onPressed: () {
            //     launchUrl(Uri.parse('https://apps.apple.com/us/app/fc-comms/id1632913950'));
          },
        ),
        ElevatedButton(
          child: Image.asset(
            'assets/images/disponibleGoogle.png',
            width: 150.0,
            fit: BoxFit.fitWidth,
          ),
          onPressed: () {
            launchUrl(Uri.parse(
                'https://play.google.com/store/apps/details?id=com.angelgm22.radio'));
          },
        )
      ],
    );
  }

  //Cuerpo Pagina Principal principal
  Widget _buildHighlights(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    int minSize = 500;
    bool fontS = _screenWidth < 1024.0;
    bool minS = false;
    minS = _screenWidth <= minSize;

    return Padding(
        padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _Pagina == 0
                        ? 'Noticias FC-Comms'
                        : _Pagina == 1
                            ? 'Anuncios'
                            : _Pagina == 2
                                ? 'Noticias'
                                : _Pagina == 3
                                    ? 'Estaciones de Radio'
                                    : 'Acerca de ',
                    style: TextStyle(
                        fontSize: minS
                            ? 12
                            : fontS
                                ? 18
                                : 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 8,
                  ),

                  _Pagina == 0
                      ? _buildHighlightsCarousel2(context) // Principal
                      : _Pagina == 1
                          ? _buildHighlightsCarousel4(context) // Anuncios
                          : _Pagina == 2
                              ? _buildHighlightsCarousel5(context) // Noticias
                              : _Pagina == 3
                                  ? _buildHighlightsCarousel6(
                                      context) // Estaciones
                                  : _Acerca(context), // Acerca de
                  SizedBox(
                    height: minS
                        ? 12
                        : fontS
                            ? 32
                            : 64,
                  ),
                ],
              ),
              SizedBox(
                width: minS
                    ? 12
                    : fontS
                        ? 32
                        : 64,
              ),
              /* Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Noticias',
                    style: TextStyle(
                        fontSize: minS
                            ? 12
                            : fontS
                                ? 18
                                : 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  _buildHighlightsCarousel3(context),
                ],
              ) */
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Noticias',
                    style: TextStyle(
                        fontSize: minS
                            ? 12
                            : fontS
                                ? 18
                                : 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  _buildHighlightsCarousel3(context),
                ],
              )
            ],
          ),
        ));
  }

// Noticias PubliNet
  Widget _buildHighlightsCarousel2(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    int minSize = 820;
    double itemWidth = 450;
    double viewportFraction = 0.85;
    bool fontS = _screenWidth < 1024.0;
    bool minS = false;
    minS = _screenWidth <= minSize;
    if (_screenWidth <= minSize) {
      itemWidth = _screenWidth / 2.0;
      viewportFraction = 0.55;
    } else {
      itemWidth = _screenWidth / 2.0; // / 2.5;
      viewportFraction = 0.275;
    }

    double maxLength = 200000.0;
    //double initialPage =  (maxLength / 2 - (maxLength / 2 % _articleModel0.length));

    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;

    return Container(
      width: itemWidth,
      child: GridView.builder(
        padding: EdgeInsets.all(4),
        itemCount: _articleModel0.length,
        controller: new ScrollController(keepScrollOffset: false),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: fontS ? 0.8 : 1.0,
        ),
        itemBuilder: (BuildContext context, index) {
          return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ArticleScreen(
                      articleUrl: _articleModel0[index].fullArticle,
                      content: _articleModel0[index].content,
                      date: _articleModel0[index].publishedDate,
                      image: _articleModel0[index].image,
                      title: _articleModel0[index].title,
                      tipo: _articleModel0[index].tipo,
                    ),
                  ),
                );
              },
              // Nuestro bot??n personalizado!
              child: Card(
                  elevation: 10,
                  margin: minS
                      ? EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 8.0)
                      : EdgeInsets.fromLTRB(0.0, 0.0, 24.0, 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(18.0),
                          child: Image.network(
                            _articleModel0[index].image,
                            width: MediaQuery.of(context).size.width / 4,
                            height: minS ? 50 : 80,
                            fit: BoxFit.contain,
                          )),
                      Container(
                          width: MediaQuery.of(context).size.width / 4,
                          child: Padding(
                            padding:
                                minS ? EdgeInsets.all(8) : EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _articleModel0[index].title,
                                  style: TextStyle(
                                      fontSize: fontS ? 9.0 : 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: minS ? 2 : 8,
                                ),
                                Text(
                                  _articleModel0[index].content,
                                  style: TextStyle(
                                      fontSize: fontS ? 8.0 : 12.0,
                                      //   fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  textAlign: TextAlign.left,
                                  maxLines: fontS ? 3 : 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ))
                    ],
                  )));
        },
      ),
    );
    //);
  }

// Noticias
  Widget _buildHighlightsCarousel3(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double minSize = 500;
    double itemWidth = 450;
    double viewportFraction = 0.85;
    bool fontS = _screenWidth < 1024.0;
    bool minS = false;

    if (_screenWidth <= minSize) {
      minS = true;

      itemWidth = _screenWidth / 2.0;
      viewportFraction = 0.55;
    } else {
      itemWidth = _screenWidth; // / 2.5;
      viewportFraction = 0.275;
    }

    double maxLength = 200000;
    double initialPage =
        (maxLength / 2 - (maxLength / 2 % _articleModel0.length));

    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;

    return Container(
      width: minS
          ? 70.0
          : fontS
              ? 280
              : _screenWidth / 2.8,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        itemCount: _articleModel1.length,
        itemBuilder: (BuildContext, index) {
          return GestureDetector(
              onTap: () async {
                await launchUrl(Uri.parse(_articleModel1[index].fullArticle));
              },
              child: Card(
                  elevation: 15,
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18.0),
                        child: CachedNetworkImage(
                          imageUrl: _articleModel1[index].image,
                          width: minS
                              ? 70
                              : fontS
                                  ? itemWidth / 8
                                  : itemWidth / 6,
                          fit: minS ? BoxFit.cover : BoxFit.fitWidth,
                          height: minS ? 70 : 100,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image(
                            image: AssetImage('assets/images/placeholder.jpeg'),
                            height: minS ? 70 : 100,
                            width: minS
                                ? 70
                                : fontS
                                    ? itemWidth / 8
                                    : itemWidth / 6,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      minS
                          ? SizedBox()
                          : Container(
                              width: minS
                                  ? 70
                                  : fontS
                                      ? itemWidth / 8
                                      : itemWidth / 6,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _articleModel1[index].title,
                                      style: fontS
                                          ? TextStyle(
                                              fontSize: 9.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)
                                          : TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      _articleModel1[index].content,
                                      style: fontS
                                          ? TextStyle(
                                              fontSize: 8.0,
                                              //  fontWeight: FontWeight.bold,
                                              color: Colors.black)
                                          : TextStyle(
                                              fontSize: 12.0,
                                              //  fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                      textAlign: TextAlign.left,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ))
                    ],
                  )));
        },
      ),
    );
  }

  Widget _AnimatedSwitcher(BuildContext context, int index) {
    double _screenWidth = MediaQuery.of(context).size.width;

    int _currentIndex = 0;

    int minSize = 500;
    double itemWidth = 450;
    double viewportFraction = 0.85;
    bool fontS = _screenWidth < 1024.0;
    bool minS = _screenWidth <= minSize;

    if (_screenWidth <= minSize) {
      itemWidth = _screenWidth / 2.0;
      viewportFraction = 0.55;
    } else {
      itemWidth = _screenWidth; // / 2.5;
      viewportFraction = 0.275;
    }

    return Center(
        child: AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(child: child, opacity: animation);
      },
      child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ArticleScreen(
                  articleUrl: " ",
                  content: _highlights[index].description,
                  date: _highlights[index].date,
                  image: _highlights[index].imageAsset,
                  title: _highlights[index].title,
                  tipo: "anuncios",
                ),
              ),
            );
          },
          // Nuestro bot??n personalizado!
          child: Card(
              color: Colors.white.withOpacity(0.05),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(18.0),
                          child: Image.network(
                            _highlights[index].imageAsset,
                            width: minS
                                ? (MediaQuery.of(context).size.width / 2) - 40
                                : fontS
                                    ? (MediaQuery.of(context).size.width / 3) -
                                        10
                                    : (MediaQuery.of(context).size.width / 3) -
                                        30,
                            height: minS ? 150 : 300.0,
                            fit: BoxFit.fitHeight,
                          )),
                      minS
                          ? SizedBox()
                          : Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                  //   margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15),
                                  width:
                                      (MediaQuery.of(context).size.width / 3) -
                                          30,
                                  height: 110,
                                  constraints: BoxConstraints(),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        _highlights[index].title,
                                        style: TextStyle(
                                            fontSize: minS
                                                ? 12
                                                : fontS
                                                    ? 16.0
                                                    : 22.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        _highlights[index].description,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10),
                                        textAlign: TextAlign.left,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      )
                                    ],
                                  )),
                            ),
                    ],
                  )))
          //       : SizedBox()//Icon(_icons[_currentIndex], key: ValueKey<int>(_currentIndex), size: 96),
          ),
    ));
  }

// Carrusel Anuncios
  Widget _Carousel(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    int minSize = 500;
    double itemWidth = 450;
    double viewportFraction = 0.85;
    bool fontS = _screenWidth < 1024.0;
    bool minS = _screenWidth <= minSize;

    if (_screenWidth <= minSize) {
      itemWidth = _screenWidth / 2.0;
      viewportFraction = 0.55;
    } else {
      itemWidth = _screenWidth; // / 2.5;
      viewportFraction = 0.275;
    }
    int min = 0;
    int max = _highlights.length - 1;
    Random rnd = new Random();
    int r = min + rnd.nextInt(max);

    return Container(
        width: minS
            ? (MediaQuery.of(context).size.width / 3) - 5
            : fontS
                ? (MediaQuery.of(context).size.width / 3) - 10
                : (MediaQuery.of(context).size.width / 3) - 30,
        height: minS ? 150 : 450.0,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
        child: _highlights.length != 0
            ? Center(
                child: CarouselSlider.builder(
                itemCount: _highlights.length,
                options: CarouselOptions(
                  pauseAutoPlayOnTouch: true,
                  initialPage: r,
                  autoPlay: true,
                  height: 500.0,
                  viewportFraction: 1.0,
                ),
                //    items: _highlights.map((i) {
                itemBuilder: (BuildContext context, int i, int p) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ArticleScreen(
                                articleUrl: " ",
                                content: _highlights[i].description,
                                date: _highlights[i].date,
                                image: _highlights[i].imageAsset,
                                title: _highlights[i].title,
                                tipo: "anuncios",
                              ),
                            ));
                      },
                      child: Card(
                          color: Colors.white.withOpacity(0.05),
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(18.0),
                                      child: Image.network(
                                        _highlights[i].imageAsset,
                                        width: minS
                                            ? (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3) -
                                                5
                                            : fontS
                                                ? (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        3) -
                                                    10
                                                : (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        3) -
                                                    30,
                                        height: minS ? 150 : 300.0,
                                        fit: BoxFit.contain,
                                      )),
                                  minS
                                      ? SizedBox()
                                      : Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                              //   margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15),
                                              width: minS
                                                  ? (MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          3) -
                                                      5
                                                  : fontS
                                                      ? (MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              3) -
                                                          10
                                                      : (MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              3) -
                                                          30,
                                              height: 110,
                                              constraints: BoxConstraints(),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  SizedBox(
                                                    height: 12,
                                                  ),
                                                  Text(
                                                    _highlights[i].title,
                                                    style: TextStyle(
                                                        fontSize: minS
                                                            ? 12
                                                            : fontS
                                                                ? 16.0
                                                                : 22.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                    textAlign: TextAlign.left,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    _highlights[i].description,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                    textAlign: TextAlign.left,
                                                    maxLines: 5,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              )
                                              //  )
                                              ),
                                        ),
                                ],
                              ))));
                },
              ))
            : SizedBox());
    //: SizedBox();
  }

// Carrusel Video Estaciones
  Widget _VideoEsta(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    int minSize = 500;
    double itemWidth = 450;
    double viewportFraction = 0.85;
    bool fontS = _screenWidth < 1024.0;
    bool minS = _screenWidth <= minSize;

    if (_screenWidth <= minSize) {
      itemWidth = _screenWidth / 2.0;
      viewportFraction = 0.55;
    } else {
      itemWidth = _screenWidth; // / 2.5;
      viewportFraction = 0.275;
    }
    int min = 0;
    int max = _highlights.length - 1;
    Random rnd = new Random();
    int r = min + rnd.nextInt(max);

    return Container(
        width: minS
            ? MediaQuery.of(context).size.width  - 5
            : fontS
                ? (MediaQuery.of(context).size.width / 3) - 10
                : (MediaQuery.of(context).size.width / 3) - 30,
        height: minS ? 450 : 450.0,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
        child: _highlights.length != 0
            ? Center(
                child: Card(
                    color: Colors.white.withOpacity(0.05),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            PlayPage(),
                          ],
                        ))))
            : SizedBox());
    //: SizedBox();
  }

//Cuerpo principal Paginas
  Widget _buildHighlights1(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Padding(
        padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _Titulo,
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 10.0,
                            child: new Center(
                              child: new Container(
                                margin: new EdgeInsetsDirectional.only(
                                    start: 1.0, end: 1.0),
                                height: 5.0,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),

                  /*  SizedBox(
                height: 8,
              ), */
                  _Pagina == 0
                      ? _buildHighlightsCarousel2(context) // Principal
                      : _Pagina == 1
                          ? _buildHighlightsCarousel4(context) // Anuncios
                          : _Pagina == 2
                              ? _buildHighlightsCarousel5(context) // Noticias
                              : _Pagina == 3
                                  ? _buildHighlightsCarousel6(
                                      context) // Estaciones
                                  : _Acerca(context), // Acerca de

                  SizedBox(
                    height: 64,
                  ),
                ],
              ),
              SizedBox(
                width: 64,
              ),
              /*  Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Noticias',
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  _buildHighlightsCarousel3(context),
                ],
              ) */
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Noticias',
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  _buildHighlightsCarousel3(context),
                  // VideoPlay()
                ],
              )
            ],
          ),
        ));
  }

  // Anuncios Pagina

  Widget _buildHighlightsCarousel4(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    int minSize = 500;
    double itemWidth = 450;
    double viewportFraction = 0.85;
    bool fontS = _screenWidth < 1024.0;

    if (_screenWidth <= minSize) {
      itemWidth = _screenWidth / 2.0;
      viewportFraction = 0.55;
    } else {
      itemWidth = _screenWidth; // / 2.5;
      viewportFraction = 0.275;
    }

    int maxLength = 200000;
    int initialPage =
        (maxLength / 2 - (maxLength / 2 % _highlights.length)) as int;

    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;

    return Container(
      width: _screenWidth / 2,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        itemCount: _highlights.length,
        itemBuilder: (BuildContext, index) {
          return GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ArticleScreen(
                      articleUrl: _highlights[index].link,
                      content: _highlights[index].description,
                      date: _highlights[index].date,
                      image: _highlights[index].imageAsset,
                      title: _highlights[index].title,
                      tipo: 'anuncios',
                    ),
                  ),
                );
                //    await launchUrl(Uri.parse(_articleModel1[index].fullArticle));
                // js.context                    .callMethod('open', [_articleModel1[index].fullArticle]);
              },
              // Nuestro bot??n personalizado!
              child: Card(
                  elevation: 15,
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: _highlights[index].imageAsset,
                        width: itemWidth / 5,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image(
                          image: AssetImage('assets/images/placeholder.jpeg'),
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
                      fontS
                          ? SizedBox()
                          : Container(
                              width: _screenWidth / 5,
                              //   height: 450,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _highlights[index].title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(color: Colors.black),
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      _highlights[index].description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(color: Colors.black),
                                      textAlign: TextAlign.left,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ))
                    ],
                  )));
        },
      ),
    );
  }

// Noticias Pagina
  Widget _buildHighlightsCarousel5(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    int minSize = 500;
    double itemWidth = 450;
    double viewportFraction = 0.85;
    bool fontS = _screenWidth < 1024.0;

    if (_screenWidth <= minSize) {
      itemWidth = _screenWidth / 2.0;
      viewportFraction = 0.55;
    } else {
      itemWidth = _screenWidth; // / 2.5;
      viewportFraction = 0.275;
    }

    int maxLength = 200000;
    int initialPage =
        (maxLength / 2 - (maxLength / 2 % _articleModel0.length)) as int;

    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;

    return Container(
      width: _screenWidth / 2,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        itemCount: _articleModel0.length,
        itemBuilder: (BuildContext, index) {
          return GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  trans.Transition(
                    child: ArticleScreen(
                      articleUrl: _articleModel0[index].fullArticle,
                      content: _articleModel0[index].content,
                      date: _articleModel0[index].publishedDate,
                      image: _articleModel0[index].image,
                      title: _articleModel0[index].title,
                      tipo: 'noticias',
                    ),
                    transitionEffect: trans.TransitionEffect.BOTTOM_TO_TOP,
                  ),
                );
              },
              child: Card(
                  elevation: 15,
                  margin: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: _articleModel0[index].image,
                        width: itemWidth / 5,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image(
                          image: AssetImage('assets/images/placeholder.jpeg'),
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
                      fontS
                          ? SizedBox()
                          : Container(
                              width: _screenWidth / 5,
                              //   height: 450,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _articleModel0[index].title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(color: Colors.black),
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      _articleModel0[index].content,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(color: Colors.black),
                                      textAlign: TextAlign.left,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ))
                    ],
                  )));
        },
      ),
    );
  }

  // Estaciones Pagina
  Widget _buildHighlightsCarousel6(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    int minSize = 500;
    double itemWidth = 450;
    double viewportFraction = 0.85;
    bool fontS = _screenWidth < 1024.0;

    if (_screenWidth <= minSize) {
      itemWidth = _screenWidth / 2.0;
      viewportFraction = 0.55;
    } else {
      itemWidth = _screenWidth; // / 2.5;
      viewportFraction = 0.275;
    }

    int maxLength = 200000;
    int initialPage =
        (maxLength / 2 - (maxLength / 2 % _articleModel0.length)) as int;

    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;

    return Container(
      width: _screenWidth / 2,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        itemCount: playList.length,
        itemBuilder: (BuildContext, index) {
          return GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  trans.Transition(
                    child: ArticleScreen(
                      articleUrl: '',
                      content: playList[index].descripcion.toString(),
                      date: ' ',
                      image: playList[index].imgURL,
                      title: playList[index].name.toString(),
                      tipo: 'noticias',
                    ),
                    transitionEffect: trans.TransitionEffect.BOTTOM_TO_TOP,
                  ),
                );
              },
              // Nuestro bot??n personalizado!
              child: Card(
                  elevation: 15,
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: playList[index].imgURL,
                        width: itemWidth / 5,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image(
                          image: AssetImage('assets/images/placeholder.jpeg'),
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
                      fontS
                          ? SizedBox()
                          : Container(
                              width: _screenWidth / 5,
                              //   height: 450,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      playList[index].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(color: Colors.black),
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      playList[index].descripcion.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(color: Colors.black),
                                      textAlign: TextAlign.left,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ))
                    ],
                  )));
        },
      ),
    );
  }

  // Acerca de...  Pagina
  Widget _Acerca(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    int minSize = 500;
    double itemWidth = 450;
    double viewportFraction = 0.85;

    if (_screenWidth <= minSize) {
      itemWidth = _screenWidth / 2.0;
      viewportFraction = 0.55;
    } else {
      itemWidth = _screenWidth; // / 2.5;
      viewportFraction = 0.275;
    }

    int maxLength = 200000;
    int initialPage =
        (maxLength / 2 - (maxLength / 2 % _articleModel0.length)) as int;

    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;

    return Container(
        width: _screenWidth / 2,
        child: Card(
          elevation: 15,
          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 32.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            children: [
              Container(
                height: 200.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: Loading ? BoxFit.contain : BoxFit.contain,
                        image: Loading
                            ? NetworkImage(imgURL)
                            : NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/tienda-8e152.appspot.com/o/circularanimation.gif?alt=media&token=5bbbad70-33ee-471a-9849-8b4dbedde90a'))),
              ),
              Text('Direcci??n'),
              Text(direccion),
              Text('Tel??fono'),
              Text(telefono),
              Text('Horario'),
              Text('$desde- $hasta'),
              new CupertinoButton(
                  child: new Text('Aviso de Privacidad'),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Aviso de Privacidad'),
                            content: new SingleChildScrollView(
                              child: Text(AvisoText,
                                  style: TextStyle(fontSize: 8.0)),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text("Aceptar"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  }),
              new CupertinoButton(
                  child: new Text('Terminos y Condiciones'),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Terminos y Condiciones'),
                            content: new SingleChildScrollView(
                              child: Text(CondicionesText,
                                  style: TextStyle(fontSize: 8.0)),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text("Aceptar"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  }),
            ],
          ),
        ));
  }
}

class _Highlights {
  String imageAsset;
  String title;
  String description;
  String date;
  String link;

  _Highlights(
      this.imageAsset, this.title, this.description, this.date, this.link);
}

class ArticleModel {
  String title;
  String image;
  String content;
  // String publishedTime;
  String publishedDate;
  String fullArticle;
  String tipo;

  ArticleModel(
      {required this.content,
      required this.fullArticle,
      required this.image,
      required this.publishedDate,
      // required this.publishedTime,
      required this.title,
      required this.tipo});
}
