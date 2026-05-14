import SwiftUI
import SwiftData

struct PantallaInicio: View {

    @Query private var facturas: [Factura]
    @State private var mostrarMenuLateral = false
    @State private var tabSeleccionada = 0

    // Cálculos en tiempo real desde SwiftData
    var totalIngresos: Double { facturas.reduce(0) { $0 + $1.total } }
    var transacciones: Int { facturas.count }
    var articulosVendidos: Int {
        facturas.flatMap { $0.items }.reduce(0) { $0 + $1.cantidad }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Contenido principal
            TabView(selection: $tabSeleccionada) {
                contenidoDashboard
                    .tabItem { Label("Inicio", systemImage: "house.fill") }
                    .tag(0)

                PantallaVender()
                    .tabItem { Label("Ventas", systemImage: "cart.fill") }
                    .tag(1)

                PantallaInventario()
                    .tabItem { Label("Productos", systemImage: "list.bullet") }
                    .tag(2)

                PantallaReportes()
                    .tabItem { Label("Reportes", systemImage: "star.fill") }
                    .tag(3)
            }
            .accentColor(Color(hex: "#0F5132"))

            // Overlay oscuro
            if mostrarMenuLateral {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { mostrarMenuLateral = false } }
            }

            // Menú lateral
            if mostrarMenuLateral {
                MenuLateral(mostrarMenu: $mostrarMenuLateral)
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .transition(.move(edge: .leading))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: mostrarMenuLateral)
    }

    // ── Contenido del Dashboard ────────────────────────────────────────────────
    var contenidoDashboard: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Banner bienvenida
                    HStack {
                        VStack(alignment: .leading) {
                            Text("¡Bienvenido de nuevo!")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#1E272E"))
                            Text("Dashboard Actualizado")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#1E272E").opacity(0.8))
                        }
                        Spacer()
                        Circle()
                            .fill(Color(hex: "#00C853"))
                            .frame(width: 48, height: 48)
                            .overlay(Text("⚡").font(.title3))
                    }
                    .padding(20)
                    .background(Color(hex: "#69F0AE"))
                    .cornerRadius(16)

                    // Banner Premium
                    HStack {
                        Circle()
                            .fill(Color(hex: "#455A64"))
                            .frame(width: 36, height: 36)
                            .overlay(Text("👑").font(.caption))
                        VStack(alignment: .leading) {
                            Text("Prueba Premium").font(.caption).bold()
                            Text("activa").font(.caption)
                        }
                        .foregroundColor(Color(hex: "#1E272E"))
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("6 días").font(.caption).bold()
                            Text("restantes").font(.caption2).foregroundColor(.gray)
                        }
                        Spacer().frame(width: 16)
                        Text("Ver beneficios >")
                            .font(.caption).bold()
                            .foregroundColor(Color(hex: "#00897B"))
                    }
                    .padding(16)
                    .background(Color(hex: "#E0F2F1"))
                    .cornerRadius(16)

                    // Título sección
                    Text("Resumen de Hoy (En vivo)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                    // Tarjetas de métricas
                    StatCardView(icono: "cart.fill", titulo: "Artículos Vendidos",
                                 valor: "\(articulosVendidos)", subtitulo: "Unidades")
                    StatCardView(icono: "dollarsign.circle.fill", titulo: "Total Ingresos",
                                 valor: String(format: "$%.2f", totalIngresos), subtitulo: "Dinero Bruto")
                    StatCardView(icono: "chart.line.uptrend.xyaxis", titulo: "Transacciones",
                                 valor: "\(transacciones)", subtitulo: "Tickets")

                    // Gráfico semanal
                    HStack {
                        Text("Ventas Semanales").font(.caption).foregroundColor(.gray)
                        Spacer()
                        Text("📊 En Vivo")
                            .font(.caption2).bold()
                            .foregroundColor(Color(hex: "#00600F"))
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color(hex: "#69F0AE"))
                            .cornerRadius(16)
                    }

                    GraficoVentasView(totalHoy: totalIngresos)
                        .frame(height: 200)
                        .background(Color.white)
                        .cornerRadius(16)

                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color(hex: "#F3F4F6"))
            .navigationTitle("Nexora POS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { withAnimation { mostrarMenuLateral = true } }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(Color(hex: "#1E272E"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "#101828"))
                        .frame(width: 32, height: 32)
                        .overlay(Text("N").foregroundColor(Color(hex: "#00D166")).bold())
                }
            }
        }
    }
}

// ── Componente tarjeta de estadística ─────────────────────────────────────────
struct StatCardView: View {
    let icono: String
    let titulo: String
    let valor: String
    let subtitulo: String

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#69F0AE").opacity(0.3))
                .frame(width: 56, height: 56)
                .overlay(Image(systemName: icono).foregroundColor(Color(hex: "#00600F")))

