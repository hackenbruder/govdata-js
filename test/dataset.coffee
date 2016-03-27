class Dataset
	@entityStandard: -> {
		"number" : "0123456789",
		"address" : "",
		"name" : "Testing name",
		"registers" : {
			"small_business": true,
			"vat": true,
			"business": true,
			"statistical": true
		},
		"vat" : {
			"updated_at": 1439926209070,
			"accounts": [ {
				"account_number": "CZ0123400000000123456789",
				"published_at": 1400112000000
			}, {
				"prefix": "1234",
				"account_number": "2400012345",
				"bank_code": "1234",
				"published_at": 1400112000000
			} ],
			"unreliable": false,
			"tax_office_id": "463",
			"dic":"0123456789"
		},
		"founded_at" : 1398211200000
	}

	@entityNoAccounts: -> {
		"number" : "0123456789",
		"address" : "",
		"name" : "Testing name",
		"registers" : {
			"small_business": true,
			"vat": true,
			"business": true,
			"statistical": true
		},
		"vat" : {
			"updated_at": 1439926209070,
			"accounts": [],
			"unreliable": false,
			"tax_office_id": "463",
			"dic":"0123456789"
		},
		"founded_at" : 1398211200000
	}

	@entityMissingVAT: -> {
		"number" : "0123456789",
		"address" : "",
		"name" : "Testing name",
		"registers" : {
			"small_business": true,
			"vat": true,
			"business": true,
			"statistical": true
		},
		"vat" : "",
		"founded_at" : 1398211200000
	}

	@entityNoVAT: -> {
		"number" : "0123456789",
		"address" : "",
		"name" : "Testing name",
		"registers" : {
			"small_business": true,
			"vat": false,
			"business": true,
			"statistical": true
		},
		"vat" : "",
		"founded_at" : 1398211200000
	}

	@addressStandard: -> {
		"geo": {
			"coords": [
				50.088182,
				14.420210
			],
			"status": 210
		},
		"ruian": {
			"data": {
				"address_id": 123456,
				"city": "Město",
				"city_area1": "Obec",
				"city_area2": "Obec",
				"city_code": 123,
				"district": "Obec",
				"district_code": 123,
				"number1": 123,
				"number2": 456,
				"number_type": "č.p.",
				"postal_code": 12345,
				"sjtsk_x": 123,
				"sjtsk_y": 456,
				"street": "Ulice",
				"wgs84_lat": 50.088182,
				"wgs84_lon": 14.420210,
				"updated_at": 1386720000
			},
			"formatted": [
				'Ulice 123/456A',
				'Obec',
				'12345 Město'
			],
			"status": 210
		},
		"status": 300
	}

	@addressIncomplete: -> {
		"geo": {
			"status": 200
		},
		"ruian": {
			"status": 200
		},
		"status": 305
	}

	@addressBroken: -> {
		"geo": {
			"status": 200
		},
		"ruian": {
			"data": ""
			"status": 210
		},
		"status": 305
	}

	@searchResults: -> {
		"pages": 1,
		"data": [
			{
				"number": "123",
				"name": "Testing name",
				"type": 101,
				"status": 210,
				"lat": 50.088182,
				"lon": 14.420210,
				"founded_at": 1398211200
			}, {
				"number": "456",
				"name": "Testing name",
				"type": 101,
				"status": 210,
				"lat": 50.088182,
				"lon": 14.420210,
				"founded_at": 1398211200
			}
		]
	}

if module? && module.exports?
	module.exports = Dataset
else if typeof define is 'function' && define.amd?
	define [], ->
		return Dataset
else
	window.dataset = Dataset