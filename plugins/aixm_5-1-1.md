# Plugin aixm_5-1-1

Target model: AIXM 5.1.1 (http://www.aixm.aero/page/aixm-511-specification)

## Basics

## Mapping of stereotype: feature

Features are mapped to SHACL shapes and RDFS classes with a single property named "timeSlice".
Timeslices of features are mapped to SHACL shapes and RDFS classes. A timeslice keeps meta information (from aixm:AIXMTimeSlice) and a feature's attributes and relationships valid for a certain time period. 

Example AirportHeliport
	
	aixm:AirportHeliport
		a sh:NodeShape, rdfs:Class ;
		sh:and (aixm:AIXMFeature) ;
		sh:property [ 
			sh:path aixm:timeSlice ;
			sh:class aixm:AirportHeliportTimeSlice ;
		] .
	aixm:AirportHeliportTimeSlice
		a sh:NodeShape, rdfs:Class
		sh:and (aixm:AIXMTimeSlice) ;
		sh:property [
			sh:path aixm:name ;
			sh:node aixm:TextNameType ;
			sh:minCount 0 ;
			sh:maxCount 1 ;
		] ...
		
TBD.

## Mapping of stereotype: object

TBD.

## Mapping of stereotype: choice

TBD.

## Mapping of stereotype: CodeList

TBD.

## Mapping of stereotype: DataType

TBD.

## Mapping of stereotype: XSDsimpleType

No mapping.

## Mapping of stereotype: XSDcomplexType

No mapping.

## Mapping of stereotype: none

TBD.
