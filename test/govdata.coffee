#server nodejs
if typeof process == 'object'
	require 'coffee-script/register'
	govdata = require '../src/govdata'
	dataset = require './dataset'
else
	govdata = window.GovData
	dataset = window.dataset

errorHelper = (error) ->
	throw new Error 'Error: ' + error.getMessage()

errorMessage = (message) ->
	throw new Error 'Error: ' + message

catchError = (callback, errorCallback, done) ->
	try
		callback()
	catch e
		if e - errorCallback() == 0
			done()
		else
			errorHelper e
	return

describe 'GovData Integration', ->
	describe 'Queries: Generic', ->
		describe 'Not found', ->
			it 'Returns an error', (done) ->
				@timeout 5000

				govdata.findEntityByNumber '123'
					, (entity) ->
						errorMessage 'Found'
					, (error) ->
						if error.getCode() is 110
							done()
						else
							errorHelper error
			return

		describe 'Found', ->
			it 'Returns an entity', (done) ->
				@timeout 5000

				govdata.findEntityByNumber '00006947'
					, (entity) ->
						done()
					, (error) ->
						errorHelper error
			return

	describe 'Queries: Geo', ->
		describe 'Find by geo', ->
			it 'Returns an array of entities', (done) ->
				@timeout 5000

				govdata.findEntitiesByGeo 50.08915042002743, 14.407195183397297, 100, 1
					, (results) ->
						done()
					, (error) ->
						errorHelper error
			return
	return

