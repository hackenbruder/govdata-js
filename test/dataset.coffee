class Dataset
	@entityStandard: -> {
		"ico" : "0123456789",
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
		"ico" : "0123456789",
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
		"ico" : "0123456789",
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
		"ico" : "0123456789",
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

if module? && module.exports?
	module.exports = Dataset
else if typeof define is 'function' && define.amd?
	define [], ->
		return Dataset
else
	window.dataset = Dataset