# Órbita · Calculadora Flutter

Calculadora multiplataforma que incluye operaciones básicas, avanzadas y
validación de paridad. El diseño se adapta a dispositivos móviles y escritorio.

## Arquitectura

El código usa una arquitectura por funcionalidades con separación por capas:

```text
lib/
├── app/                         # Configuración general de la aplicación
├── core/
│   ├── constants/               # Constantes globales
│   ├── errors/                  # Errores controlados
│   └── theme/                   # Colores y tema visual
├── features/
│   └── calculator/
│       ├── data/                # Modelos y repositorio de operaciones
│       ├── logic/               # Estado, validaciones y controlador
│       └── presentation/        # Pantalla y componentes visuales
└── main.dart                    # Punto de entrada
```

Esta organización mantiene la interfaz separada de los cálculos y facilita las
pruebas, el mantenimiento y la incorporación de nuevas funcionalidades.

## Validación

```shell
flutter analyze
flutter test
```



INTEGRANTES 
SEBASTIAN MONTERO
SAMUEL RHENALS 
ELETT ARCHIBOLD
DAVID MONRROY
