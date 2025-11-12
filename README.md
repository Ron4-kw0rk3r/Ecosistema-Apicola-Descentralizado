# Apiario Virtual - Ecosistema Apicola Descentralizado

## Vision del Sistema

Plataforma blockchain para gestion integral de operaciones apicolas. Modela ciclo completo desde instalacion de colmenas hasta comercializacion de miel. Implementa tracking de salud de abejas, metricas de produccion, y registro de cosechas con trazabilidad.

## Modelado de Entidades

### Apiario - Hub Central

Contenedor compartido de toda la operacion apicola:

**Componentes estructurales**:
- Identificador unico del apiario
- Address del apicultor propietario
- Tabla de colmenas indexadas
- Tabla de cosechas historicas
- Contadores autoincrementales

**Modelo de acceso**:
- Shared object (acceso publico para consulta)
- Operaciones restringidas solo a apicultor
- Persistencia permanente on-chain

### Colmena - Unidad de Produccion

Representacion de colonia de abejas con metricas biologicas:

```move
Colmena {
    id: u64,
    ubicacion: String,
    poblacion_abejas: u64,
    salud_reina: u8,
    produccion_diaria: u64,
    temperatura: u64,
    activa: bool,
    dias_activos: u64
}
```

**Parametros clave**:

- `ubicacion`: Descripcion geografica del emplazamiento
- `poblacion_abejas`: Numero estimado de individuos en la colonia
- `salud_reina`: Estado de la abeja reina (0-100 scale)
- `produccion_diaria`: Gramos de miel por dia (calculado automaticamente)
- `temperatura`: Grados Celsius dentro de la colmena
- `activa`: Flag de operacion (permite/bloquea cosechas)
- `dias_activos`: Contador de longevidad de la colmena

**Formula de produccion**:
```
produccion_diaria = poblacion_abejas / 1000
```

Ejemplo:
- 50,000 abejas → 50 gramos/dia
- 100,000 abejas → 100 gramos/dia

### Cosecha - Registro de Extraccion

Documentacion de recoleccion de miel con metadatos de calidad:

**Atributos**:
- ID unico de cosecha
- Referencia a colmena origen
- Cantidad en kilogramos
- Nivel de calidad (0-100)
- Timestamp de extraccion
- Tipo de flora predominante
- Estado de comercializacion

**Trazabilidad**: Vincula producto final con colmena especifica

## Operaciones del Sistema

### crear_apiario

Establecimiento del hub apicola

**Proceso de creacion**:
1. Instanciar estructura Apiario
2. Registrar apicultor como propietario
3. Inicializar tablas vacias
4. Compartir objeto publicamente

**Caracteristica distintiva**: Share object vs owned (permite consultas publicas de produccion)

**Setup inicial**:
```bash
sui client call \
  --package $PACKAGE_ID \
  --module apiario_virtual \
  --function crear_apiario \
  --gas-budget 15000000
```

**Resultado**: Apiario compartido listo para instalar colmenas

### instalar_colmena

Incorporacion de nueva unidad productiva

**Parametros de instalacion**:
- `ubicacion`: Descripcion textual del lugar
- `poblacion`: Numero inicial de abejas

**Logica de inicializacion**:
1. Validar autorizacion del apicultor
2. Crear estructura Colmena con ID del contador
3. Convertir ubicacion a String
4. Establecer poblacion inicial
5. Inicializar salud_reina al maximo (100)
6. Calcular produccion_diaria automaticamente
7. Setear temperatura estandar (35°C)
8. Marcar como activa
9. Dias activos en cero
10. Insertar en tabla
11. Incrementar contador

**Calculos automaticos**:
- `produccion_diaria = poblacion / 1000`
- `salud_reina = 100` (nueva reina)
- `temperatura = 35` (optima para abejas)

**Instalar colmena grande**:
```bash
sui client call \
  --package $PKG \
  --module apiario_virtual \
  --function instalar_colmena \
  --args $APIARIO_ID \
    \"Valle Norte - Sector A\" \
    80000 \
  --gas-budget 12000000
```

**Instalar colmena pequeña**:
```bash
sui client call \
  --package $PKG \
  --module apiario_virtual \
  --function instalar_colmena \
  --args $APIARIO_ID \
    \"Cerro Sur - Zona B\" \
    30000 \
  --gas-budget 12000000
```

**Tamaños tipicos de colmenas**:
- Pequeña: 20,000-40,000 abejas → 20-40g/dia
- Mediana: 40,000-60,000 abejas → 40-60g/dia
- Grande: 60,000-100,000 abejas → 60-100g/dia

### actualizar_colmena

Actualizacion de parametros biologicos

**Parametros modificables**:
- `nueva_poblacion`: Conteo actualizado de abejas
- `nueva_temp`: Temperatura actual en °C

**Efectos secundarios**:
- Recalcula produccion_diaria automaticamente
- Incrementa contador dias_activos

