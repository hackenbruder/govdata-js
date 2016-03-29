#govdata restful api wrapper
do ->
	#server nodejs
	if typeof process == 'object'
		https = require 'https'
		url = require 'url'

	class Helpers
		@getDate: (timestamp) ->
			date = new Date
			date.setTime timestamp
			date

		@createError: {
			generic:					-> new Error 100, 'api request error'
			throttled:				-> new Error 105, 'api request was throttled'
			notFound:					-> new Error 110, 'requested content was not found'
			invalidRequest:		-> new Error 115, 'invalid request'
			dataUnavailable:	-> new Error 120, 'data unavailable or missing'
		}

	class Error
		constructor: (code, message) ->
			@code = code
			@message = message

		getCode:				=> @code
		getMessage:			=> @message

		valueOf:				=> @getCode()
		toString:				=> ''.concat @getCode(), ' - ', @getMessage()

	class RUIAN
		constructor: (data) ->
			@data = data.data
			@formatted = data.formatted
			@updatedAt = Helpers.getDate(data.updated_at * 1000)

		getUpdatedAt:		=> @updatedAt
		getId:					=> if @hasId() then @data.address_id else throw Helpers.createError.dataUnavailable()
		getNumber:			=>
			if @data.number2_character?
				value = [@data.number1, @data.number2].join('/') + @data.number2_character.toUpperCase()
			else if @data.number2?
				value = [@data.number1, @data.number2].join('/')
			else if @data.number1?
				value = @data.number1
			else
				throw Helpers.createError.dataUnavailable()

			#prefix if
			#number is evidence or
			#there are no streets and city is a district
			prefix = @data.number_type?.length > 4 || !@hasStreet() && @isCityDistrict()
			if prefix then [@data.number_type, value].join(' ') else value

		getCity:				=> if @hasCity() then @data.city else throw Helpers.createError.dataUnavailable()
		getDistrict:		=> if @hasDistrict() then @data.district else throw Helpers.createError.dataUnavailable()
		getStreet:			=> if @hasStreet() then @data.street else throw Helpers.createError.dataUnavailable()
		getFormatted:		=> if @hasFormatted() then @formatted else throw Helpers.createError.dataUnavailable()
		getPostalCode:	=> if @hasPostalCode() then @data.postal_code else throw Helpers.createError.dataUnavailable()

		isPrague: 			=> @data.city_area2?
		isCityDistrict:	=> @data.city == @data.district
		hasId:					=> @data.address_id?
		hasCity:				=> @data.city?
		hasDistrict:		=> @data.district?
		hasStreet:			=> @data.street?
		hasNumber:			=> @data.number1? || @data.number2? || @data.number2_character?
		hasFormatted:		=> @formatted?.length > 0
		hasPostalCode:	=> @data.postal_code?

		toString:				=> @getFormatted().join '\n'

	class Address
		constructor: (data) ->
			@data = data

			if @hasRUIAN() && @data.ruian?
				@ruian = new RUIAN(@data.ruian)

		enumProcessing: {
			OK:									300,
			MISSING_DATA:				305,
			RUIAN_PENDING:			310,
			GEOCODING_PENDING:	315
		}

		enumStates: {
			UNAVAILABLE:				200,
			INACCURATE:					205,
			ACCURATE:						210
		}

		getGeo:					=> if @hasGeo() then @data.geo?.coords else throw Helpers.createError.dataUnavailable()
		getRUIAN:				=> if @hasRUIAN() then @ruian else throw Helpers.createError.dataUnavailable()
		getFormatted:		=> if @hasFormatted() then @data.ruian?.formatted else throw Helpers.createError.dataUnavailable()

		isAccurate:			=> @data.status == @enumProcessing.OK
		isGeoAccurate:	=> @data.geo?.status == @enumStates.ACCURATE
		hasGeo:					=> @data.geo?.status != @enumStates.UNAVAILABLE
		hasRUIAN:				=> @data.ruian?.status == @enumStates.ACCURATE
		hasFormatted:		=> @hasRUIAN()

		toString:				=> @getFormatted().join ', '

	class Account
		constructor: (data) ->
			@data = data
			@publishedAt = Helpers.getDate data.published_at

		getPublishedAt: => @publishedAt
		getNumber:			=> @data.account_number
		getPrefix:			=> if @hasPrefix() then @data.prefix else throw Helpers.createError.dataUnavailable()
		getBankCode:		=> if @isLocal() then @data.bank_code else throw Helpers.createError.dataUnavailable()

		isLocal:				=> @hasBankCode()
		isIntl:					=> !@isLocal()
		hasPrefix:			=> @data.prefix?
		hasBankCode:		=> @data.bank_code?

		toString: 			=>
			unless @data?.account_number?
				#invalid account
				throw Helpers.createError.dataUnavailable()
			else if @isIntl()
				#international account
				@getNumber()
			else if @hasPrefix()
				#local account with prefix
				return ''.concat @getPrefix(), '-', @getNumber(), '/', @getBankCode()
			else
				#local account
				return ''.concat @getNumber(), '/', @getBankCode()

	class VAT
		constructor: (data) ->
			@data = data
			@updatedAt = Helpers.getDate data.updated_at

			@accounts = []
			@accounts.push new Account account for account in @data.accounts if Array.isArray @data.accounts

		getUpdatedAt:		=> @updatedAt
		getNumber:			=> 'CZ' + @data.dic
		getAccounts:		=> @accounts

		hasAccounts:		=> @accounts.length > 0
		isUnreliable:		=> @data.unreliable

		toString:				=> @getNumber()

	class Entity
		constructor: (data) ->
			@data = data
			@foundedAt = Helpers.getDate data.founded_at

			if @hasAddressData()
				@address = new Address(data.address)
			else
				@address = ''

			if @hasVAT() && @hasVATData()
				@vat = new VAT(data.vat)
			else
				@vat = ''

		getNumber:			=> @data.number
		getName:				=> @data.name
		getFoundedAt:		=> @foundedAt
		getAddress:			=>
			if @hasAddressData()
				return @address
			else
				throw Helpers.createError.dataUnavailable()

		getVAT:					=>
			if @hasVAT()
				if @hasVATData()
					return @vat
				else
					throw Helpers.createError.dataUnavailable()
			else
				throw Helpers.createError.invalidRequest()

		hasAddressData:	=> @data.address != ''
		hasVAT:					=> @data.registers?.vat == true
		hasVATData:			=> @data.vat != ''

		toString:				=> @getName()

	class SearchResult
		constructor: (data) ->
			@data = data
			@foundedAt = Helpers.getDate(data.founded_at * 1000)

		getNumber:			=> @data.number
		getName:				=> @data.name
		getFoundedAt:		=> @foundedAt

	class SearchResults
		constructor: (data) ->
			@data = data

			if !Array.isArray @data.data
				@results = []
			else
				@results = @data.data.map (result) ->
					new SearchResult result

		getPages:				=> @data.pages
		getCount:				=> @results.length
		getResults:			=> @results

	class GovData
		constructor: ->
			@setDefaults()

			if typeof process is 'object'
				#server nodejs
				@get = (method, resolve, reject) =>
					clientURL = url.parse @getURL method
					options = {
						hostname: clientURL.hostname,
						port: 443,
						path: clientURL.path,
						method: 'GET',
						headers: {
							'accept': 'application/json',
							'x-api-key': @key
						}
					}

					request = https.request options, (response) ->
						body = ''

						response.on 'data', (data) -> body += data
						response.on 'end', ->
							try
								message = JSON.parse body
							catch
								reject new Error()
								return

							if response.statusCode == 200
								resolve message
							else if response.statusCode == 429
								reject Helpers.createError.throttled()
							else if message.error?
								reject new Error message.error.code, message.error.message

					request.on 'error', -> new Error reject

					request.write ' '
					request.end
					return
			else
				#client jquery
				@get = (method, resolve, reject) =>
					$.ajax {
						url: @getURL method
						method: 'GET'
						dataType: 'json',
						headers: {
							'x-api-key': @key
						}
					}
					.always (message, status, xhr) =>
						if xhr.status == 200
							resolve message
						else if xhr == '' && status == 'error'
							reject Helpers.createError.throttled()
						else if message.responseJSON?.error?
							error = message.responseJSON.error
							reject new Error error.code, error.message
						else
							reject Helpers.createError.generic()

					return

		init: (options) ->
			{ @stage, @key } = options

		setDefaults: =>
			@url = 'https://api.govdata.cz/v1/'
			@init {
				stage: 'demo',
				key: 'ZX1Ap4RUDY2VisBOu2P0e4sEvh2LhWh4Cx8lqoO6'
			}

		getURL: (method) => ''.concat @url, @stage, '/', method
		getParams: (params) ->
			Object.keys(params).map (key) ->
				encodeURIComponent(key) + '=' + encodeURIComponent(params[key])
			.join '&'

		findEntityByNumber: (number, resolve, reject) =>
			@get 'entity/' + number,
				(data) => resolve @createEntity data,
				reject

		findEntitiesByGeo: (latitude, longitude, radius, page, resolve, reject) =>
			params = @getParams {
				lat: latitude,
				lon: longitude,
				radius: radius,
				page: page
			}
			@get 'search/geo?' + params,
				(data) => resolve @createSearchResults data,
				reject

		createSearchResults: (data) ->
			return new SearchResults data

		createEntity: (data) ->
			return new Entity data

		createAddress: (data) ->
			return new Address data

		createError: Helpers.createError

	if module? && module.exports?
		module.exports = new GovData()
	else if typeof define is 'function' && define.amd?
		define -> new GovData()
	else
		window.GovData = new GovData()