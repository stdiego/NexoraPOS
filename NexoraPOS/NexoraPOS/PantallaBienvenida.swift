import SwiftUI

// ── Modelo de cada slide ───────────────────────────────────────────────────────
struct InformacionPantalla {
    let titulo: String
    let descripcion: String
    let icono: String
    let color: Color
}

// ── Subvista del contenido del slide ──────────────────────────────────────────
private struct SlideContentView: View {
    let pantalla: InformacionPantalla

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: pantalla.icono)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(pantalla.color)

            Text(pantalla.titulo)
                .font(.title2).bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text(pantalla.descripcion)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

// ── Pantalla de Bienvenida ─────────────────────────────────────────────────────
struct PantallaBienvenida: View {

    @AppStorage("onboardingCompletado") private var onboardingCompletado = false
    @State private var pasoActual: Int = 0

    let pantallas: [InformacionPantalla] = [
        InformacionPantalla(
            titulo: "Vende y factura fácilmente",
            descripcion: "Cumple con la facturación electrónica DIAN desde tu celular de forma rápida y segura.",
            icono: "checkmark.circle.fill",
            color: Color(hex: "#2ECC71")
        ),
        InformacionPantalla(
            titulo: "Organiza tu negocio en un solo lugar",
            descripcion: "Gestiona tus productos, registra ventas y visualiza reportes claros en segundos.",
            icono: "list.bullet.rectangle.fill",
            color: Color(hex: "#3498DB")
        ),
        InformacionPantalla(
            titulo: "Comienza con 7 días de Premium",
            descripcion: "Disfruta todas las herramientas avanzadas sin costo durante tus primeros 7 días.",
            icono: "star.fill",
            color: Color(hex: "#F39C12")
        )
    ]

    var body: some View {
        ZStack {
            Color(hex: "#0D1B2A").ignoresSafeArea()

            VStack(spacing: 0) {
                botonSaltar
                Spacer()
                SlideContentView(pantalla: pantallas[pasoActual])
                Spacer()
                indicadoresPuntos
                botonSiguiente
            }
        }
    }

    // ── Botón saltar ──────────────────────────────────────────────────────────
    private var botonSaltar: some View {
        HStack {
            Spacer()
            Button("Saltar") { onboardingCompletado = true }
                .foregroundColor(.gray)
                .padding(.trailing, 16)
                .padding(.top, 16)
        }
    }

    // ── Indicadores de puntos ─────────────────────────────────────────────────
    private var indicadoresPuntos: some View {
        HStack(spacing: 8) {
            ForEach(0..<pantallas.count, id: \.self) { index in
                Capsule()
                    .fill(index == pasoActual ? pantallas[pasoActual].color : Color.gray.opacity(0.4))
                    .frame(width: index == pasoActual ? 24 : 8, height: 8)
                    .animation(.easeInOut, value: pasoActual)
            }
        }
        .padding(.bottom, 24)
    }

    // ── Botón siguiente / comenzar ────────────────────────────────────────────
    private var botonSiguiente: some View {
        let esUltimo = pasoActual == pantallas.count - 1
        return Button {
            if esUltimo {
                onboardingCompletado = true
            } else {
                withAnimation { pasoActual += 1 }
            }
        } label: {
            Text(esUltimo ? "⚙ Comenzar" : "Siguiente →")
                .font(.headline).bold()
                .foregroundColor(esUltimo ? Color(hex: "#0D1B2A") : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(esUltimo ? Color(hex: "#F39C12") : Color(hex: "#2ECC71"))
                .cornerRadius(12)
                .padding(.horizontal, 48)
        }
        .padding(.bottom, 48)
    }
}
