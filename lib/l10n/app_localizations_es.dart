// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Viernes Mobile';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get register => 'Registrarse';

  @override
  String get dashboard => 'Panel de Control';

  @override
  String get conversations => 'Conversaciones';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Configuración';

  @override
  String get analytics => 'Analíticas';

  @override
  String get customers => 'Clientes';

  @override
  String get templates => 'Plantillas';

  @override
  String get workflows => 'Flujos de Trabajo';

  @override
  String get calls => 'Llamadas';

  @override
  String get organization => 'Organización';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get comingSoonDescription => '¡Esta funcionalidad estará disponible pronto!';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => '¡Ups! Algo salió mal';

  @override
  String get retry => 'Reintentar';

  @override
  String get goBack => 'Regresar';

  @override
  String get contactSupport => 'Si este problema persiste, por favor contacta soporte.';

  @override
  String get loading => 'Cargando...';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get search => 'Buscar';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String get refresh => 'Actualizar';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get systemMode => 'Sistema';

  @override
  String get language => 'Idioma';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get biometricAuth => 'Autenticación Biométrica';

  @override
  String get offlineMode => 'Modo Sin Conexión';

  @override
  String get online => 'En Línea';

  @override
  String get offline => 'Sin Conexión';

  @override
  String get welcomeToViernes => 'Bienvenido a Viernes';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get signIn => 'Iniciar Sesión';

  @override
  String get enterYourEmail => 'Ingresa tu correo electrónico';

  @override
  String get enterYourPassword => 'Ingresa tu contraseña';

  @override
  String get rememberMe => 'Recordarme';

  @override
  String get orContinueWith => 'o continúa con';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get passwordRecovery => 'Recuperación de Contraseña';

  @override
  String get forgotYourPassword => '¿Olvidaste tu contraseña?';

  @override
  String get enterEmailToResetPassword => 'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get resetPasswordHelperText => 'Enviaremos un enlace de restablecimiento a este correo';

  @override
  String get sendResetEmail => 'Enviar Correo de Restablecimiento';

  @override
  String get rememberPassword => '¿Recuerdas tu contraseña?';

  @override
  String get backToSignIn => 'Volver al Inicio de Sesión';

  @override
  String get checkYourEmail => 'Revisa tu correo electrónico';

  @override
  String passwordResetEmailSent(String email) {
    return 'Hemos enviado un enlace de restablecimiento de contraseña a $email';
  }

  @override
  String get checkSpamFolder => '¿No ves el correo? Revisa tu carpeta de spam.';

  @override
  String get sendAnotherEmail => 'Enviar Otro Correo';

  @override
  String get enableFaceId => 'Habilitar Face ID';

  @override
  String get enableFingerprint => 'Habilitar Huella Dactilar';

  @override
  String get enableBiometric => 'Habilitar Autenticación Biométrica';

  @override
  String get faceIdDescription => 'Usa Face ID para acceso rápido y seguro a tu cuenta';

  @override
  String get fingerprintDescription => 'Usa tu huella dactilar para acceso rápido y seguro a tu cuenta';

  @override
  String get biometricDescription => 'Usa autenticación biométrica para acceso rápido y seguro';
}
