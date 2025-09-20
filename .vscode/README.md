# VS Code Configuration for Viernes Mobile

Este directorio contiene las configuraciones de VS Code optimizadas para el desarrollo de Viernes Mobile.

## 🚀 Configuraciones de Launch

### Configuraciones Disponibles:

1. **🚀 Viernes Dev (Debug)** - Ejecuta la app en modo desarrollo con debugging
2. **🏭 Viernes Prod (Debug)** - Ejecuta la app en modo producción con debugging
3. **🚀 Viernes Dev (Release)** - Ejecuta la app en modo desarrollo optimizado
4. **🏭 Viernes Prod (Release)** - Ejecuta la app en modo producción optimizado
5. **🌐 Viernes Web Dev** - Ejecuta la app en Chrome (desarrollo)
6. **🌐 Viernes Web Prod** - Ejecuta la app en Chrome (producción)
7. **🍎 Viernes iOS Dev** - Ejecuta la app en simulador específico (desarrollo)
8. **🍎 Viernes iOS Prod** - Ejecuta la app en simulador específico (producción)
9. **🍎 iOS Simulator (Auto)** - Detecta automáticamente simulador iOS
10. **🤖 Android Emulator** - Ejecuta en emulador Android
11. **📱 Any Available Device** - Usa cualquier dispositivo disponible

### Cómo Usar:

1. **Presiona `F5`** o ve a `Run and Debug` (Ctrl/Cmd + Shift + D)
2. **Selecciona la configuración** que desees usar del dropdown
3. **Haz click en el botón play** o presiona `F5`

### Atajos de Teclado:

- `F5` - Ejecutar configuración seleccionada
- `Ctrl/Cmd + F5` - Ejecutar sin debugging
- `Shift + F5` - Detener debugging
- `Ctrl/Cmd + Shift + F5` - Restart debugging

## 🛠️ Tasks Disponibles

Accede a las tasks mediante `Ctrl/Cmd + Shift + P` y escribe `Tasks: Run Task`:

- **🧹 Flutter Clean** - Limpia el proyecto
- **📦 Flutter Pub Get** - Instala dependencias
- **🔧 Build Runner (Build)** - Genera código una vez
- **🔧 Build Runner (Watch)** - Genera código automáticamente
- **🏗️ Build APK Dev** - Construye APK de desarrollo
- **🏗️ Build APK Prod** - Construye APK de producción
- **🧪 Run Tests** - Ejecuta las pruebas
- **🔍 Flutter Analyze** - Analiza el código
- **🩺 Flutter Doctor** - Verifica la configuración de Flutter

## ⚙️ Configuraciones

### Settings.json
- Auto-formateo al guardar
- Organización automática de imports
- Exclusión de archivos de build
- Configuraciones específicas de Dart/Flutter

### Extensions.json
Lista de extensiones recomendadas para el proyecto:
- Dart y Flutter
- Herramientas de debugging y análisis
- Mejoras de productividad

## 🔥 Tips de Productividad

1. **Hot Reload**: `r` en la terminal de debugging
2. **Hot Restart**: `R` en la terminal de debugging
3. **DevTools**: Se abre automáticamente con las configuraciones
4. **Multi-dispositivo**: Puedes ejecutar múltiples configuraciones simultáneamente
5. **Dispositivos específicos**: Usa configuraciones con ID específico para consistencia
6. **Dispositivos automáticos**: Usa configuraciones "Auto" para flexibilidad

## 📱 Solución de Problemas de Dispositivos

### Si aparece "Device not found":

1. **Verificar dispositivos disponibles**:
   ```bash
   ./scripts/dev.sh devices
   # o
   flutter devices
   ```

2. **Para iOS**:
   - Usar configuración "🍎 iOS Simulator (Auto)"
   - O abrir simulador manualmente antes de ejecutar

3. **Para Android**:
   - Usar configuración "🤖 Android Emulator"
   - O iniciar emulador desde Android Studio

4. **Usar script alternativo**:
   ```bash
   # Ver dispositivos disponibles
   ./scripts/dev.sh devices

   # Ejecutar en dispositivo específico
   ./scripts/dev.sh dev chrome
   ./scripts/dev.sh dev FB419AB3-DB53-4860-A812-F619AEE5D222
   ```

## 🔧 Variables de Entorno

Las configuraciones automáticamente setean:
- `ENVIRONMENT=dev` para configuraciones de desarrollo
- `ENVIRONMENT=production` para configuraciones de producción

**Nota**: Las configuraciones de VS Code no usan flavors (`--flavor`) porque el proyecto iOS no tiene esquemas personalizados configurados. Para usar flavors, ejecuta manualmente:
```bash
# Android con flavors
flutter run --flavor=dev --dart-define=ENVIRONMENT=dev -t lib/main_dev.dart -d android

# iOS sin flavors (automático)
flutter run --dart-define=ENVIRONMENT=dev -t lib/main_dev.dart -d ios
```

## 📱 Dispositivos

- **Android**: Usa el emulador o dispositivo conectado por defecto
- **iOS**: Especifica dispositivo iOS (requiere macOS)
- **Web**: Se ejecuta en Chrome
- **Desktop**: Configuraciones disponibles según el SO

### Dispositivos Actualmente Detectados:
- **iPhone 16e**: `FB419AB3-DB53-4860-A812-F619AEE5D222`
- **macOS**: `macos`
- **Chrome**: `chrome`

## 🐛 Debugging

Todas las configuraciones de debug incluyen:
- Breakpoints
- Variable inspection
- Call stack
- Performance profiling
- Widget inspector