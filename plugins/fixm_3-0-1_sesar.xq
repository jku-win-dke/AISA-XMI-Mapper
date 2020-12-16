module namespace fixm_3-0-1_sesar="http://www.aisa-project.eu/xquery/fixm_3-0-1_sesar";

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace sh="http://www.w3.org/ns/shacl#";
declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare variable $fixm_3-0-1_sesar:namespace:="http://www.fixm.aero/"; 
declare variable $fixm_3-0-1_sesar:xsd:="http://www.w3.org/2001/XMLSchema#";
declare variable $fixm_3-0-1_sesar:rdf:="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare variable $fixm_3-0-1_sesar:rdfs:="http://www.w3.org/2000/01/rdf-schema#";

declare function fixm_3-0-1_sesar:map(
  $modelSubset as element()
) as element() {
  <rdf:RDF
    xmlns:sh="http://www.w3.org/ns/shacl#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#">
    {
      for $element in $modelSubset/elements/element
      return
        if($element/properties[@stereotype="enumeration"]) then
          fixm_3-0-1_sesar:mapEnumeration($element, $modelSubset)
        else if ($element/properties[@stereotype="choice"]) then
          fixm_3-0-1_sesar:mapChoice($element, $modelSubset)
        else
          fixm_3-0-1_sesar:mapPlain($element, $modelSubset)
    }
  </rdf:RDF>
};

declare function fixm_3-0-1_sesar:mapEnumeration(
  $element as element(),
  $modelSubset as element()
) as element()* {
  <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$element/@name/string()}" />
} ;

declare function fixm_3-0-1_sesar:mapChoice(
  $element as element(),
  $modelSubset as element()
) as element()* {
  <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$element/@name/string()}" />
} ;

declare function fixm_3-0-1_sesar:mapPlain(
  $element as element(),
  $modelSubset as element()
) as element()* {
  <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$element/@name/string()}">
    <rdf:type rdf:resource="{$fixm_3-0-1_sesar:rdfs}Class" />
    {
      fixm_3-0-1_sesar:mapAttributes($element)
    }
    {
      fixm_3-0-1_sesar:mapConnectors($element, $modelSubset)
    }
  </sh:NodeShape>
} ;

declare function fixm_3-0-1_sesar:mapAttributes(
  $element as element()
) as element()* {
  for $attribute in $element/attributes/attribute
  return <sh:property rdf:parseType="Resource">
    <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attribute/@name/string()}" />
    <sh:node rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attribute/properties/@type/string()}" />
    <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:maxCount> 
  </sh:property>
};

declare function fixm_3-0-1_sesar:mapConnectors(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $connector in $modelSubset/connectors/connector
  where $connector/source[@xmi:idref=$element/@xmi:idref]
  let $pathName:=
    if(fn:exists($connector/@name)) then
      $connector/@name/string()
    else
      $connector/target/model/@name/string()
  let $cardinality:=$connector/target/type/@multiplicity
  return <sh:property rdf:parseType="Resource">
    <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$pathName}" />
    <sh:class rdf:resource="{$fixm_3-0-1_sesar:namespace}{$connector/target/model/@name/string()}" />
    {
      let $minCount:=fn:substring($cardinality, 1, 1)
      return if(fn:exists($minCount) and $minCount!="*" and $minCount!="0") then
        <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$minCount}</sh:minCount>
    }
    {
      let $maxCount:=fn:substring($cardinality, fn:string-length($cardinality), 1)
      return if(fn:exists($maxCount) and $maxCount!="*") then
        <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$maxCount}</sh:maxCount> 
      }
  </sh:property>
};