**Proceso de actualizacion**:
1. Verificar permisos de apicultor
2. Obtener referencia mutable a colmena
3. Actualizar poblacion
4. Actualizar temperatura
5. Recalcular produccion (nueva_poblacion / 1000)
6. Incrementar dias activos

**Uso tipico**: Monitoreo periodico (semanal/mensual) de estado de colmena

**Actualizar tras inspeccion**:
```bash
COLMENA_ID=0
NUEVA_POBLACION=75000  # Crecimiento de la colonia
NUEVA_TEMP=34  # Temperatura medida

sui client call \
  --package $PKG \
  --module apiario_virtual \
  --function actualizar_colmena \
  --args $APIARIO $COLMENA_ID $NUEVA_POBLACION $NUEVA_TEMP \
  --gas-budget 10000000
```

**Actualizar tras perdidas**:
```bash
# Colmena afectada por clima
NUEVA_POBLACION=45000  # Reduccion poblacional
NUEVA_TEMP=32  # Temperatura baja

sui client call \
  --package $PKG \
  --module apiario_virtual \
  --function actualizar_colmena \
  --args $APIARIO $COLMENA_ID $NUEVA_POBLACION $NUEVA_TEMP
```

**Rangos saludables**:
- Temperatura: 33-37°C (optimo 35°C)
- Poblacion: 20,000+ abejas (minimo viable)

### cosechar_miel

Extraccion y registro de produccion

**Parametros de cosecha**:
- `id_colmena`: Colmena origen de la miel
- `kilos`: Cantidad extraida
- `calidad`: Score 0-100
- `tipo_flor`: Flora predominante

**Validaciones**:
1. Verificar autorizacion de apicultor (error 1)
2. Comprobar que colmena este activa (error 2)

**Proceso de registro**:
1. Obtener referencia a colmena
2. Validar estado activo
3. Crear estructura Cosecha
4. Asignar ID autoincremental
5. Vincular con ID de colmena
6. Registrar cantidad en kilos
7. Almacenar calidad
8. Fecha en 0 (placeholder - podria usar Clock)
9. Convertir tipo_flor a String
10. Marcar como no vendida
11. Insertar en tabla de cosechas
12. Incrementar contador

**Cosechar miel de azahar**:
```bash
COLMENA_ID=0
KILOS=12
CALIDAD=95
TIPO_FLOR="Azahar"

sui client call \
  --package $PKG \
  --module apiario_virtual \
  --function cosechar_miel \
  --args $APIARIO $COLMENA_ID $KILOS $CALIDAD \"$TIPO_FLOR\" \
  --gas-budget 12000000
```

**Cosechar miel multifloral**:
```bash
sui client call \
  --package $PKG \
  --module apiario_virtual \
  --function cosechar_miel \
  --args $APIARIO 1 8 85 \"Multifloral\" \
  --gas-budget 12000000
```

**Tipos de miel comunes**:
- Azahar: Alta calidad (90-100)
- Romero: Calidad media-alta (80-90)
- Multifloral: Calidad variable (70-85)
- Bosque: Calidad media (75-85)

**Escala de calidad**:
```
90-100: Premium (exportacion)
80-89:  Alta (comercio especializado)
70-79:  Buena (consumo local)
60-69:  Regular (procesamiento)
<60:    Baja (descarte/uso industrial)
```

### vender_cosecha

Marcado de comercializacion

**Funcionalidad**:
- Cambia flag `vendida` a true
- Registra que cosecha fue vendida
- No elimina registro (trazabilidad)

**Limitaciones**:
- No maneja pagos on-chain
- No valida precio
- No registra comprador
- Solo marca estado

**Marcar como vendida**:
```bash
COSECHA_ID=0

sui client call \
  --package $PKG \
  --module apiario_virtual \
  --function vender_cosecha \
  --args $APIARIO $COSECHA_ID \
  --gas-budget 7000000
```

**Uso en workflow completo**:
```bash
# 1. Cosechar
sui client call --package $PKG --module apiario_virtual \
  --function cosechar_miel --args $APIARIO 0 10 92 "Lavanda"

# 2. Esperar venta off-chain
# ... negociacion, pago fiat/crypto ...

# 3. Marcar como vendida
sui client call --package $PKG --module apiario_virtual \
  --function vender_cosecha --args $APIARIO 0
```

## Ciclos Operacionales Completos

### Caso 1: Iniciar Operacion Apicola

**Setup completo de apiario**:

```bash
# Desplegar contrato
sui client publish --gas-budget 100000000
export PKG=<package_id>

# Crear apiario
sui client call --package $PKG --module apiario_virtual --function crear_apiario
export APIARIO=<apiario_id>

# Instalar primera colmena
sui client call --package $PKG --module apiario_virtual \
  --function instalar_colmena \
  --args $APIARIO "Monte Verde - Parcela 1" 50000

# Instalar segunda colmena
sui client call --package $PKG --module apiario_virtual \
  --function instalar_colmena \
  --args $APIARIO "Monte Verde - Parcela 2" 45000

# Instalar tercera colmena
sui client call --package $PKG --module apiario_virtual \
  --function instalar_colmena \
  --args $APIARIO "Valle Bajo - Sector A" 60000
```

