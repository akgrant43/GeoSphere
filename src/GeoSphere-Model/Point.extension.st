Extension { #name : #Point }

{ #category : #'*GeoSphere-Model' }
Point >> asGSCoordinates [
	"Answer the receiver as GSCoordinates"

	^GSCoordinates 
		latitude: self y
		longitude: self x
]
