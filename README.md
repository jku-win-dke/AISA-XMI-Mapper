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
	3. [Extensions](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#23-extensions)
3. [Mapper](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3-mapper)
	1. [mapper.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#31-mapperxq)
	2. [extractor.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#32-extractorxq)
	3. [Plugins](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#33-plugins)
		1. [utilities.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#331-utilitiesxq)
		2. [aixm_5-1-1.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#332-aixm_5-1-1xq)
			1. [Basic elements for AIXM features](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3321-basic-elements-for-aixm-features)
			2. [Basic Mapping Methods](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3322-basic-mapping-methods)
			3. [Mapping of UML classes](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3323-mapping-of-uml-classes)
		3. [fixm_3-0-1_sesar.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#333-fixm_3-0-1_sesarxq)
			1. [Mapping of UML classes](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3331-mapping-of-uml-classes)
		4. [plain.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#334-plainxq)
			1. [Mapping of UML classes](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#3341-mapping-of-uml-classes)
4. [RDFS/SHACL Document](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/README.md#4-rdfsshacl-document)

## 1. Introduction

The AISA-XMI-Mapper maps selected classes of UML class diagrams to RDF Schema (RDFS) and Shape Constraint Language (SHACL) documents. RDFS defines the vocabulary of the domain which is described by the UML class diagrams, i.e. classes and class hierarchies. SHACL defines structural constraints of the domain. The mapper is created with the aim of mapping aeronautical UML models (AIXM 5.1.1., FIXM 3.0.1. SESAR) which adhere to a specific modelling style. Therefore, models provided to the mapper must fulfill certain semantic and syntactic requirements.

### 1.1. Semantic Requirements

1. Class names must be unique within a model (AIXM, FIXM, ...). There can be a UML class called "Route" in an AIXM based model and an FIXM based model but there must not be two different UML classes called "Route" in one model even if they are in different packages.
2. Models must contain only directed associations because RDF is based on directed graphs.          
3. Role names (at the target) of associations with the same source class must be unique within the source class.      
4. Role names must exist, if there is more than one association between a source and a target class. If there is only one association and no role name provided, the role name is constructed using the name of the target class.

Requirement 1 is validated by the mapper and, if violated, throws an error. Requirements 2-4 are assumed to be UML model requirements and are not validated by the mapper.

### 1.2. Syntactic Requirements

1. Models to-be mapped must be exported to a single XMI file (version 2.1) by the Enterprise Architect (version 14.1).

### 1.3. Architecture

The architecture of the mapper is shown in the figure below. A configuration file refers to XMI files and keeps lists of selected UML classes. A single configuration file is provided as input to the mapper. Based on the configuration file, selected subsets of models are extracted by the extractor module. Extracted subsets of models are mapped by plugins which are responsible for certain models to RDFS/SHACL documents provided as RDF/XML files. There is no one fits all mapping approach, therefore we use different plugins for different models.

![Architecture](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_architecture/architecture.JPG)

### 1.4. How to run the Mapper

There are a few ways to run the mapper, here are two examples:

1. Install a W3C compliant XQuery processor (e.g. BaseX) and run the file mapper.xq:
	1. Using the BaseX command line tool: `basex -b$config="<locationOfTheConfigurationFile.xml>" mapper.xq`.
	2. Or using the BaseX GUI and manually binding the location of the configuration file to the config variable.
2. Run Java Code which runs the mapper.xq
	1. See the example [RunMapper.java](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_sampleJavaProgram/SampleProgram/src/main/java/at/jku/dke/samples/RunMapper.java) of the SampleProgram.
	
### 1.5. How to validate data graphs

There are a few ways to validate data with generated RDFS/SHACL documents. As an example, the SampleProgram provides two classes which can utilize generated RDFS/SHACL documents:

1. Transforming an RDFS/SHACL document from RDF/XML to RDF/TTL, see [TransformXML2TTL.java](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_sampleJavaProgram/SampleProgram/src/main/java/at/jku/dke/samples/TransformXML2TTL.java) using Apache Jena.
2. Perform RDFS reasoning and validating data graphs by an RDFS/SHACL document, see [ValidationWithSHACL.java](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_sampleJavaProgram/SampleProgram/src/main/java/at/jku/dke/samples/ValidationWithSHACL.java) using Apache Jena.

Be aware of data graphs using the same namespaces as the generated RDFS/SHACL dcouments! Instead of using "http://www.aixm.aero/schema/5.1.1#", we use "http://www.aisa-project.eu/vocabulary/aixm_5-1-1#" for AIXM. Furthermore, we use "http://www.aisa-project.eu/vocabulary/fixm_3-0-1_sesar#" for fixm and "http://www.aisa-project.eu/xquery/plain#" for plain models.

### 1.6. Performance

There is no performance requirement for the AISA XMI Mapper because the schemas are typically only mapped once in the beginning. Hence, the XQuery code is not written to maximize performance. However, here are some exemplary performance data running the mapper with the provided configuration files in the BaseX GUI (using a Lenovo Thinkpad T470p).

Execution | AIXM_DONLON.xml | AIXM_COCESNA.xml | FIXM_EDDF-VHHH.xml
--------- | --------------- | ---------------- | ------------------
1 | 32 821 ms | 102 323 ms | 12 555 ms
2 | 34 069 ms | 102 758 ms | 12 336 ms
3 | 33 137 ms | 103 382 ms | 12 524 ms
4 | 33 875 ms | 103 906 ms | 12 333 ms
5 | 34 443 ms | 104 194 ms | 12 335 ms
Average | 33 669ms | 103 313 ms | 12 417 ms

The performance highly depends on the connectorLevel in the configuration file (connectorLevel="n" needs a lot of processing) and on the connections of selected classes of a model. It DOES NOT depend on the number of classes! As an example, the mapper using AIXM_DONLON.xml (selects 11 classes) is way more faster than the mapper using AIXM_COCESNA.xml (selects 3 classes). If performance becomes an issue, the connectorLevel could be adapted or especially the extractor.xq could be optimized because it includes some overhead (not necessary) processing.

## 2. Configuration File

### 2.1. Structure of the configuration file

In configuration files UML classes of different models to-be mapped can be specified. The following attributes (or parameters) must be provided:
1. input: The path to the model's XMI file.
2. type: The type of the model determines the plugin used for mapping, i.e. type can be "aixm_5-1-1", "fixm_3-0-1_sesar" or "plain".
3. output: The path to the to-be generated RDFS/SHACL document.
4. connectorLevel: For each connector level, the subset is increased by another level of outgoing connectors from selected classes to other classes and resolving attributes of classes. The connectorLevel can be "1", "2", ..., "n". It is recommended to use "n" to include not visible classes (especially from stereotype "choice" in AIXM and FIXM) of a data graph. However, using connectorLevel "n" decreases performance and increases the size of the schema eventually including classes which are not required. If "n" is not used, then the connector level should be choosen in a way that it resolves necessary datatypes, e.g. in AIXM a minimum of connector level 4 is recommended.

The example below shows that the the classes "AirportHeliport" and "City" of the model at "input/AIXM_5.1.1.xmi" should be mapped by the plugin with the name "aixm_5-1-1" and using a connector level of "n".

		<configuration>
			<selection>
				<models>
					<model input="input/AIXM_5.1.1.xmi" type="aixm_5-1-1" output="output/AIXM_example.xml">
						<classes connectorLevel="n">
							<class>AirportHeliport</class>
							<class>City</class>
						</classes>
					</model>
					<model ... >
						...
					</model>
				</models>
			</selection>
		</configuration>

### 2.2. How to write a configuration file 

In order to determine the UML classes to be selected, only consider UML classes from the namespace of the model. In addition, TimeSlice classes in AIXM cannot be selected because they are not part of the AIXM UML class diagrams, instead they are generated by the mapper if the parent feature is selected. As an example, see the decisions for the [configuration](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/configurations/AIXM_DONLON.xml) of the [Donlon airport example](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_exampleData/AIXM_DONLON.ttl) below.

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

### 2.3. Extensions

In case the mapper should be further configurable by attributes or connections of classes which should only be mapped or which should not be mapped, this information should be provided as an inclusion or exclusion list in the configuration file. As an example:

	...
		<classes>
			<class name="AirportHeliport">
				<attributes>
					<attribute>name</attribute>
				</attributes>
				<connectors>
					<connector>serves</connector>
				</connectors>
			</class>
			...
		</classes>
	...

Make sure you must adapt the extractor module accordingly. Furthermore, you must consider this configuration in the mapping plugins. Simply check while mapping attributes or connectors of an UML class if this attribute or connector is part of the list in the configuration file. 

## 3. Mapper

### 3.1. mapper.xq

The [mapper.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/mapper.xq) is the main module of the mapper. The variable $config refering to the location of the configuration file needs to be set externally. For each model specified in the configuration file, it delegates the extraction process to the extractor.xq. After the extraction the mapper delegates the mapping process to the corresponding plugin, and finally writes the result to a file. 

### 3.2. extractor.xq

The [extractor.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/extractor.xq) extracts a subset of UML classes and connections from an XMI file based on the configuration file. The following steps are performed:

1. Extracting the selected UML classes
2. Extracting of corresponding UML classes and connections (recursive):
	1. Extract outgoing connections from the set of selected and extracted UML classes
	2. Extract UML classes with an ingoing connection from 2.1.
	3. Extract UML classes which are association classes of connections from 2.1.
	4. Extract UML classes which are attributes of selected and extracted UML classes
	5. If connectorLevel="n":
		1. If the extracted model subset increased in size, then add another cycle of extraction.
		2. Otherwise, return the extracted model subset.
	6. Otherwise:
		1. If the extracted model subset increased in size and connectorLevel > 1, then add another cycle of extraction and reduce the connectorLevel by 1.
		2. Otherwise, return the extracted model subset.
		
In the end, the extracted model subset is returned to the mapper.xq.

### 3.3. Plugins

[Plugins](https://github.com/bastlyo/AISA-XMI-Mapper/tree/main/plugins) are implementations of different models' mapping semantics. Each plugin is a XQuery module with the task to map a given model subset to an RDFS/SHACL document. We use different plugins for different models because there is no one fits all mapping approach. For example, stereotypes or attributes may have different meanings or may be used differently in different models. By default, the following plugins are available:

1. utilities.xq provides basic functionality for plugins
2. aixm_5-1-1.xq for AIXM 5.1.1
3. fixm_3-0-1_sesar.xq for FIXM 3.0.1 SESAR
4. plain.xq for plain UML models (no consideration of stereotypes)

The mapper can simply be extended by adding new plugins as XQuery modules to the plugin folder and by adding them to the delegation of the mapping process in the mapper.xq (variable $mappedModel). A new plugin may be useful, if a model needs to be mapped that uses stereotypes differently than in previous models. In addition, a new plugin may also be useful, if an existing plugin needs to be adapated, e.g. different namespaces or updating the meaning of a stereotype.

### 3.3.1. utilities.xq

The [utilities.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/plugins/utilities.xq) provides basic functionality used in the plugins. It provides two functions:

1. Transform a sequence of elements to an RDF/XML list
2. Find super classes of an class in a given model subset with two options:
	1. Super elements are not from a certain stereotype
	2. Call this function recursively to find all super classes of a class

### 3.3.2. aixm_5-1-1.xq

The [aixm_5-1-1.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/plugins/aixm_5-1-1.xq) targets models which are based on [AIXM 5.1.1](http://www.aixm.aero/page/aixm-511-specification). First, basic elements are added and then, element by element of the extracted model subset is mapped.

#### 3.3.2.1. Basic Elements for AIXM features

If the extracted model subset contains an element with stereotype "feature", the following basic classes are added to the result:

1. An empty SHACL shape named "aixm:AIXMFeature" which could be extended by general AIXM feature properties. This shape represents the abstract AIXMFeature class. Its identifier attribute is not mapped into a property shape because the identifier of features is used as resource identifier (IRI). 
		
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
				sh:path gml:indeterminatePosition ;
				sh:in ( "after" "before" "now" "unknown" )
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

These basic elements are mandatory for AIXM features and not modelled accordingly in the AIXM 5.1.1 UML class diagrams, therefore, they are added manually. Other GML constructs like gml:pos inherited through gml:Point are also not part of the AIXM 5.1.1 UML class diagrams. A generated AIXM RDFS/SHACL document could be combined with a GML RDFS/SHACL document for a complete validation of the data.

#### 3.3.2.2. Basic Mapping Methods

Some mapping methods in AIXM are used in multiple cases, including mapping of attributes, connectors and association classes:

1. **Attributes** of a UML class are mapped into optional (i.e. sh:minCount 0) property shapes with the attribute type being the target node. The name of the attribute is used as sh:path. Example attribute aixm:name of aixm:AirportHeliport:

		aixm:AirportHeliportTimeSlice
			sh:property [
				sh:path aixm:name ;
				sh:node aixm:TextNameType ;
				sh:maxCount 1 ;
			] .
2. **Connections** to other UML classes are mapped into property shapes with the sh:minCount and sh:maxCount representing the cardinality of the relationship. The target class is specified by the sh:class constraint. If a role name is provided, this name is used for sh:path. Otherwise, the sh:path is the combination of "the" plus the target class name. There is an exception of mapping connections: association classes. If an association class for a connection exists, the property of the source UML class targets the association class. Furthermore, the association class has a property shape which targets the connection's target class. Example of aixm:AirportHeliport with a connection to the class aixm:City and a connection to the class aixm:OrganisationAuthority with an association class with the association class aixm:AirportHeliportResponsibilityOrganisation:

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
3. A UML class can be an **association class** for a connection between two other classes. As already explained above, a property shape is added to an association class targeting the connection's target class. The sh:path is always the combination of "the" plus the target class name since the role name is already used by the source class. Example of the connection between aixm:AirportHeliport and aixm:OrganisationAuthority with aixm:AirportHeliportResponsibilityOrganisation as assocation class:
		
		aixm:AirportHeliportResponsibilityOrganisation
			sh:property [
				sh:class aixm:OrganisationAuthority ;
				sh:maxCount 1 ;
				sh:minCount 1 ;
				sh:path aixm:theOrganisationAuthority
                         ] .
#### 3.3.2.3. Mapping of UML classes

UML classes of AIXM 5.1.1 are mapped based on their stereotype:

1. Stereotype **"feature"**: For each UML class with stereotype "feature" two SHACL shapes / RDFS classes are generated. The first SHACL shape / RDFS class extends the aixm:AIXMFeature shape and has only one property named aixm:timeSlice. The second SHACL shape / RDFS class extends the aixm:AIXMTimeSlice shape and is named like the UML class with the phrase "TimeSlice" added at the end. For each super class of the feature, a rdfs:subClassOf and sh:and statement are added to the corresponding TimeSlice. Furthermore, the TimeSlice holds all attributes and connections of the corresponding feature as property shapes. Therefore, the three basic methods explained above are used. Example feature aixm:AirportHeliport with aixm:AirportHeliportTimeSlice:
	
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
2. Stereotype **"object"**: For each UML class with stereotype "object" a SHACL shape / RDFS class is generated. Super classes and the three basic mapping methods are used exactly in the same way as in UML classes with stereotype "feature". The only difference between features and objects is that there are no added TimeSlice classes for objects. Example aixm:AirportHeliportUsage:
	
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
4. Stereotype **"DataType"**: For each UML class with stereotype "DataType" a SHACL shape is generated. For each super class with stereotype "DataType", a sh:and statement is added. The property shape with sh:path rdf:value is always added to classes with stereotype "DataType". If a super class with stereotype "XSDsimpleType" exists, a sh:datatype constraint is added for the rdf:value property shape. If a super class with stereotype "CodeList" exists, a sh:node constraint is added for the property shape of rdf:value. If an attribute with stereotype "XSDfacet" exists, it is added as corresponding SHACL constraint (e.g. minLength) for the rdf:value property shape. If a super class with stereotype "XSDsimpleType" exists, a SHACL datatype constraint is added for the rdf:value property shape. All other attributes with stereotype not being "XSDfacet" are mapped according to the basic mapping of attributes. If an attribute from type "NilReasonEnumeration" exists, a SHACL exactly one (sh:xone) constraint is added, specifiyng that either a aixm:nilReason can occur or all other properties and rdf:value. Classes with stereotype "DataType" are typically used in attributes and not in connections, thus, the basic mapping methods 2 and 3 are not used. Example aixm:ValDistanceVerticalType and its super class aixm:ValDistanceVerticalBaseType:

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
5. Stereotype **"choice"**: For each UML class with stereotype "choice" a SHACL shape is generated. The generated SHACL shape is only a link between a UML class and a choice between allowed classes. Therefore, the SHACL shape of the choice class only contains the connections in a sh:xone (only one connection is allowed). Example aixm:SignficantPoint:
	
		aixm:SignificantPoint
		a sh:NodeShape ;
		sh:xone (
			[ sh:class aixm:AirportHeliport ]
			[ sh:class aixm:TouchDownLiftOff ]
			[ sh:class aixm:RunwayCentrelinePoint ]
			[ sh:class aixm:Point ]
			[ sh:class aixm:Navaid ]
			[ sh:class aixm:DesignatedPoint ]
		) .
6. Stereotype **"XSDsimpleType"**: No mapping. Super classes with this stereotype are used to derive sh:datatype constraints in sub classes (with stereotype "DataType" or "CodeList").
7. Stereotype **"XSDcomplexType"**: No mapping.
8. **No** stereotype: UML classes with no stereotypes are mapped the same as UML classes with stereotype "object". Example gml:Point: 

		gml:Point a rdfs:Class , sh:NodeShape .

### 3.3.3. fixm_3-0-1_sesar.xq

The [fixm_3-0-1_sesar.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/plugins/fixm_3-0-1_sesar.xq) target models which are based on [FIXM 3.0.1 SESAR](https://www.fixm.aero/release.pl?rel=SESAR_Ext-1.0). 

#### 3.3.3.1. Mapping of UML classes

UML classes of FIXM 3.0.1 SESAR are mapped based on their stereotype:

1. Stereotype **"enumeration"**: For each UML class with stereotype "enumeration" a SHACL shape is generated. It has a single mandatory (sh:minCount 1) property with the sh:path being fixm:uom or rdf:value. In case the name of the UML class contains "Measure" the sh:path is fixm:uom, otherwise it is rdf:value. The attribute names of the UML class are allowed values and therefore mapped as a SHACL list into sh:in. Example fixm:AbrogationReasonCode and fixm:TemperatureMeasure: 
		
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
2. Stereotype **"choice"**: For each UML class with stereotype "choice" a SHACL shape is generated. There are two different cases: (1) a choice class is used as attribute or (2) a choice class is used via connections. In case (1) the generated SHACL shape is only a link between a UML class and a choice between allowed attributes or connected classes. Therefore, the SHACL shape of the choice class only contains the attributes and connections in a sh:xone (only one attribute or connection is allowed). In case (2) the generated SHACL shape is also an RDFS class. It also provides the choice between attributes and connections in a sh:xone but including their paths and maxCount constraint. Example fixm:PersonOrOrganization (case 1) and fixm:AircraftType (case 2):

		fixm:PersonOrOrganization
			a sh:NodeShape ;
			sh:xone (
				[ sh:class  fixm:Organization ]
				[ sh:class  fixm:Person ]
			) .
		fixm:AircraftType 
			a rdfs:Class , sh:NodeShape ;
        		sh:xone ( 
				[ 
					sh:property [ 
						sh:maxCount 1 ;
						sh:minCount 1 ;
						sh:node fixm:IcaoAircraftIdentifier ;
						sh:path fixm:icaoModelIdentifier
					]
				]
				[ 
					sh:property [ 
						sh:maxCount 1 ;
						sh:minCount 1 ;
						sh:node fixm:FreeText ;
						sh:path fixm:otherModelData
					]
				]
			) .
3. **No** stereotype: For each UML class with no stereotype a SHACL shape is generated. If a UML class or one of its super classes are not based on an XSD datatype, it is also an RDFS class with its super classes as rdfs:subClassOf Triple added. In every case, super classes are added as sh:and statements. In case, there is an attribute called "uom", an sh:and statements needs to include the SHACL shape of that attribute. If the UML class (or one of its super classes) is connected to an XSD datatype, a SHACL property shape with sh:path rdf:value is added (together with its constraints and datatype). Attributes of classes are mapped into optional property shapes. In case the type of an attribute is one of a few possible XSD datatypes, the attribute's property shape targets a blank node shape with a single property shape that has the rdf:value as sh:path. The blank node shape is necessary to keep the structure of instance data consistant. In all other cases, attributes are simply mapped into optional property shapes. Connectoions of a UML class are also mapped into property shapes. Example attribute fixm:topOfClimb with an XSD datatype in fixm:TrajectoryPointRole, and attribute fixm:aircraftColours as well as connection fixm:aircraftType in fixm:Aircraft:

		fixm:TrajectoryPointRole
			a rdfs:Class , sh:NodeShape ;
			sh:property [ 
				sh:maxCount 1 ;
				sh:node [ 
					a sh:NodeShape ;
					sh:property [ 
						sh:datatype xsd:boolean ;
						sh:path rdf:value
					]
				] ;
				sh:path fixm:topOfClimb
			] ... .
		fixm:Aircraft 
			a rdfs:Class , sh:NodeShape ;
			rdfs:subClassOf fixm:Feature ;
			sh:and ( fixm:Feature ) ;
			sh:property [ 
				sh:node fixm:FreeText ;
				sh:maxCount 1 ;
				sh:path fixm:aircraftColours
			] ;
			sh:property [ 
				sh:class fixm:AircraftType ;
				sh:maxCount 1 ;
				sh:path fixm:aircraftType
			] ... .

### 3.3.4. plain.xq

The [plain.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/plugins/plain.xq) targets models which are not based AIXM and FIXM and do not use stereotypes. Due to this general requirement, this mapping approach is also very limited and may need manual investigation and improvments.

#### 3.3.4.1. Mapping of UML classes

For each UML class from the extracted subset, a SHACL shape / RDFS class is generated. Super classes of a UML class are mapped into rdfs:subClassOf and sh:and. Attributes are mapped into optional property shapes, while connections are mapped into property shapes with the cardinality of the relationship being represented in the sh:minCount and sh:maxCount. If a UML class is an association class, connections are resolved such that the source class has a property shape which targets the association class, while the association class has a property shape which targets the target class.

## 4. RDFS/SHACL Document

The resulting document combines RDFS and SHACL because in AISA both formats are generated from the same source and used together. The combination of RDFS and SHACL is very similar to UML class diagrams.

Example aixm:AirportHeliport:

	aixm:AirportHeliport
		a rdfs:Class ;		# This is RDFS!
		a sh:NodeShape ;	# This is SHACL!
		... .
