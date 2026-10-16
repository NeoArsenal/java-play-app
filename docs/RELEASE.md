# Guía de Generación y Firma de Release (Android) - JavaPlay

Esta guía detalla el proceso para generar el keystore de carga (upload key), configurar `key.properties`, compilar el App Bundle (.aab) firmado para Google Play y generar APKs de release para pruebas directas.

---

## 1. Generación del Keystore de Carga

> [!CAUTION]
> **UBICACIÓN DEL KEYSTORE:**  
> **NUNCA** guardes el keystore dentro del repositorio de Git ni dentro de carpetas sincronizadas en la nube como **OneDrive**, Dropbox o Google Drive (las sincronizaciones pueden corromper el archivo o exponer credenciales).  
> Guárdalo en una ruta local segura de tu máquina (por ejemplo `C:\Users\<usuario>\.android-keys\javaplay-upload-keystore.jks`) y mantén un respaldo seguro cifrado (ej. gestor de contraseñas o disco externo).

### Comando `keytool`
Abre una terminal (PowerShell o CMD) y ejecuta:

```powershell
# Crear directorio seguro fuera del repositorio y de OneDrive si no existe
New-Item -ItemType Directory -Path "$env:USERPROFILE\.android-keys" -Force

# Generar el keystore
keytool -genkey -v -keystore "$env:USERPROFILE\.android-keys\javaplay-upload-keystore.jks" `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias javaplay-upload-key
```

El asistente te solicitará:
1. Una contraseña para el almacén de claves (guárdala de forma segura).
2. Preguntas de identificación (Nombre, Organización, Ciudad, etc.).
3. Confirmar datos (`sí` / `yes`).

---

## 2. Configurar `android/key.properties`

El archivo `android/key.properties` está excluido del control de versiones en `.gitignore`.

1. Copia la plantilla de ejemplo:
   ```powershell
   Copy-Item android/key.properties.example android/key.properties
   ```
2. Abre `android/key.properties` y completa los valores con tus credenciales.  
   **Recomendación en Windows:** Usa barras inclinadas hacia adelante (`/`) para la ruta de `storeFile`:

```properties
storePassword=tu_contraseña_del_keystore
keyPassword=tu_contraseña_del_alias
keyAlias=javaplay-upload-key
storeFile=C:/Users/alons/.android-keys/javaplay-upload-keystore.jks
```

> [!WARNING]
> Nunca hagas commit ni compartas el archivo `android/key.properties`.

---

## 3. Comandos de Compilación

### A. Android App Bundle (.aab) para Google Play (Recomendado para Producción)
Google Play Store requiere el formato `.aab` para nuevas aplicaciones.

```bash
flutter build appbundle --release
```

- **Ubicación del artefacto generado:**
  `build/app/outputs/bundle/release/app-release.aab`

### B. APK de Release (Para pruebas directas en dispositivos)
Si deseas instalar el binario firmado directamente en un teléfono sin pasar por Google Play:

```bash
flutter build apk --release
```

- **Ubicación del artefacto generado:**
  `build/app/outputs/flutter-apk/app-release.apk`

---

## 4. Google Play App Signing

JavaPlay está configurado para utilizar **Play App Signing** de Google Play:

1. **Upload Key (Clave de Carga):** El keystore generado en el paso 1 funciona como tu clave de carga. Al compilar con `flutter build appbundle --release`, firmas el paquete con esta clave.
2. **App Signing Key (Clave de Firma de la App):** Al subir el `.aab` a Google Play Console, Google valida la firma con tu clave de carga, retira la firma de carga y firma los APKs distribuidos a los usuarios con la clave definitiva administrada por Google.
3. **Beneficio crítico:** Si pierdes tu keystore local o tu equipo de desarrollo cambia, puedes solicitar un restablecimiento de la *Upload Key* a través de Google Play Console sin perder el paquete `com.neoarsenal.javaplay` ni la base de usuarios existente.
