/// Apiario Virtual - Gestión de colmenas y producción de miel
module apiario_virtual::apiario_virtual {
    use sui::object;
    use sui::tx_context;
    
    use sui::table::{Self, Table};
    use std::string::{Self, String};

    public struct Apiario has key {
        id: object::UID,
        apicultor: address,
        colmenas: Table<u64, Colmena>,
        cosechas: Table<u64, Cosecha>,
        contador_colmenas: u64,
        contador_cosechas: u64,
    }

    public struct Colmena has store {
        id: u64,
        ubicacion: String,
        poblacion_abejas: u64,
        salud_reina: u8,
        produccion_diaria: u64,
        temperatura: u64,
        activa: bool,
        dias_activos: u64,
    }

    public struct Cosecha has store {
        id: u64,
        colmena_id: u64,
        kilos_miel: u64,
        calidad: u8,
        fecha: u64,
        tipo_flor: String,
        vendida: bool,
    }

    public fun crear_apiario(ctx: &mut tx_context::TxContext) {
        let apiario = Apiario {
            id: sui::object::new(ctx),
            apicultor: sui::tx_context::sender(ctx),
            colmenas: table::new(ctx),
            cosechas: table::new(ctx),
            contador_colmenas: 0,
            contador_cosechas: 0,
        };
        sui::transfer::share_object(apiario);
    }

    public fun instalar_colmena(
        apiario: &mut Apiario,
        ubicacion: vector<u8>,
        poblacion: u64,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(apiario.apicultor == sui::tx_context::sender(ctx), 1);
        let colmena = Colmena {
            id: apiario.contador_colmenas,
            ubicacion: string::utf8(ubicacion),
            poblacion_abejas: poblacion,
            salud_reina: 100,
            produccion_diaria: poblacion / 1000,
            temperatura: 35,
            activa: true,
            dias_activos: 0,
        };
        table::add(&mut apiario.colmenas, apiario.contador_colmenas, colmena);
        apiario.contador_colmenas = apiario.contador_colmenas + 1;
    }

    public fun actualizar_colmena(
        apiario: &mut Apiario,
        id: u64,
        nueva_poblacion: u64,
        nueva_temp: u64,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(apiario.apicultor == sui::tx_context::sender(ctx), 1);
        let colmena = table::borrow_mut(&mut apiario.colmenas, id);
        colmena.poblacion_abejas = nueva_poblacion;
        colmena.temperatura = nueva_temp;
        colmena.produccion_diaria = nueva_poblacion / 1000;
        colmena.dias_activos = colmena.dias_activos + 1;
    }

    public fun cosechar_miel(
        apiario: &mut Apiario,
        id_colmena: u64,
        kilos: u64,
        calidad: u8,
        tipo_flor: vector<u8>,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(apiario.apicultor == sui::tx_context::sender(ctx), 1);
        let colmena = table::borrow(&apiario.colmenas, id_colmena);
        assert!(colmena.activa, 2);
        
        let cosecha = Cosecha {
            id: apiario.contador_cosechas,
            colmena_id: id_colmena,
            kilos_miel: kilos,
            calidad,
            fecha: 0,
            tipo_flor: string::utf8(tipo_flor),
            vendida: false,
        };
        table::add(&mut apiario.cosechas, apiario.contador_cosechas, cosecha);
        apiario.contador_cosechas = apiario.contador_cosechas + 1;
    }

    public fun vender_cosecha(
        apiario: &mut Apiario,
        id_cosecha: u64,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(apiario.apicultor == sui::tx_context::sender(ctx), 1);
        let cosecha = table::borrow_mut(&mut apiario.cosechas, id_cosecha);
        cosecha.vendida = true;
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut tx_context::TxContext) {
        crear_apiario(ctx);
    }
}


