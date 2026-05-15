import SwiftUI
import SwiftData

// ── Item de venta manual (no vinculado a Producto del inventario) ──────────────
struct ItemManual: Identifiable {
    let id = UUID()
    var nombre: String
    var precio: Double
    var cantidad: Int
}

struct PantallaVender: View {

    @Query private var productos: [Producto]
    @Environment(\.modelContext) private var contexto

    @State private var carrito: [Producto: Int] = [:]
    @State private var itemsManuales: [ItemManual] = []

    @State private var busqueda = ""
    @State private var pantallaActual = "CATALOGO"
    @State private var metodoPago    = "Efectivo"
    @State private var montoRecibido = ""
    @State private var facturaGenerada: Factura? = nil
    @State private var navegarADetalle = false

    // Sheet venta manual
    @State private var mostrarAgregarManual = false
    @State private var nombreManual  = ""
    @State private var precioManual  = ""
    @State private var cantidadManual = "1"

    // ── Totales ────────────────────────────────────────────────────────────────
    var subtotalInventario: Double { carrito.reduce(0) { $0 + ($1.key.precio * Double($1.value)) } }
    var subtotalManual: Double     { itemsManuales.reduce(0) { $0 + ($1.precio * Double($1.cantidad)) } }
    var subtotal: Double   { subtotalInventario + subtotalManual }
    var iva: Double        { subtotal * 0.19 }
    var granTotal: Double  { subtotal + iva }
    var totalItemsEnCarrito: Int {
        carrito.values.reduce(0, +) + itemsManuales.reduce(0) { $0 + $1.cantidad }
    }
    var productosFiltrados: [Producto] {
        busqueda.isEmpty ? productos : productos.filter {
            $0.nombre.lowercased().contains(busqueda.lowercased())
        }
    }

