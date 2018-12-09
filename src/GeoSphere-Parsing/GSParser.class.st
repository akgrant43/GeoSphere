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
		'DmsRE',
		'PointRE'
	],
	#category : #'GeoSphere-Parsing'
}

{ #category : #private }
GSParser class >> decimalFromDegrees: degrees minutes: minutes seconds: seconds direction: direction [

	| char decimal |

	char := direction first asUppercase.
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

	| coordinate |

	PointRE := '\s*([-+]?[0-9]*\.?[0-9]+)\s*@\s*([-+]?[0-9]*\.?[0-9]+)\s*' asRegex.
	coordinate := '\s*(\d\d?\d?)\s?(deg|°)\s?(\d\d?)[''′]\s?(\d\d?\.?\d?\d?)["″]\s?([news]?)\s*'.
	DmsRE := (coordinate, ',', coordinate) asRegexIgnoringCase.
]

{ #category : #public }
GSParser class >> parseCoordinates: aString [
	"Attempt to parse the supplied coordinates, accepting any known format (see class comments)"

	(self parsePoint: aString) ifNotNil: [ :coordinates | ^coordinates ].
	(self parseDMS: aString) ifNotNil: [ :coordinates | ^coordinates ].
	^nil
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
		GSCoordinates 
						latitude: latitude
						longitude: longitude ]
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
