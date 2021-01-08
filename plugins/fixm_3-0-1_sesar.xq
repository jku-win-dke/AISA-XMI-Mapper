module namespace fixm_3-0-1_sesar="http://www.aisa-project.eu/xquery/fixm_3-0-1_sesar";

import module "http://www.aisa-project.eu/xquery/utilities" at "../utilities.xq";

declare namespace utilities="http://www.aisa-project.eu/xquery/utilities";
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
        else if($element/properties[@stereotype="choice"]) then
          fixm_3-0-1_sesar:mapChoice($element, $modelSubset)
        else
          fixm_3-0-1_sesar:mapPlain($element, $modelSubset)
    }
  </rdf:RDF>
};

declare %private function fixm_3-0-1_sesar:mapEnumeration(
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
      <sh:in rdf:parseType="Resource">
        { utilities:getCollection($element/attributes/attribute) }
      </sh:in>
    </sh:property>
  </sh:NodeShape>
};

declare %private function fixm_3-0-1_sesar:mapChoice(
  $element as element(),
  $modelSubset as element()
)as element()* {
  if(fn:exists($modelSubset/connectors/connector/source[@xmi:idref=$element/@xmi:idref])=false()) then
    fixm_3-0-1_sesar:mapPlain($element, $modelSubset)
} ;

declare %private function fixm_3-0-1_sesar:mapPlain(
  $element as element(),
  $modelSubset as element()
) as element() {
  <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$element/@name/string()}">
    <rdf:type rdf:resource="{$fixm_3-0-1_sesar:rdfs}Class" />
    {
      for $superElement in utilities:getSuperElements($element, $modelSubset, ())
      return 
        <rdfs:subClassOf rdf:resource="{$fixm_3-0-1_sesar:namespace}{$superElement/@name/string()}" />
    }
    {
      let $superElements:=utilities:getSuperElements($element, $modelSubset, ())
      return if(fn:exists($superElements)) then
        <sh:and rdf:parseType="Collection">
          {
            for $superElement in $superElements
            return 
              <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$superElement/@name/string()}" /> 
          } 
        </sh:and>
    }
    {
      let $uomAttribute:=$element/attributes/attribute[@name="uom"]
      return if(fn:exists($uomAttribute)) then
        <sh:and rdf:parseType="Collection">
          <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$uomAttribute/properties/@type/string()}" /> 
        </sh:and>
    }
    {
      let $genlinks:=$element/properties/@genlinks
      return if(fn:exists($genlinks)) then
        <sh:property rdf:parseType="Resource">
          <sh:path rdf:resource="{$fixm_3-0-1_sesar:rdf}value"/>
          {
            let $datatype:=fn:replace($genlinks, "Parent=", "")
            let $datatype:=fn:replace($datatype, ";", "")
            let $datatype:=
              if($datatype="int") then "integer" 
              else if($datatype="duration") then "string"
              else if($datatype="double") then "decimal"
              else $datatype
            return 
              <sh:datatype rdf:resource="{$fixm_3-0-1_sesar:xsd}{$datatype}"/>
          }
          {
            for $constraint in $element/constraints/constraint
            return 
              if($constraint[fn:lower-case(@type)="pattern"]) then
                <sh:pattern rdf:datatype="{$fixm_3-0-1_sesar:xsd}string">
                  { $constraint/@name/string() }
                </sh:pattern>
              else if($constraint[fn:lower-case(@type)="range"]) then
                let $min:=fn:substring-after($constraint/@name, "[")
                let $min:=fn:substring-before($min, "..")
                let $max:=fn:substring-after($constraint/@name, "..")
                let $max:=fn:substring-before($max, "]")
                return (
                  if($min!="*") then
                    if(fn:contains($min, ".")) then
                      <sh:minInclusive rdf:datatype="{$fixm_3-0-1_sesar:xsd}decimal">
                        { $min }
                      </sh:minInclusive>
                    else
                      <sh:minInclusive rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">
                        { $min }
                      </sh:minInclusive>,
                  if($max!="*") then
                    if(fn:contains($max, ".")) then
                      <sh:maxInclusive rdf:datatype="{$fixm_3-0-1_sesar:xsd}decimal">
                        { $max }
                      </sh:maxInclusive>
                    else
                      <sh:maxInclusive rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">
                        { $max }
                      </sh:maxInclusive>
                )
              else if($constraint[fn:lower-case(@type)="length"]) then
                let $min:=fn:substring-after($constraint/@name, "[")
                let $min:=fn:substring-before($min, "..")
                let $max:=fn:substring-after($constraint/@name, "..")
                let $max:=fn:substring-before($max, "]")
                return (
                  if($min!="*") then
                    <sh:minLength rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">
                      { $min }
                    </sh:minLength>,
                  if($max!="*") then
                    <sh:maxLength rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">
                      { $max }
                    </sh:maxLength>
                )
              else () (: constraint type: usage, xsd, relation :) 
          }
          <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:minCount>
          <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:maxCount>
        </sh:property>
    }
    { fixm_3-0-1_sesar:mapAttributes($element, $modelSubset) }
    { fixm_3-0-1_sesar:mapConnectors($element, $modelSubset) }
  </sh:NodeShape>
} ;

