# Farm SiK-Ness - Diseño Core V1 (MVP Escalable)

## 1. Filosofía de Diseño
**"Simple de jugar, profundo de optimizar."**
El objetivo es crear un MVP (Producto Mínimo Viable) sólido y escalable. Eliminamos la complejidad del procesamiento (cadenas de producción) para centrarnos en la **gestión espacial** y la **optimización de adyacencias**.

## 2. Bucle de Juego Simplificado (Core Loop)
1.  **Generación (Idle):** Los edificios en el grid generan "Recursos" o "Dinero" automáticamente con el tiempo.
2.  **Recolección/Venta:** El jugador recolecta las ganancias (click o automático).
3.  **Expansión/Adquisición:** El jugador gasta dinero para obtener **nuevos edificios** (piezas).
4.  **Optimización (Puzzle):** El jugador coloca el nuevo edificio en el Grid.
    *   *Reto:* El espacio es limitado y las formas son irregulares (Tetrominos/Polyominos).
    *   *Estrategia:* Buscar sinergias (ej. Un "Pozo" aumenta la producción de los "Cultivos" adyacentes).

## 3. Mecánicas Detalladas

### A. El Grid y los Edificios (Sistema de Tetris/Puzzle)
- **El Tablero:** Una cuadrícula finita (ej. 10x10) que se puede expandir comprando filas/columnas.
- **Las Piezas (Edificios):**
    - Cada edificio tiene una **forma** definida en celdas (1x1, 1x2, L, T, cuadrado 2x2).
    - **Rotación:** El jugador puede rotar las piezas antes de colocarlas.
    - **Movimiento:** Las piezas ya colocadas se pueden mover (quizás con un coste de tiempo o "energía" para evitar el spam, o libre en modo edición).

### B. Sistema de Adquisición (La "Tienda")
En lugar de un menú infinito, usaremos un sistema de **"Oferta Diaria"** o **"Draft"** para dar valor a las piezas:
- El jugador tiene 3 opciones de edificios para comprar.
- Al comprar uno, la tienda se refresca (o cuesta dinero refrescarla).
- Esto fuerza al jugador a adaptarse a las formas que le tocan, aumentando el componente de puzzle.

### C. Sistema de Sinergias (Adyacencia)
La clave de la optimización.
- **Buffs de Proximidad:**
    - *Espantapájaros (1x1):* +10% producción a cultivos en radio 1.
    - *Silo (2x2):* Almacena el doble, pero debe estar tocando un cultivo.
    - *Río (lineal):* +50% a cultivos adyacentes, pero bloquea el paso.

## 4. Arquitectura Técnica en Godot (Data-Driven)

Para hacer el juego escalable y fácil de ampliar sin tocar código, usaremos intensivamente **`Resource` (.tres)**.

### A. Definición de Datos (`BuildingData.gd` extends Resource)
Cada edificio será un archivo `.tres` con:
- `id`: String único.
- `name`: Nombre visible.
- `texture`: Sprite base.
- `shape_pattern`: Array de Vector2 (define la forma, ej: `[(0,0), (1,0), (0,1)]` para una 'L').
- `base_production`: Cantidad por segundo.
- `cost`: Precio base.
- `synergy_tags`: Array de Strings (ej. ["crop", "water"]).
- `synergy_rules`: Diccionario de reglas (ej. `{"water": 1.5}` -> multiplica x1.5 si toca "water").

### B. Escenas y Nodos
- **`MainGame.tscn`**: Escena principal.
- **`GridManager` (Node2D):**
    - Controla el `TileMapLayer` (Godot 4.5 usa Layers).
    - Gestiona la lógica de ocupación (Matriz de datos).
    - Valida si una pieza cabe en una posición `(x, y)`.
- **`BuildingEntity` (Node2D):**
    - Instancia visual de un edificio.
    - Tiene un script que lee su `BuildingData`.
    - Maneja su propio timer de producción.

### C. Sistema Offline (Idle)
1.  Al cerrar el juego, guardamos: `timestamp_cierre` (Unix Time).
2.  Al abrir:
    - `tiempo_pasado = timestamp_actual - timestamp_cierre`.
    - `produccion_total = 0`.
    - Iteramos sobre todos los edificios construidos:
        - `produccion_edificio = (produccion_base * modificadores_adyacencia) * tiempo_pasado`.
        - `produccion_total += produccion_edificio`.
    - Mostramos popup: "¡Bienvenido de nuevo! Tu granja produjo X mientras dormías".

## 5. Hoja de Ruta de Implementación (Roadmap)

1.  **Fase 1: El Grid y Datos.**
    - Crear `BuildingData` (Resource).
    - Crear sistema de Grid que acepte formas arbitrarias.
    - Visualizar una pieza siguiendo el ratón (Ghost building).

2.  **Fase 2: Colocación y Persistencia.**
    - Validar colocación (no solapar, dentro de límites).
    - Guardar/Cargar estado del grid.

3.  **Fase 3: Producción y UI.**
    - Loop de producción simple.
    - UI de recursos (Contador de dinero).
    - Tienda básica para comprar piezas.

4.  **Fase 4: Sinergias.**
    - Implementar lógica de detección de vecinos.
    - Aplicar multiplicadores.
