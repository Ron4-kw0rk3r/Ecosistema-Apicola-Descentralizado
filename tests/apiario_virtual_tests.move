#[test_only]
module apiario_virtual::apiario_virtual_tests {
    use apiario_virtual::apiario_virtual::{Self, Apiario};
    use sui::test_scenario::{Self as ts};

    const APICULTOR: address = @0xA;
    const OTRO: address = @0xB;

    #[test]
    fun test_crear_apiario() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, APICULTOR);
        {
            assert!(ts::has_most_recent_shared<Apiario>(), 0);
        };
        ts::end(scenario);
    }

    #[test]
    fun test_instalar_colmena() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, APICULTOR);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::instalar_colmena(&mut apiario, b"Valle Norte", 50000, ts::ctx(&mut scenario));
            ts::return_shared(apiario);
        };
        ts::end(scenario);
    }

    #[test]
    fun test_actualizar_colmena() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, APICULTOR);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::instalar_colmena(&mut apiario, b"Sector A", 60000, ts::ctx(&mut scenario));
            apiario_virtual::actualizar_colmena(&mut apiario, 0, 65000, 36, ts::ctx(&mut scenario));
            ts::return_shared(apiario);
        };
        ts::end(scenario);
    }

    #[test]
    fun test_cosechar_miel() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, APICULTOR);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::instalar_colmena(&mut apiario, b"Zona B", 70000, ts::ctx(&mut scenario));
            apiario_virtual::cosechar_miel(&mut apiario, 0, 15, 95, b"Azahar", ts::ctx(&mut scenario));
            ts::return_shared(apiario);
        };
        ts::end(scenario);
    }

    #[test]
    fun test_vender_cosecha() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, APICULTOR);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::instalar_colmena(&mut apiario, b"Parcela 1", 55000, ts::ctx(&mut scenario));
            apiario_virtual::cosechar_miel(&mut apiario, 0, 12, 90, b"Romero", ts::ctx(&mut scenario));
            apiario_virtual::vender_cosecha(&mut apiario, 0, ts::ctx(&mut scenario));
            ts::return_shared(apiario);
        };
        ts::end(scenario);
    }

    #[test]
    fun test_multiples_colmenas() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, APICULTOR);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::instalar_colmena(&mut apiario, b"Colmena 1", 40000, ts::ctx(&mut scenario));
            apiario_virtual::instalar_colmena(&mut apiario, b"Colmena 2", 50000, ts::ctx(&mut scenario));
            apiario_virtual::instalar_colmena(&mut apiario, b"Colmena 3", 60000, ts::ctx(&mut scenario));
            ts::return_shared(apiario);
        };
        ts::end(scenario);
    }

    #[test]
    fun test_multiples_cosechas() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, APICULTOR);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::instalar_colmena(&mut apiario, b"Colmena Principal", 80000, ts::ctx(&mut scenario));
            apiario_virtual::cosechar_miel(&mut apiario, 0, 20, 98, b"Azahar", ts::ctx(&mut scenario));
            apiario_virtual::cosechar_miel(&mut apiario, 0, 15, 92, b"Romero", ts::ctx(&mut scenario));
            apiario_virtual::cosechar_miel(&mut apiario, 0, 18, 85, b"Multifloral", ts::ctx(&mut scenario));
            ts::return_shared(apiario);
        };
        ts::end(scenario);
    }

    #[test]
    fun test_flujo_completo() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, APICULTOR);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::instalar_colmena(&mut apiario, b"Monte Verde", 50000, ts::ctx(&mut scenario));
            apiario_virtual::actualizar_colmena(&mut apiario, 0, 55000, 35, ts::ctx(&mut scenario));
            apiario_virtual::cosechar_miel(&mut apiario, 0, 14, 94, b"Lavanda", ts::ctx(&mut scenario));
            apiario_virtual::vender_cosecha(&mut apiario, 0, ts::ctx(&mut scenario));
            ts::return_shared(apiario);
        };
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    fun test_instalar_colmena_no_autorizado() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, OTRO);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::instalar_colmena(&mut apiario, b"Intento no autorizado", 40000, ts::ctx(&mut scenario));
            ts::return_shared(apiario);
        };
        ts::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    fun test_actualizar_colmena_no_autorizado() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, APICULTOR);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::instalar_colmena(&mut apiario, b"Test", 50000, ts::ctx(&mut scenario));
            ts::return_shared(apiario);
        };
        ts::next_tx(&mut scenario, OTRO);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::actualizar_colmena(&mut apiario, 0, 60000, 36, ts::ctx(&mut scenario));
            ts::return_shared(apiario);
        };
        ts::end(scenario);
    }

    #[test]
    fun test_temporada_completa() {
        let mut scenario = ts::begin(APICULTOR);
        {
            apiario_virtual::crear_apiario(ts::ctx(&mut scenario));
        };
        ts::next_tx(&mut scenario, APICULTOR);
        {
            let mut apiario = ts::take_shared<Apiario>(&scenario);
            apiario_virtual::instalar_colmena(&mut apiario, b"Valle Norte", 60000, ts::ctx(&mut scenario));
            apiario_virtual::instalar_colmena(&mut apiario, b"Valle Sur", 55000, ts::ctx(&mut scenario));
            
            apiario_virtual::actualizar_colmena(&mut apiario, 0, 65000, 35, ts::ctx(&mut scenario));
            apiario_virtual::actualizar_colmena(&mut apiario, 1, 58000, 34, ts::ctx(&mut scenario));
            
            apiario_virtual::cosechar_miel(&mut apiario, 0, 16, 96, b"Azahar", ts::ctx(&mut scenario));
            apiario_virtual::cosechar_miel(&mut apiario, 1, 14, 93, b"Azahar", ts::ctx(&mut scenario));
            
            apiario_virtual::vender_cosecha(&mut apiario, 0, ts::ctx(&mut scenario));
            apiario_virtual::vender_cosecha(&mut apiario, 1, ts::ctx(&mut scenario));
            
            ts::return_shared(apiario);
        };
        ts::end(scenario);
    }
}