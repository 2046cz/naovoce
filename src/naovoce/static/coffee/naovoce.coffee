@Naovoce = {} # Application namespace


class JsonStorage
	###
	Provides getting and setting JSON-serialized objects in localStorage,
	which otherwise supports key-value strings storage only.
	###
	constructor: (namespace) ->
		if Storage?
			storage = localStorage

			@getObject = (name) ->
				data = storage.getItem(namespace)
				if data then JSON.parse(data)[name] else null

			@setObject = (name, val) ->
				data = storage.getItem(namespace)
				data = if data then JSON.parse(data) else {}
				data[name] = val
				storage.setItem namespace, JSON.stringify data

		else
			@getObject = @setObject = -> null


@Naovoce.storage = new JsonStorage('naovoce')


prepareDB = ->
	database = $.Deferred()

	# Create database and indexed storage for markers.
	# This should be much more performant than localStorage.
	indexedDB = window.indexedDB ||
				window.mozIndexedDB ||
				window.webkitIndexedDB ||
				window.msIndexedDB

	if indexedDB
		request = indexedDB.open('naovoce', 1)

		request.onsuccess = (event) ->
			db = event.target.result
			database.resolve(db)

		request.onupgradeneeded = (event) ->
			db = event.target.result
			db.createObjectStore 'markers', {keyPath: 'id'}
			database.resolve(db)
	else
		database.reject('IndexedDB is not supported by this browser.')

	return database.promise()


@Naovoce.db = prepareDB()


# Enhance strings with truncete method.
String::truncate = (n) ->
	@substr(0, n - 1).trim() + ((if @length > n then "&hellip;" else ""))


$.fn.fillViewport = ->
	###
	jQuery plugin for stretching an element height to fill down the browser window
	###
	$window = $(window)
	$elem = this
	navigation_h = $('#main-nav').outerHeight() + $('#user-info').outerHeight()

	$window.resize ->
		$elem.css 'min-height', "#{ Math.max $window.height() - navigation_h, 320 }px"
	.trigger 'resize'


$('#main-content').fillViewport()
