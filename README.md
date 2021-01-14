# AISA-XMI-Mapper

For feedback or issues contact: sebastian.gruber@jku.at 

## Table of content

1. Introduction
	1. Semantic Requirements
	2. Syntactic Requirements
	3. Architecture
	4. How to run the Mapper
	5. How to validate data graphs
2. Configuration File
	1. Structure of a configuration file
	2. How to write a configuration file
3. Mapper
	1. mapper.xq
	2. extractor.xq
	3. Plugins
		1. utilities.xq
		2. aixm_5-1-1.xq
		3. fixm_3-0-1_sesar.xq
		4. plain.xq
4. RDFS/SHACL Document

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

The architecture of the mapper is shown in the figure below (or see [\architecture.jpg](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_architecture/architecture.JPG)). A configuration file refering to XMI files and with lists of selected UML classes is provided as input to the mapper. The selected subset of UML classes is extracted by the extractor module. The extracted subset is then mapped by the corresponding plugin to a RDFS/SHACL document and provided in a RDF/XML file.

![Architecture](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_architecture/architecture.JPG)

### 1.4. How to run the Mapper

There are a few ways to run the mapper, here are two examples:

1. Install a W3C compliant XQuery processor (e.g. BaseX) and run the file mapper.xq
	1. Using the BaseX command line tool: `basex -b$config="<configurationFile.xml>" mapper.xq`
	2. Or using the BaseX GUI and manually binding the location of the configuration file to the config variable
2. Run a Java Code which in turn runs the mapper.xq
	1. See the example [RunMapper.java](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_sample%20java%20program/SampleProgram/src/main/java/at/jku/dke/samples/RunMapper.java) of the SampleProgram.
	
### 1.5. How to validate data graphs

The SampleProgram provides two classes which can utilize generated RDFS/SHACL documents:

1. Transforming an RDFS/SHACL document from RDF/XML to RDF/TTL, see [TransformXML2TTL.java](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_sample%20java%20program/SampleProgram/src/main/java/at/jku/dke/samples/TransformXML2TTL.java) using Apache Jena.
2. Validating data graphs by an RDFS/SHACL document, see [ValidationWithSHACL.java](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_sample%20java%20program/SampleProgram/src/main/java/at/jku/dke/samples/ValidationWithSHACL.java) using Apache Jena.

Attention! Be cautious that data graphs use the same namespaces as the generated RDFS/SHACL dcouments!
Example: Instead of using "http://www.aixm.aero/schema/5.1.1#" for AIXM, we use "http://www.aisa-project.eu/vocabulary/aixm_5-1-1#".

## 2. Configuration File

### 2.1. Structure of the configuration file

In the configuration file subsets of UML classes of models to-be mapped can be specified. The following parameters must be provided:
1. input: The path to the model's XMI file.
2. type: The type of the model determines the plugin used for mapping, i.e. type can be "aixm_5-1-1", "fixm_3-0-1_sesar", "plain".
3. output: The path of the to-be generated RDFS/SHACL document.
4. connectorLevel: For each connector level, the subset is increased by another level of outgoing connectors from selected classes to other classes and resolving attributes of classes. The connectorLevel can be "1", "2", ..., "n". It is recommended to use "n" to include not visible classes (especially from stereotype <<choice>> in AIXM and FIXM) of a data graph.
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

In order to determine the UML classes to be selected, only consider UML classes from the namespace of the model. As an example, see the decisions for the [configuration](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/configurations/AIXM_DONLON.xml) of the [Donlon airport example](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/_example%20data/AIXM_DONLON.ttl) below.

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

Additional configuration files can be added without changing existing ones. However, the mapper can only consider one configuration file. Make sure that the reference to the to-be used configuration file is correctly set in the [mapper.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/mapper.xq) (variable $config). 

## 3. Mapper

### 3.1. mapper.xq

The [mapper.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/mapper.xq) is the main module of the mapper. The variable $config refering to the location of the configuration file needs to be set correctly. For each model specified in the configuration file, it delegates the extraction process to the extractor.xq, then it delegates the mapping process with the extracted model subset to the corresponding plugin, and finally writes the result to a file. 

### 3.2. extractor.xq

The [extractor.xq](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/extractor.xq)
The mapper passes the model and selected classes to the extractor-module to extract the to-be mapped subset. The extractor-module selects the follwing data as a subset:

1. The selected classes
2. Connections only between 1. (except dependencies)
3. Association classes only between 2.
4. Super classes of 1. and 3. (as well as their super classes and so forth)
5. Attribute classes of 1., 3. and 4. (as well as their super classes and their attribute classes and so forth)

The subset of a model is returned to the mapper.

## 3.2. Plugins

After the subset of a model is returned to the mapper, the mapper delegates the mapping process to the corresponding plugin. A plugin is an XQuery module with the task to map given data to RDFS/SHACL according to the semantics of the plugin's UML diagrams. For example, stereotypes or attributes may have different meanings in different models. By default, the following plugins are available:

1. AIXM 5.1.1
2. FIXM 3.0.1 SESAR
3. Plain (no consideration of stereotypes)

Currently only the plugin "aixm_5-1-1" for AIXM 5.1.1 is realized. In future releases plugins for FIXM 3.0.1 SESAR and for plain UML class diagrams are planned.

The mapper can simply be extended by adding new plugins as XQuery modules to the plugin folder and by adding them to the plugin-choice in the main module "mapper.xq" (variable $mappedModel). A new plugin may be useful, if a model to-be mapped uses stereotypes differently than AIXM 5.1.1, FIXM 3.0.1 or plain UML. In addition, a new plugin may also be useful, if an existing plugin needs to be adapated, e.g. different namespace or new meaning of a stereotype. It is recommended to also provide a documentation for each plugin in the plugin folder following the guidelines.

The resulting RDFS/SHACL is returned to the mapper.

## 4. RDFS/SHACL Document

After the RDFS/SHACL mapped by a plugin is returned to the mapper, it is written to an RDF/XML file with the name of the model appended by "\_subset" in the output folder.


In order to run the mapper, the main module "mapper.xq" must be executed using an XQuery processor, e.g. BaseX.



# To be incorporated
Run: basex -b$config="configurations/FIXM_EDDF-VHHH.xml" mapper.xq
More Java Examples: https://docs.basex.org/wiki/Java_Examples
