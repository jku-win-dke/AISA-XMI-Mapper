# AISA-XMI-Mapper

For feedback or issues contact: sebastian.gruber@jku.at 

## Table of content

1. [Introduction](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#1-introduction)
	1. [Semantic Requirements](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#11-semantic-requirements)
	2. [Syntactic Requirements](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#12-syntactic-requirements)
	3. [Architecture](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#13-architecture)
	4. [How to run the Mapper](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#14-how-to-run-the-mapper)
	5. [How to validate data graphs](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#15-how-to-validate-data-graphs)
	6. [Performance](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#16-performance)
2. [Configuration File](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#2-configuration-file)
	1. [Structure of the configuration file](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#21-structure-of-the-configuration-file)
	2. [How to write a configuration file](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#22-how-to-write-a-configuration-file)
3. [Mapper](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3-mapper)
	1. [mapper.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#31-mapperxq)
	2. [extractor.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#32-extractorxq)
	3. [Plugins](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#33-plugins)
		1. [utilities.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#331-utilitiesxq)
		2. [aixm_5-1-1.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#332-aixm_5-1-1xq)
			1. [GML basic classes for AIXM features](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3321-gml-basic-classes-for-aixm-features)
			2. [Basic Mapping Methods](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3322-basic-mapping-methods)
			3. [Mapping of UML classes](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3323-mapping-of-uml-classes)
		3. [fixm_3-0-1_sesar.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#333-fixm_3-0-1_sesarxq)
			1. [Mapping of UML classes](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3331-mapping-of-uml-classes)
		4. [plain.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#334-plainxq)
4. [RDFS/SHACL Document](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#4-rdfsshacl-document)

## 1. Introduction

The AISA-XMI-Mapper maps selected classes of UML diagrams to a combination of RDF Schema (RDFS) and Shape Constraint Language (SHACL). The RDFS defines the vocabulary of the domain (classes and class hierarchies) which is described by the UML class diagrams. The SHACL defines structural constraints of the domain. The mapper is created with the aim of mapping aeronautical UML models (AIXM, FIXM, ...) which adhere to a specific modelling style. Therefore, models provided to the mapper must fulfill certain semantic and syntactic requirements.

### 1.1. Semantic Requirements

1. Class names must be unique within a model (AIXM, FIXM, ...). There can be a UML class called "Route" in an AIXM based model and an FIXM based model but there must not be two different UML classes called "Route" in one model (even if they are in different packages).
2. Models must contain only directed associations because RDF is based on directed graphs.          
3. Role names (at the target) of associations with the same source class must be unique within the source class.      
4. Role names must exist, if there is more than one association between a source and a target class. If there is only one association and no role name provided, the role name is constructed using the name of the target class.

Requirement 1 is validated by the mapper and if violated, throws an error. Requirements 2-4 are assumed to be UML model requirements and not validated by the mapper.

### 1.2. Syntactic Requirements

1. Models to-be mapped must be exported to a single XMI file (version 2.1) by the Enterprise Architect (version 14.1).

### 1.3. Architecture

The architecture of the mapper is shown in the figure below (or see [architecture.jpg](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_architecture/architecture.JPG)). A configuration file refering to XMI files and with lists of selected UML classes is provided as input to the mapper. The selected subset of UML classes is extracted by the extractor module. The extracted subset is then mapped by the corresponding plugin to a RDFS/SHACL document and provided in a RDF/XML file.

![Architecture](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_architecture/architecture.JPG)

### 1.4. How to run the Mapper

There are a few ways to run the mapper, here are two examples:

1. Install a W3C compliant XQuery processor (e.g. BaseX) and run the file mapper.xq
	1. Using the BaseX command line tool: `basex -b$config="<configurationFile.xml>" mapper.xq`
	2. Or using the BaseX GUI and manually binding the location of the configuration file to the config variable
2. Run a Java Code which in turn runs the mapper.xq
	1. See the example [RunMapper.java](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_sampleJavaProgram/SampleProgram/src/main/java/at/jku/dke/samples/RunMapper.java) of the SampleProgram.
	
### 1.5. How to validate data graphs

The SampleProgram provides two classes which can utilize generated RDFS/SHACL documents:

1. Transforming an RDFS/SHACL document from RDF/XML to RDF/TTL, see [TransformXML2TTL.java](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_sampleJavaProgram/SampleProgram/src/main/java/at/jku/dke/samples/TransformXML2TTL.java) using Apache Jena.
2. Validating data graphs by an RDFS/SHACL document, see [ValidationWithSHACL.java](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_sampleJavaProgram/SampleProgram/src/main/java/at/jku/dke/samples/ValidationWithSHACL.java) using Apache Jena.

Attention! Be cautious that data graphs use the same namespaces as the generated RDFS/SHACL dcouments!
Example: Instead of using "http://www.aixm.aero/schema/5.1.1#" for AIXM, we use "http://www.aisa-project.eu/vocabulary/aixm_5-1-1#".

### 1.6. Performance

TBD.

## 2. Configuration File

### 2.1. Structure of the configuration file

In the configuration file subsets of UML classes of models to-be mapped can be specified. The following parameters must be provided:
1. input: The path to the model's XMI file.
2. type: The type of the model determines the plugin used for mapping, i.e. type can be "aixm_5-1-1", "fixm_3-0-1_sesar", "plain".
3. output: The path of the to-be generated RDFS/SHACL document.
4. connectorLevel: For each connector level, the subset is increased by another level of outgoing connectors from selected classes to other classes and resolving attributes of classes. The connectorLevel can be "1", "2", ..., "n". It is recommended to use "n" to include not visible classes (especially from stereotype "choice" in AIXM and FIXM) of a data graph.
The example below shows that the the classes "AirportHeliport" and "City" of the model at "input/AIXM_5.1.1.xmi" should be mapped by the plugin with the name "aixm_5-1-1".

		<configuration>
			<selection>
				<models>
					<model input="input/AIXM_5.1.1.xmi" type="aixm_5-1-1" output="output/AIXM_example.xml">
						<classes connectorLevel="n">
							<class>AirportHeliport</class>
							<class>City</class>
						</classes>
					</model>
				</models>
			</selection>
		</configuration>

### 2.2. How to write a configuration file 

In order to determine the UML classes to be selected, only consider UML classes from the namespace of the model. As an example, see the decisions for the [configuration](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/configurations/AIXM_DONLON.xml) of the [Donlon airport example](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_exampleData/AIXM_DONLON.ttl) below.

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

Additional configuration files can be added without changing existing ones. However, the mapper can only consider one configuration file. Make sure that the reference to the to-be used configuration file is correctly set in the mapper.xq (variable $config). 

## 3. Mapper

### 3.1. mapper.xq

The [mapper.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/mapper.xq) is the main module of the mapper. The variable $config refering to the location of the configuration file needs to be set correctly. For each model specified in the configuration file, it delegates the extraction process to the extractor.xq, then it delegates the mapping process with the extracted model subset to the corresponding plugin, and finally writes the result to a file. 

### 3.2. extractor.xq

The [extractor.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/extractor.xq) extracts a subset of UML classes and connectors from an XMI file based on the configuration file. The following steps are performed:

1. Extracting the selected UML classes
2. Recursive call of extraction:
	1. Extract outgoing connectors from the set of extracted UML classes
	2. Extract UML classes with an ingoing connector from 2.1.
	3. Extract UML classes which are association classes of connectors from 2.1.
	4. Extract UML classes which are attributes of extracted UML classes
	5. If connectorLevel="n":
		1. If the extracted model subset increased in size, then add another cycle of extraction.
		2. Otherwise, return the extracted model subset.
	6. Else:
		1. If the extracted model subset increased in size and connectorLevel > 1, then add another cycle of extraction and reduce the connectorLevel by 1.
		2. Otherwise, return the extracted model subset.

### 3.3. Plugins

[Plugins](https://github.com/bastlyo/AISA-XMI-Mapper/tree/main/plugins) are implementations of mapping semantics of different models. Each plugin is a XQuery module with the task to map a given model subset to an RDFS/SHACL document. There is no one fits all mapping approach! For example, stereotypes or attributes may have different meanings or may be used differently in different models. By default, the following plugins are available:

1. aixm_5-1-1.xq for AIXM 5.1.1
2. fixm_3-0-1_sesar.xq for FIXM 3.0.1 SESAR
3. plain.xq for plain UML models (no consideration of stereotypes)

The mapper can simply be extended by adding new plugins as XQuery modules to the plugin folder and by adding them to the plugin-choice in the mapper.xq (variable $mappedModel). A new plugin may be useful, if a model to-be mapped uses stereotypes differently than in previous models. In addition, a new plugin may also be useful, if an existing plugin needs to be adapated, e.g. different namespace or new meaning of a stereotype.

### 3.3.1. utilities.xq

The [utilities.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/plugins/utilities.xq) provides basic functionality for all other plugins. It provides two functions:

1. Transform a sequence of elements to an RDF/XML list
2. Find super elements of an element in a given model subset (optional: which are not from an certain stereotype) 

### 3.3.2. aixm_5-1-1.xq

The [aixm_5-1-1.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/plugins/aixm_5-1-1.xq) targets models which are based on [AIXM 5.1.1](http://www.aixm.aero/page/aixm-511-specification). First, GML basic elements may be added, then element by element of the extracted model subset is mapped.

#### 3.3.2.1. GML basic Classes for AIXM features

If the extracted model subset contains an element with stereotype "feature", the following basic elements are added to the result:

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
6. A SHACL shape named "aixm:NoNumberType" (type of aixm:sequenceNumber and aixm:correctionNumber) which has an xsd:unsignedInt as rdf:value.

		aixm:NoNumberType 
			a sh:NodeShape ;
			sh:property [ 
				sh:datatype xsd:unsignedInt ;
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:path rdf:value
			] .

These basic elements are not part of the AIXM 5.1.1 XMI file and therefore added manually. Other GML constructs like gml:pos inherited through gml:Point are also not part of the AIXM 5.1.1 XMI file either and not considered. A generated AIXM RDFS/SHACL document could be combined with a GML RDFS/SHACL document for a complete validation of the data.

#### 3.3.2.2. Basic Mapping Methods

UML classes of AIXM 5.1.1 are mapped based on their stereotype. But before diving into the details of the AIXM plugin, let's introduce a few basic mapping methods, i.e. mapping of attributes, connectors and association classes:

1. **Attributes** of a UML class are mapped into optional (i.e. sh:minCount 0) property shapes with the attribute type being the target node. Example attribute aixm:name of aixm:AirportHeliport:

		aixm:AirportHeliportTimeSlice
			sh:property [
				sh:path aixm:name ;
				sh:node aixm:TextNameType ;
				sh:maxCount 1 ;
			] .
2. **Connections** to other UML classes are mapped into property shapes with the sh:minCount and sh:maxCount representing the cardinality of the relationship. The target class is specified by the sh:class constraint. If a role name is provided, this name is used for sh:path. Otherwise, the sh:path name is the combination of "the" plus the target class name. There is an exception of mapping connections: association classes. If an association class for a connection exists, the property of the UML class targets the association class and not the initial target class. Furthermore, the association class has a property added for the connection to the target class. Example of a normal connection to the class aixm:City and a connection with an association class to aixm:OrganisationAuthority of aixm:AirportHeliport:

		aixm:AirportHeliportTimeSlice
			sh:property [ 
				sh:class aixm:City ;
				sh:path aixm:servedCity
			] ;
			sh:property  [ 
				sh:class aixm:AirportHeliportResponsibilityOrganisation ;
				sh:maxCount 1 ;
				sh:path aixm:responsibleOrganisation
			] .
3. A UML class can be an **association class** for a connection between two other classes. As already explained above, a property shape is added to a association class targeting the target class of the association. The sh:path is always the combination of "the" plus the target class name. Example of connection between aixm:AirportHeliport and aixm:OrganisationAuthority with aixm:AirportHeliportResponsibilityOrganisation as assocation class:
		
		aixm:AirportHeliportResponsibilityOrganisation
			sh:property [
				sh:class aixm:OrganisationAuthority ;
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:path aixm:theOrganisationAuthority
                         ] .
#### 3.3.2.3. Mapping of UML classes
Now after introducing the basic mapping methods, the mapping of elements based on their stereotype is presented:

1. Stereotype **"feature"**: For each UML class with stereotype "feature" two SHACL shapes / RDFS classes are generated. The first SHACL shape / RDFS class extends the aixm:AIXMFeature shape and has only one property named aixm:timeSlice. The second SHACL shape / RDFS class extends the aixm:AIXMTimeSlice shape and is named like the UML class with the phrase "TimeSlice" added at the end. For each super class of the feature, a rdfs:subClassOf and sh:and statement are added to the TimeSlice. Furthermore, the TimeSlice holds all attributes and connections of the corresponding feature. The three basic methods explained above are used for mapping attributes and connections of a feature into its TimeSlice. Example feature aixm:AirportHeliport with aixm:AirportHeliportTimeSlice:
	
		aixm:AirportHeliport
			a rdfs:Class , sh:NodeShape ;
			sh:and ( aixm:AIXMFeature ) ;
			sh:property [ 
				sh:path aixm:timeSlice ;
				sh:class aixm:AirportHeliportTimeSlice ;
			] .
		aixm:AirportHeliportTimeSlice
			a rdfs:Class , sh:NodeShape ;
			sh:and ( aixm:AIXMTimeSlice ) ;
			sh:property [
				sh:path aixm:name ;
				sh:node aixm:TextNameType ;
				sh:maxCount 1 ;
			] ... .
2. Stereotype **"object"**: For each UML class with stereotype "object" a SHACL shape / RDFS class is generated. Super classes and the three basic mapping methods are used exactly in the same way as in UML classes with stereotype "feature". The only difference between features and objects is that there are no TimeSlice classes in objects. Example aixm:AirportHeliportUsage:
	
		aixm:AirportHeliportUsage
			a rdfs:Class , sh:NodeShape ;
			rdfs:subClassOf aixm:UsageCondition ;
			sh:and ( aixm:UsageCondition ) ;
			sh:property [ 
				sh:maxCount 1 ;
				sh:node aixm:CodeOperationAirportHeliportType ;
				sh:path aixm:operation
			] .
3. Stereotype **"CodeList"**: For each UML class with stereotype "CodeList" a SHACL shape is generated. Its attribute names are allowed values and therefore mapped as a SHACL list into sh:in. If a super class with stereotype "XSDsimpleType" exists, a SHACL datatype statement is added. Example aixm:NilReasonEnumeration and aixm:UomDistanceVerticalType:

		aixm:NilReasonEnumeration
			a sh:NodeShape ;
			sh:datatype xsd:string ;
			sh:in ( "inapplicable" "missing" "template" "unknown" "withheld" "other" ) .
		aixm:UomDistanceVerticalType
			a sh:NodeShape ;
			sh:datatype  xsd:string ;
			sh:in ( "FT" "M" "FL" "SM" "OTHER" ) .
4. Stereotype **"DataType"**: For each UML class with stereotype "DataType" a SHACL shape is generated. For each super class with stereotype "DataType", a sh:and statement is added. The property shape with sh:path rdf:value is always added to classes with stereotype "DataType". If a super class with stereotype "XSDsimpleType" exists, a sh:datatype constraint is added for the property shape of rdf:value. If a super class with stereotype "CodeList" exists, a sh:node constraint is added for the property shape of rdf:value. If an attribute with stereotype "XSDfacet" exists, it is added as corresponding constraint (e.g. minLength) for the property shape of rdf:value. If a super class with stereotype "XSDsimpleType" exists, a SHACL datatype constraint is added for the property shape of rdf:value. All other attributes with stereotype not being "XSDfacet" are mapped according to the basic mapping of attributes. If an attribute from type "NilReasonEnumeration" exists, a SHACL exactly one (sh:xone) constraint is added, specifiyng that either a aixm:nilReason can occur or all other properties and rdf:value. Example aixm:ValDistanceVerticalType and its super class aixm:ValDistanceVerticalBaseType:

		aixm:ValDistanceVerticalType
			a sh:NodeShape ;
			sh:and ( aixm:ValDistanceVerticalBaseType ) ;
			sh:property [ 
				sh:maxCount 1 ;
				sh:node aixm:NilReasonEnumeration ;
				sh:path aixm:nilReason
			] ;
			sh:property [ 
				sh:maxCount 1 ;
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
				sh:pattern "^((\\+|\\-){0,1}[0-9]{1,8}(\\.[0-9]{1,4}){0,1})|UNL|GND|FLOOR|CEILING$"
			] .
5. Stereotype **"choice"**: There is no direct mapping into SHACL shape or RDFS class. UML classes with stereotype "choice" are mapped by classes which target the "choice" class with a connection. In this case, a SHACL property shape is added to the class which targets the "choice" class. The property shape has the connection name to the choice class as sh:path but no sh:class constraint. Instead, the sh:class is determined by an additional sh:xone constraint which provides the classes connected to the "choice" class by outgoing connections. Example aixm:SegmentPoint with property aixm:pointChoice targeting the choice aixm:SignificantPoint:

		aixm:SegmentPoint
			a rdfs:Class , sh:NodeShape ;
			sh:property [
				sh:path aixm:pointChoice ;
				sh:maxCount 1 ;
		] ;
		sh:xone (
			[ 
				sh:property [ 
					sh:minCount 1 ;
					sh:path aixm:pointChoice ;
					sh:class aixm:AirportHeliport ; 
				] ;
			]
			[ 
				sh:property [ 
					sh:minCount 1 ;
					sh:path aixm:pointChoice ;
					sh:class aixm:DesignatedPoint ; 
				] ;
			]
			...
		) .
6. Stereotype **"XSDsimpleType"**: No mapping.
7. Stereotype **"XSDcomplexType"**: No mapping.
8. **No** stereotype: For each UML class with no stereotype a SHACL shape / RDFS class with no content are generated. Typically, only GML based classes have no stereotype. UML classes from GML are classes with names starting with "GM_". These GML based classes are mapped into the GML namespace.

		gml:Point a rdfs:Class , sh:NodeShape .

### 3.3.3. fixm_3-0-1_sesar.xq

The [fixm_3-0-1_sesar.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/plugins/fixm_3-0-1_sesar.xq) target models which are based on [FIXM 3.0.1 SESAR](https://www.fixm.aero/release.pl?rel=SESAR_Ext-1.0). 

#### 3.3.3.1. Mapping of UML classes

UML classes of FIXM 3.0.1 SESAR are mapped based on their stereotype:

1. Stereotype **"enumeration"**: For each UML class with stereotype "enumeration" a SHACL shape is generated. It has a single mandatory (sh:minCount 1) property with the sh:path depending on the name of the UML class. In case of the name containing "Measure" the sh:path is fixm:uom, otherwise it is rdf:value. The class's attribute names are allowed values and therefore mapped as a SHACL list into sh:in. Example fixm:AbrogationReasonCode and fixm:TemperatureMeasure: 
		
		fixm:AbrogationReasonCode
			a sh:NodeShape ;
			sh:property [ 
				sh:in ( "TFL" "ROUTE" "CANCELLATION" "DELAY" "HOLD" ) ;
				sh:minCount 1 ;
				sh:path rdf:value
			] .
		fixm:TemperatureMeasure
			a sh:NodeShape ;
			sh:property [
				sh:in ( "FARENHEIT" "CELSIUS" "KELVIN" ) ;
				sh:minCount 1 ;
				sh:path fixm:uom
			] .
2. Stereotype **"choice"**: There is no direct mapping into SHACL shapes or RDFS classes. In case a UML class with stereotype "choice" has outgoing connections, it is mapped in the targeting UML class, i.e. similar to the mapping in AIXM the "choice" class is resolved in the class targeting the "choice" class. In case a UML with stereotype "choice" has no outgoing connections, it is mapped as if it would have no stereotype (see below). Example fixm:AircraftType (no outgoing connections):

		fixm:AircraftType
			a rdfs:Class , sh:NodeShape ;
			sh:property [ 
				sh:maxCount 1 ;
				sh:node fixm:FreeText ;
				sh:path fixm:otherModelData
			] ;
			sh:property [ 
				sh:maxCount 1 ;
				sh:node fixm:IcaoAircraftIdentifier ;
				sh:path fixm:icaoModelIdentifier
			] .

3. **No** stereotype:

### 3.3.4. plain.xq

The [plain.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/plugins/plain.xq) ...

## 4. RDFS/SHACL Document

The resulting document combines RDFS and SHACL because in AISA both formats are generated from the same source and used together. The combination of RDFS and SHACL is very similar to UML class diagrams.

Example aixm:AirportHeliport:

	aixm:AirportHeliport
		a rdfs:Class ;		# This is RDFS!
		a sh:NodeShape ;	# This is SHACL!
		... .
