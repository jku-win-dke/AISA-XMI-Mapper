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

## 2. Mapping

### 2.1. GML basic elements for AIXM features

If the selected subset of an AIXM model contains a element with stereotype "feature", the following basic elements are added to the result:

1. An empty SHACL shape named "aixm:AIXMFeature" which can be extended by general AIXM feature properties.
		
		aixm:AIXMFeature a sh:NodeShape .
2. A SHACL shape named "aixm:AIXMTimeSlice" which keeps general and mandatory attributes of feature time slices, i.e. gml:validTime, aixm:interpretation, aixm:sequenceNumber, aixm:correctionNumber.
	
		aixm:AIXMTimeSlice 
			a sh:NodeShape ;
			sh:property [ 
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:node	aixm:NoNumberType ;
				sh:path aixm:correctionNumber
			] ;
			sh:property [
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:node aixm:NoNumberType ;
				sh:path aixm:sequenceNumber
			] ;
			sh:property [ 
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:node aixm:TimeSliceInterpretationType ;
				sh:path aixm:interpretation
			] ;
			sh:property [ 
				sh:class gml:TimePeriod ;
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:path gml:validTime
			] .
3. A SHACL shape and RDFS class named "gml:TimePeriod" (type of gml:validTime) which keeps a gml:beginPosition and a gml:endPosition.

		gml:TimePeriod 
			a rdfs:Class , sh:NodeShape ;
			sh:property [ 
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:node gml:TimePrimitive ;
				sh:path gml:endPosition
			] ;
			sh:property [ 
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:node gml:TimePrimitive ;
				sh:path gml:beginPosition
			] .
4. A SHACL shape named "gml:TimePrimitive" (type of gml:beginPosition and gml:endPosition) which can have xsd:dateTime as rdf:value or can be a gml:indeterminatePosition.

		gml:TimePrimitive 
			a sh:NodeShape ;
			sh:property [ 
				sh:datatype xsd:string ;
				sh:maxCount 1 ;
				sh:path gml:indeterminatePosition
			] ;
			sh:property [ 
				sh:datatype xsd:dateTime ;
				sh:maxCount 1 ;
				sh:path rdf:value
			] ;
			sh:xone ( 
				[ 
					sh:property [ 
						sh:minCount 1 ;
						sh:path rdf:value
					]
				]
				[ 
					sh:property [ 
						sh:minCount 1 ;
						sh:path gml:indeterminatePosition
					] 
				]
			) .
5. A SHACL shape named "aixm:TimeSliceInterpretationType" (type of aixm:interpretation) which can have the rdf:value "BASELINE" or "TEMPDELTA".

		aixm:TimeSliceInterpretationType 
			a sh:NodeShape ;
			sh:property [ 
				sh:in ( "BASELINE" "TEMPDELTA" ) ;
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:path rdf:value
			] .
6. A SHACL shape named "aixm:NoNumberType" (type of aixm:sequenceNumber and aixm:correctionNumber) which has an xsd:integer as rdf:value.

		aixm:NoNumberType 
			a sh:NodeShape ;
			sh:property [ 
				sh:datatype xsd:integer ;
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:path rdf:value
			] .

These basic elements are not part of the AIXM 5.1.1 XMI file and therefore are generated manually. Other GML constructs like gml:pos inherited through gml:Point are also not part of the AIXM 5.1.1 XMI file and not considered. The generated AIXM SHACL shapes could basically be combined with GML SHACL shapes for a complete validation of AIXM.

### 2.2. Basic methods of mapping

For mapping of different stereotypes, the following basic methods are used (but there are exceptions):
1. Attributes of a UML class are mapped into optional property shapes with the AIXM datatype being a target node. Example attribute name of AirportHeliport:

		aixm:AirportHeliportTimeSlice
			sh:property [
				sh:path aixm:name ;
				sh:node aixm:TextNameType ;
				sh:minCount 0 ;
				sh:maxCount 1 ;
			] .