            VStack(alignment: .leading, spacing: 2) {
                Text(titulo).font(.caption).foregroundColor(.gray)
                Text(valor).font(.title2).bold().foregroundColor(Color(hex: "#1E272E"))
                Text(subtitulo).font(.caption2).foregroundColor(.gray)
            }
            Spacer()
            Text("Actualizado")
                .font(.caption2).bold()
                .foregroundColor(Color(hex: "#0277BD"))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color(hex: "#E1F5FE"))
                .cornerRadius(16)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#E5E7EB"), lineWidth: 1))
    }
}

// ── Gráfico de barras ──────────────────────────────────────────────────────────
struct GraficoVentasView: View {
    let totalHoy: Double
    let datos: [(String, Double)] = [
        ("Lun", 800), ("Mar", 1200), ("Mié", 950),
        ("Jue", 1500), ("Vie", 2300), ("Sáb", 1800), ("Hoy", 0)
    ]

    var body: some View {
        let datosConHoy = datos.dropLast() + [("Hoy", totalHoy > 0 ? totalHoy : 400)]
        let maxValor = datosConHoy.map { $0.1 }.max() ?? 1

        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(datosConHoy), id: \.0) { dia, monto in
                VStack(spacing: 4) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(dia == "Hoy" ? Color(hex: "#00D166") : Color(hex: "#E5E7EB"))
                        .frame(width: 28, height: CGFloat(monto / maxValor) * 100)
                    Text(dia)
                        .font(.caption2)
                        .foregroundColor(dia == "Hoy" ? Color(hex: "#1E272E") : .gray)
                        .fontWeight(dia == "Hoy" ? .bold : .regular)
                }
            }
        }
        .padding(16)
    }
}

// ── Menú lateral ──────────────────────────────────────────────────────────────
struct MenuLateral: View {
    @Binding var mostrarMenu: Bool
    @State private var navegarAlLogin = false

    var body: some View {
        VStack(spacing: 0) {
            // Header verde
            VStack(alignment: .leading, spacing: 12) {
                Button(action: { withAnimation { mostrarMenu = false } }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.title3)
                }

                Spacer().frame(height: 8)

                HStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#101828"))
                        .frame(width: 48, height: 48)
                        .overlay(Text("N").foregroundColor(Color(hex: "#69F0AE")).bold().font(.title2))
                    VStack(alignment: .leading) {
                        Text("Nexora POS").font(.headline).bold().foregroundColor(Color(hex: "#1E272E"))
                        Text("v1.0.0").font(.caption).foregroundColor(Color(hex: "#444444"))
                    }
                }

                Divider().padding(.vertical, 8)

                Label("Tech Store Pro", systemImage: "house").font(.subheadline).foregroundColor(Color(hex: "#1E272E"))
                Label("20123456789-0", systemImage: "mappin").font(.subheadline).foregroundColor(Color(hex: "#1E272E"))

                Divider().padding(.vertical, 8)

                HStack {
                    Circle().fill(Color(hex: "#00C853")).frame(width: 44, height: 44)
                        .overlay(Image(systemName: "person.fill").foregroundColor(.white))
                    VStack(alignment: .leading) {
                        Text("Admin Usuario").font(.callout).bold().foregroundColor(Color(hex: "#1E272E"))
                        Text("admin@nexora.com").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .padding(24)
            .background(Color(hex: "#69F0AE"))

            // Opciones del menú
            VStack(spacing: 0) {
                OpcionMenuView(icono: "person", titulo: "Mi Perfil") { mostrarMenu = false }
                OpcionMenuView(icono: "gearshape", titulo: "Configuración") { mostrarMenu = false }
                OpcionMenuView(icono: "list.bullet", titulo: "Historial de Facturas") { mostrarMenu = false }
                OpcionMenuView(icono: "questionmark.circle", titulo: "Soporte") { mostrarMenu = false }
            }

            Spacer()

            Divider().padding(.horizontal, 24)

            // Botón cerrar sesión
            Button(action: { navegarAlLogin = true }) {
                HStack {
                    Image(systemName: "arrow.right.square").foregroundColor(Color(hex: "#D32F2F"))
                    Text("Cerrar Sesión").foregroundColor(Color(hex: "#D32F2F")).fontWeight(.medium)
                }
                .padding(.horizontal, 24).padding(.vertical, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .fullScreenCover(isPresented: $navegarAlLogin) {
                PantallaLogin()
            }

            Spacer().frame(height: 16)
        }
        .background(Color.white)
    }
}

struct OpcionMenuView: View {
    let icono: String
    let titulo: String
    let accion: () -> Void

    var body: some View {
        Button(action: accion) {
            HStack(spacing: 20) {
                Image(systemName: icono).foregroundColor(.gray).frame(width: 26)
                Text(titulo).font(.callout).foregroundColor(Color(hex: "#1E272E"))
                Spacer()
            }
            .padding(.horizontal, 24).padding(.vertical, 18)
        }
    }
}
