module namespace plain="http://www.aisa-project.eu/xquery/plain";

declare namespace gml="http://www.opengis.net/gml/3.2#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace sh="http://www.w3.org/ns/shacl#";
declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare variable $plain:namespace:="http://www.aisa-project.eu/xquery/plain#"; 
declare variable $plain:xsd:="http://www.w3.org/2001/XMLSchema#";
declare variable $plain:rdf:="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare variable $plain:rdfs:="http://www.w3.org/2000/01/rdf-schema#";

declare function plain:map(
  $modelSubset as element()
) as element() {
  <rdf:RDF
    xmlns:sh="http://www.w3.org/ns/shacl#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#">
    {
      for $element in $modelSubset/elements/element
      return <sh:NodeShape rdf:about="{$plain:namespace}{$element/@name/string()}">
        <rdf:type rdf:resource="{$plain:rdfs}Class" />
        {
          plain:mapSubClasses($element, $modelSubset),
          plain:mapAttributes($element, $modelSubset),
          plain:mapConnectors($element, $modelSubset),
          plain:mapIndirectConnectors($element, $modelSubset)
        }
      </sh:NodeShape>
    }
  </rdf:RDF>
};

declare function plain:mapSubClasses(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $generalization in $element/links/Generalization
  where $generalization[@start=$element/@xmi:idref]
  let $superClass:=$modelSubset/elements/element[@xmi:idref=$generalization/@end]
  where fn:exists($superClass)
  return <rdfs:subClassOf rdf:resource="{$plain:namespace}{$superClass/@name/string()}" />
};

declare function plain:mapAttributes(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $attribute in $element/attributes/attribute
  return <sh:property rdf:parseType="Resource">
    
  </sh:property>
};

declare function plain:mapConnectors(
  $element as element(),
  $modelSubset as element()
) as element()* {
  
};

declare function plain:mapIndirectConnectors(
  $element as element(),
  $modelSubset as element()
) as element()* {
  
};