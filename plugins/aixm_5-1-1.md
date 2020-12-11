# Plugin aixm_5-1-1

Target model: AIXM 5.1.1 (http://www.aixm.aero/page/aixm-511-specification)

## 1. Configuration File

In the configuration file only UML classes from the AIXM namespace can be selected. If you are not sure, check the AIXM 5.1.1 UML navigator (http://www.aixm.aero/sites/aixm.aero/files/imce/AIXM511HTML/index.html). 
See the decisions for the configuration (../input/configuration4donlon.xml) of the Donlon airport example (../\_example data/donlon airport.ttl) below.

	Donlon airport									decisions for configuration file
	<uuid:dd062d88-3e64-4a5d-bebd-89476db9ebea> a aixm:AirportHeliport; 	-->	<class>AirportHeliport</class>
	s1:AHP_EADH a aixm:AirportHeliportTimeSlice;				-->	time slices are no UML classes
	s1:vtnull0 a gml:TimePeriod;						-->	no aixm namespace
	s1:ltnull0 a gml:TimePeriod;						-->	no aixm namespace
	s1:ID_110 a aixm:City;							-->	<class>City</class>
	s1:A-a72cfd3a a aixm:AirportHeliportResponsibilityOrganisation;		-->	<class>AirportHeliportResponsibiltyOrganisation</class>
	<uuid:74efb6ba-a52a-46c0-a16b-03860d356882> a aixm:OrganisationAuthority -->	<class>OrganisationAuthority</class>
	s1:elpoint1EADH a aixm:ElevatedPoint;					-->	<class>ElevatedPoint</class>
	s1:AHY_EADH_PERMIT a aixm:AirportHeliportAvailability;			-->	<class>AirportHeliportAvailability</class>
	s1:AHU_EADH_PERMIT a aixm:AirportHeliportUsage;				-->	<class>AirportHeliportUsage</class>
	s1:agtayyat a aixm:ConditionCombination;				-->	<class>ConditionCombination</class>
	s1:F_yastadyt a aixm:FlightCharacteristic;				-->	<class>FlightCharacteristic</class>
	s1:n002 a aixm:Note;							-->	<class>Note</class>
	s1:ln002 a aixm:LinguisticNote;						-->	<class>LinguisticNote</class>
	s1:n003 a aixm:Note;							-->	already part of the configuration file
	s1:ln003 a aixm:LinguisticNote;						--> 	already part of the configuration file
	<uuid:1d713318-a022-4f0f-808a-8eea31b3e411> a event:Event;		-->	no aixm namespace
	s2:IDE_ACT_22 a event:EventTimeSlice;					-->	no aixm namespace
	s2:IDE_ACT_23 a gml:TimePeriod;						-->	no aixm namespace
	s2:IDE_ACT_24 a gml:TimePeriod;						-->	no aixm namespace
	s2:IDE_ACT_25 a event:NOTAM;						-->	no aixm namespace
	s2:ID_ACT_11 a aixm:AirportHeliportTimeSlice;				-->	time slices are no UML classes
	s2:ID_ACT_12 a gml:TimePeriod;						-->	no aixm namespace
	s2:ID_ACT_13 a aixm:AirportHeliportAvailability;			-->	already part of the configuration file
	s2:ID_ACT_14 a aixm:AirportHeliportUsage;				-->	already part of the configuration file
	s2:ID_ACT_15 a aixm:ConditionCombination;				-->	already part of the configuration file
	s2:ID_ACT_16 a aixm:ConditionCombination;				-->	already part of the configuration file
	s2:ID_ACT_17 a aixm:FlightCharacteristic;				-->	already part of the configuration file
	s2:ID_ACT_18 a aixm:ConditionCombination;				-->	already part of the configuration file
	s2:ID_ACT_19 a aixm:FlightCharacteristic;				-->	already part of the configuration file
	s2:ID_ACT_20 a aixm:ConditionCombination;				-->	already part of the configuration file
	s2:ID_ACT_21 a aixm:FlightCharacteristic;				-->	already part of the configuration file
	s2:ID_ACT_211 a event:AirportHeliportExtension;				-->	no aixm namespace

## 2. Basics

### 2.1 Mapping of attributes

TBD.

### 2.2 Mapping of connectors

TBD.

### 2.3 Mapping of connectors with association classes

TBD.

## 3. Mapping of stereotypes

### 3.1 Feature

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

### 3.2 Object

TBD.

### 3.3 Choice

TBD.

### 3.4 CodeList

TBD.

### 3.5 DataType

TBD.

### 3.6 XSDsimpleType

No mapping.

### 3.7 XSDcomplexType

No mapping.

### 3.8 No stereotype

TBD.
