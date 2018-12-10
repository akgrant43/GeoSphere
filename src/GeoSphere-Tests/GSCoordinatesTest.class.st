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
GSCoordinatesTest >> testDistanceToIsLessThan [

	self assert: ((144.61416 @ -38.27312) asGSCoordinates 
		distanceTo: (144.6161@ -38.274) isLessThan: 200).

	"This is more than 200 meters, but within the fast comparison"
	self deny: ((144.61416 @ -38.27312) asGSCoordinates 
		distanceTo: (144.6162@ -38.274) isLessThan: 200).

	"This is much more than 200 meters, should be false on fast comparison"
	self deny: ((144.61416 @ -38.27312) asGSCoordinates 
		distanceTo: (145 @ -38.274) isLessThan: 200).

]

{ #category : #tests }
GSCoordinatesTest >> testDmsOnFromLabels [

	| dms |

	dms := String streamContents: [ :stream |
		GSCoordinates dms: 50.5 labels: #('° ' '′ ' '″') to: stream ].
	self assert: dms equals: '50° 30′ 0.0″'
]

{ #category : #tests }
GSCoordinatesTest >> testHaversineDistanceTo [

	self
		assert: ((13.80351 @ 50.35158) asGSCoordinates haversineDistanceTo: 
			(13.8044 @ 50.3523))
		closeTo: 102.08.

	self
		assert: ((144.61437 @ -38.27304) asGSCoordinates haversineDistanceTo: 
			(144.62024 @ -38.2759))
		closeTo: 603.75.

]
