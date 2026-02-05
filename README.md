# TicTacToe iOS

Una aplicación iOS nativa del juego clásico Tres en Raya con diseño elegante y características modernas.

## 🎯 Características

- **Modo Un Jugador**: Juega contra IA con 3 niveles de dificultad
- **Modo Dos Jugadores**: Multijugador local en el mismo dispositivo
- **IA Avanzada**: Algoritmo Minimax con poda alfa-beta
- **Estadísticas Persistentes**: Historial de partidas y logros
- **Diseño Clásico**: Interfaz elegante y sofisticada
- **Accesibilidad Completa**: VoiceOver, Dynamic Type, reducción de movimiento
- **Localización**: Español e Inglés
- **Sonidos y Música**: Experiencia auditiva inmersiva

## 📱 Requisitos

- iOS 13.0+
- Xcode 14.0+
- iPhone/iPad compatible

## 🏗️ Arquitectura

- **MVVM** con SwiftUI y Combine
- **Programación Reactiva**
- **Testing Unitario** completo
- **Inyección de Dependencias**
- **Repositorio de Datos**

## 🚀 Instalación

### Clonar el repositorio
```bash
git clone <repository-url>
cd TicTacToeIOS
```

### Abrir en Xcode
```bash
open TicTacToeIOS.xcodeproj
```

### Compilar y Ejecutar
- Selecciona tu dispositivo o simulador
- Presiona `Cmd + R` para compilar y ejecutar

## 🧪 Testing

```bash
# Ejecutar tests unitarios
xcodebuild test -scheme TicTacToeIOS

# Ejecutar tests de UI
xcodebuild test -scheme TicTacToeIOS -only-testing:TicTacToeIOSUITests
```

## 📄 Documentación

- [Guía de Arquitectura](Documentation/Architecture.md)
- [Guía de Despliegue](Documentation/Deployment.md)

## 🎮 Cómo Jugar

1. Abre la aplicación
2. Selecciona "Un Jugador" o "Dos Jugadores"
3. Elige la dificultad (solo un jugador)
4. Toca las celdas vacías para jugar
5. Gana al alinear 3 símbolos

## 🏆 Logros

- **Primera Victoria**: Gana tu primera partida
- **Racha de 3**: Gana 3 partidas seguidas
- **Jugador Dedicado**: Juega 10 partidas
- **Maestro del Juego**: Juega 50 partidas
- **Experto en IA**: Gana 3 partidas en dificultad difícil

## 🛠 Tecnologías

- **Swift 5.7+**
- **SwiftUI**
- **Combine**
- **AVFoundation**
- **UserDefaults**
- **Unit Testing**

## 📱 Capturas de Pantalla

*(Agrega capturas de pantalla aquí)*

## 🤝 Contribuciones

1. Fork del repositorio
2. Crea una rama feature: `git checkout - feature/nueva-caracteristica`
3. Commits: `git commit -am 'Añadir nueva característica'`
4. Push: `git push origin feature/nueva-caracteristica`
5. Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo MIT License.

## 👨‍💻 Desarrollador

iOS Game Studio - 2024

---

**Nota**: Esta es una aplicación educativa que demuestra las mejores prácticas en desarrollo iOS moderno.