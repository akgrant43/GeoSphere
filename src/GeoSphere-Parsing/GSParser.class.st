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
		'DmsAngleRE',
		'DmsCoordinateRE',
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
	coordinate := '\s*(\d\d?\d?)\s?(deg|°)\s?(\d\d?)[''′]\s?(\d\d?\.?\d?\d?\d?)["″]\s?([news]?)\s*'.
	DmsCoordinateRE := coordinate asRegexIgnoringCase.
	DmsRE := (coordinate, ',', coordinate) asRegexIgnoringCase.
	decimalMinuteCoordinate := '\s*(\d\d?\d?)\s?(deg|°)\s?(\d\d?\.?\d?\d?\d?)[''′]\s?([news]?)\s*'.
	DmRE := (decimalMinuteCoordinate, ',', decimalMinuteCoordinate) asRegexIgnoringCase.
	OsmRE := ('http.+openstreetmap\.org.+#map=\d\d?/', number, '/', number) asRegexIgnoringCase.
	DecimalRE := '(\d\d?\d?.\d+)\s+(\d\d?\d?.\d+)' asRegex.
	DmsAngleRE := '(\d\d?\d?)\s?(deg|°)\s?(\d\d?)[''′]\s?(\d\d?\.?\d?\d?)["″]' asRegexIgnoringCase.
]

{ #category : #public }
GSParser class >> parseCoordinates: aString [
	"Attempt to parse the supplied coordinates, accepting any known format (see class comments)"

	(self parsePoint: aString) ifNotNil: [ :coordinates | ^coordinates ].
	(self parseDecimal: aString) ifNotNil: [ :coordinates | ^coordinates ].
	(self parseDms: aString) ifNotNil: [ :coordinates | ^coordinates ].
	(self parseOpenStreetMap: aString) ifNotNil: [ :coordinates | ^coordinates ].
	^nil
]

{ #category : #public }
GSParser class >> parseDecimal: aString [
	"Parse the supplied coordinates assuming decimal 'lat long' format"
	| re |

	re := DecimalRE copy.
	^ (re matches: aString) 
		ifTrue: [ GSCoordinates 
						latitude: (re subexpression: 2) asNumber
						longitude: (re subexpression: 3) asNumber ]
		ifFalse: [ nil ]
]

{ #category : #public }
GSParser class >> parseDm: aString [
	"Parse the supplied coordinates assuming long , lat point format"
	| re latitude longitude |

	re := DmRE copy.
	^(re matches: aString) ifTrue: 
		[ latitude := self decimalFromDegrees: (re subexpression: 2) asNumber
								minutes: (re subexpression: 4) asNumber
								seconds: 0
								direction: (re subexpression: 5).
		longitude := self decimalFromDegrees: (re subexpression: 6) asNumber
								minutes: (re subexpression: 8) asNumber
								seconds: 0
								direction: (re subexpression: 9).
		(latitude isNil and: [ longitude isNil ])
			ifTrue: [ ^nil ].
		GSCoordinates 
						latitude: latitude
						longitude: longitude ]
	ifFalse: 
		[ nil ]
]

{ #category : #public }
GSParser class >> parseDms: aString [
	"Parse the supplied coordinates assuming long @ lat point format"

	| re latitude longitude |

	re := DmsRE  copy.
	^(re matches: aString) ifTrue: 
		[ latitude := self decimalFromDegrees: (re subexpression: 2) asNumber
								minutes: (re subexpression: 4) asNumber
								seconds: (re subexpression: 5) asNumber
								direction: (re subexpression: 6).
		longitude := self decimalFromDegrees: (re subexpression: 7) asNumber
								minutes: (re subexpression: 9) asNumber
								seconds: (re subexpression: 10) asNumber
								direction: (re subexpression: 11).
		(latitude isNil and: [ longitude isNil ])
			ifTrue: [ ^nil ].
		GSCoordinates 
						latitude: latitude asFloat
						longitude: longitude asFloat ]
	ifFalse: 
		[ nil ]
]

{ #category : #public }
GSParser class >> parseDmsAngle: aString [
	"Parse the supplied DMS angle"
	| re angle |

	re := DmsAngleRE copy.
	^ (re matches: aString) ifTrue: 
		[ angle := self decimalFromDegrees: (re subexpression: 2) asNumber
								minutes: (re subexpression: 4) asNumber
								seconds: (re subexpression: 5) asNumber
								direction: ''.
		angle ifNil: [ ^ nil ].
		angle asFloat ]
	ifFalse: 
		[ nil ]
]

{ #category : #public }
GSParser class >> parseDmsCoordinate: aString [
	"Parse the supplied coordinate"
	| coordinate re |

	re := DmsCoordinateRE copy.
	^(re matches: aString) ifTrue: 
		[ coordinate := self decimalFromDegrees: (re subexpression: 2) asNumber
								minutes: (re subexpression: 4) asNumber
								seconds: (re subexpression: 5) asNumber
								direction: (re subexpression: 6).
		coordinate ifNil: [ ^ nil ].
		coordinate asFloat ]
	ifFalse: 
		[ nil ]
]

{ #category : #accessing }
GSParser class >> parseGeoCoordinate: aString [ 
	| rx coordinate |

	rx := 'geo\:(\d\d?\d?.\d+),(\d\d?\d?.\d+).*' asRegexIgnoringCase.
	(rx matches: aString) ifTrue:
		[ coordinate := GSCoordinates
			latitude: (rx subexpression: 2) asNumber
			longitude: (rx subexpression: 3) asNumber ].
	^ coordinate
]

{ #category : #parsing }
GSParser class >> parseOpenStreetMap: aString [
	| re |

	re := OsmRE copy.
	^(re matches: aString) ifTrue: 
		[ GSCoordinates 
			latitude: (re subexpression: 2) asNumber
			longitude: (re subexpression: 3) asNumber ]
	ifFalse:
		[ nil ]
]

{ #category : #public }
GSParser class >> parsePoint: aString [
	"Parse the supplied coordinates assuming long @ lat point format"
	| re |

	re := PointRE copy.
	^(re matches: aString) 
		ifTrue: [ GSCoordinates 
						latitude: (re subexpression: 3) asNumber
						longitude: (re subexpression: 2) asNumber ]
		ifFalse: [ nil ]
]