2. Connections to other UML classes are mapped into property shapes with the sh:minCount and sh:maxCount representing the cardinality of the relationship. In contrast to mapping of attributes, the target of connections are classes and not nodes. If a role name is provided, this name is used for the sh:path. Otherwise, the sh:path name is combined of "the" + target class name. There is an exception of mapping connections: association classes. If an association class for a connection exists, the property of the UML class targets the association class and not the initial target class. Furthermore, the association class has a property added for the connection to the target class of the connection. Example of a normal connection to the class City and a connection with an association class to OrganisationAuthority of AirportHeliport:

		aixm:AirportHeliportTimeSlice
			sh:property [ 
				sh:class aixm:City ;
				sh:minCount 0 ;
				sh:path aixm:servedCity
			] ;
			sh:property  [ 
				sh:class aixm:AirportHeliportResponsibilityOrganisation ;
				sh:maxCount 1 ;
				sh:minCount 0 ;
				sh:path aixm:responsibleOrganisation
			] .
3. A UML class can be an association class for a connection between to other classes. As already explained in 2., a property shape is added to an association class targeting the target class of the association. Example of connection between AirportHeliport and OrganisationAuthority with AirportHeliportResponsibilityOrganisation as assocation class:
		
		aixm:AirportHeliportResponsibilityOrganisation
			sh:property [
				sh:class aixm:OrganisationAuthority ;
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:path aixm:theOrganisationAuthority
                         ] .

### 2.3. Stereotypes

#### 2.3.1. Feature

For each UML class with stereotype "feature" two SHACL shapes and RDFS classes are generated:

1. A SHACL shape and RDFS class extending the aixm:AIXMFeature shape and with the single property aixm:timeSlice. Example AirportHeliport:
	
		aixm:AirportHeliport
			a rdfs:Class , sh:NodeShape ;
			sh:and ( aixm:AIXMFeature ) ;
			sh:property [ 
				sh:path aixm:timeSlice ;
				sh:class aixm:AirportHeliportTimeSlice ;
			] .
2. A SHACL shape and RDFS class extending the aixm:AIXMTimeSlice shape and with attributes as well as connections of the corresponding feature. The three basic methods above are used for mapping attributes and connections of a feature. The time slice is named like the UML class with the phrase "TimeSlice" added at the end. Example AirportHeliportTimeSlice for AirportHeliport:

		aixm:AirportHeliportTimeSlice
			a rdfs:Class , sh:NodeShape ;
			sh:and ( aixm:AIXMTimeSlice ) ;
			sh:property [
				sh:path aixm:name ;
				sh:node aixm:TextNameType ;
				sh:minCount 0 ;
				sh:maxCount 1 ;
			] ...

#### 2.3.2. Object

For each UML class with stereotype "object" a SHACL shape and RDFS class is generated. In addition to the use of the three basic mapping methods, generalizations need to mapped. For each super class, a RDFS subClassOf and SHACL and statement are added. Example AirportHeliportUsage:

	aixm:AirportHeliportUsage
		a rdfs:Class , sh:NodeShape ;
		rdfs:subClassOf aixm:UsageCondition ;
		sh:and ( aixm:UsageCondition ) ;
		sh:property [ 
			sh:maxCount 1 ;
			sh:minCount 0 ;
			sh:node aixm:CodeOperationAirportHeliportType ;
			sh:path aixm:operation
		] .

#### 2.3.3. Choice

For each UML class with stereotype "choice" a SHACL shape is generated. The basic methods 1 and 2 are used for mapping attributes and connections. In addition, a SHACL exactly one (sh:xone) statement is added for each connection property, because the choice represents a link between a class and some other classes. Example SignificantPoint (if only DesignatedPoint and AirportHeliport are selected):

	aixm:SignificantPoint
		a sh:NodeShape ;
		sh:property [ 
			sh:class aixm:DesignatedPoint ;
			sh:maxCount 1 ;
			sh:minCount 0 ;
			sh:path aixm:fixDesignatedPoint
		] ;
		sh:property [ 
			sh:class aixm:AirportHeliport ;
			sh:maxCount 1 ;
			sh:minCount 0 ;
			sh:path aixm:airportReferencePoint
		] ;
		sh:xone (
			[ 
				sh:property [ 
					sh:minCount 1 ;
                                        sh:path aixm:airportReferencePoint
				]
			]
			[ 
				sh:property [ 
					sh:minCount 1 ;
				        sh:path aixm:fixDesignatedPoint
				] 
			]
		) .

