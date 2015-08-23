# GovData Javascript SDK

Oficiální javascriptové SDK s podporou prohlížečů a Node.js.
***

## Instalace
***
### Prohlížeče

Nejsnadnější instalaci SDK do prohlížeče můžete provést vložením následujícího tagu do HTML kódu vaší stránky:

	<script src="https://s3-eu-west-1.amazonaws.com/cdn.govdata.cz/js/govdata-1.0.0.min.js"></script>

Knihovnu také můžete instalovat lokálně na váš server a načítat jako vlastní javascript. Podporujeme knihovnu `Require.js`. SDK po instalaci vytváří jediný globální objekt `GovData` nebo `window.GovData`.

### Node.js

SDK nainstalujete standardním příkazem:
	
	npm install govdata

Volání `require` vrací jediný objekt.

## Konfigurace
***
SDK je dodáváno předkonfigurované jako `demo` s příslušným klíčem a limity. Tuto konfiguraci je možné využít k otestování naší služby a při vývoji vaší aplikace.

Konfigurace SDK pro produkční použití se provádí voláním metody `init` na objektu `GovData`:
	
	GovData.init({ stage: '<hodnota>', key: '<hodnota>' });

## Použití
***
Vyhledání právnické osoby v obchodním rejstříku:

	GovData.findByICO('00006947',
		function(entity) {
			console.info(entity.getName());
		},
		function(error) {
			console.error(error.toString());
		}
	);

## Dokumentace
***
Dokumentace objektů v SDK se připravuje. Dostupné objekty a jejich metody si můžete prohlédnout v souboru [govdata.coffee](src/govdata.coffee).

##Licence
***
[MIT](LICENSE.md)