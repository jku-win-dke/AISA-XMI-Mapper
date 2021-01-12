module namespace plain="http://www.aisa-project.eu/xquery/plain";

import module "http://www.aisa-project.eu/xquery/utilities" at "utilities.xq";

declare namespace utilities="http://www.aisa-project.eu/xquery/utilities";
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
      return 
        <sh:NodeShape rdf:about="{$plain:namespace}{$element/@name/string()}">
          <rdf:type rdf:resource="{$plain:rdfs}Class" />
          {
            for $superElement in utilities:getSuperElements($element, $modelSubset, ())
            return 
              <rdfs:subClassOf rdf:resource="{$plain:namespace}{$superElement/@name/string()}" />
          }
          {
            let $superElements:=utilities:getSuperElements($element, $modelSubset, ())
            return if(fn:exists($superElements)) then
              <sh:and rdf:parseType="Collection">
                {
                  for $superElement in $superElements
                  return 
                    <sh:NodeShape rdf:about="{$plain:namespace}{$superElement/@name/string()}" /> 
                } 
              </sh:and>
          }
          {
            for $attribute in $element/attributes/attribute
            return 
              <sh:property rdf:parseType="Resource">
                <sh:path rdf:resource="{$plain:namespace}{$attribute/@name/string()}" />
                <sh:class rdf:resource="{$plain:namespace}{$attribute/properties/@type/string()}" />
                <sh:minCount rdf:datatype="{$plain:xsd}integer">0</sh:minCount>
                {
                  let $maxCount:=$attribute/bounds/@upper/string()
                  return if($maxCount!="*") then
                    <sh:maxCount rdf:datatype="{$plain:xsd}integer">{$maxCount}</sh:maxCount>
                }
              </sh:property>
          }
          {
            for $connector in $modelSubset/connectors/connector
            where $connector/source[@xmi:idref=$element/@xmi:idref]
            let $targetName:=
              if(fn:exists($connector/extendedProperties/@associationclass)) then
                $modelSubset/elements/element[@xmi:idref=$connector/extendedProperties/@associationclass]/@name/string()
              else $connector/target/model/@name/string()
            let $pathName:=
              if(fn:exists($connector/target/role/@name)) then
                $connector/target/role/@name/string()
              else
                "the"||$targetName
            let $cardinality:=$connector/target/type/@multiplicity
            return 
              <sh:property rdf:parseType="Resource">
                <sh:path rdf:resource="{$plain:namespace}{$pathName}" />
                <sh:class rdf:resource="{$plain:namespace}{$targetName}" />
                {
                  let $minCount:=fn:substring-before($cardinality, "..")
                  return if(fn:exists($minCount) and $minCount!="*") then
                    <sh:minCount rdf:datatype="{$plain:xsd}integer">{$minCount}</sh:minCount>
                }
                {
                  let $maxCount:=fn:substring-after($cardinality, "..")
                  return if(fn:exists($maxCount) and $maxCount!="*") then
                    <sh:maxCount rdf:datatype="{$plain:xsd}integer">{$maxCount}</sh:maxCount> 
                }
              </sh:property>
          }
          {
            for $connector in $modelSubset/connectors/connector
            where $element[@xmi:idref=$connector/extendedProperties/@associationclass]
            let $targetName:=$connector/target/model/@name/string()
            let $pathName:="the"||$targetName
            return 
              <sh:property rdf:parseType="Resource">
                <sh:path rdf:resource="{$plain:namespace}{$pathName}" />
                <sh:class rdf:resource="{$plain:namespace}{$targetName}" />
                <sh:minCount rdf:datatype="{$plain:xsd}integer">1</sh:minCount>
                <sh:maxCount rdf:datatype="{$plain:xsd}integer">1</sh:maxCount> 
              </sh:property>
          }
        </sh:NodeShape>
    }
  </rdf:RDF>
};