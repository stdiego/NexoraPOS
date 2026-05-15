// ══════════════════════════════════════════════════════════════════════════════
// PantallaInventario.swift
// ══════════════════════════════════════════════════════════════════════════════
import SwiftUI
import SwiftData

struct PantallaInventario: View {

    @Query private var productos: [Producto]
    @State private var mostrarNuevoProducto = false

    var body: some View {
        NavigationStack {
            Group {
                if productos.isEmpty {
                    VStack(spacing: 16) {
                        Text("📦").font(.system(size: 64))
                        Text("Tu inventario está vacío").foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "#F3F4F6"))
                } else {
                    List(productos, id: \.id) { producto in
                        let indice = productos.firstIndex(where: { $0.id == producto.id }) ?? 0
                        NavigationLink(destination: PantallaEditarProducto(producto: producto)) {
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "#F1F5F9"))
                                    .frame(width: 64, height: 64)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(producto.nombre).font(.callout).fontWeight(.medium)
                                    Text(String(format: "$%.2f", producto.precio))
                                        .foregroundColor(Color(hex: "#00D166")).bold().font(.footnote)
                                    Text("En almacén: \(producto.cantidadEnStock) uds.")
                                        .font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "pencil").foregroundColor(.gray)
                            }
                        }
                        .listRowBackground(Color.white)
                    }
                    .listStyle(.plain)
                    .background(Color(hex: "#F3F4F6"))
                }
            }
            .navigationTitle("Inventario General")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { mostrarNuevoProducto = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrarNuevoProducto) {
                PantallaNuevoProducto()
            }
        }
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// PantallaNuevoProducto.swift
// ══════════════════════════════════════════════════════════════════════════════
struct PantallaNuevoProducto: View {

