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
          (: rdfs:subClassOf :)
          for $generalization in $element/links/Generalization
          where $generalization[@start=$element/@xmi:idref]
          let $superClass:=$modelSubset/elements/element[@xmi:idref=$generalization/@end]
          where fn:exists($superClass)
          return <rdfs:subClassOf rdf:resource="{$plain:namespace}{$superClass/@name/string()}" />
        }
        {
          (: sh:and :)
          for $generalization in $element/links/Generalization
          where $generalization[@start=$element/@xmi:idref]
          let $superClass:=$modelSubset/elements/element[@xmi:idref=$generalization/@end]
          where fn:exists($superClass)
          return <sh:and rdf:parseType="Collection">
            <sh:NodeShape rdf:about="{$plain:namespace}{$superClass/@name/string()}" />
          </sh:and>
        }
        {
          (: attributes :)
          for $attribute in $element/attributes/attribute
          return <sh:property rdf:parseType="Resource">
            <sh:path rdf:resource="{$plain:namespace}{$attribute/@name/string()}" />
            <sh:class rdf:resource="{$plain:namespace}{$attribute/properties/@type/string()}" />
            <sh:maxCount rdf:datatype="{$plain:xsd}integer">1</sh:maxCount> 
          </sh:property>
        }
        {
          (: connectors :)
          for $connector in $modelSubset/connectors/connector
          where $connector/source[@xmi:idref=$element/@xmi:idref]
          let $pathName:=
            if(fn:exists($connector/target/role/@name)) then
              $connector/target/role/@name/string()
            else if(fn:exists($connector/@name)) then
              $connector/@name/string()
            else
              $connector/target/model/@name/string()
          let $cardinality:=$connector/target/type/@multiplicity
          return <sh:property rdf:parseType="Resource">
            <sh:path rdf:resource="{$plain:namespace}{$pathName}" />
            <sh:class rdf:resource="{$plain:namespace}{$connector/target/model/@name/string()}" />
            {
              let $minCount:=fn:substring($cardinality, 1, 1)
              return if(fn:exists($minCount) and $minCount!="*" and $minCount!="0") then
                <sh:minCount rdf:datatype="{$plain:xsd}integer">{$minCount}</sh:minCount>
            }
            {
              let $maxCount:=fn:substring($cardinality, fn:string-length($cardinality), 1)
              return if(fn:exists($maxCount) and $maxCount!="*") then
                <sh:maxCount rdf:datatype="{$plain:xsd}integer">{$maxCount}</sh:maxCount> 
            }
          </sh:property>
        }
        {
          for $connector in $modelSubset/connectors/connector
          where $element[@xmi:idref=$connector/extendedProperties/@associationclass]
          let $pathName:=
            if(fn:exists($connector/target/role/@name)) then
              $connector/target/role/@name/string()
            else if(fn:exists($connector/@name)) then
              $connector/@name/string()
            else
              $connector/target/model/@name/string()
          return <sh:property rdf:parseType="Resource">
            <sh:path rdf:resource="{$plain:namespace}{$pathName}" />
            <sh:class rdf:resource="{$plain:namespace}{$connector/target/model/@name/string()}" />
            <sh:minCount rdf:datatype="{$plain:xsd}integer">1</sh:minCount>
            <sh:maxCount rdf:datatype="{$plain:xsd}integer">1</sh:maxCount> 
          </sh:property>
        }
      </sh:NodeShape>
    }
  </rdf:RDF>
};