#### 2.3.4. CodeList

For each UML class with stereotype "CodeList" a SHACL shape is generated. Its attributes are allowed values and therefore mapped into a SHACL list. If a super class with stereotype "XSDsimpleType" exists, a SHACL datatype statement is added. Example NilReasonEnumeration and UomDistanceVerticalType:

	aixm:NilReasonEnumeration
		a sh:NodeShape ;
		sh:datatype xsd:string ;
		sh:in ( "inapplicable" "missing" "template" "unknown" "withheld" "other" ) .
	
	aixm:UomDistanceVerticalType
		a sh:NodeShape ;
		sh:datatype  xsd:string ;
		sh:in ( "FT" "M" "FL" "SM" "OTHER" ) .

#### 2.3.5. DataType

For each UML class with stereotype "DataType" a SHACL shape is generated. For each super class with stereotype "DataType", a SHACL and statement is added. In addition, a property shape with SHACL path rdf:value is always added. If an attribute with stereotype "XSDfacet" exists, it is added as constraint for the property shape of rdf:value. If a super class with stereotype "XSDsimpleType" exists, a SHACL datatype constraint is added for the property shape of rdf:value. If a super class with stereotype "CodeList" exists, a SHACL target node statement is added for the property shape of rdf:value. All other attributes (stereotype not "XSDfacet") are added with the basic mapping method number 1. If an attribute from type "NilReasonEnumeration" exists, a SHACL exactly one (sh:xone) statement needs to be added, specifiyng that either a nil reason can occur or all other attributes and rdf:value. Example ValDistanceVerticalType:

	aixm:ValDistanceVerticalType
		a sh:NodeShape ;
		sh:and ( aixm:ValDistanceVerticalBaseType ) ;
		sh:property [ 
			sh:maxCount 1 ;
			sh:minCount 0 ;
			sh:node aixm:NilReasonEnumeration ;
			sh:path aixm:nilReason
		] ;
		sh:property [ 
			sh:maxCount 1 ;
			sh:minCount 0 ;
			sh:node aixm:UomDistanceVerticalType ;
			sh:path aixm:uom
		] ;
		sh:property [ 
			sh:maxCount 1 ;
			sh:path rdf:value
		] ;
		sh:xone (
			[ 
				sh:property [ 
					sh:minCount 1 ;
					sh:path rdf:value
				] ;
				sh:property [
					sh:minCount 0 ;
					sh:path aixm:uom
				] 
			]
			[ 
				sh:property [ 
					sh:minCount 1 ;
					sh:path aixm:nilReason
				] 
			]
		) .
	
	aixm:ValDistanceVerticalBaseType
		a sh:NodeShape ;
		sh:property [ 
			sh:datatype xsd:string ;
			sh:maxCount 1 ;
			sh:path rdf:value ;
			sh:pattern "((\\+|\\-){0,1}[0-9]{1,8}(\\.[0-9]{1,4}){0,1})|UNL|GND|FLOOR|CEILING"
		] .

#### 2.3.6. XSDsimpleType

No mapping.

#### 2.3.7. XSDcomplexType

No mapping.

### 2.3.8. No stereotype

For each UML class with no stereotype a RDFS class and a simple SHACL shape with no content are generated. Typically, only GML based classes have no stereotype. UML classes from GML are classes with names starting with "GM_".  These GML based classes are mapped into the GML namespace.

	gml:Point a rdfs:Class , sh:NodeShape .