    // ── Cuerpo ─────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationStack {
            Group {
                switch pantallaActual {
                case "PAGO":    vistaPago
                case "CARRITO": vistaCarrito
                default:        vistaCatalogo
                }
            }
            .navigationDestination(isPresented: $navegarADetalle) {
                if let factura = facturaGenerada {
                    PantallaDetalleFactura(factura: factura)
                        .navigationBarBackButtonHidden(true)
                }
            }
            .sheet(isPresented: $mostrarAgregarManual) { sheetAgregarManual }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("volverAlInicio"))) { _ in
                navegarADetalle = false
                pantallaActual = "CATALOGO"
            }
        }
    }

    // ── Vista Catálogo ─────────────────────────────────────────────────────────
    var vistaCatalogo: some View {
        VStack(spacing: 0) {

            // Barra búsqueda + botón manual
            HStack(spacing: 10) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Buscar productos...", text: $busqueda)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))

                Button(action: { mostrarAgregarManual = true }) {
                    VStack(spacing: 2) {
                        Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(.white)
                        Text("Manual").font(.caption2).bold().foregroundColor(.white)
                    }
                    .frame(width: 60, height: 44)
                    .background(Color(hex: "#3498DB"))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Color.white)

            // Chips de items manuales en carrito
            if !itemsManuales.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(itemsManuales) { item in
                            HStack(spacing: 6) {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(item.nombre).font(.caption).bold()
                                        .foregroundColor(Color(hex: "#1E272E")).lineLimit(1)
                                    Text(String(format: "$%.2f x%d", item.precio, item.cantidad))
                                        .font(.caption2).foregroundColor(Color(hex: "#3498DB"))
                                }
                                Button(action: { eliminarManual(item) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(hex: "#E74C3C")).font(.caption)
                                }
                            }
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color(hex: "#EBF5FB"))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 8)
                }
                .background(Color.white)
            }

            // Lista inventario
            if productos.isEmpty && itemsManuales.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "archivebox").font(.largeTitle).foregroundColor(.gray)
                    Text("Sin productos en inventario").foregroundColor(.gray)
                    Button("Agregar venta manual") { mostrarAgregarManual = true }
                        .font(.subheadline).bold().foregroundColor(Color(hex: "#3498DB"))
                }
                Spacer()
            } else {
                List(productosFiltrados, id: \.id) { producto in
                    let enCarrito = carrito[producto] ?? 0
                    let sinStock  = producto.cantidadEnStock == 0
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#F1F5F9"))
                            .frame(width: 64, height: 64)
                            .overlay(Image(systemName: "shippingbox").foregroundColor(Color(hex: "#94A3B8")))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(producto.nombre).font(.callout).fontWeight(.medium)
                                .foregroundColor(Color(hex: "#1E272E"))
                            Text(String(format: "$%.2f", producto.precio))
                                .foregroundColor(Color(hex: "#2ECC71")).bold()
                            HStack(spacing: 4) {
                                Circle().fill(sinStock ? Color.red : Color(hex: "#2ECC71")).frame(width: 6, height: 6)
                                Text(sinStock ? "Sin stock" : "Stock: \(producto.cantidadEnStock)")
                                    .font(.caption).foregroundColor(sinStock ? .red : Color(hex: "#E67E22"))
                            }
                        }
                        Spacer()
                        if enCarrito > 0 {
                            HStack(spacing: 10) {
                                Button(action: {
                                    if enCarrito > 1 { carrito[producto] = enCarrito - 1 }
                                    else { carrito.removeValue(forKey: producto) }
                                }) {
                                    Image(systemName: "minus").frame(width: 32, height: 32)
                                        .background(Color(hex: "#F1F5F9")).cornerRadius(8)
                                        .foregroundColor(Color(hex: "#1E272E"))
                                }
                                Text("\(enCarrito)").font(.callout).bold().foregroundColor(Color(hex: "#1E272E")).frame(minWidth: 20)
                                Button(action: {
                                    if enCarrito < producto.cantidadEnStock { carrito[producto] = enCarrito + 1 }
                                }) {
                                    Image(systemName: "plus").frame(width: 32, height: 32)
                                        .background(enCarrito >= producto.cantidadEnStock ? Color.gray.opacity(0.2) : Color(hex: "#27AE60"))
                                        .cornerRadius(8).foregroundColor(.white)
                                }
                                .disabled(enCarrito >= producto.cantidadEnStock)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button(action: { if !sinStock { carrito[producto] = 1 } }) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(sinStock ? Color.gray.opacity(0.2) : Color(hex: "#27AE60"))
                                    .frame(width: 52, height: 52)
                                    .overlay(Image(systemName: sinStock ? "xmark" : "plus").foregroundColor(.white).font(.title3))
                            }
                            .buttonStyle(.plain).disabled(sinStock)
                        }
                    }
                    .listRowBackground(Color.white)
                    .opacity(sinStock ? 0.5 : 1)
                }
                .listStyle(.plain).background(Color(hex: "#F3F4F6"))
            }

            // Botón ir al carrito
            Button(action: { if totalItemsEnCarrito > 0 { pantallaActual = "CARRITO" } }) {
                HStack(spacing: 10) {
                    Image(systemName: "cart.fill").foregroundColor(.white)
                    if totalItemsEnCarrito > 0 {
                        Text(String(format: "Ver Carrito · $%.2f", subtotal))
                            .font(.headline).bold().foregroundColor(.white)
                        Spacer()
                        Text("\(totalItemsEnCarrito)")
                            .font(.caption).bold().foregroundColor(Color(hex: "#00D166"))
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.white).cornerRadius(12)
                    } else {
                        Text("El carrito está vacío").font(.headline).bold().foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity).frame(height: 60)
                .background(totalItemsEnCarrito > 0 ? Color(hex: "#00D166") : Color.gray.opacity(0.4))
                .cornerRadius(20).padding(.horizontal, 16).padding(.vertical, 10)
            }
            .disabled(totalItemsEnCarrito == 0)
        }
        .background(Color(hex: "#F3F4F6"))
        .navigationTitle("Nueva Venta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { mostrarAgregarManual = true }) {
                    Label("Manual", systemImage: "plus.circle").foregroundColor(Color(hex: "#3498DB"))
                }
            }
        }
    }

    // ── Sheet: Agregar venta manual ────────────────────────────────────────────
    var sheetAgregarManual: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Image(systemName: "pencil.and.list.clipboard")
                            .font(.system(size: 40)).foregroundColor(Color(hex: "#3498DB"))
                        Text("Venta Manual").font(.title2).bold().foregroundColor(Color(hex: "#1E272E"))
                        Text("Agrega un producto que no está en inventario")
                            .font(.caption).foregroundColor(.gray).multilineTextAlignment(.center)
                    }.padding(.top, 8)

                    VStack(spacing: 16) {
                        // Nombre
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Nombre del producto").font(.caption).bold().foregroundColor(.gray)
                            TextField("Ej: Servicio técnico, Producto especial...", text: $nombreManual)
                                .padding(14).background(Color(hex: "#F8FAFC")).cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                                    nombreManual.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "#3498DB"), lineWidth: 1.5))
                        }
                        // Precio
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Precio unitario").font(.caption).bold().foregroundColor(.gray)
                            HStack {
                                Text("$").foregroundColor(.gray).font(.headline)
                                TextField("0.00", text: $precioManual).keyboardType(.decimalPad)
                            }
                            .padding(14).background(Color(hex: "#F8FAFC")).cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                                precioManual.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "#3498DB"), lineWidth: 1.5))
                        }
                        // Cantidad
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Cantidad").font(.caption).bold().foregroundColor(.gray)
                            HStack(spacing: 16) {
                                Button(action: {
                                    let c = Int(cantidadManual) ?? 1
                                    if c > 1 { cantidadManual = "\(c - 1)" }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2).foregroundColor(Color(hex: "#3498DB"))
                                }
                                TextField("1", text: $cantidadManual).keyboardType(.numberPad)
                                    .multilineTextAlignment(.center).font(.title3).bold()
                                    .frame(width: 60).padding(.vertical, 10)
                                    .background(Color(hex: "#F8FAFC")).cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                Button(action: {
                                    let c = Int(cantidadManual) ?? 1; cantidadManual = "\(c + 1)"
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2).foregroundColor(Color(hex: "#3498DB"))
                                }
                            }
                        }
                        // Preview
                        if let precio = Double(precioManual), let cant = Int(cantidadManual), precio > 0 {
                            HStack {
                                Text("Subtotal").foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "$%.2f", precio * Double(cant)))
                                    .font(.headline).bold().foregroundColor(Color(hex: "#2ECC71"))
                            }
                            .padding(14).background(Color(hex: "#F0FDF4")).cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)

                    Button(action: agregarItemManual) {
                        Text("Agregar al carrito")
                            .font(.headline).bold().foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 56)
                            .background(puedeAgregarManual ? Color(hex: "#3498DB") : Color.gray.opacity(0.4))
                            .cornerRadius(16).padding(.horizontal, 24)
                    }
                    .disabled(!puedeAgregarManual)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Venta Manual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { resetearFormularioManual(); mostrarAgregarManual = false }
                        .foregroundColor(.gray)
                }
            }
        }
    }

    var puedeAgregarManual: Bool {
        !nombreManual.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Double(precioManual) ?? 0) > 0 &&
        (Int(cantidadManual) ?? 0) > 0
    }
    func agregarItemManual() {
        guard puedeAgregarManual, let precio = Double(precioManual), let cantidad = Int(cantidadManual) else { return }
        itemsManuales.append(ItemManual(nombre: nombreManual.trimmingCharacters(in: .whitespaces), precio: precio, cantidad: cantidad))
        resetearFormularioManual()
        mostrarAgregarManual = false
    }
    func eliminarManual(_ item: ItemManual) { itemsManuales.removeAll { $0.id == item.id } }
    func resetearFormularioManual() { nombreManual = ""; precioManual = ""; cantidadManual = "1" }

    // ── Vista Carrito ──────────────────────────────────────────────────────────
    var vistaCarrito: some View {
        VStack(spacing: 0) {
            let hayItems = !carrito.isEmpty || !itemsManuales.isEmpty
            if !hayItems {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "cart").font(.largeTitle).foregroundColor(.gray)
                    Text("El carrito está vacío").foregroundColor(.gray)
                }
                Spacer()
            } else {
                List {
                    if !carrito.isEmpty {
                        Section(header: Text("Del inventario").font(.caption).foregroundColor(.gray)) {
                            ForEach(Array(carrito.keys), id: \.id) { producto in
                                filaCarritoInventario(producto: producto, cantidad: carrito[producto] ?? 0)
                            }
                        }
                    }
                    if !itemsManuales.isEmpty {
                        Section(header: Text("Ventas manuales").font(.caption).foregroundColor(.gray)) {
                            ForEach(itemsManuales) { item in filaCarritoManual(item: item) }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }

            VStack(spacing: 10) {
                HStack { Text("Subtotal").foregroundColor(.gray); Spacer(); Text(String(format: "$%.2f", subtotal)) }
                HStack { Text("IVA (19%)").foregroundColor(.gray); Spacer(); Text(String(format: "$%.2f", iva)) }
                Divider()
                HStack {
                    Text("TOTAL").bold().font(.headline); Spacer()
                    Text(String(format: "$%.2f", granTotal)).font(.title2).bold().foregroundColor(Color(hex: "#00D166"))
                }
                Button(action: { pantallaActual = "PAGO" }) {
                    Text("Proceder al Pago →").font(.headline).bold().foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Color(hex: "#00D166")).cornerRadius(16)
                }
            }
            .padding(20).background(Color.white)
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .shadow(color: .black.opacity(0.06), radius: 12, y: -4)
        }
        .background(Color(hex: "#F3F4F6"))
        .navigationTitle("Carrito (\(totalItemsEnCarrito))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { pantallaActual = "CATALOGO" }) { Image(systemName: "chevron.left") }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { mostrarAgregarManual = true }) {
                    Image(systemName: "plus.circle").foregroundColor(Color(hex: "#3498DB"))
                }
            }
        }
    }

    @ViewBuilder
    func filaCarritoInventario(producto: Producto, cantidad: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(producto.nombre).fontWeight(.medium)
                    Text(String(format: "$%.2f c/u", producto.precio)).font(.caption).foregroundColor(Color(hex: "#00D166"))
                }
                Spacer()
                Button(action: { carrito.removeValue(forKey: producto) }) {
                    Image(systemName: "trash").foregroundColor(Color(hex: "#E74C3C"))
                }
            }
            HStack {
                HStack(spacing: 14) {
                    Button(action: {
                        if cantidad > 1 { carrito[producto] = cantidad - 1 } else { carrito.removeValue(forKey: producto) }
                    }) {
                        Image(systemName: "minus").frame(width: 36, height: 36)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                            .foregroundColor(Color(hex: "#1E272E"))
                    }
                    Text("\(cantidad)").font(.callout).bold()
                    Button(action: {
                        if cantidad < producto.cantidadEnStock { carrito[producto] = cantidad + 1 }
                    }) {
                        Image(systemName: "plus").frame(width: 36, height: 36)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                            .foregroundColor(Color(hex: "#1E272E"))
                    }
                }
                Spacer()
                Text(String(format: "$%.2f", producto.precio * Double(cantidad))).fontWeight(.semibold)
            }
        }.padding(.vertical, 4)
    }

    @ViewBuilder
    func filaCarritoManual(item: ItemManual) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.circle.fill").foregroundColor(Color(hex: "#3498DB")).font(.caption)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.nombre).fontWeight(.medium)
                        Text(String(format: "$%.2f c/u", item.precio)).font(.caption).foregroundColor(Color(hex: "#3498DB"))
                    }
                }
                Spacer()
                Button(action: { eliminarManual(item) }) {
                    Image(systemName: "trash").foregroundColor(Color(hex: "#E74C3C"))
                }
            }
            HStack {
                HStack(spacing: 14) {
                    Button(action: {
                        if let i = itemsManuales.firstIndex(where: { $0.id == item.id }) {
                            if itemsManuales[i].cantidad > 1 { itemsManuales[i].cantidad -= 1 }
                            else { itemsManuales.remove(at: i) }
                        }
                    }) {
                        Image(systemName: "minus").frame(width: 36, height: 36)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                            .foregroundColor(Color(hex: "#1E272E"))
                    }
                    Text("\(item.cantidad)").font(.callout).bold()
                    Button(action: {
                        if let i = itemsManuales.firstIndex(where: { $0.id == item.id }) { itemsManuales[i].cantidad += 1 }
                    }) {
                        Image(systemName: "plus").frame(width: 36, height: 36)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                            .foregroundColor(Color(hex: "#1E272E"))
                    }
                }
                Spacer()
                Text(String(format: "$%.2f", item.precio * Double(item.cantidad))).fontWeight(.semibold)
            }
        }.padding(.vertical, 4)
    }

    // ── Vista Pago ─────────────────────────────────────────────────────────────
    var vistaPago: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Total
                VStack(spacing: 8) {
                    Text("Total a Pagar").foregroundColor(.gray).font(.subheadline)
                    Text(String(format: "$%.2f", granTotal))
                        .font(.system(size: 46, weight: .bold)).foregroundColor(Color(hex: "#2ECC71"))
                    HStack(spacing: 16) {
                        Label(String(format: "Sub: $%.2f", subtotal), systemImage: "minus.circle")
                            .font(.caption).foregroundColor(.gray)
                        Label(String(format: "IVA: $%.2f", iva), systemImage: "percent")
                            .font(.caption).foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity).padding(28)
                .background(Color(hex: "#F1F5F9")).cornerRadius(20)

                // Resumen items
                VStack(alignment: .leading, spacing: 8) {
                    Text("Resumen de la venta").font(.caption).bold().foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(Array(carrito.keys), id: \.id) { p in
                        let c = carrito[p] ?? 0
                        HStack {
                            Text("\(p.nombre) x\(c)").font(.caption)
                            Spacer()
                            Text(String(format: "$%.2f", p.precio * Double(c))).font(.caption).bold()
                        }
                    }
                    ForEach(itemsManuales) { item in
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil.circle.fill").font(.caption2).foregroundColor(Color(hex: "#3498DB"))
                                Text("\(item.nombre) x\(item.cantidad)").font(.caption)
                            }
                            Spacer()
                            Text(String(format: "$%.2f", item.precio * Double(item.cantidad))).font(.caption).bold()
                        }
                    }
                }
                .padding(16).background(Color.white).cornerRadius(16)

                // Método pago
                Text("Método de Pago").font(.title3).fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 12) {
                    ForEach([("Efectivo","💵"), ("Tarjeta","💳"), ("Transfer","🏦")], id: \.0) { nombre, emoji in
                        Button(action: { metodoPago = nombre }) {
                            VStack(spacing: 8) {
                                Text(emoji).font(.title)
                                Text(nombre).font(.subheadline)
                                    .foregroundColor(metodoPago == nombre ? Color(hex: "#2ECC71") : .gray)
                            }
                            .frame(maxWidth: .infinity).frame(height: 96)
                            .background(metodoPago == nombre ? Color(hex: "#F0FDF4") : Color.white)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .stroke(metodoPago == nombre ? Color(hex: "#2ECC71") : Color(hex: "#E5E7EB"), lineWidth: 2))
                        }
                    }
                }

                // Efectivo: monto y cambio
                if metodoPago == "Efectivo" {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monto Recibido").foregroundColor(.gray).font(.caption).bold()
                        HStack {
                            Text("$").foregroundColor(.gray).font(.headline)
                            TextField("0.00", text: $montoRecibido).keyboardType(.decimalPad)
                        }
                        .padding(14).background(Color(hex: "#F8FAFC")).cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#2ECC71"), lineWidth: 1.5))

                        if let monto = Double(montoRecibido), monto >= granTotal {
                            HStack {
                                Image(systemName: "arrow.uturn.left.circle.fill").foregroundColor(Color(hex: "#2ECC71"))
                                Text("Cambio: ")
                                Text(String(format: "$%.2f", monto - granTotal)).bold().foregroundColor(Color(hex: "#2ECC71"))
                            }
                            .font(.subheadline).padding(12).background(Color(hex: "#F0FDF4")).cornerRadius(10)
                        }
                    }
                }

                Button(action: confirmarPago) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Confirmar Pago").font(.headline).bold()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 58)
                    .background(Color(hex: "#00D166")).cornerRadius(16)
                }
                Spacer().frame(height: 20)
            }
            .padding(20)
        }
        .background(Color(hex: "#F3F4F6"))
        .navigationTitle("Procesar Pago")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { pantallaActual = "CARRITO" }) { Image(systemName: "chevron.left") }
            }
        }
    }

    // ── Confirmar venta — guarda en SwiftData y descuenta stock ───────────────
    func confirmarPago() {
        let fecha = Date().formatted(date: .abbreviated, time: .shortened)
        let id    = Int.random(in: 10000...99999)

        var items: [ProductoEnFactura] = carrito.map {
            ProductoEnFactura(nombreProducto: $0.key.nombre, precioProducto: $0.key.precio, cantidad: $0.value)
        }
        items += itemsManuales.map {
            ProductoEnFactura(nombreProducto: $0.nombre, precioProducto: $0.precio, cantidad: $0.cantidad)
        }

        // Descontar stock del inventario
        for (producto, cantidad) in carrito {
            producto.cantidadEnStock = max(0, producto.cantidadEnStock - cantidad)
        }

        // Guardar con total = subtotal + IVA
        let factura = Factura(id: id, total: granTotal, fecha: fecha, metodoPago: metodoPago, items: items)
        contexto.insert(factura)

        facturaGenerada = factura
        carrito         = [:]
        itemsManuales   = []
        montoRecibido   = ""
        navegarADetalle = true
    }
}



