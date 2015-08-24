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

describe 'GovData Integration', ->
	describe 'Queries: Generic', ->
		describe 'Not found', ->
			it 'Returns an error', (done) ->
				@timeout 5000

				govdata.findByICO('123',
					(entity) -> errorMessage 'Found',
					(error) ->
						if error.getCode() is 110
							done()
						else
							errorHelper error
				)
			return

		describe 'Found', ->
			it 'Returns an entity', (done) ->
				@timeout 5000

				govdata.findByICO('00006947',
					(entity) -> done(),
					(error) -> errorHelper error
				)
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

		it 'Has ICO', ->
			s = entity.getICO()
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

		it 'Has DIC', ->
			s = standard.getVAT().getDIC()
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
					try
						entity.getVAT()
					catch e
						if e - govdata.createError.dataUnavailable() == 0
							done()
						else
							errorHelper e
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
				try
					intl.getPrefix()
				catch e
					if e - govdata.createError.dataUnavailable() == 0
						done()
					else
						errorHelper e
				return

			it 'Throws an error on missing bank code', (done) ->
				try
					intl.getBankCode()
				catch e
					if e - govdata.createError.dataUnavailable() == 0
						done()
					else
						errorHelper e
				return

			it 'Acts as a string', ->
				l = local.toString()
				i = intl.toString()
				typeof l is 'string' && l.length > 0 && typeof i is 'string' && i.length > 0
	return