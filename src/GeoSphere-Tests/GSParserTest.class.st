Class {
	#name : #GSParserTest,
	#superclass : #TestCase,
	#category : #'GeoSphere-Tests'
}

{ #category : #tests }
GSParserTest >> testParseCoordinates [

	self
		assert: (GSParser parseCoordinates: '50 deg 30'' 0" N, 13 deg 30'' 0.0" E')
		equals: (13.5 @ 50.5) asGSCoordinates.

	self
		assert: (GSParser parseCoordinates: '53°30′00″S, 13°30′00″W')
		equals: (-13.5 @ -53.5) asGSCoordinates.

	self
		assert: (GSParser parseCoordinates: '13.5 @ 50.5 ')
		equals: (13.5 @ 50.5) asGSCoordinates.

	self
		assert: (GSParser parseOpenStreetMap: 'https://www.openstreetmap.org/search?query=pt%20lonsdale%2C%20victoria#map=18/50.5/13.5')
		equals: (13.5 @ 50.5) asGSCoordinates
]

{ #category : #tests }
GSParserTest >> testParseDMS [

	self
		assert: (GSParser parseDMS: '50 deg 30'' 0" N, 13 deg 30'' 0.0" E')
		equals: (13.5 @ 50.5) asGSCoordinates.

	self
		assert: (GSParser parseDMS: '53°30′00″S, 13°30′00″W')
		equals: (-13.5 @ -53.5) asGSCoordinates.

]

{ #category : #tests }
GSParserTest >> testParseOpenStreetMap [

	self
		assert: (GSParser parseOpenStreetMap: 'https://www.openstreetmap.org/search?query=pt%20lonsdale%2C%20victoria#map=18/50.5/13.5')
		equals: (13.5 @ 50.5) asGSCoordinates
]

{ #category : #tests }
GSParserTest >> testParsePoint [

	self
		assert: (GSParser parsePoint: '13.5 @ 50.5 ')
		equals: (13.5 @ 50.5) asGSCoordinates
]
