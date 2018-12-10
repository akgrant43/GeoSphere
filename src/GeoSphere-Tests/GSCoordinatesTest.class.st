Class {
	#name : #GSCoordinatesTest,
	#superclass : #TestCase,
	#category : #'GeoSphere-Tests'
}

{ #category : #tests }
GSCoordinatesTest >> testDmsOnFromLabels [

	| dms |

	dms := String streamContents: [ :stream |
		GSCoordinates dms: 50.5 labels: #('° ' '′ ' '″') to: stream ].
	self assert: dms equals: '50° 30′ 0.0″'
]
