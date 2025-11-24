# Economy System

## Overview
The economy in Farm SiK-Ness is split into two main resources:
1.  **Products:** Raw resources produced by crops (Farmland).
2.  **Money:** Currency used to buy new buildings and upgrades.

## The Loop
1.  **Production:**
    *   Buildings with the `crop` tag (e.g., Farmland) produce **Products** over time.
    *   Production rate is influenced by synergies (adjacency bonuses).
    *   Products are stored in a global inventory.

2.  **Storage:**
    *   There is a global **Max Storage** limit (default: 100).
    *   If storage is full, crops stop producing (or production is wasted - currently wasted).
    *   *Future:* Silos will increase Max Storage.

3.  **Selling (Shipping Bin):**
    *   The **Shipping Bin** is a unique building located at (0,0).
    *   It automatically converts **Products** into **Money** over time.
    *   **Sell Rate:** 5 Products / second (default).
    *   **Price:** $1 / Product (default).

## Technical Implementation
*   **GameManager:**
    *   `products`: Float (Current amount).
    *   `max_storage`: Float (Capacity).
    *   `add_products(amount)`: Adds products up to max storage.
    *   `consume_products(amount)`: Removes products for selling.
*   **BuildingEntity:**
    *   Checks `tags` for "crop".
    *   Calls `GameManager.add_products()` on timer timeout.
*   **ShippingBin:**
    *   `Node2D` (not a standard BuildingEntity).
    *   Uses a `Timer` to call `GameManager.consume_products()` and `GameManager.add_money()`.
