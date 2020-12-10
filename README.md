# AISA-XMI-Mapper

For feedback or issues contact: sebastian.gruber@jku.at 

## 1. Introduction

The AISA-XMI-Mapper maps selected content of UML class diagrams to a combination of RDF Schema (RDFS) and Shape Constraint Language (SHACL). The RDFS defines the vocabulary of the domain (classes and class hierarchies) which is described by the UML class diagrams. The SHACL defines structural constraints of the domain or, in other words, the schema. The mapper is created with the aim of mapping aeronautical UML models (AIXM, FIXM, ...) which adhere to a specific modelling style. Therefore, models provided to the mapper must fulfill certain semantic and syntactic requirements.

### 1.1. Semantic Requirements

Requirement 1 is validated by the mapper and if violated, throws an error. Requirements 2-6 are assumed to be UML model requirements and not validated by the mapper.

1. Class names must be unique within a model (AIXM, FIXM, ...). There can be a UML class called "Route" in AIXM and FIXM but there must not be two different UML classes called "Route" in one model (even if they are in different packages).
2. Models must contain only directed associations because RDF is based on directed graphs.          
3. Role names (at the target) of associations with the same source class must be unique within the source class.      
4. Role names must exist, if there is more than one association between a source and a target class. If there is only one association and no role name provided, the role name is constructed using the name of the target class.
5. Classes with stereotypes are treated individually based on their use in AIXM and FIXM.
      
### 1.2. Syntactic Requirements

1. Models to-be mapped must be exported to a single XMI file (version 2.1) by the Enterprise Architect (version 14.1).

### 1.3 Architecture

The architecture of the mapper is shown in the figure below. In the configuration file the models and their selected subset of UML classes are specified. The selected subset of UML classes is extracted by the extractor-module. The extracted subset is mapped by the corresponding plugin to RDFS/SHACL. This architecture is now explained in more detail.

![Architecture](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/img/architecture.JPG)
      
## 2. Input

The input for the mapper should be provided in the input folder of the mapper. The input consists of a configuration file and an arbitrary number of XMI files. 

### 2.1. Configuration File

The configuration file lists the models to-be mapped, i.e. the type of a model, the location/name of its XMI file, and the classes to-be mapped. The example below shows that the the classes "AirportHeliport" and "City" of the model at "input/AIXM_5.1.1.xmi" should be mapped by the plugin with the name "aixm_5-1-1".

	<configuration>
		<selection>
			<models>
				<model type="aixm_5-1-1" location="input/AIXM_5.1.1.xmi">
					<classes>
						<class>AirportHeliport</class>
						<class>City</class>
					</classes>
				</model>
			</models>
		</selection>
	</configuration>

a. The name of a model can be a arbitrary choosen but should be meaningful because it is used to provide an individual namespace for each model. 
The identifier (URI) of an element is composed of a namespace and its local name. The namespace is the combination of the AISA URI and the model name, e.g. http://www.aisa-project.eu/AIXM/ for AIXM. The local name is the element name from the XMI file, e.g. TerminalSegmentPoint. The composition of namespace and local name results in URI of the element, e.g. http://www.aisa-project.eu/AIXM/TerminalSegmentPoint for TerminalSegmentPoint.
For SHACL, we use the same URI and append "Shape" to the local name, e.g. http://www.aisa-project.eu/AIXM/TerminalSegmentPointShape for TerminalSegmentPoint.

  
b. The location/name of a model's XMI file can be an absolute reference to an XMI file anywhere in the system. It is, however, recommended that the XMI file is in the input folder of the mapper's folder such that the reference is just "input/<fileName.xmi>".
  
c. The classes to-be mapped are a subset of the whole model. By default, the configuration file contains all classes from AIXM and FIXM selected from the comprehensive example. Based on the class selection the following elements are mapped: 
c1. The selected classes.
c2. Connections only between c1 (except dependencies).
c3. Association classes only between c2.
c4. Super classes of c1 and c3 (and their super classes and so forth).
c5. Attribute classes of c1, c3, c4 (and their super classes and their attribute classes and so forth)

### 2.2. Models

For each model listed in the configuration file a XMI file conforming the semantic and syntactic requirements (1.1 and 1.2) must be provided at the referenced location.

## 3. Mapping

The selected subset of the models is mapped to RDFS and SHACL. The mapper is realized as a set of XQuery modules which can be executed using a XQuery processor complying to the XQuery W3C standard, e.g. BaseX. In order to execute the mapper with a given configuration, the "xmiMapper.xq" file needs to be executed. Optionally, the reference to the configuration file can be changed in line 8.

Before actually starting the mapping, the mapper extracts and stores the subset of the models in an additional XMI file. The new file is located in the output folder with the name "subset.xmi".

### 3.1 RDFS

### 3.2 SHACL

## 4. Output

The output of the mapper is provided in the output folder within the folder of the mapper. The output consists of the subset (XMI) file, RDFS (XML) file and SHACL (XML) file. 
