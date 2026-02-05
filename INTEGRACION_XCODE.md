# Instrucciones para Integrar Archivos en Xcode

## 📁 Estructura de Carpetas en Xcode:

### 1. En tu proyecto Xcode crea las siguientes carpetas:
```
TicTacToeIOS/
├── App/
│   ├── TicTacToeApp.swift
│   └── ContentView.swift
├── Models/
│   ├── GameModel.swift
│   ├── Player.swift
│   ├── GameState.swift
│   └── ScoreManager.swift
├── Views/
│   ├── MenuView.swift
│   ├── GameView.swift
│   ├── GameBoardView.swift
│   ├── ScoreView.swift
│   └── SettingsView.swift
├── ViewModels/
│   ├── GameViewModel.swift
│   └── MenuViewModel.swift
├── Services/
│   ├── AIService.swift
│   └── SoundService.swift
└── Utilities/
    ├── Constants.swift
    ├── Extensions.swift
    ├── AnimationExtensions.swift
    └── AccessibilityExtensions.swift
```

## 🔄 Pasos para Integrar:

### 1. Copiar Archivos
Desde el repositorio clonado, copia los archivos:

```bash
# Copiar archivos App
cp TicTacToeIOS/Sources/App/* TU_PROYECTO/App/

# Copiar Models
cp TicTacToeIOS/Sources/Models/* TU_PROYECTO/Models/

# Copiar Views  
cp TicTacToeIOS/Sources/Views/* TU_PROYECTO/Views/

# Copiar ViewModels
cp TicTacToeIOS/Sources/ViewModels/* TU_PROYECTO/ViewModels/

# Copiar Services
cp TicTacToeIOS/Sources/Services/* TU_PROYECTO/Services/

# Copiar Utilities
cp TicTacToeIOS/Sources/Utilities/* TU_PROYECTO/Utilities/
```

### 2. Arrastrar a Xcode
1. Abre tu proyecto Xcode
2. Selecciona el folder principal en el navegador de proyectos
3. Arrastra todas las carpetas copiadas
4. Selecciona "Copy items if needed"
5. Selecciona "Create groups" (no folders)
6. Marca "Add to target: TicTacToeIOS"

### 3. Configurar Resources
1. Crea carpeta "Resources" en tu proyecto
2. Arrastra los archivos .strings a esta carpeta
3. En Project Settings → Info → Localizations, agrega English y Spanish

### 4. Actualizar Info.plist
Agrega estas claves a Info.plist:
```xml
<key>CFBundleDisplayName</key>
<string>Tic Tac Toe</string>
<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
```

### 5. Configurar Tests
Arrastra los archivos de Tests a tu target de pruebas.

## 🚀 Listo para Compilar!

Una vez hecho esto, presiona Cmd+R para compilar y ejecutar.