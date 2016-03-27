# GovData Javascript SDK

Oficiální javascriptové SDK podporující prohlížeče a Node.js.

[![Build Status](https://travis-ci.org/hackenbruder/govdata-js.svg)](https://travis-ci.org/hackenbruder/govdata-js)

## Instalace
### Prohlížeče

Nejsnadnější instalaci SDK do prohlížeče můžete provést vložením následujících tagů do HTML kódu vaší stránky:

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.0/jquery.min.js"></script>
	<script src="https://s3-eu-west-1.amazonaws.com/cdn.govdata.cz/js/govdata-1.0.4.min.js"></script>

Knihovnu také můžete instalovat lokálně na váš server a načítat jako vlastní javascript. Podporujeme knihovnu `Require.js`. SDK po instalaci vytváří jediný globální objekt `GovData` nebo `window.GovData`.

### Node.js

SDK nainstalujete standardním příkazem:
	
	npm install govdata

Volání `require` vrací jediný objekt.

## Konfigurace

SDK je dodáváno předkonfigurované jako `demo` s příslušným klíčem a limity. Tuto konfiguraci je možné využít k otestování naší služby a při vývoji vaší aplikace.

Konfigurace SDK pro produkční použití se provádí voláním metody `init` na objektu `GovData`:
	
	GovData.init({ stage: '<hodnota>', key: '<hodnota>' });

## Použití
### Jednoduché hledání

Vyhledání subjektu v obchodním rejstříku:

	GovData.findEntityByNumber('00006947',
		function(entity) {
			console.info('Název:', entity.getName());
		},
		function(error) {
			console.error(error.toString());
		}
	);

Podrobnější příklad můžete najít [zde](https://gist.github.com/hackenbruder/9313b37361efab6391d5).

### Geoprostorové hledání

Vyhledání subjektů pomocí GPS souřadnic a rádiusu:

    GovData.findEntitiesByGeo(50.08915042002743, 14.407195183397297, 100, 1,
        function(response) {
            console.info('Počet stránek:', response.getPages());
            console.info('Počet výsledků na aktuální stránce:', response.getCount());

            var results = response.getResults();
            for(var i = 0; i < results.length; ++i) {
                var r = results[i];
                console.info('Identifikační číslo:', r.getNumber(), 'Název:', r.getName());
            }
        },
        function(error) {
            console.error(error.toString());
        }
    );

## Dokumentace

Dokumentace objektů v SDK se připravuje. Dostupné objekty a jejich metody si můžete prohlédnout v souboru [govdata.coffee](src/govdata.coffee?ts=2).

## Licence

[MIT](LICENSE.md)
