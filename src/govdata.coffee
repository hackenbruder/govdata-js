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
			@accounts.push new Account account for account in @data.accounts

		getUpdatedAt:		=> @updatedAt
		getDIC:					=> 'CZ' + @data.dic
		getAccounts:		=> @accounts

		hasAccounts:		=> @accounts.length > 0
		isUnreliable:		=> @data.unreliable

		toString:				=> @getDIC()

	class Entity
		constructor: (data) ->
			@data = data
			@foundedAt = Helpers.getDate data.founded_at
			@vat = if @hasVAT() && @hasVATData() then new VAT data.vat else ''

		getICO:					=> @data.ico
		getName:				=> @data.name
		getFoundedAt:		=> @foundedAt
		getVAT:					=>
			if @hasVAT()
				if @hasVATData()
					return @vat
				else
					throw Helpers.createError.dataUnavailable()
			else
				throw Helpers.createError.invalidRequest()

		hasVAT:					=> @data.registers?.vat? == true
		hasVATData:			=> @data.vat != ''

		toString:				=> @getName()

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
						url:			@getURL method
						method:		'GET'
						dataType:	'json',
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

		findByICO: (ico, resolve, reject) =>
			@get 'ico/' + ico,
				(data) => resolve @createEntity data,
				reject

		createEntity: (data) ->
			return new Entity data

		createError: Helpers.createError

	if module? && module.exports?
		module.exports = new GovData()
	else if typeof define is 'function' && define.amd?
		define -> new GovData()
	else
		window.GovData = new GovData()