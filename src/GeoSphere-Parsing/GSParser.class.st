"
Attempt to parse the supplied string

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.


    Implementation Points
"
Class {
	#name : #GSParser,
	#superclass : #Object,
	#classVars : [
		'DecimalRE',
		'DmRE',
		'DmsRE',
		'OsmRE',
		'PointRE'
	],
	#category : #'GeoSphere-Parsing'
}

{ #category : #private }
GSParser class >> decimalFromDegrees: degrees minutes: minutes seconds: seconds direction: direction [

	| char decimal |

	(direction isEmpty and: [ degrees + minutes + seconds = 0 ]) ifTrue: [ ^nil ].
	char := direction
		ifEmpty: [ "positive" $N ]
		ifNotEmpty: [ direction first asUppercase ].
	decimal := (char = $N or: [ char = $E ]) ifTrue: 
		[ 1 ]
	ifFalse: [ (char = $S or: [ char = $W ]) ifTrue:
		[ -1 ]
	ifFalse:
		[ self error: 'invalid direction' ] ].
	^decimal * (degrees + (minutes / 60) + (seconds / 3600))
]

{ #category : #'class initialization' }
GSParser class >> initialize [ 
	<script>
	| number coordinate decimalMinuteCoordinate |

	number := '\s*([-+]?[0-9]*\.?[0-9]+)\s*'.
	PointRE := (number, '@', number) asRegex.
	coordinate := '\s*(\d\d?\d?)\s?(deg|°)\s?(\d\d?)[''′]\s?(\d\d?\.?\d?\d?)["″]\s?([news]?)\s*'.
	DmsRE := (coordinate, ',', coordinate) asRegexIgnoringCase.
	decimalMinuteCoordinate := '\s*(\d\d?\d?)\s?(deg|°)\s?(\d\d?\.?\d?\d?\d?)[''′]\s?([news]?)\s*'.
	DmRE := (decimalMinuteCoordinate, ',', decimalMinuteCoordinate) asRegexIgnoringCase.
	OsmRE := ('http.+openstreetmap\.org.+#map=\d\d?/', number, '/', number) asRegexIgnoringCase.
	DecimalRE := '(\d\d?\d?.\d+)\s+(\d\d?\d?.\d+)' asRegex.
]

{ #category : #public }
GSParser class >> parseCoordinates: aString [
	"Attempt to parse the supplied coordinates, accepting any known format (see class comments)"

	(self parsePoint: aString) ifNotNil: [ :coordinates | ^coordinates ].
	(self parseDecimal: aString) ifNotNil: [ :coordinates | ^coordinates ].
	(self parseDMS: aString) ifNotNil: [ :coordinates | ^coordinates ].
	(self parseOpenStreetMap: aString) ifNotNil: [ :coordinates | ^coordinates ].
	^nil
]

{ #category : #public }
GSParser class >> parseDM: aString [
	"Parse the supplied coordinates assuming long , lat point format"

	| latitude longitude |

	^(DmRE matches: aString) ifTrue: 
		[ latitude := self decimalFromDegrees: (DmRE subexpression: 2) asNumber
								minutes: (DmRE subexpression: 4) asNumber
								seconds: 0
								direction: (DmRE subexpression: 5).
		longitude := self decimalFromDegrees: (DmRE subexpression: 6) asNumber
								minutes: (DmRE subexpression: 8) asNumber
								seconds: 0
								direction: (DmRE subexpression: 9).
		(latitude isNil and: [ longitude isNil ])
			ifTrue: [ ^nil ].
		GSCoordinates 
						latitude: latitude
						longitude: longitude ]
	ifFalse: 
		[ nil ]
]

{ #category : #public }
GSParser class >> parseDMS: aString [
	"Parse the supplied coordinates assuming long @ lat point format"

	| latitude longitude |

	^(DmsRE matches: aString) ifTrue: 
		[ latitude := self decimalFromDegrees: (DmsRE subexpression: 2) asNumber
								minutes: (DmsRE subexpression: 4) asNumber
								seconds: (DmsRE subexpression: 5) asNumber
								direction: (DmsRE subexpression: 6).
		longitude := self decimalFromDegrees: (DmsRE subexpression: 7) asNumber
								minutes: (DmsRE subexpression: 9) asNumber
								seconds: (DmsRE subexpression: 10) asNumber
								direction: (DmsRE subexpression: 11).
		(latitude isNil and: [ longitude isNil ])
			ifTrue: [ ^nil ].
		GSCoordinates 
						latitude: latitude
						longitude: longitude ]
	ifFalse: 
		[ nil ]
]

{ #category : #public }
GSParser class >> parseDecimal: aString [
	"Parse the supplied coordinates assuming decimal 'lat long' format"

	^(DecimalRE matches: aString) 
		ifTrue: [ GSCoordinates 
						latitude: (DecimalRE subexpression: 2) asNumber
						longitude: (DecimalRE subexpression: 3) asNumber ]
		ifFalse: [ nil ]
]

{ #category : #parsing }
GSParser class >> parseOpenStreetMap: aString [

	^(OsmRE matches: aString) ifTrue: 
		[ GSCoordinates 
			latitude: (OsmRE subexpression: 2) asNumber
			longitude: (OsmRE subexpression: 3) asNumber ]
	ifFalse:
		[ nil ]
]

{ #category : #public }
GSParser class >> parsePoint: aString [
	"Parse the supplied coordinates assuming long @ lat point format"

	^(PointRE matches: aString) 
		ifTrue: [ GSCoordinates 
						latitude: (PointRE subexpression: 3) asNumber
						longitude: (PointRE subexpression: 2) asNumber ]
		ifFalse: [ nil ]
]