describe 'GovData Unit', ->
	describe 'Errors', ->
		it 'Have integer codes', ->
			errors = govdata.createError
			for k, v of errors
				code = v().getCode()
				if typeof code isnt 'integer' || code - error != 0
					return false
			return true

		it 'Have messages and act as strings', ->
			errors = govdata.createError
			for k, v of errors
				error = v()
				message = error.getMessage()
				if typeof message isnt 'string' || message != error.toString()
					return false
			return true

	describe 'Mocked: Entity', ->
		entity = govdata.createEntity dataset.entityStandard()

		it 'Has s number (ICO)', ->
			s = entity.getNumber()
			typeof s is 'string' && s.length > 0

		it 'Has a name', ->
			s = entity.getName()
			typeof s is 'string' && s.length > 0

		it 'Has a valid foundation date', ->
			foundedAt = entity.getFoundedAt()
			typeof foundedAt is 'object' && foundedAt.getTime() > 0

		it 'Acts as a string', ->
			typeof entity.toString() is 'string'

	describe 'Mocked: VAT', ->
		standard = govdata.createEntity dataset.entityStandard()

		it 'Has a valid update date', ->
			updatedAt = standard.getVAT().getUpdatedAt()
			typeof updatedAt is 'object' && updatedAt.getTime() > 0

		it 'Has a number (DIC)', ->
			s = standard.getVAT().getNumber()
			typeof s is 'string' && s.length > 0

		it 'Has accounts', ->
			s = standard.getVAT().getAccounts()
			Array.isArray(s) && s.length > 0

		it 'Returns accounts', -> standard.getVAT().hasAccounts()
		it 'Returns unreliability', -> standard.getVAT().isUnreliable() == false
		it 'Acts as a string', -> typeof standard.getVAT().toString() is 'string'

		describe 'Registered entity', ->
			it 'Has information', -> standard.hasVAT()

			it 'Throws an error on missing information', (done) ->
				entity = govdata.createEntity dataset.entityMissingVAT()
				if entity.hasVAT()
					catchError entity.getVAT
					, govdata.createError.dataUnavailable
					, done
				else
					errorMessage 'Doesn\'t have VAT information available'
				return

			it 'Reports no accounts', ->
				entity = govdata.createEntity dataset.entityNoAccounts()
				entity.hasVAT() && entity.getVAT().hasAccounts() == false

		describe 'Mocked: Account', ->
			standard = govdata.createEntity dataset.entityStandard()
			accounts = standard.getVAT().getAccounts()
			intl = accounts[0]
			local = accounts[1]

			it 'Has a valid published date', ->
				at = local.getPublishedAt()
				typeof at is 'object' && at.getTime() > 0

			it 'Returns a number', ->
				s = local.getNumber()
				typeof s is 'string' && s.length > 0

			it 'Returns locality', -> local.isLocal() && !local.isIntl()
			it 'Returns internationality', -> !intl.isLocal() && intl.isIntl()
			it 'Returns prefix presence', -> local.hasPrefix() && !intl.hasPrefix()
			it 'Returns bank code presence', -> local.hasBankCode() && !intl.hasBankCode()

			it 'Throws an error on missing prefix', (done) ->
				catchError intl.getPrefix
				, govdata.createError.dataUnavailable
				, done

			it 'Throws an error on missing bank code', (done) ->
				catchError intl.getBankCode
				, govdata.createError.dataUnavailable
				, done

			it 'Acts as a string', ->
				l = local.toString()
				i = intl.toString()
				typeof l is 'string' && l.length > 0 && typeof i is 'string' && i.length > 0

	describe 'Mocked: Address', ->
		address1 = govdata.createAddress dataset.addressStandard()
		address2 = govdata.createAddress dataset.addressIncomplete()

		it 'Acts as a string', ->
			typeof address1.toString() is 'string'

		it 'Has a formatted string', ->
			address1.hasFormatted()

		it 'Has RUIAN data', ->
			address1.hasRUIAN() && !address2.hasRUIAN()

		it 'Has geo data', ->
			address1.hasGeo() && !address2.hasGeo()

		it 'Returns geo accuracy', ->
			address1.isGeoAccurate() && !address2.isGeoAccurate()

		it 'Returns data accuracy', ->
			address1.isAccurate() && !address2.isAccurate()

		it 'Returns formatted string', ->
			typeof address1.toString() is 'string'

		it 'Returns RUIAN object', ->
			typeof address1.getRUIAN() is 'object'

		it 'Returns geo array', ->
			Array.isArray address1.getGeo() && address1.getGeo().length == 2

		it 'Throws an error on missing formatted string', (done) ->
			catchError address2.getFormatted
			, govdata.createError.dataUnavailable
			, done

		it 'Throws an error on string conversion when missing data', (done) ->
			catchError address2.toString
			, govdata.createError.dataUnavailable
			, done

		it 'Throws an error on missing RUIAN data', (done) ->
			catchError address2.getRUIAN
			, govdata.createError.dataUnavailable
			, done

		it 'Throws an error on missing geo data', (done) ->
			catchError address2.getGeo
			, govdata.createError.dataUnavailable
			, done

		describe 'Mocked: RUIAN', ->
			ruian1 = govdata.createAddress(dataset.addressStandard()).getRUIAN()
			ruian2 = govdata.createAddress(dataset.addressBroken()).getRUIAN()

			it 'Acts as a string', ->
				typeof ruian1.toString() is 'string'

			it 'Has a postal code', -> ruian1.hasPostalCode() && !ruian2.hasPostalCode()
			it 'Has formatted output', -> ruian1.hasFormatted() && !ruian2.hasFormatted()
			it 'Has a street', -> ruian1.hasStreet() && !ruian2.hasStreet()
			it 'Has a number', -> ruian1.hasNumber() && !ruian2.hasNumber()
			it 'Has a district', -> ruian1.hasDistrict() && !ruian2.hasDistrict()
			it 'Has a city', -> ruian1.hasCity() && !ruian2.hasCity()
			it 'Has an id', -> ruian1.hasId() && !ruian2.hasId()
			it 'Returns if city is a district', -> ruian1.isCityDistrict()
			it 'Returns if address is in Prague', -> ruian1.isPrague()

			it 'Returns a postal code', ->
				typeof ruian1.getPostalCode() is 'number'

			it 'Returns formatted', ->
				Array.isArray ruian1.getFormatted() && ruian1.getFormatted().length > 0

			it 'Returns a street', ->
				typeof ruian1.getStreet() is 'string'

			it 'Returns a district', ->
				typeof ruian1.getDistrict() is 'string'

			it 'Returns a city', ->
				typeof ruian1.getCity() is 'string'

			it 'Returns a number', ->
				typeof ruian1.getNumber() is 'string'

			it 'Returns a id', ->
				typeof ruian1.getId() is 'number'

			it 'Has a valid updated date', ->
				at = ruian1.getUpdatedAt()
				typeof at is 'object' && at.getTime() > 0

			it 'Throws an error on missing postal code', (done) ->
				catchError ruian2.getPostalCode
				, govdata.createError.dataUnavailable
				, done

			it 'Throws an error on missing formatted', (done) ->
				catchError ruian2.getFormatted
				, govdata.createError.dataUnavailable
				, done

			it 'Throws an error on missing street', (done) ->
				catchError ruian2.getStreet
				, govdata.createError.dataUnavailable
				, done

			it 'Throws an error on missing district', (done) ->
				catchError ruian2.getDistrict
				, govdata.createError.dataUnavailable
				, done

			it 'Throws an error on missing city', (done) ->
				catchError ruian2.getCity
				, govdata.createError.dataUnavailable
				, done

			it 'Throws an error on missing number', (done) ->
				catchError ruian2.getNumber
				, govdata.createError.dataUnavailable
				, done

			it 'Throws an error on missing id', (done) ->
				catchError ruian2.getId
				, govdata.createError.dataUnavailable
				, done

	describe 'Mocked: Search Results', ->
		results = govdata.createSearchResults dataset.searchResults()

		it 'Returns page count', ->
			results.getPages() > 0

		it 'Returns result count', ->
			results.getCount() > 0

		it 'Returns results', ->
			Array.isArray results.getResults() && results.getResults().length > 0

		describe 'Mocked: Search Result', ->
			result = results.getResults()[0]

			it 'Returns a number', ->
				typeof result.getNumber() is 'string'

			it 'Returns a name', ->
				typeof result.getName() is 'string'

			it 'Has a valid founded date', ->
				at = result.getFoundedAt()
				typeof at is 'object' && at.getTime() > 0

	return