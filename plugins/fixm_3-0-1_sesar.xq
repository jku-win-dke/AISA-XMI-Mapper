module namespace fixm_3-0-1_sesar="http://www.aisa-project.eu/xquery/fixm_3-0-1_sesar";

import module "http://www.aisa-project.eu/xquery/utilities" at "utilities.xq";

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
      (: mapping of classes based on their stereotype :)
      for $element in $modelSubset/elements/element
      return
        if($element/properties[@stereotype="enumeration"]) 
        then fixm_3-0-1_sesar:mapEnumeration($element, $modelSubset)
        else if($element/properties[@stereotype="choice"]) 
        then fixm_3-0-1_sesar:mapChoice($element, $modelSubset)
        else fixm_3-0-1_sesar:mapPlain($element, $modelSubset)
    }
  </rdf:RDF>
};

declare %private function fixm_3-0-1_sesar:mapEnumeration(
  $element as element(),
  $modelSubset as element()
) as element() {
  <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$element/@name/string()}">
    <sh:property rdf:parseType="Resource">
      <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:minCount>
      <sh:in rdf:parseType="Resource">
        { utilities:getCollection($element/attributes/attribute) }
      </sh:in>
      {
        (: map property shapes of enumerations with "Measure" at the end to fixm:uom instead of rdf:value :)
        if(fn:ends-with($element/@name/string(), "Measure"))
        then <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}uom" />
        else <sh:path rdf:resource="{$fixm_3-0-1_sesar:rdf}value" />
      }
    </sh:property>
  </sh:NodeShape>
};

declare %private function fixm_3-0-1_sesar:mapChoice(
  $element as element(),
  $modelSubset as element()
)as element() {
  <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$element/@name/string()}">
    {
      (: map a <<choice>> class which is only used as attribute into a linking node shape :)
      if($modelSubset/elements/element/attributes/attribute/properties[@type=$element/@name]) 
      then
        <sh:xone rdf:parseType="Collection">
          {
            for $attribute in $element/attributes/attribute
            let $attributeElement:=$modelSubset/elements/element[@name=$attribute/properties/@type]
            return 
              <rdf:Description>
                { fixm_3-0-1_sesar:getTargetConstraint($attributeElement, $modelSubset, $attribute/properties/@type/string())}
              </rdf:Description>
          }
          {
            for $connector in $modelSubset/connectors/connector
              [source/@xmi:idref=$element/@xmi:idref]
              [properties/@ea_type!="Generalization"]
            let $targetElement:=$modelSubset/elements/element[@xmi:idref=$connector/target/@xmi:idref]
            return 
              <rdf:Description>
                { fixm_3-0-1_sesar:getTargetConstraint($targetElement, $modelSubset, $connector/target/model/@name/string())}
              </rdf:Description>
          }
        </sh:xone>
      else (: map a <<choice>> class which is linked into a RDFS class :) (
        <rdf:type rdf:resource="{$fixm_3-0-1_sesar:rdfs}Class" />,
        <sh:xone rdf:parseType="Collection">
          {
            for $attribute in $element/attributes/attribute
            let $attributeElement:=$modelSubset/elements/element
              [@name=$attribute/properties/@type]
            return
              <rdf:Description>
                <sh:property rdf:parseType="Resource">
                  <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attribute/@name/string()}" />
                  <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:minCount>
                  { fixm_3-0-1_sesar:getTargetConstraint($attributeElement, $modelSubset, $attribute/properties/@type/string())}
                  {
                    let $maxCount:=$attribute/bounds/@upper/string()
                    return 
                      if($maxCount!="*") 
                      then <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$maxCount}</sh:maxCount>
                  }
                </sh:property>
              </rdf:Description>
            }
            {
              for $connector in $modelSubset/connectors/connector
                [source/@xmi:idref=$element/@xmi:idref]
                [properties/@ea_type!="Generalization"]
              let $targetElement:=$modelSubset/elements/element
                [@xmi:idref=$connector/target/@xmi:idref]
              let $pathName:=
                if(fn:exists($connector/@name)) 
                then $connector/@name/string()
                else fn:lower-case(fn:substring($connector/target/model/@name/string(), 1, 1))
                  ||fn:substring($connector/target/model/@name/string(), 2)
              return 
                <rdf:Description>
                  <sh:property rdf:parseType="Resource">
                    <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$pathName}" />
                    <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:minCount>
                    { fixm_3-0-1_sesar:getTargetConstraint($targetElement, $modelSubset, $connector/target/model/@name/string())}
                    {
                      let $maxCount:=fn:substring-after($connector/target/type/@multiplicity, "..")
                      return 
                        if(fn:exists($maxCount) and $maxCount!="*") 
                        then <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$maxCount}</sh:maxCount> 
                    }
                  </sh:property>
                </rdf:Description>
          }
        </sh:xone>
      )
    }
  </sh:NodeShape>
};

