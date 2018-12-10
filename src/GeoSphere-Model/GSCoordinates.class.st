"
GSCoordinates represents a latitude / longitude location on a globe in degrees. 

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	latitude:		<Object>
	longitude:		<Object>


    Implementation Points
"
Class {
	#name : #GSCoordinates,
	#superclass : #Object,
	#instVars : [
		'latitude',
		'longitude'
	],
	#category : #'GeoSphere-Model'
}

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
GSCoordinates >> asPoint [
	"Answer the receiver in point format"

	^longitude @ latitude
]

{ #category : #comparing }
GSCoordinates >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ longitude hash bitXor: latitude hash
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
			print: latitude;
			nextPut: $/;
			print: longitude ].
	WebBrowser openOn: url
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