    @Environment(\.modelContext) private var contexto
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var precioTexto = ""
    @State private var stockTexto = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Equivalente a OutlinedTextField en Compose
                TextField("Nombre del Producto", text: $nombre)
                    .padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))

                TextField("Precio ($)", text: $precioTexto)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))

                TextField("Cantidad en Stock", text: $stockTexto)
                    .keyboardType(.numberPad)
                    .padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))

                Spacer()

                Button(action: guardarProducto) {
                    Text("Guardar Producto")
                        .font(.headline).bold().foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Color(hex: "#2ECC71"))
                        .cornerRadius(12)
                }
            }
            .padding(24)
            .navigationTitle("Nuevo Producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }

    func guardarProducto() {
        guard !nombre.isEmpty,
              let precio = Double(precioTexto), precio > 0 else { return }
        let stock = Int(stockTexto) ?? 0
        let producto = Producto(nombre: nombre, precio: precio, cantidadEnStock: stock)
        contexto.insert(producto)
        dismiss()
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// PantallaEditarProducto.swift
// ══════════════════════════════════════════════════════════════════════════════
struct PantallaEditarProducto: View {

    @Environment(\.modelContext) private var contexto
    @Environment(\.dismiss) private var dismiss

    let producto: Producto

    @State private var nombre: String
    @State private var precioTexto: String
    @State private var stockTexto: String
    @State private var errorNombre = false
    @State private var errorPrecio = false
    @State private var errorStock = false

    init(producto: Producto) {
        self.producto = producto
        _nombre = State(initialValue: producto.nombre)
        _precioTexto = State(initialValue: String(producto.precio))
        _stockTexto = State(initialValue: String(producto.cantidadEnStock))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Tarjeta estado actual
                VStack(alignment: .leading, spacing: 12) {
                    Text("Estado actual").font(.caption).bold().foregroundColor(.gray)
                    HStack {
                        VStack { Text("Nombre").font(.caption).foregroundColor(.gray); Text(producto.nombre).font(.footnote).fontWeight(.medium) }
                        Spacer()
                        VStack { Text("Precio").font(.caption).foregroundColor(.gray); Text(String(format: "$%.2f", producto.precio)).font(.footnote).bold().foregroundColor(Color(hex: "#00D166")) }
                        Spacer()
                        VStack { Text("Stock").font(.caption).foregroundColor(.gray); Text("\(producto.cantidadEnStock) uds.").font(.footnote).bold() }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)

                Text("MODIFICAR DATOS").font(.caption).bold().foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Campo nombre
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Nombre del Producto", text: $nombre)
                        .onChange(of: nombre) { _, _ in errorNombre = false }
                        .padding(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(errorNombre ? Color.red : Color(hex: "#00D166"), lineWidth: errorNombre ? 1.5 : 1))
                    if errorNombre { Text("El nombre no puede estar vacío").font(.caption2).foregroundColor(.red) }
                }

                // Campo precio
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Precio ($)", text: $precioTexto)
                        .keyboardType(.decimalPad)
                        .onChange(of: precioTexto) { _, _ in errorPrecio = false }
                        .padding(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(errorPrecio ? Color.red : Color(hex: "#00D166"), lineWidth: errorPrecio ? 1.5 : 1))
                    if errorPrecio { Text("Ingresa un precio válido mayor a 0").font(.caption2).foregroundColor(.red) }
                }

                // Campo stock
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Cantidad en Stock", text: $stockTexto)
                        .keyboardType(.numberPad)
                        .onChange(of: stockTexto) { _, _ in errorStock = false }
                        .padding(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(errorStock ? Color.red : Color(hex: "#00D166"), lineWidth: errorStock ? 1.5 : 1))
                    if errorStock { Text("El stock no puede ser negativo").font(.caption2).foregroundColor(.red) }
                }

                Spacer()

                Button(action: guardarCambios) {
                    Text("Guardar Cambios")
                        .font(.headline).bold().foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Color(hex: "#00D166"))
                        .cornerRadius(16)
                }
            }
            .padding(20)
        }
        .background(Color(hex: "#F3F4F6"))
        .navigationTitle("Editar Producto")
        .navigationBarTitleDisplayMode(.inline)
    }

    func guardarCambios() {
        let precio = Double(precioTexto)
        let stock = Int(stockTexto)
        errorNombre = nombre.isEmpty
        errorPrecio = precio == nil || precio! <= 0
        errorStock = stock == nil || stock! < 0
        guard !errorNombre && !errorPrecio && !errorStock else { return }
        producto.nombre = nombre.trimmingCharacters(in: .whitespaces)
        producto.precio = precio!
        producto.cantidadEnStock = stock!
        dismiss()
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// PantallaHistorial.swift
// ══════════════════════════════════════════════════════════════════════════════
struct PantallaHistorial: View {

    @Query(sort: \Factura.id, order: .reverse) private var facturas: [Factura]

    var body: some View {
        NavigationStack {
            Group {
                if facturas.isEmpty {
                    Text("Aún no tienes ventas registradas.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hex: "#F5F5F5"))
                } else {
                    List(facturas, id: \.id) { factura in
                        NavigationLink(destination: PantallaDetalleFactura(factura: factura)) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color(hex: "#3498DB"))
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Ticket #\(factura.id)").font(.callout).bold()
                                        .foregroundColor(Color(hex: "#0D1B2A"))
                                    Text(factura.fecha).font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                                Text(String(format: "$%.2f", factura.total))
                                    .font(.callout).bold()
                                    .foregroundColor(Color(hex: "#2ECC71"))
                            }
                        }
                        .listRowBackground(Color.white)
                    }
                    .listStyle(.plain)
                    .background(Color(hex: "#F5F5F5"))
                }
            }
            .navigationTitle("Historial de Ventas")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// PantallaDetalleFactura.swift
// ══════════════════════════════════════════════════════════════════════════════
struct PantallaDetalleFactura: View {

    let factura: Factura
    @Environment(\.dismiss) private var dismiss

    var iva: Double { factura.total * 0.16 }
    var granTotal: Double { factura.total + iva }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Banner éxito
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "#2ECC71")).font(.title)
                    VStack(alignment: .leading) {
                        Text("Venta Completada").font(.callout).bold()
                            .foregroundColor(Color(hex: "#27AE60"))
                        Text(String(format: "Factura #%05d generada", factura.id))
                            .font(.caption).foregroundColor(Color(hex: "#444444"))
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color(hex: "#E8F8F5"))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#2ECC71"), lineWidth: 1))
                .cornerRadius(12)

                // Tarjeta ticket
                VStack(spacing: 16) {
                    // Header empresa
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#2ECC71"))
                            .frame(width: 48, height: 48)
                            .overlay(Text("N").font(.title).bold().foregroundColor(.white))
                        Text("Nexora POS").font(.title3).fontWeight(.medium)
                        Text("RFC: NEX123456789").font(.caption).foregroundColor(.gray)
                        Text("Av. Principal #123, CDMX").font(.caption).foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    // Info cliente
                    Group {
                        Text("FACTURA A:").font(.caption).bold().foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Cliente General").foregroundColor(Color(hex: "#1E272E"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("RFC: XAXX010101000").font(.caption).foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Metadatos
                    VStack(spacing: 8) {
                        HStack { Text("Factura #").foregroundColor(.gray); Spacer(); Text(String(format: "%05d", factura.id)) }
                        HStack { Text("Fecha").foregroundColor(.gray); Spacer(); Text(factura.fecha) }
                        HStack { Text("Método de Pago").foregroundColor(.gray); Spacer(); Text(factura.metodoPago) }
                    }
                    .font(.footnote)

                    Divider()

                    // Productos
                    ForEach(factura.items, id: \.nombreProducto) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.nombreProducto).font(.footnote).fontWeight(.medium)
                                Text("\(item.cantidad) x \(String(format: "$%.2f", item.precioProducto))")
                                    .font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            Text(String(format: "$%.2f", item.precioProducto * Double(item.cantidad)))
                                .font(.footnote)
                        }
                    }

                    Divider()

                    // Totales
                    VStack(spacing: 8) {
                        HStack { Text("Subtotal").foregroundColor(.gray); Spacer(); Text(String(format: "$%.2f", factura.total)) }
                        HStack { Text("IVA (16%)").foregroundColor(.gray); Spacer(); Text(String(format: "$%.2f", iva)) }
                        HStack {
                            Text("TOTAL").font(.callout).bold()
                            Spacer()
                            Text(String(format: "$%.2f", granTotal))
                                .font(.title3).bold().foregroundColor(Color(hex: "#2ECC71"))
                        }
                    }
                    .font(.footnote)
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(24)

                // Botones de acción
                Button(action: {}) {
                    Text("⬇ Descargar PDF")
                        .foregroundColor(Color(hex: "#1E272E"))
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#E5E7EB"), lineWidth: 1))
                }

                HStack(spacing: 12) {
                    Button(action: {}) {
                        Text("💬 WhatsApp").foregroundColor(Color(hex: "#1E272E"))
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#E5E7EB"), lineWidth: 1))
                    }
                    Button(action: {}) {
                        HStack { Image(systemName: "envelope"); Text("Correo") }
                            .foregroundColor(Color(hex: "#1E272E"))
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#E5E7EB"), lineWidth: 1))
                    }
                }

                
                // ANTES — línea 401
                Button("Volver al Inicio") { dismiss() }
               
                
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16).padding(.vertical, 20)
        }
        .background(Color(hex: "#F3F4F6"))
        .navigationTitle("Factura Generada")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// PantallaReportes.swift
