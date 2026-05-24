# Marketplace Colombia

## Descripción
App Android de marketplace de servicios profesionales para el mercado colombiano. Conecta clientes con profesionales de oficios (plomería, carpintería, electricidad, etc.).

## Stack
- Flutter (Dart) — app Android
- Firebase Auth — autenticación con email y Google
- Cloud Firestore — base de datos
- Firebase Storage — fotos de perfil y portafolio
- Wompi — pagos (fase 2, no implementar aún)

## Roles de usuario
### Cliente (gratis)
- Registro con email o Google
- Busca profesionales por categoría y ciudad
- Ve perfiles, fotos de trabajos, reviews
- Contacta vía WhatsApp o llamada directa
- Puede dejar reviews

### Profesional (suscripción)
- Registro con email o Google
- 3 meses gratis al registrarse
- Después: $49.900 COP/mes para aparecer en el marketplace
- Perfil: foto, descripción, categoría, ciudad
- Portafolio: fotos de trabajos terminados
- Contacto por WhatsApp o llamada (fuera de la app)

## Categorías de servicios
Carpintería, Plomería, Pintura, Cerrajería, Electricidad,
Aires acondicionados, Jardinería, Mudanzas, Limpieza, Reformas

## Reglas de código
- Todo el código en inglés (variables, funciones, clases)
- Comentarios en español
- Un widget por archivo
- Siempre manejar errores con try/catch
- No hardcodear strings — usar constantes en constants.dart
- Crear tests para toda lógica de negocio
- Seguir arquitectura: /screens /widgets /models /services /constants

## Lo que NO hacer
- No implementar pagos todavía (Wompi es fase 2)
- No hacer chat dentro de la app (el contacto es externo)
- No implementar mapa por ahora

## Contexto Colombia
- Ciudad principal de lanzamiento: Colombia (nationwide)
- Moneda: COP
- Teléfono: formato colombiano (+57)

