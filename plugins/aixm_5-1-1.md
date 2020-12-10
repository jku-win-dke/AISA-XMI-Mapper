# Plugin aixm_5-1-1

Target model: AIXM 5.1.1 (http://www.aixm.aero/page/aixm-511-specification)

## 1. Basics

### 1.1 Mapping of attributes

TBD.

### 1.2 Mapping of connectors

TBD.

### 1.3 Mapping of connectors with association classes

TBD.

## 2. Mapping of stereotypes

### 2.1 Feature

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

### 2.2 Object

TBD.

### 2.3 Choice

TBD.

### 2.4 CodeList

TBD.

### 2.5 DataType

TBD.

### 2.6 XSDsimpleType

No mapping.

### 2.7 XSDcomplexType

No mapping.

### 2.8 No stereotype

TBD.
