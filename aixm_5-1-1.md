### 3.1 RDFS

UML classes are mapped to RDFS classes except classes containing "BaseType" in the name (we want to already resolve AIXM base types in the actually used datatype). In addition, an RDFS label and RDFS comment are added. If a generalization to a class exists, an RDFS subClassOf property is added (again, except generalizations to classes containing "BaseType" in the name).
               
Example AIXM TerminalSegmentPoint
          
	  aixm:TerminalSegmentPoint 
	          a rdfs:Class ;
	          rdfs:label „TerminalSegmentPoint“ ;
	          rdfs:comment „…“ ;
	          rdfs:subClassOf aixm:SegmentPoint .
          
Attributes of UML classes are mapped to RDF properties except attributes from UML classes with stereotype "CodeList" or "enumeration". These stereotypes provide a list of codes to be used as value for attributes and require special consideration for mapping. We cannot use domain and range for RDF properties since we assume global names in order to improve SPARQL query writing by shorter names (instead we use OWL, see details later). 

Example AIXM RouteSegment length
          aixm:length a rdf:Property .

One and the same property may be used by multiple classes but with a different range. Therefore, we use OWL. But properties of "CodeList", "enumeration" or "DataType" are not mapped using OWL.

Example AIXM TerminalSegmentPoint
          
	  aixm:TerminalSegmentPoint
	          rdfs:subClassOf [
		          rdf:type owl:Restriction ;
		          owl:onProperty aixm:leadRadial ;
		          owl:allValuesFrom aixm:ValBearingType ;
	          ] ;
	          rdfs:subClassOf [
		          rdf:type owl:Restriction ;
		          owl:onProperty aixm:leadDME ;
		          owl:allValuesFrom aixm:ValDistanceType ;
	          ] ; ... .
	  
Using OWL we can infer that a RDF property within a certain RDFS class has a certain type and, thus, the correct SHACL shape can target that node.

Example OWL Entailment
	
	Basis: OWL construct
	aixm:TerminalSegmentPoint
		rdfs:subClassOf [
			rdf:type owl:Restriction ;
			owl:onProperty aixm:indicatorFACF ;
			owl:allValuesFrom aixm:CodeYesNoType ;
		] ; ...
		
	Basis: RDFS data
	ex:TSP1
		a aixm:TerminalSegmentPoint
		aixm:indicatorFACF [
			rdf:value "YES" ;
		] ; ...	.
		
	Infers: Entailment
	ex:TSP1
		a aixm:TerminalSegmentPoint
		aixm:indicatorFACF [
			rdf:value "YES" ;
			a aixm:CodeYesNoType ;
		] ; ...	.
			
Connectors between UML classes may be mapped bi-directional or uni-directional. Aeronautical UML models have been designed with the aim of mapping to XML in a hierarchical style. We follow this approach for mapping connectors and also traverse association classes in one direction (see details later). 
Connectors (except generalizations and dependencies) are mapped to RDF properties similar to attributes. The role name (at the target end) is used as property name. 

Example AIXM RoutePortion startsAt
	
	aixm:start a rdf:Property .
		
If there is an association class, an connector is mapped to two RDF properties. The first property represents the connection from the source class to the association class, while the second property represents the connection from the association class to the target class.

Example AIXM Airspace hasGeometry
	
	aixm:airspaceGeometryComponent a rdf:Property .
	aixm:airspaceVolume a rdf:Property .
