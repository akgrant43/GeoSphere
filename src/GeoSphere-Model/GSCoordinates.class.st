"
GSCoordinates represents a latitude / longitude location on a globe in degrees and provides useful operations, e.g. 

- calculate distance between coordinates
- open a map at the coordinates


Internal Representation and Key Implementation Points.

Instance Variables
	latitude:		<Number>
	longitude:	<Number>


Implementation Points

- The two main sources of information for GeoSphere are:
-- http://www.movable-type.co.uk/scripts/latlong.html
-- https://cran.r-project.org/web/packages/geosphere/geosphere.pdf
- Earth's Radius is taken from https://cran.r-project.org/web/packages/geosphere/geosphere.pdf, which agrees with the equatorial radius given in https://en.wikipedia.org/wiki/Earth_radius

"
Class {
	#name : #GSCoordinates,
	#superclass : #Object,
	#instVars : [
		'latitude',
		'longitude'
	],
	#classVars : [
		'EarthRadius'
	],
	#category : #'GeoSphere-Model'
}

{ #category : #printing }
GSCoordinates class >> dms: aNumber labels: labelArray to: aStream [
	"Write the supplied number (latitude or longitude) as Degrees Minutes Seconds on aStream.
	The labelArray provides the identifer for Degrees, Minutes and Seconds"

	| absNumber degrees minutes seconds |

	absNumber := aNumber abs.
	degrees := absNumber truncated.
	minutes := ((absNumber - degrees) * 60) truncated.
	seconds := ((absNumber - degrees - (minutes / 60)) * 3600) roundTo: 0.01.
	aStream 
		print: degrees;
		<< labelArray first;
		print: minutes;
		<< labelArray second;
		<< (seconds asFloat printShowingDecimalPlaces: 2);
		<< labelArray third.
]

{ #category : #printing }
GSCoordinates class >> dms: aNumber to: aStream [
	"Write the supplied number (latitude or longitude) as Degrees Minutes Seconds on aStream.
	The labelArray provides the identifer for Degrees, Minutes and Seconds"

	^self dms: aNumber labels: #('° ' '′ ' '″') to: aStream
]

{ #category : #'class initialization' }
GSCoordinates class >> initialize [ 
	<script>

	EarthRadius := 6378137. "metres"
]

{ #category : #'instance creation' }
GSCoordinates class >> latitude: latitude longitude: longitude [

	^self new
		latitude: latitude;
		longitude: longitude;
		yourself
]

{ #category : #comparing }
GSCoordinates >> = anObject [
	"Answer whether the receiver and anObject represent the same object."

	self == anObject
		ifTrue: [ ^ true ].
	self class = anObject class
		ifFalse: [ ^ false ].
	^ longitude = anObject longitude
		and: [ latitude = anObject latitude ]
]

{ #category : #converting }
GSCoordinates >> asDegreesMinutesSeconds [
	"Answer the receiver in DMS string format"

	^String streamContents: [ :stream |
		self class dms: latitude to: stream.
		stream << (latitude >= 0
			ifTrue: [ ' N, ' ]
			ifFalse: [ ' S, ' ]).
		self class dms: longitude to: stream.
		stream << (longitude >= 0
			ifTrue: [ ' E' ]
			ifFalse: [ ' W' ]) ]
]

{ #category : #converting }
GSCoordinates >> asPoint [
	"Answer the receiver in point format"

	^longitude @ latitude
]

{ #category : #operations }
GSCoordinates >> destinationBearing: bearingInDegrees distance: distanceInMeters [
	"Answer the coordinates of a point distanceInMeters away in bearingInDegrees direction"
	| latitude2 longitude2 angularDistance |

	angularDistance := distanceInMeters / EarthRadius.
	latitude2 := (latitude degreeSin * angularDistance cos +
		(latitude degreeCos * angularDistance sin * bearingInDegrees degreeCos)) arcSin radiansToDegrees.
	longitude2 := longitude + 
		((bearingInDegrees degreeSin * angularDistance sin * latitude degreeCos) arcTan2: 
			(angularDistance cos - (latitude degreeSin * latitude2 degreeSin))) radiansToDegrees.
	^ self class latitude: latitude2 longitude: longitude2
]

{ #category : #operations }
GSCoordinates >> distanceTo: aCoordinate [
	"Answer the distance to aCoordinate (on Earth) using the default method, currently haversine"

	^self haversineDistanceTo: aCoordinate
]

{ #category : #operations }
GSCoordinates >> distanceTo: aCoordinate isLessThan: meters [
	"Answer a boolean indicating whether the distance between the receiver and aCoordinate is less than meters, using the harversine formula on Earth (as a sphere)"

	"Haversine distance is relatively expensive, for coordinates that are far enough apart we can use simple difference in latitude or longitude.
	deg / meter stays constant for latitude, approx. 111000 m/deg.  Double it for safety.
	Longitude gets smaller away from the equator.  For latitudes less than 60 deg longitudes are at least 55000 m/deg"
	^((aCoordinate y - self y) abs > (meters / 55500.0) or: 
		[ (self y abs < 60 and: [ (aCoordinate x - self x) abs > (meters / 27500.0) ])]) 
		ifTrue: [ false ]
		ifFalse: [ (self haversineDistanceTo: aCoordinate) < meters ]
]

{ #category : #ui }
GSCoordinates >> gtMapFor: aView [
	"Display a single tile map around the image location"
	<gtView>

	^ aView explicit
		title: 'OSM Map';
		priority: 30;
		stencil: [ self osmMapElement ];
		actionButtonLabel: 'Copy URL' action:
			[ Clipboard default clipboardText: 
				(self openStreetMapUrl: 17) ].
]

{ #category : #inspecting }
GSCoordinates >> gtSummaryFor: aView [
	<gtView>

	^aView textEditor 
		title: 'Summary';
		priority: 10;
		text: [ self summaryString asRopedText ]
]

{ #category : #comparing }
GSCoordinates >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ longitude hash bitXor: latitude hash
]

{ #category : #operations }
GSCoordinates >> haversineDistanceTo: aCoordinate [
	"Answer the distance between the receiver and aCoordinate on the earth in metres, using the Haversine formula.
	This assumes the earth is a perfect sphere and is the shortest distance between the two points, also known as the great-circle distance, or distance as the crow flies"

	^self haversineDistanceTo: aCoordinate radius: EarthRadius
]

{ #category : #operations }
GSCoordinates >> haversineDistanceTo: aCoordinate radius: radius [
	"Answer the distance between the receiver and aCoordinate on a sphere of radius meters using the Haversine formula.
	This is the shortest distance between the two points"
	"Based on code at http://www.movable-type.co.uk/scripts/latlong.html"

	| phi1 phi2 deltaPhi deltaLambda a c |

	phi1 := self y degreesToRadians.
	phi2 := aCoordinate y degreesToRadians.
	deltaPhi := (aCoordinate y - self y) degreesToRadians.
	deltaLambda := (aCoordinate x - self x) degreesToRadians.

	a := ((deltaPhi / 2) sin ** 2) +
			(phi1 cos * phi2 cos *
			((deltaLambda / 2) sin ** 2)).
	c := 2 * (a sqrt arcTan2: (1 - a) sqrt).
	^c * radius.

]

{ #category : #accessing }
GSCoordinates >> latitude [
	^ latitude
]

{ #category : #accessing }
GSCoordinates >> latitude: aNumber [

	(aNumber between: -90 and: 90) ifFalse: 
		[ self error: 'latitude must be between -90 and 90' ].
	latitude := aNumber
]

{ #category : #converting }
GSCoordinates >> latitudeAsDegreesMinutesSeconds [
	"Answer the receiver's latitude in DMS string format"

	^ String streamContents: [ :stream |
		self class dms: latitude to: stream.
		stream << (latitude >= 0
			ifTrue: [ ' N, ' ]
			ifFalse: [ ' S, ' ]) ]
]

{ #category : #accessing }
GSCoordinates >> longitude [
	^ longitude
]

{ #category : #accessing }
GSCoordinates >> longitude: aNumber [

	(aNumber between: -180 and: 180) ifFalse:
		[ self error: 'longitude must be between -180 and 180' ].
	longitude := aNumber
]

{ #category : #converting }
GSCoordinates >> longitudeAsDegreesMinutesSeconds [
	"Answer the receiver's latitude in DMS string format"

	^ String streamContents: [ :stream |
		self class dms: longitude to: stream.
		stream << (longitude >= 0
			ifTrue: [ ' E ' ]
			ifFalse: [ ' W ' ]) ]
]

{ #category : #displaying }
GSCoordinates >> openStreetMap [
	"Open the default browser with OpenStreetMap at the receiver's coordinates and default zoom"

	^self openStreetMap: 17
]

{ #category : #displaying }
GSCoordinates >> openStreetMap: zoom [
	"Open the default browser with OpenStreetMap at the receiver's coordinates and specified zoom"

	| url |

	url := String streamContents: [ :stream |
		stream
			<< 'https://www.openstreetmap.org#map=';
			print: zoom asInteger;
			nextPut: $/;
			print: latitude asFloat;
			nextPut: $/;
			print: longitude asFloat ].
	WebBrowser openOn: url
]

{ #category : #displaying }
GSCoordinates >> openStreetMapUrl: zoom [
	"Answer the OpenStreetMap URL for the receiver at the specified zoom"

	^ String streamContents: [ :stream |
		stream
			<< 'https://www.openstreetmap.org#map=';
			print: zoom asInteger;
			nextPut: $/;
			print: latitude asFloat;
			nextPut: $/;
			print: longitude asFloat ]
]

{ #category : #ui }
GSCoordinates >> osmMapElement [
	| map |

	map := GtOsmMap new
		includeCoordinate: self;
		zoom: 12;
		addChildren.
	self osmMarker addToMap: map.
	^ map asScalableElement.
]

{ #category : #ui }
GSCoordinates >> osmMarker [
	^ GtOsmMarker new coordinate: self
]

{ #category : #printing }
GSCoordinates >> printOn: aStream [

	aStream
		<< 'GSCoordinates(';
		print: latitude;
		<< ', ';
		print: longitude;
		<< ')'
]

{ #category : #printing }
GSCoordinates >> summaryOn: aStream [

	aStream
		<< 'Decimal: ';
			print: latitude;
			<< ', ';
			print: longitude; cr;
		<< 'DMS:     ';
			<< self asDegreesMinutesSeconds; cr;
		<< 'URL:     ';
			<< (self openStreetMapUrl: 17); cr.
]

{ #category : #accessing }
GSCoordinates >> summaryString [

	^String streamContents: [ :stream | self summaryOn: stream ]
]

{ #category : #accessing }
GSCoordinates >> x [
	"Answer the receivers longitude.
	This is a convenience method allowing Points to be used directly in calculations"

	^longitude
]

{ #category : #accessing }
GSCoordinates >> y [
	"Answer the receivers latitude.
	This is a convenience method allowing Points to be used directly in calculations"

	^latitude
]
