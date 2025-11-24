# Lluvia de Ideas - Farm SiK-Ness

## 1. Concepto General
Videojuego multiplataforma (PC y Smartphone) desarrollado en Godot 4.5.1.
**Género:** Idle / Gestión / Puzzle (Grid).
**Premisa:** Granjeo de elementos, procesamiento y venta. Mecánica central Idle con gestión activa de edificios en una cuadrícula.

## 2. Mecánicas Principales (Core Mechanics)

### A. Sistema de Granjeo (Farming)
- **Cultivo:** Plantar semillas que crecen con el tiempo.
- **Cosecha:** Recolección manual o automática (mejoras).
- **Recursos:** Diferentes tipos de cultivos con valores y tiempos de crecimiento variados.

### B. Sistema de Procesamiento
- Transformación de materias primas en productos de mayor valor.
- Ejemplo: Trigo -> Harina -> Pan.

### C. Sistema de Construcción (Grid/Tetris)
- **Cuadrícula:** El terreno de juego es una cuadrícula finita.
- **Edificios:** Tienen formas específicas (tipo Tetris/Polyominoes) que deben encajar en la cuadrícula.
- **Estrategia:** La disposición de los edificios afecta la eficiencia (bonus de adyacencia).
- **Movimiento:** Posibilidad de mover edificios ya construidos para optimizar el espacio.

### D. Mecánica Idle
- Generación de recursos incluso cuando el juego está cerrado.
- Acumulación de "Tiempo Offline" o recursos directos.

## 3. Ciclo de Juego (Core Loop)
1. **Producir:** Cultivar y recolectar recursos básicos.
2. **Procesar:** Convertir recursos en productos.
3. **Vender:** Obtener dinero (soft currency).
4. **Mejorar/Expandir:** Comprar nuevos edificios, expandir la cuadrícula, mejorar eficiencia.
5. **Repetir.**

## 4. Pantallas e Interfaz (UI)

### Pantalla Principal (La Granja)
- Vista de la cuadrícula (Grid).
- HUD: Recursos, Dinero, Nivel.
- Botones de acceso rápido: Construir, Inventario, Tienda.

### Menú de Construcción
- Lista de edificios disponibles.
- Visualización de la forma del edificio (pieza de Tetris).

### Menú de Gestión/Mejoras
- Árbol de tecnologías o lista de mejoras (velocidad, valor de venta, automatización).

### Pantalla de Venta/Mercado
- Fluctuación de precios (opcional).
- Contratos o pedidos específicos.

## 5. Elementos del Juego (Entidades)
- **Cultivos:** Trigo, Maíz, Zanahorias, etc.
- **Edificios de Producción:** Huerto, Invernadero.
- **Edificios de Procesamiento:** Molino, Panadería, Fábrica de Jugos.
- **Edificios de Almacenamiento:** Silos, Almacenes.
- **Decoración:** Elementos estéticos que podrían dar bonus pasivos.

## 6. Algoritmos y Lógica (Borrador)
- **Sistema de Grid:** Matriz 2D para controlar ocupación y adyacencias.
- **Cálculo Offline:** `(Tiempo Actual - Última Conexión) * Tasa de Producción`.
- **Economía:** Curvas de coste exponencial para edificios y mejoras.

## 7. Dudas y Definiciones Pendientes
- ¿El movimiento de edificios es libre o tiene coste?
- ¿Hay un personaje controlable o es "vista de dios"?
- ¿Cómo se monetiza (si aplica)? (Ads, IAP).
- Estilo visual: ¿Pixel Art, Low Poly, Vectorial?