### Caso 2: Monitoreo Mensual

**Actualizacion regular de colmenas**:

```bash
#!/bin/bash

# Mes 1: Inspeccion de colmenas
# Colmena 0: Crecimiento estable
sui client call --package $PKG --module apiario_virtual \
  --function actualizar_colmena --args $APIARIO 0 55000 35

# Colmena 1: Crecimiento moderado
sui client call --package $PKG --module apiario_virtual \
  --function actualizar_colmena --args $APIARIO 1 48000 34

# Colmena 2: Excelente crecimiento
sui client call --package $PKG --module apiario_virtual \
  --function actualizar_colmena --args $APIARIO 2 70000 36
```

### Caso 3: Temporada de Cosecha

**Ciclo completo de extraccion**:

```bash
# Primavera: Cosecha de Azahar
# Colmena 0: 15 kilos calidad premium
sui client call --package $PKG --module apiario_virtual \
  --function cosechar_miel --args $APIARIO 0 15 96 "Azahar"

# Colmena 1: 12 kilos calidad alta
sui client call --package $PKG --module apiario_virtual \
  --function cosechar_miel --args $APIARIO 1 12 92 "Azahar"

# Colmena 2: 18 kilos calidad premium
sui client call --package $PKG --module apiario_virtual \
  --function cosechar_miel --args $APIARIO 2 18 98 "Azahar"

# Verano: Cosecha de Romero
sui client call --package $PKG --module apiario_virtual \
  --function cosechar_miel --args $APIARIO 0 10 88 "Romero"

sui client call --package $PKG --module apiario_virtual \
  --function cosechar_miel --args $APIARIO 1 9 85 "Romero"

sui client call --package $PKG --module apiario_virtual \
  --function cosechar_miel --args $APIARIO 2 14 90 "Romero"
```

### Caso 4: Comercializacion

**Registro de ventas**:

```bash
# Vender cosecha premium de azahar (ID 0)
sui client call --package $PKG --module apiario_virtual \
  --function vender_cosecha --args $APIARIO 0

# Vender segunda cosecha de azahar (ID 1)
sui client call --package $PKG --module apiario_virtual \
  --function vender_cosecha --args $APIARIO 1

# Vender tercera cosecha de azahar (ID 2)
sui client call --package $PKG --module apiario_virtual \
  --function vender_cosecha --args $APIARIO 2

# Cosechas de romero aun en inventario
```

## Detalles Tecnicos

**Calculo de Produccion**:
- Formula simple: poblacion / 1000
- Actualizacion automatica al cambiar poblacion
- No considera factores externos (clima, flores)

**Salud de Reina**:
- Inicializada en 100 (optima)
- No hay funcion de actualizacion
- Limitacion: no modela degradacion

**Temperatura**:
- Inicializada en 35°C (optima)
- Actualizable via actualizar_colmena
- No hay validacion de rango

**Estado Activa**:
- Inicializada en true
- No hay funcion para desactivar
- Bloquea cosechas si es false (error 2)

**Dias Activos**:
- Contador de longevidad
- Incrementa con cada actualizacion
- No esta vinculado a tiempo real

**Control de Acceso**:
- Todas las operaciones requieren ser apicultor
- Error 1 si no autorizado
- Solo cosechar_miel valida estado activo (error 2)

**Trazabilidad**:
- Cosecha vincula a colmena origen
- No se eliminan registros
- Permite audit trail completo

## Limitaciones y Extensiones

**Limitaciones actuales**:
1. No hay funcion de desactivar colmena
2. Salud de reina no actualizable
3. Fecha de cosecha placeholder (no usa Clock)
4. No hay validacion de rangos de temperatura
5. No hay gestion de pagos por ventas
6. No registra comprador en venta
7. No modela factores climaticos

**Extensiones propuestas**:
- Integracion con Clock para timestamps reales
- Sistema de alertas por temperatura critica
- Tracking de tratamientos sanitarios
- Metricas de productividad por temporada
- Marketplace integrado para ventas
- NFTs de certificacion de calidad
- Analisis de tendencias de produccion

## Testing

```bash
sui move test
```

## Deployment

```bash
sui client publish --gas-budget 100000000
```

## Aplicaciones Reales

**Apicultura Comercial**:
- Gestion de multiples apiarios
- Tracking de productividad
- Certificacion de origen

**Cooperativas**:
- Transparencia en produccion
- Trazabilidad para exportacion
- Auditoria descentralizada

**Investigacion**:
- Datos de salud de colmenas
- Estudios de productividad
- Impacto de factores ambientales

**Consumidores**:
- Verificacion de origen
- Garantia de calidad
- Trazabilidad del producto
