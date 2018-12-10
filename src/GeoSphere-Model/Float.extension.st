Extension { #name : #Float }

{ #category : #'*GeoSphere-Model' }
Float >> arcTan2: x [
	"Answer the angle in the Euclidean plane, in radians, of the point x,y, where y is the receiver"

	^x > 0 ifTrue:
		[ (self / x) arcTan ]
	ifFalse: [ x < 0 ifTrue:
		[ self >= 0 ifTrue:
			[ (self / x) arcTan + Pi ]
		ifFalse:
			[ (self / x) arcTan - Pi ] ]
	ifFalse: "x = 0"
		[ self > 0 ifTrue:
			[ Halfpi ]
		ifFalse: [ self < 0 ifTrue:
			[ 0 - Halfpi ]
		ifFalse:
			[ NaN ] ] ] ]
]
