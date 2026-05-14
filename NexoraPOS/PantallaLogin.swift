import SwiftUI

struct PantallaLogin: View {

    // Equivalente a var correo by remember { mutableStateOf("") }
    @State private var correo: String = ""
    @State private var contrasena: String = ""
    @State private var mostrarError: Bool = false
    @State private var navegarAlInicio: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    colors: [Color(hex: "#27AE60"), Color(hex: "#4A625A")],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 72)

                        // Logo
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(hex: "#131B2A"))
                            .frame(width: 110, height: 110)
                            .overlay(
                                Text("N")
                                    .font(.system(size: 72, weight: .bold))
                                    .foregroundColor(Color(hex: "#00FFD1"))
                            )
                            .shadow(radius: 8)

                        Spacer().frame(height: 24)

                        Text("Nexora POS")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        Text("Sistema Inteligente de Punto de Venta")
                            .font(.callout).fontWeight(.medium)
                            .foregroundColor(.white)
                        Text("Facturación electrónica en tiempo real")
                            .font(.caption)
                            .foregroundColor(Color(white: 0.85))

                        Spacer().frame(height: 36)

                        // Tarjeta blanca del formulario
                        VStack(spacing: 16) {
                            Text("Iniciar Sesión")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#333333"))

                            Spacer().frame(height: 8)

                            // Campo Correo
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Usuario")
                                    .font(.caption).bold()
                                    .foregroundColor(Color(hex: "#444444"))
                                HStack {
                                    Image(systemName: "person")
                                        .foregroundColor(.gray)
                                    TextField("nombre@empresa.com", text: $correo)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .onChange(of: correo) { _ in mostrarError = false }
                                }
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                                Text("Ingresa tu correo corporativo")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }

                            // Campo Contraseña
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Contraseña")
                                    .font(.caption).bold()
                                    .foregroundColor(Color(hex: "#444444"))
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(mostrarError ? .red : .gray)
                                    SecureField("••••••••", text: $contrasena)
                                        .onChange(of: contrasena) { _ in mostrarError = false }
                                }
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(mostrarError ? Color.red : Color.gray.opacity(0.4), lineWidth: 1)
                                )
                            }

                            // Mensaje de error
                            if mostrarError {
                                Text("Usuario y contraseña son requeridos")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "#B71C1C"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#FFEBEE"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "#D32F2F"), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                            }

                            // Botón Iniciar Sesión
                            Button(action: {
                                if !correo.isEmpty && !contrasena.isEmpty {
                                    navegarAlInicio = true
                                } else {
                                    mostrarError = true
                                }
                            }) {
                                Text("Iniciar Sesión")
                                    .font(.headline).bold()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color(hex: "#00D166"))
                                    .clipShape(Capsule())
                            }

                            Spacer().frame(height: 8)

                            Button("¿Olvidaste tu contraseña?") { }
                                .font(.subheadline).bold()
                                .foregroundColor(Color(hex: "#00D166"))
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(radius: 8)
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 24)

                        // Footer
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
            }
            .navigationDestination(isPresented: $navegarAlInicio) {
                PantallaInicio()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}
