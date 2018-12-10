Class {
	#name : #BaselineOfGeoSphere,
	#superclass : #BaselineOf,
	#category : #BaselineOfGeoSphere
}

{ #category : #baselines }
BaselineOfGeoSphere >> baseline: spec [
	<baseline>

	| packages |

	spec for: #common do: [ 
		spec blessing: #baseline.
		packages := #('GeoSphere-Model' 'GeoSphere-Parsing').
		packages do: [ :package |
			spec package: package ].
		spec
			package: #('GeoSphere-Tests');
			group: 'Core' with: packages;
			group: 'Tests' with: #('GeoSphere-Tests');
			group: 'all' with: #(Core Tests);
			group: 'default' with: #(Core Tests) ]
]