declare %private function fixm_3-0-1_sesar:mapPlain(
  $element as element(),
  $modelSubset as element()
) as element() {
  let $superElements:=utilities:getSuperElements($element, $modelSubset, (), false())
  let $allSuperElements:=utilities:getSuperElements($element, $modelSubset, (), true())
  return
    <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$element/@name/string()}">
      {
        (: map into RDFS class if no XSD basis exists :)
        if(fn:exists($element/properties/@genlinks)=false()
          and fn:exists($allSuperElements/properties/@genlinks)=false()) 
        then <rdf:type rdf:resource="{$fixm_3-0-1_sesar:rdfs}Class" />  
      }
      {
        (: map super classes into rdfs:subClassOf if no XSD basis exists :)
        if(fn:exists($element/properties/@genlinks)=false()
          and fn:exists($allSuperElements/properties/@genlinks)=false()) 
        then 
          for $superElement in $superElements
          return <rdfs:subClassOf rdf:resource="{$fixm_3-0-1_sesar:namespace}{$superElement/@name/string()}" />
      }
      {
        (: map super classes into sh:and :)
        if(fn:exists($superElements)) 
        then 
          <sh:and rdf:parseType="Collection">
            {
              for $superElement in $superElements
              return <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$superElement/@name/string()}" /> 
            } 
          </sh:and>
      }
      {
        (: map types of attribute named "uom" into sh:and :)
        let $uomAttributes:=$element/attributes/attribute[@name="uom"]
        return 
          if(fn:exists($uomAttributes)) 
          then
            <sh:and rdf:parseType="Collection">
              {
                for $uom in $uomAttributes
                return <sh:NodeShape rdf:about="{$fixm_3-0-1_sesar:namespace}{$uom/properties/@type/string()}" />  
              }
            </sh:and>
      }
      {
        (: if XSD basis exists, add rdf:value propery shape :)
        if(fn:exists($element/properties/@genlinks) 
          or fn:exists($allSuperElements/properties/@genlinks)) 
        then
          <sh:property rdf:parseType="Resource">
            <sh:path rdf:resource="{$fixm_3-0-1_sesar:rdf}value"/>
            <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:maxCount>
            { fixm_3-0-1_sesar:mapConstraints($element/constraints/constraint) }
            {
              (: add sh:datatype to rdf:value property shape if it exists :)
              let $datatype:=fn:replace($element/properties/@genlinks, "Parent=", "")
              let $datatype:=fn:replace($datatype, ";", "")
              let $datatype:=
                if($datatype="int") then "integer" 
                else if($datatype="duration") then "string"
                else if($datatype="double") then "decimal"
                else $datatype
              return 
                if(fn:exists($element/properties/@genlinks)) 
                then <sh:datatype rdf:resource="{$fixm_3-0-1_sesar:xsd}{$datatype}"/>
            }
        </sh:property>
      }
      {
        (: map attributes of a class into property shapes :)
        for $attribute in $element/attributes/attribute
        where $attribute[@name!="uom"]
        return 
          (: case of attribute type being a XSD datatype :)
          if($attribute/properties[@type="int" or @type="string" or @type="double" or @type="duration" or @type="boolean"]) 
          then
            <sh:property rdf:parseType="Resource">
              <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attribute/@name/string()}" />
              {
                let $maxCount:=$attribute/bounds/@upper/string()
                return 
                  if($maxCount!="*") 
                  then <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$maxCount}</sh:maxCount>
              }
              {
                let $datatype:=$attribute/properties/@type
                let $datatype:=
                  if($datatype="int") then "integer"
                  else if($datatype="double") then "decimal"
                  else if($datatype="duration") then "string"
                  else $datatype
                return 
                  <sh:node>
                    <sh:NodeShape>
                      <sh:property rdf:parseType="Resource">
                        <sh:path rdf:resource="{$fixm_3-0-1_sesar:rdf}value"/>
                        <sh:datatype rdf:resource="{$fixm_3-0-1_sesar:xsd}{$datatype}"/>
                        { fixm_3-0-1_sesar:mapConstraints($attribute/Constraints/Constraint) }
                      </sh:property>
                    </sh:NodeShape>
                  </sh:node>
              }
            </sh:property>
          else (: all other cases of mapping attributes :)
            <sh:property rdf:parseType="Resource">
              <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$attribute/@name/string()}" />
              {
                let $maxCount:=$attribute/bounds/@upper/string()
                return 
                  if($maxCount!="*") 
                  then <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$maxCount}</sh:maxCount>
              }
              {
                let $attributeElement:=$modelSubset/elements/element
                  [@name=$attribute/properties/@type]
                return fixm_3-0-1_sesar:getTargetConstraint($attributeElement, $modelSubset, $attribute/properties/@type/string())
              }
            </sh:property>
      }
      {
        (: map connectors of a class into property shapes :)
        for $connector in $modelSubset/connectors/connector
        where $connector/properties[@ea_type!="Generalization"]
        where $connector/source[@xmi:idref=$element/@xmi:idref]
        let $pathName:=
          if(fn:exists($connector/@name))
          then $connector/@name/string()
          else fn:lower-case(fn:substring($connector/target/model/@name/string(), 1, 1))
            ||fn:substring($connector/target/model/@name/string(), 2)
        let $targetElement:=$modelSubset/elements/element
          [@xmi:idref=$connector/target/@xmi:idref]
        return 
          <sh:property rdf:parseType="Resource">
            <sh:path rdf:resource="{$fixm_3-0-1_sesar:namespace}{$pathName}" />
            { fixm_3-0-1_sesar:getTargetConstraint($targetElement, $modelSubset, $connector/target/model/@name/string()) }
            {
              let $minCount:=fn:substring-before($connector/target/type/@multiplicity, "..")
              return 
                if(fn:exists($minCount) and $minCount!="*" and $minCount!="0") 
                then <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$minCount}</sh:minCount>
            }
            {
              let $maxCount:=fn:substring-after($connector/target/type/@multiplicity, "..")
              return 
                if(fn:exists($maxCount) and $maxCount!="*") 
                then <sh:maxCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$maxCount}</sh:maxCount> 
            }
          </sh:property>
      }
  </sh:NodeShape>
};

