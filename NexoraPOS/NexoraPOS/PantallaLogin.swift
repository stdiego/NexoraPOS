import SwiftUI

struct PantallaLogin: View {

    @State private var correo: String = ""
    @State private var contrasena: String = ""
    @State private var mostrarError: Bool = false
    @State private var navegarAlInicio: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#27AE60"), Color(hex: "#4A625A")],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 72)
                    logoSection
                    Spacer().frame(height: 36)
                    formularioSection
                    Spacer().frame(height: 24)
                    footerSection
                }
            }
        }
        .fullScreenCover(isPresented: $navegarAlInicio) {
            PantallaInicio()
        }
    }

    // ── Logo ──────────────────────────────────────────────────────────────────
    private var logoSection: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(hex: "#131B2A"))
                .frame(width: 110, height: 110)
                .overlay(
                    Text("N")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(Color(hex: "#00FFD1"))
                )
                .shadow(radius: 8)

            Text("Nexora POS")
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            Text("Sistema Inteligente de Punto de Venta")
                .font(.callout).fontWeight(.medium)
                .foregroundColor(.white)
            Text("Facturación electrónica en tiempo real")
                .font(.caption)
                .foregroundColor(Color(white: 0.85))
        }
    }

    // ── Formulario ────────────────────────────────────────────────────────────
    private var formularioSection: some View {
        VStack(spacing: 16) {
            Text("Iniciar Sesión")
                .font(.title2)
                .foregroundColor(Color(hex: "#333333"))

            Spacer().frame(height: 4)

            campoCorreo
            campoContrasena

            if mostrarError {
                mensajeError
            }

            botonLogin
            Spacer().frame(height: 4)

            Button("¿Olvidaste tu contraseña?") { }
                .font(.subheadline).bold()
                .foregroundColor(Color(hex: "#00D166"))
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(radius: 8)
        .padding(.horizontal, 24)
    }

    // ── Campo correo ──────────────────────────────────────────────────────────
    private var campoCorreo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Usuario")
                .font(.caption).bold()
                .foregroundColor(Color(hex: "#444444"))

            HStack {
                Image(systemName: "person").foregroundColor(.gray)
                TextField("nombre@empresa.com", text: $correo)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: correo) { _, _ in mostrarError = false }
            }
            .padding(12)
            .background(Color(hex: "#F8FAFC"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )

            Text("Ingresa tu correo corporativo")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    // ── Campo contraseña ──────────────────────────────────────────────────────
    private var campoContrasena: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Contraseña")
                .font(.caption).bold()
                .foregroundColor(Color(hex: "#444444"))

            HStack {
                Image(systemName: "lock")
                    .foregroundColor(mostrarError ? .red : .gray)
                SecureField("••••••••", text: $contrasena)
                    .onChange(of: contrasena) { _, _ in mostrarError = false }
            }
            .padding(12)
            .background(Color(hex: "#F8FAFC"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(mostrarError ? Color.red : Color.gray.opacity(0.4), lineWidth: 1)
            )
        }
    }

    // ── Mensaje de error ──────────────────────────────────────────────────────
    private var mensajeError: some View {
        Text("Usuario y contraseña son requeridos")
            .font(.caption)
            .foregroundColor(Color(hex: "#B71C1C"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(hex: "#FFEBEE"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#D32F2F"), lineWidth: 1)
            )
    }

    // ── Botón login ───────────────────────────────────────────────────────────
    private var botonLogin: some View {
        Button {
            if !correo.isEmpty && !contrasena.isEmpty {
                navegarAlInicio = true
            } else {
                mostrarError = true
            }
        } label: {
            Text("Iniciar Sesión")
                .font(.headline).bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(hex: "#00D166"))
                .clipShape(Capsule())
        }
    }

    // ── Footer ────────────────────────────────────────────────────────────────
    private var footerSection: some View {
        HStack {
            Text("¿No tienes cuenta? ")
                .foregroundColor(.white)
                .font(.footnote)
            Text("Solicitar acceso")
                .foregroundColor(.white)
                .font(.footnote).bold()
                .underline()
        }
        .padding(.bottom, 32)
    }
}
