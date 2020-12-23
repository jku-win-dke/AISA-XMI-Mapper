module namespace fixm_3-0-1_sesar="http://www.aisa-project.eu/xquery/fixm_3-0-1_sesar";

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace sh="http://www.w3.org/ns/shacl#";
declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare variable $fixm_3-0-1_sesar:namespace:="http://www.aisa-project.eu/vocabulary/fixm_3-0-1_sesar#"; 
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
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:fixm="http://www.aisa-project.eu/vocabulary/fixm_3-0-1_sesar#">
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
) as element() {
  <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$element/@name/string()}">
    <rdf:type rdf:resource="{$fixm_3-0-1_sesar:rdfs}Class" />
    <sh:property rdf:parseType="Resource">
      {
        if(fn:ends-with($element/@name/string(), "Measure")) then
          <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}uom" />
        else <sh:path rdf:resource="{$fixm_3-0-1_sesar:rdf}value" />
      }
      <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:minCount>
      <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:maxCount>
      <sh:in rdf:parseType="Resource">
        { fixm_3-0-1_sesar:getCollection($element/attributes/attribute) }
      </sh:in>
    </sh:property>
  </sh:NodeShape>
} ;

declare function fixm_3-0-1_sesar:mapChoice(
  $element as element(),
  $modelSubset as element()
) {} ;

declare function fixm_3-0-1_sesar:mapPlain(
  $element as element(),
  $modelSubset as element()
) as element() {
  <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$element/@name/string()}">
    <rdf:type rdf:resource="{$fixm_3-0-1_sesar:rdfs}Class" />
    {
      for $superElement in fixm_3-0-1_sesar:getSuperElements($element, $modelSubset)
      return <rdfs:subClassOf rdf:resource="{$fixm_3-0-1_sesar:namespace}{$superElement/@name/string()}" />
    }
    {
      for $superElement in fixm_3-0-1_sesar:getSuperElements($element, $modelSubset)
      return <sh:and rdf:parseType="Collection">
        { <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$superElement/@name/string()}" /> } 
      </sh:and>
    }
    {
      let $uomAttribute:=$element/attributes/attribute[@name="uom"]
      return if(fn:exists($uomAttribute)) then
        <sh:and rdf:parseType="Collection">
          { <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$uomAttribute/properties/@type/string()}" /> } 
        </sh:and>
    }
    {
      if(fn:exists($element/properties/@genlinks)) then
        <sh:property rdf:parseType="Resource">
          <sh:path rdf:resource="{$fixm_3-0-1_sesar:rdf}value"/>
          {
            let $datatype:=fn:replace($element/properties/@genlinks, "Parent=", "")
            let $datatype:=fn:replace($datatype, ";", "")
            let $datatype:=
              if($datatype="int") then "integer" 
              else if($datatype="duration") then "string"
              else if($datatype="double") then "decimal"
              else $datatype
            return <sh:datatype rdf:resource="{$fixm_3-0-1_sesar:xsd}{$datatype}"/>
          }
          <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:minCount>
          <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:maxCount> 
        </sh:property>
    }
    { fixm_3-0-1_sesar:mapAttributes($element, $modelSubset) }
    { fixm_3-0-1_sesar:mapConnectors($element, $modelSubset) }
  </sh:NodeShape>
} ;

declare function fixm_3-0-1_sesar:getSuperElements(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $generalization in $element/links/Generalization
  where $generalization[@start=$element/@xmi:idref]
  let $superElement:=$modelSubset/elements/element[@xmi:idref=$generalization/@end]
  return $superElement
};

declare function fixm_3-0-1_sesar:getCollection(
  $elements as element()*
) as element()? {
  if(fn:count($elements)>0) then
    <rdf:rest rdf:parseType="Resource">
      <rdf:first>{$elements[1]/@name/string()}</rdf:first>
      {
        fixm_3-0-1_sesar:getCollection(fn:subsequence($elements, 2))
      }
    </rdf:rest>
  else
    <rdf:rest rdf:resource="{$fixm_3-0-1_sesar:rdf}nil"/>
};

(:maxcount???:)
declare function fixm_3-0-1_sesar:mapChoiceAttributeToXone(
  $element as element(),
  $modelSubset as element(),
  $attributeName as xs:string
) as element() {
  <sh:xone rdf:parseType="Collection">
  {
    for $connector in $modelSubset/connectors/connector
    where $connector/source[@xmi:idref=$element/@xmi:idref]
    return <rdf:Description>
      <sh:property rdf:parseType="Resource">
         <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attributeName}" />
         <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:minCount>
         <sh:class rdf:resource="{$fixm_3-0-1_sesar:namespace}{$connector/target/model/@name/string()}" />
       </sh:property>
     </rdf:Description>
   }
   </sh:xone>
};

declare function fixm_3-0-1_sesar:mapAttributes(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $attribute in $element/attributes/attribute
  where $attribute[@name!="uom"]
  let $attributeElement:=$modelSubset/elements/element[@name=$attribute/properties/@type]
  return if($attributeElement/properties[@stereotype="choice"]) then (
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attribute/@name/string()}" />
      <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">0</sh:minCount>
      {
        let $maxCount:=$attribute/bounds/@upper/string()
        return if($maxCount!="*") then
          <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$maxCount}</sh:maxCount>
      }
    </sh:property>,
    fixm_3-0-1_sesar:mapChoiceAttributeToXone($attributeElement, $modelSubset, $attribute/@name/string())
  )
  else
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attribute/@name/string()}" />
      <sh:node rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attribute/properties/@type/string()}" />
      <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">0</sh:minCount>
      {
        let $maxCount:=$attribute/bounds/@upper/string()
        return if($maxCount!="*") then
          <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$maxCount}</sh:maxCount>
      }
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
      fn:lower-case(fn:substring($connector/target/model/@name/string(), 1, 1))
      ||fn:substring($connector/target/model/@name/string(), 2)
  return <sh:property rdf:parseType="Resource">
    <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$pathName}" />
    <sh:node rdf:resource="{$fixm_3-0-1_sesar:namespace}{$connector/target/model/@name/string()}" />
    {
      let $minCount:=fn:substring-before($connector/target/type/@multiplicity, "..")
      return if(fn:exists($minCount) and $minCount!="*") then
        <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$minCount}</sh:minCount>
    }
    {
      let $maxCount:=fn:substring-after($connector/target/type/@multiplicity, "..")
      return if(fn:exists($maxCount) and $maxCount!="*") then
        <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$maxCount}</sh:maxCount> 
      }
  </sh:property>
};