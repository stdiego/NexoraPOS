import SwiftUI
import SwiftData

struct PantallaVender: View {

    @Query private var productos: [Producto]
    @Environment(\.modelContext) private var contexto

    // Equivalente a mutableStateMapOf<Producto, Int>()
    @State private var carrito: [Producto: Int] = [:]
    @State private var busqueda = ""
    @State private var pantallaActual = "CATALOGO"  // "CATALOGO", "CARRITO", "PAGO"
    @State private var metodoPago = "Efectivo"
    @State private var montoRecibido = ""
    @State private var facturaGenerada: Factura? = nil
    @State private var navegarADetalle = false

    var productosFiltrados: [Producto] {
        busqueda.isEmpty ? productos : productos.filter { $0.nombre.lowercased().contains(busqueda.lowercased()) }
    }
    var subtotal: Double { carrito.reduce(0) { $0 + ($1.key.precio * Double($1.value)) } }
    var iva: Double { subtotal * 0.16 }
    var granTotal: Double { subtotal + iva }

    var body: some View {
        NavigationStack {
            Group {
                if pantallaActual == "PAGO" {
                    vistaPago
                } else if pantallaActual == "CARRITO" {
                    vistaCarrito
                } else {
                    vistaCatalogo
                }
            }
            .navigationDestination(isPresented: $navegarADetalle) {
                if let factura = facturaGenerada {
                    PantallaDetalleFactura(factura: factura)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }

    // ── Vista Catálogo ─────────────────────────────────────────────────────────
    var vistaCatalogo: some View {
        VStack(spacing: 0) {
            // Barra de búsqueda
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Buscar productos...", text: $busqueda)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Color.white)

            if productos.isEmpty {
                Spacer()
                Text("No hay productos en inventario.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(productosFiltrados, id: \.id) { producto in
                    let cantidadEnCarrito = carrito[producto] ?? 0
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "#F1F5F9"))
                            .frame(width: 72, height: 72)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(producto.nombre).font(.callout).fontWeight(.medium)
                                .foregroundColor(Color(hex: "#1E272E"))
                            Text(String(format: "$%.2f", producto.precio))
                                .foregroundColor(Color(hex: "#2ECC71")).bold()
                            Text("Stock: \(producto.cantidadEnStock)")
                                .font(.caption).foregroundColor(Color(hex: "#E67E22"))
                        }
                        Spacer()

                        Button(action: {
                            if cantidadEnCarrito < producto.cantidadEnStock {
                                carrito[producto] = cantidadEnCarrito + 1
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#27AE60"))
                                .frame(width: 56, height: 56)
                                .overlay(Image(systemName: "plus").foregroundColor(.white).font(.title2))
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowBackground(Color.white)
                }
                .listStyle(.plain)
                .background(Color(hex: "#F3F4F6"))
            }

            // Botón carrito
            Button(action: { if subtotal > 0 { pantallaActual = "CARRITO" } }) {
                HStack {
                    Image(systemName: "cart.fill").foregroundColor(.white)
                    Text(subtotal > 0 ? String(format: "Ir al Carrito ($%.2f)", subtotal) : "El carrito está vacío")
                        .font(.headline).bold().foregroundColor(.white)
                }
                .frame(maxWidth: .infinity).frame(height: 64)
                .background(Color(hex: "#00D166"))
                .cornerRadius(24)
                .padding(.horizontal, 16).padding(.vertical, 8)
            }
        }
        .background(Color(hex: "#F3F4F6"))
        .navigationTitle("Nueva Venta")
        .navigationBarTitleDisplayMode(.inline)
    }

    // ── Vista Carrito ──────────────────────────────────────────────────────────
    var vistaCarrito: some View {
        VStack(spacing: 0) {
            if carrito.isEmpty {
                Spacer()
                Text("El carrito está vacío").foregroundColor(.gray)
                Spacer()
            } else {
                List(Array(carrito.keys), id: \.id) { producto in
                    let cantidad = carrito[producto] ?? 0
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(producto.nombre).fontWeight(.medium)
                                Text(String(format: "$%.2f", producto.precio))
                                    .foregroundColor(Color(hex: "#00D166")).bold()
                            }
                            Spacer()
                            Button(action: { carrito.removeValue(forKey: producto) }) {
                                Image(systemName: "trash").foregroundColor(Color(hex: "#E74C3C"))
                            }
                        }

                        HStack {
                            HStack(spacing: 16) {
                                Button(action: {
                                    if cantidad > 1 { carrito[producto] = cantidad - 1 }
                                    else { carrito.removeValue(forKey: producto) }
                                }) {
                                    Text("-").font(.title2)
                                        .frame(width: 40, height: 40)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                                }
                                Text("\(cantidad)").font(.callout).bold()
                                Button(action: {
                                    if cantidad < producto.cantidadEnStock { carrito[producto] = cantidad + 1 }
                                }) {
                                    Text("+").font(.title3)
                                        .frame(width: 40, height: 40)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                                }
                            }
                            .foregroundColor(Color(hex: "#1E272E"))
                            Spacer()
                            Text(String(format: "$%.2f", producto.precio * Double(cantidad)))
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(.plain)
            }

            // Panel resumen
            VStack(spacing: 8) {
                HStack { Text("Subtotal"); Spacer(); Text(String(format: "$%.2f", subtotal)) }
                HStack { Text("IVA (16%)"); Spacer(); Text(String(format: "$%.2f", iva)) }
                Divider()
                HStack {
                    Text("TOTAL").bold()
                    Spacer()
                    Text(String(format: "$%.2f", granTotal))
                        .font(.title2).bold().foregroundColor(Color(hex: "#00D166"))
                }
                Button(action: { pantallaActual = "PAGO" }) {
                    Text("Proceder al Pago")
                        .font(.headline).bold().foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Color(hex: "#00D166"))
                        .cornerRadius(16)
                }
            }
            .padding(24)
            .background(Color(hex: "#E5E7EB").opacity(0.5))
            .cornerRadius(24, corners: [.topLeft, .topRight])
        }
        .navigationTitle("Carrito")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { pantallaActual = "CATALOGO" }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }

    // ── Vista Pago ─────────────────────────────────────────────────────────────
    var vistaPago: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Total
                VStack {
                    Text("Total a Pagar").foregroundColor(.gray)
                    Text(String(format: "$%.2f", granTotal))
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(Color(hex: "#2ECC71"))
                }
                .frame(maxWidth: .infinity).padding(32)
                .background(Color(hex: "#F1F5F9"))
                .cornerRadius(16)

                // Método de pago
                Text("Método de Pago").font(.title3).fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    ForEach(["Efectivo 💵", "Tarjeta 💳", "Transfer 🏦"], id: \.self) { metodo in
                        let nombre = String(metodo.prefix(while: { $0 != " " }))
                        Button(action: { metodoPago = nombre }) {
                            VStack(spacing: 8) {
                                Text(String(metodo.split(separator: " ").last ?? "")).font(.title)
                                Text(nombre).font(.subheadline)
                                    .foregroundColor(metodoPago == nombre ? Color(hex: "#2ECC71") : .gray)
                            }
                            .frame(maxWidth: .infinity).frame(height: 100)
                            .background(metodoPago == nombre ? Color(hex: "#F0FDF4") : Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(metodoPago == nombre ? Color(hex: "#2ECC71") : Color(hex: "#E5E7EB"), lineWidth: 2)
                            )
                        }
                    }
                }

                if metodoPago == "Efectivo" {
                    VStack(alignment: .leading) {
                        Text("Monto Recibido").foregroundColor(.gray).font(.caption)
                        TextField("0.00", text: $montoRecibido)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#2ECC71"), lineWidth: 1))
                    }
                }

                Spacer()

                Button(action: confirmarPago) {
                    Text("Confirmar Pago")
                        .font(.headline).bold().foregroundColor(Color(hex: "#1E272E"))
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#E5E7EB"), lineWidth: 1))
                }
            }
            .padding(20)
        }
        .navigationTitle("Procesar Pago")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { pantallaActual = "CARRITO" }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }

    // ── Confirmar venta y guardar en SwiftData ─────────────────────────────────
    func confirmarPago() {
        let fecha = Date().formatted(date: .abbreviated, time: .shortened)
        let id = Int.random(in: 1000...9999)
        let items = carrito.map { ProductoEnFactura(nombreProducto: $0.key.nombre, precioProducto: $0.key.precio, cantidad: $0.value) }
        let factura = Factura(id: id, total: subtotal, fecha: fecha, metodoPago: metodoPago, items: items)
        contexto.insert(factura)
        facturaGenerada = factura
        carrito = [:]
        navegarADetalle = true
    }
}

// ── Extensión para cornerRadius parcial ───────────────────────────────────────
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