declare %private function fixm_3-0-1_sesar:getTargetConstraint(
  $element as element()*,
  $modelSubset as element(),
  $name as xs:string
) {
  if(fn:exists($element/properties/@genlinks)
    or fn:exists(utilities:getSuperElements($element, $modelSubset, (), true())/properties/@genlinks)
    or $element/properties[@stereotype="enumeration"]
    or $element/properties[@stereotype="choice"]) 
  then <sh:node rdf:resource="{$fixm_3-0-1_sesar:namespace}{$name}" />
  else <sh:class rdf:resource="{$fixm_3-0-1_sesar:namespace}{$name}" />
};
 
declare %private function fixm_3-0-1_sesar:mapConstraints(
  $constraints as element()*
) as element()*{
  for $constraint in $constraints
  return 
    if($constraint[fn:lower-case(@type)="pattern"]) 
    then <sh:pattern rdf:datatype="{$fixm_3-0-1_sesar:xsd}string">^{fn:normalize-space($constraint/@name/string())}$</sh:pattern>
    else if($constraint[fn:lower-case(@type)="required"]) 
    then <sh:minCount rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">1</sh:minCount>
    else if($constraint[fn:lower-case(@type)="range"])
    then
      let $min:=fn:substring-after($constraint/@name, "[")
      let $min:=fn:substring-before($min, "..")
      let $max:=fn:substring-after($constraint/@name, "..")
      let $max:=fn:substring-before($max, "]")
      return (
        if($min!="*") 
        then
          if(fn:contains($min, ".")) 
          then <sh:minInclusive rdf:datatype="{$fixm_3-0-1_sesar:xsd}decimal">{$min}</sh:minInclusive>
          else <sh:minInclusive rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$min}</sh:minInclusive>,
        if($max!="*")
        then
          if(fn:contains($max, "."))
          then <sh:maxInclusive rdf:datatype="{$fixm_3-0-1_sesar:xsd}decimal">{$max}</sh:maxInclusive>
          else <sh:maxInclusive rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$max}</sh:maxInclusive>
      )
    else if($constraint[fn:lower-case(@type)="length"]) 
    then
      let $min:=fn:substring-after($constraint/@name, "[")
      let $min:=fn:substring-before($min, "..")
      let $max:=fn:substring-after($constraint/@name, "..")
      let $max:=fn:substring-before($max, "]")
      return (
        if($min!="*") 
        then <sh:minLength rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$min}</sh:minLength>,
        if($max!="*") 
        then <sh:maxLength rdf:datatype="{$fixm_3-0-1_sesar:xsd}integer">{$max}</sh:maxLength>
      )
      else () (: constraint type: usage, xsd, relation, ... :) 
};