// ══════════════════════════════════════════════════════════════════════════════
struct PantallaReportes: View {

    @Query private var facturas: [Factura]

    var totalVentas: Int { facturas.count }
    var ingresosTotales: Double { facturas.reduce(0) { $0 + $1.total } }
    var productoEstrella: String {
        var conteo: [String: Int] = [:]
        facturas.flatMap { $0.items }.forEach { conteo[$0.nombreProducto, default: 0] += $0.cantidad }
        return conteo.max(by: { $0.value < $1.value })?.key ?? "Sin datos de venta"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("RESUMEN GENERAL").font(.caption).bold().foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)

                    reporteCard(icono: "$", color: Color(hex: "#2ECC71"), titulo: "Ingresos Brutos",
                                valor: String(format: "$%.2f", ingresosTotales))
                    reporteCard(icono: "#", color: Color(hex: "#3498DB"), titulo: "Tickets Generados",
                                valor: "\(totalVentas) transacciones")

                    Text("MÉTRICAS DESTACADAS").font(.caption).bold().foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)

                    reporteCard(icono: "⭐", color: Color(hex: "#F1F5F9"), titulo: "Tu Producto Estrella",
                                valor: productoEstrella)
                }
                .padding(.horizontal, 16).padding(.vertical, 16)
            }
            .background(Color(hex: "#F3F4F6"))
            .navigationTitle("Reportes y Analíticas")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func reporteCard(icono: String, color: Color, titulo: String, valor: String) -> some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.15))
                .frame(width: 56, height: 56)
                .overlay(Text(icono).font(.title).fontWeight(.bold).foregroundColor(color))
            VStack(alignment: .leading, spacing: 4) {
                Text(titulo).font(.footnote).foregroundColor(.gray)
                Text(valor).font(.title3).bold().foregroundColor(Color(hex: "#1E272E"))
            }
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// PantallaConfiguracion.swift
// ══════════════════════════════════════════════════════════════════════════════
struct PantallaConfiguracion: View {

    // Equivalente a var notificacionesActivas by remember { mutableStateOf(true) }
    @State private var notificacionesActivas = true
    @State private var modoOscuroActivo = false
    @State private var cerrarSesion = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tarjeta perfil
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color(hex: "#3498DB"))
                        .frame(width: 64, height: 64)
                        .overlay(Image(systemName: "person.fill").foregroundColor(.white).font(.title2))
                    VStack(alignment: .leading) {
                        Text("Juan Pérez").font(.title3).bold().foregroundColor(Color(hex: "#0D1B2A"))
                        Text("Dueño del Negocio").foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .padding(16)

                Text("PREFERENCIAS").font(.caption).bold().foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)

                VStack(spacing: 0) {
                    // Equivalente a Switch en Compose
                    HStack {
                        Label("Notificaciones Push", systemImage: "bell")
                        Spacer()
                        Toggle("", isOn: $notificacionesActivas)
                            .tint(Color(hex: "#2ECC71"))
                    }
                    .padding(16)

                    Divider()

                    HStack {
                        Label("Modo Oscuro (Beta)", systemImage: "exclamationmark.triangle")
                        Spacer()
                        Toggle("", isOn: $modoOscuroActivo)
                    }
                    .padding(16)
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal, 16)

                Spacer()

                Button(action: { cerrarSesion = true }) {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Cerrar Sesión").font(.headline).bold()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Color(hex: "#E74C3C"))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
                .fullScreenCover(isPresented: $cerrarSesion) { PantallaLogin() }
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


