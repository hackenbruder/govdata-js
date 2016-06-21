# GovData Javascript SDK

[Česká verze](README.md)

Official Javascript SDK with browser and Node.js support.

[![Build Status](https://travis-ci.org/hackenbruder/govdata-js.svg)](https://travis-ci.org/hackenbruder/govdata-js)

## GovData

`GovData` provides select OpenData using an API and simplifies it's integration in applications with an SDK. OpenData, APIs and SDKs create an ecosystem and high quality apps can only exist in healthy ecosystem. Our SDKs are test-covered and services highly available.

We provide data from small business, business and other registries including registry of VAT payers. Data are standardized and searchable.

Try our service and SDK for free.

## Installation
### Browsers

Easiest browser SDK integration can be done by inserting following HTML tags in your page code:

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.0/jquery.min.js"></script>
	<script src="https://s3-eu-west-1.amazonaws.com/cdn.govdata.cz/js/govdata-1.0.7.min.js"></script>

You can also install the library locally on your server and load it as your own Javascript. We support `Require.js` library. After installation, SDK creates a single object `GovData` or `window.GovData`.

### Node.js

Install the SDK with standard command:
	
	npm install govdata

Calling `require` returns a single object.

## Configuration

SDK is pre-configured to use `demo` account with our service with specific key and limits. This configuration can be used to test our service and to develop your app.

SDK configuration can be performed by calling `init` method on `GovData` object:
	
	GovData.init({ stage: '<hodnota>', key: '<hodnota>' });

## Usage
### Simple search

Find entities in business registry using `findEntityByNumber` method:

	GovData.findEntityByNumber('00006947',
		function(entity) {
			console.info('Název:', entity.getName());
		},
		function(error) {
			console.error(error.toString());
		}
	);

Please find more detailed example [here](https://gist.github.com/hackenbruder/9313b37361efab6391d5).

### Geospatial search

Entity search using GPS coordinates and radius using `findEntitiesByGeo` method:

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

Documenting SDK objects is in progress. Please explore available objects and their methods in [govdata.coffee](src/govdata.coffee?ts=2).

## Licence

[MIT](LICENSE.md)
