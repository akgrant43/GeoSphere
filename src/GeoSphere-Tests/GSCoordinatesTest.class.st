Class {
	#name : #GSCoordinatesTest,
	#superclass : #TestCase,
	#category : #'GeoSphere-Tests'
}

{ #category : #tests }
GSCoordinatesTest >> testArcTan2 [

	self assert: (0 arcTan2: 0) isNaN.

	self 
		assert: (1 arcTan2: 0)
		equals: Float halfPi.

	self 
		assert: (-1 arcTan2: 0)
		equals: 0 - Float halfPi.

	self
		assert: (1 arcTan2: 1) 
		equals: (1 arcTan: 1).

	self
		assert: (1 arcTan2: -1) 
		closeTo: 2.356194490192345.

	self
		assert: (-1 arcTan2: -1) 
		closeTo: -2.356194490192345.

	self
		assert: (-1 arcTan2: 1) 
		closeTo: -0.7853981633974483.

]

{ #category : #tests }
GSCoordinatesTest >> testDmsOnFromLabels [

	| dms |

	dms := String streamContents: [ :stream |
		GSCoordinates dms: 50.5 labels: #('° ' '′ ' '″') to: stream ].
	self assert: dms equals: '50° 30′ 0.0″'
]
