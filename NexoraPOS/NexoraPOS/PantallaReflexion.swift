import SwiftUI

struct PantallaReflexion: View {

    var alCerrar: (() -> Void)? = nil

    var body: some View {
        ZStack {

            // Fondo general suave
            Color(hex: "#F4F7FB").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // ── Encabezado ─────────────────────────────────────────────
                    VStack(spacing: 16) {

                        ZStack {
                            Circle()
                                .fill(Color(hex: "#5B8DEF").opacity(0.15))
                                .frame(width: 110, height: 110)

                            Image(systemName: "arrow.left.arrow.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                                .foregroundColor(Color(hex: "#5B8DEF"))
                        }

                        Text("Reflexión del microproyecto")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color(hex: "#1F2937"))
                            .multilineTextAlignment(.center)

                        Text("Android (Jetpack Compose) vs iOS (SwiftUI)")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#6B7280"))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 52)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)

                    // ── Tarjetas ───────────────────────────────────────────────
                    VStack(spacing: 20) {

                        // SwiftUI
                        tarjeta(
                            icono: "desktopcomputer.trianglebadge.exclamationmark",
                            etiqueta: "SwiftUI · Limitación de hardware",
                            color: Color(hex: "#1F2937"),
                            fondo: Color(hex: "#EAF2FF"),
                            titulo: "El hardware fue el primer obstáculo",
                            descripcion: "Desarrollar en SwiftUI exige un Mac. Al trabajar desde una máquina con Windows fue necesario recurrir a máquinas virtuales, lo que generó lentitud e inestabilidad. Gran parte del tiempo se destinó a configurar el entorno en lugar de construir la app, lo que impidió alcanzar el mismo nivel de calidad que en Android."
                        )

                        // Android
                        tarjeta(
                            icono: "checkmark.seal.fill",
                            etiqueta: "Jetpack Compose · Ventaja",
                            color: Color(hex: "#1F2937"),
                            fondo: Color(hex: "#EAFBF1"),
                            titulo: "Android: accesible desde cualquier equipo",
                            descripcion: "Jetpack Compose y Android Studio corren sin problema en Windows. Esto permitió concentrarse completamente en el código y la experiencia de usuario, sin fricciones de entorno, logrando un resultado más pulido, completo y estable."
                        )

                        // Conclusión
                        tarjeta(
                            icono: "lightbulb.fill",
                            etiqueta: "Conclusión",
                            color: Color(hex: "#1F2937"),
                            fondo: Color(hex: "#FFF4E8"),
                            titulo: "El entorno importa tanto como el código",
                            descripcion: "SwiftUI ofrece integración profunda con iOS y resultados muy profesionales cuando se tiene el hardware adecuado. Sin embargo, cuando el acceso al Mac es limitado o nulo, la productividad cae drásticamente. Jetpack Compose demostró ser la opción más inclusiva: permite desarrollar aplicaciones de alta calidad desde cualquier equipo, sin depender de un ecosistema cerrado."
                        )
                    }
                    .padding(.horizontal, 24)

                    // ── Botón cerrar ───────────────────────────────────────────
                    if let cerrar = alCerrar {

                        Button(action: cerrar) {

                            Text("Cerrar")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(hex: "#5B8DEF"))
                                .cornerRadius(14)
                                .padding(.horizontal, 48)
                        }
                        .padding(.top, 36)
                        .padding(.bottom, 52)
                    }
                }
            }
        }
    }

    // ── Componente tarjeta ─────────────────────────────────────────────────────
    private func tarjeta(
        icono: String,
        etiqueta: String,
        color: Color,
        fondo: Color,
        titulo: String,
        descripcion: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 14) {

                ZStack {

                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 52, height: 52)

                    Image(systemName: icono)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(color)
                }

                Text(etiqueta.uppercased())
                    .font(.caption2)
                    .bold()
                    .foregroundColor(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(color.opacity(0.12))
                    .cornerRadius(20)
            }

            Text(titulo)
                .font(.headline)
                .bold()
                .foregroundColor(Color(hex: "#1F2937"))

            Rectangle()
                .fill(color.opacity(0.25))
                .frame(height: 1)

            Text(descripcion)
                .font(.subheadline)
                .foregroundColor(Color(hex: "##1F2937"))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(fondo)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
        .shadow(
            color: color.opacity(0.08),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}
