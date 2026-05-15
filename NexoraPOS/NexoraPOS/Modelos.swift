import Foundation
import SwiftData

// ── Modelo Producto ────────────────────────────────────────────────────────────
@Model
class Producto {
    var id: Int
    var nombre: String
    var precio: Double
    var cantidadEnStock: Int

    init(id: Int = Int.random(in: 1000...99999), nombre: String, precio: Double, cantidadEnStock: Int) {
        self.id = id
        self.nombre = nombre
        self.precio = precio
        self.cantidadEnStock = cantidadEnStock
    }
}

// ── Modelo ProductoEnFactura (relación Factura ↔ Producto) ─────────────────────
// SwiftData no soporta Map<Producto, Int>, usamos una entidad intermedia
@Model
class ProductoEnFactura {
    var nombreProducto: String
    var precioProducto: Double
    var cantidad: Int

    init(nombreProducto: String, precioProducto: Double, cantidad: Int) {
        self.nombreProducto = nombreProducto
        self.precioProducto = precioProducto
        self.cantidad = cantidad
    }
}

// ── Modelo Factura ─────────────────────────────────────────────────────────────
@Model
class Factura {
    var id: Int
    var total: Double
    var fecha: String
    var metodoPago: String
    @Relationship(deleteRule: .cascade)
    var items: [ProductoEnFactura]

    init(id: Int, total: Double, fecha: String, metodoPago: String = "Efectivo", items: [ProductoEnFactura] = []) {
        self.id = id
        self.total = total
        self.fecha = fecha
        self.metodoPago = metodoPago
        self.items = items
    }
}