declare %private function fixm_3-0-1_sesar:mapAttributes(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $attribute in $element/attributes/attribute
  where $attribute[@name!="uom"]
  let $attributeElement:=$modelSubset/elements/element[@name=$attribute/properties/@type]
  let $attributeConnectors:=$modelSubset/connectors/connector[source/@xmi:idref=$attributeElement/@xmi:idref]
  return 
    if($attributeElement/properties[@stereotype="choice"] and fn:exists($attributeConnectors)) then (
      <sh:property rdf:parseType="Resource">
        <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attribute/@name/string()}" />
        <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">0</sh:minCount>
          {
            let $maxCount:=$attribute/bounds/@upper/string()
            return if($maxCount!="*") then
              <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$maxCount}</sh:maxCount>
          }
      </sh:property>,
      <sh:or rdf:parseType="Collection">
        {
          for $connector in $attributeConnectors
          return 
            <rdf:Description>
              <sh:property rdf:parseType="Resource">
                <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attribute/@name/string()}" />
                <sh:class rdf:resource="{$fixm_3-0-1_sesar:namespace}{$connector/target/model/@name/string()}" />
              </sh:property>
            </rdf:Description>
        }
      </sh:or>
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

declare %private function fixm_3-0-1_sesar:mapConnectors(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $connector in $modelSubset/connectors/connector
  where $connector/properties[@ea_type!="Generalization"]
  where $connector/source[@xmi:idref=$element/@xmi:idref]
  let $pathName:=
    if(fn:exists($connector/@name)) then $connector/@name/string()
    else
      fn:lower-case(fn:substring($connector/target/model/@name/string(), 1, 1))
      ||fn:substring($connector/target/model/@name/string(), 2)
  let $targetElement:=$modelSubset/elements/element[@xmi:idref=$connector/target/@xmi:idref]
  let $targetConnectors:=$modelSubset/connectors/connector
    [source/@xmi:idref=$targetElement/@xmi:idref]
    [properties/@ea_type!="Generalization"]
  return 
    if($targetElement/properties[@stereotype="choice"] and fn:exists($targetConnectors)) then (
      <sh:property rdf:parseType="Resource">
        <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$pathName}" />
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
      </sh:property>,
      <sh:xone rdf:parseType="Collection">
        {
          for $connector in $targetConnectors
          return 
            <rdf:Description>
              <sh:property rdf:parseType="Resource">
                <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$pathName}" />
                <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:minCount>
                <sh:class rdf:resource="{$fixm_3-0-1_sesar:namespace}{$connector/target/model/@name/string()}" />
              </sh:property>
            </rdf:Description>
       }
     </sh:xone>
    )
    else
      <sh:property rdf:parseType="Resource">
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