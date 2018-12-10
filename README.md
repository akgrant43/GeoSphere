# GeoSphere
Compute distances, parse coordinates, etc. for Pharo

Currently GeoSphere:

- Parses string coordinates
- Calculates the distance between coordinates
- Opens OpenStreetMap at the receiver's coordinates

Examples of string formats that can be parsed:

* 144.61025 @ -38.28697
* 38° 17′ 13.09″ S, 144° 36′ 36.9″ E
* 38 deg 17' 13.09" S, 144 deg 36' 36.9" E
* https://www.openstreetmap.org/#map=18/-38.28697/144.61025


### Installing

GeoSphere can be installed in Pharo 7 or later with

```smalltalk
Metacello new
	repository: 'github://akgrant43/GeoSphere/src';
	baseline: 'GeoSphere';
	load
```


### Acknowledgements

Many thanks to:

* Sven Van Caekenberghe
* Benoît St-Jean
* Richard O'Keefe
* Pierce Ng

for their suggestions and input.  Any bugs are, of course, mine.
