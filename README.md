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

The architecture of the mapper is shown in the figure below (or see folder "00 img"). In the configuration file the models and their selected subset of UML classes are specified. The selected subset of UML classes is extracted by the extractor-module. The extracted subset is mapped by the corresponding plugin to RDFS/SHACL and provided by the mapper in the output-folder as RDF/XML file. This architecture is now explained in more detail.

![Architecture](https://github.com/bastlyo/AISA-XMI-Mapper/blob/main/img/architecture.JPG)

## 2. Configuration File

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

1. The type of a model determines the plugin used for mapping. If no plugin is specified or a plugin with the provided name does not exist, the plugin for plain UML class diagrams is used. 
2. The location/name of a model's XMI file can be an absolute reference to an XMI file anywhere in the system. It is, however, recommended that the XMI file is in the input folder of the mapper's folder such that the reference is just "input/<fileName>.xmi".
3. The selected classes are a subset of a model. By default, the configuration file contains all classes from AIXM and FIXM selected from the comprehensive example.

Additional configuration files can be added without changing existing ones. However, the mapper can only consider one configuration file. Make sure that the reference to the to-be used configuration file is correctly set in the main module "mapper.xq" (variable $config). 

## 3. Mapper

The main module of the mapper delegates the processing to the extractor module and to plugins.

### 3.1. Extractor

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

## 4. RDFS/SHACL

After the RDFS/SHACL mapped by a plugin is returned to the mapper, it is written to an RDF/XML file with the name of the model appended by "\_subset" in the output folder.


In order to run the mapper, the main module "mapper.xq" must be executed using an XQuery processor, e.g. BaseX.
