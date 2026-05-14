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

    var body: some View {
        if onboardingCompletado {
            PantallaLogin()
        } else {
            PantallaBienvenida()
        }
    }
}
