import SwiftUI
import SwiftData

@main
struct NexoraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Producto.self, Factura.self, ProductoEnFactura.self])
    }
}

// ── Vista raíz — decide si mostrar Onboarding o Login ─────────────────────────
struct ContentView: View {
    @AppStorage("onboardingCompletado") private var onboardingCompletado = false
    @Environment(\.modelContext) private var contexto

    var body: some View {
        let _ = DatosPanaderia.cargarSiEsNecesario(contexto: contexto)
        if onboardingCompletado {
            PantallaLogin()
        } else {
            PantallaBienvenida()
        }
    }
}
