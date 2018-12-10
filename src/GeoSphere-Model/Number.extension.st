Extension { #name : #Number }

{ #category : #'*GeoSphere-Model' }
Number >> arcTan2: x [
	"Answer the angle in the Euclidean plane, in radians, of the point x, y, where y is the receiver"

	^self asFloat arcTan2: x
]
