import SwiftUI
import SwiftData

// ── Datos iniciales Panadería ──────────────────────────────────────────────────
// Agrega este archivo al proyecto. Los productos se insertan automáticamente
// la primera vez que se abre la app (usando @AppStorage como bandera).
// ──────────────────────────────────────────────────────────────────────────────

struct DatosPanaderia {

    static let productos: [(nombre: String, precio: Double, stock: Int)] = [

        // ── Panes ──────────────────────────────────────────────────────────────
        ("Pan Francés (unidad)",        0.20,  200),
        ("Pan Integral (unidad)",       0.25,  150),
        ("Pan de Queso (unidad)",       0.50,  100),
        ("Pan de Bono (unidad)",        0.60,   80),
        ("Pan de Mantequilla (unidad)", 0.30,  120),
        ("Mogolla (unidad)",            0.25,  150),
        ("Pan Tajado (500g)",           2.50,   60),
        ("Pan de Ajo (unidad)",         0.80,   80),
        ("Croissant (unidad)",          1.50,   60),
        ("Pan de Chocolate (unidad)",   1.20,   50),

        // ── Pasteles y Tortas ──────────────────────────────────────────────────
        ("Torta de Vainilla (porción)", 3.50,   40),
        ("Torta de Chocolate (porción)",3.50,   40),
        ("Torta de Zanahoria (porción)",3.00,   30),
        ("Torta Entera Vainilla",      28.00,    8),
        ("Torta Entera Chocolate",     28.00,    8),
        ("Pastel de Manzana (porción)", 2.80,   35),
        ("Cheesecake (porción)",        4.00,   25),

        // ── Galletas y Ponqués ─────────────────────────────────────────────────
        ("Galleta de Chips (unidad)",   0.80,  100),
        ("Galleta de Avena (unidad)",   0.70,  100),
        ("Ponqué (unidad)",             1.50,   60),
        ("Ponqué de Arándanos (unidad)",1.80,   50),
        ("Brownie (unidad)",            2.00,   45),
        ("Muffin (unidad)",             1.80,   50),

        // ── Hojaldre y Empanadas ───────────────────────────────────────────────
        ("Empanada de Pollo (unidad)",  1.50,   80),
        ("Empanada de Carne (unidad)",  1.50,   80),
        ("Empanada de Queso (unidad)",  1.20,   80),
        ("Hojaldre Dulce (unidad)",     1.80,   50),
        ("Hojaldre Salado (unidad)",    1.80,   50),
        ("Palito de Queso (unidad)",    0.60,  100),
        ("Pandebono (unidad)",          0.80,  120),

        // ── Bebidas ────────────────────────────────────────────────────────────
        ("Café Negro (vaso)",           1.00,   80),
        ("Café con Leche (vaso)",       1.50,   80),
        ("Chocolate Caliente (vaso)",   1.80,   60),
        ("Jugo de Naranja (vaso)",      2.00,   50),
        ("Agua Botella (500ml)",        1.00,   60),

        // ── Combos ────────────────────────────────────────────────────────────
        ("Combo Desayuno (pan+café)",   2.50,   40),
        ("Combo Onces (pastel+bebida)", 4.50,   30),
    ]

    /// Inserta los productos en SwiftData si no se han cargado antes
    static func cargarSiEsNecesario(contexto: ModelContext) {
        let cargado = UserDefaults.standard.bool(forKey: "panaderiaCargada")
        guard !cargado else { return }

        for item in productos {
            let producto = Producto(
                nombre: item.nombre,
                precio: item.precio,
                cantidadEnStock: item.stock
            )
            contexto.insert(producto)
        }

        UserDefaults.standard.set(true, forKey: "panaderiaCargada")
    }
}


