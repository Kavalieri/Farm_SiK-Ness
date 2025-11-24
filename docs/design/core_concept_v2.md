# Farm SiK-Ness - Diseño Core V2 (Detallado)

## 1. Arquitectura de Datos y Persistencia

### A. Sistema de Guardado (Save System)
Usaremos un sistema basado en **JSON encriptado** (o binario) para evitar modificaciones triviales, pero manteniendo la estructura flexible.
- **Ruta:** `user://savegame.save`
- **Estructura del JSON:**
  ```json
  {
    "meta": {
      "version": "0.1.0",
      "last_login": 1715623400
    },
    "player": {
      "money": 1500,
      "level": 5,
      "xp": 450,
      "unlocked_ids": ["farm_basic", "silo_small"]
    },
    "grid": [
      { "uid": "unique_id_1", "data_id": "farm_basic", "x": 2, "y": 3, "rot": 0, "level": 12, "milestones": 1 }
    ],
    "settings": {
      "sfx_volume": 0.8,
      "music_volume": 0.5,
      "notifications": true
    }
  }
  ```
- **Autoguardado:** Cada X segundos (ej. 30s) y al eventos importantes (comprar, cerrar app).

### B. Configuración (Settings)
- **Usuario:** Volumen (Master, SFX, Música), Idioma, Ahorro de batería (bajar FPS).
- **Desarrollo (ProjectSettings):**
  - `game/config/debug_mode`: Boolean.
  - `game/balance/production_multiplier`: Float (para testear ritmo).

### C. Modo Debug (Developer Tools)
Un "God Mode" accesible mediante una secuencia oculta o tecla (F12 en PC).
- **Funciones:**
  - `Add Money / XP`: Botones para inyectar recursos.
  - `Unlock All`: Desbloquear todas las piezas.
  - `Clear Save`: Borrar partida y reiniciar.
  - `Speed Hack`: Acelerar el tiempo del juego (x10, x100) para probar el Idle.
  - `Spawn Item`: Forzar la aparición de una pieza específica en la tienda.

---

## 2. Progresión y Mecánicas Avanzadas

### A. Sistema de Adquisición: "El Mercado de Contratos"
Para mantener el enganche, no hay una tienda estática.
- **Mecánica de Draft (Selección):**
  - Aparecen **3 Contratos (Cartas)** aleatorios.
  - El jugador elige uno. Los otros se descartan.
  - **Coste:** El precio sube cuanto más compras en el mismo día (o sesión), reseteándose o bajando con el tiempo.
- **Algoritmo de Probabilidad (Weighted Random):**
  - `Pool`: Lista de edificios desbloqueados por nivel.
  - `Peso`: `Rareza_Base * (1 + Suerte_Jugador)`.
  - *Ejemplo:* A nivel 1, solo salen "Huertos". A nivel 5, hay un 10% de que salga un "Silo".

### B. Sistema de Experiencia y Niveles (Player Level)
- **Ganar XP:**
  - Al recolectar recursos (poco).
  - Al construir un edificio nuevo (medio).
  - Al completar un "Milestone" de edificio (mucho).
- **Subir de Nivel:**
  - Desbloquea **nuevas piezas** en el pool del Mercado.
  - Aumenta el tamaño del Grid (cada 5 niveles).

### C. Mejoras de Edificios (Milestones)
En lugar de solo subir nivel 1 a 100 linealmente.
- **Niveles 1-9:** Aumento lineal de producción (+10% base).
- **Nivel 10 (Hito de Bronce):** **x2 Multiplicador Global** a este edificio.
- **Nivel 25 (Hito de Plata):** Desbloquea **Efecto de Radio** (ej. ahora da bonus a los de al lado).
- **Nivel 50 (Hito de Oro):** **Autorecolección** (si no la tenía).
- *Visual:* El edificio cambia ligeramente o gana partículas al llegar a un hito.

### D. Eventos Aleatorios (Random Events)
Pequeños modificadores temporales para romper la monotonía.
- **Al Recolectar (Trigger):** 1% de probabilidad de "Cosecha Dorada" (x10 recursos instantáneos).
- **Clima (Global):** "Lluvia" (duración 2 min) -> +50% velocidad de crecimiento de cultivos.

---

## 3. Diseño de Interfaz (UI/UX)

### A. Pantalla Principal (HUD)
- **Top Bar:**
  - Izquierda: Nivel Jugador (Barra XP circular).
  - Centro: Dinero (con notación K, M, B).
  - Derecha: Ajustes (Engranaje).
- **Center:** Viewport del Grid (Zoom/Pan táctil).
- **Bottom Bar:**
  - Botón Gigante Central: **"MERCADO"** (Notificación si hay oferta gratis).
  - Izquierda: "Inventario/Almacén" (Piezas guardadas no colocadas).
  - Derecha: "Misiones/Logros".

### B. Ventanas Flotantes (Modales)

#### 1. Detalle de Edificio (Inspector)
Al tocar un edificio en el grid:
- **Cabecera:** Nombre, Icono, Nivel actual.
- **Stats:** Producción/seg, Sinergias activas (resaltadas en verde).
- **Barra de Hito:** "Nivel 12/25 para siguiente mejora".
- **Acciones:**
  - Botón "Mejorar" (Coste y preview de subida).
  - Botón "Mover" (Entra en modo edición).
  - Botón "Info" (Muestra el lore o detalle técnico).

#### 2. El Mercado (Draft)
- Animación de cartas volteándose.
- Cada carta muestra: Forma (Grid), Rareza (Color de borde), Stats base.
- Botón "Reroll" (Coste incremental).

#### 3. Debug Overlay
- Panel semitransparente con botones simples.
- Consola de logs en la parte inferior.

---

## 4. Hoja de Ruta Técnica Actualizada

1.  **Core System:**
    - `SaveManager` (Autoload): Cargar/Guardar JSON.
    - `GameManager` (Autoload): Control de estado global (Dinero, XP).
2.  **Grid & Data:**
    - Implementar `BuildingResource` con soporte para hitos (Milestones).
    - Grid lógico con validación de formas.
3.  **UI Framework:**
    - Crear componentes base (Botón animado, Ventana modal genérica).
    - Implementar HUD principal.
4.  **Gameplay Loop:**
    - Implementar algoritmo de Draft (Mercado).
    - Conectar producción con XP y Dinero.
