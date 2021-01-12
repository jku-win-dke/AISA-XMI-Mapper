module namespace aixm_5-1-1="http://www.aisa-project.eu/xquery/aixm_5-1-1";

import module "http://www.aisa-project.eu/xquery/utilities" at "utilities.xq";

declare namespace utilities="http://www.aisa-project.eu/xquery/utilities";
declare namespace gml="http://www.opengis.net/gml/3.2#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace sh="http://www.w3.org/ns/shacl#";
declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare variable $aixm_5-1-1:namespace:="http://www.aisa-project.eu/vocabulary/aixm_5-1-1#"; 
declare variable $aixm_5-1-1:xsd:="http://www.w3.org/2001/XMLSchema#";
declare variable $aixm_5-1-1:gml:="http://www.opengis.net/gml/3.2#";
declare variable $aixm_5-1-1:rdf:="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare variable $aixm_5-1-1:rdfs:="http://www.w3.org/2000/01/rdf-schema#";

declare function aixm_5-1-1:map(
  $modelSubset as element()
) as element() {
  <rdf:RDF
    xmlns:sh="http://www.w3.org/ns/shacl#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:gml="http://www.opengis.net/gml/3.2#"
    xmlns:aixm="http://www.aisa-project.eu/vocabulary/aixm_5-1-1#">
    {
      if(fn:exists($modelSubset/elements/element/properties[@stereotype="feature"])) then
        aixm_5-1-1:getBasisElements()
    }
    {
      for $element in $modelSubset/elements/element
      return 
        if($element/properties[@stereotype="feature"]) then
          aixm_5-1-1:mapFeature($element, $modelSubset)
        else if($element/properties[@stereotype="object"]) then
          aixm_5-1-1:mapObject($element, $modelSubset)
        else if($element/properties[@stereotype="choice"]) then
          aixm_5-1-1:mapChoice($element, $modelSubset)
        else if($element/properties[@stereotype="CodeList"]) then
          aixm_5-1-1:mapCodeList($element, $modelSubset)
        else if($element/properties[@stereotype="DataType"]) then
          aixm_5-1-1:mapDataType($element, $modelSubset)
        else if($element/properties[@stereotype="XSDsimpleType"]) then
          aixm_5-1-1:mapXSDsimpleType($element, $modelSubset)
        else if($element/properties[@stereotype="XSDcomplexType"]) then
          aixm_5-1-1:mapXSDcomplexType($element, $modelSubset)
        else
          aixm_5-1-1:mapPlain($element, $modelSubset)
    }
  </rdf:RDF>
};

declare %private function aixm_5-1-1:mapFeature(
  $element as element(),
  $modelSubset as element()
) as element()* {
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}">
    <rdf:type rdf:resource="{$aixm_5-1-1:rdfs}Class" />
    <sh:and rdf:parseType="Collection">
      <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}AIXMFeature" />
    </sh:and>
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:namespace}timeSlice" />
      <sh:class rdf:resource="{$aixm_5-1-1:namespace}{$element/@name/string()}TimeSlice" />
    </sh:property>
  </sh:NodeShape>,
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}TimeSlice">
    <rdf:type rdf:resource="{$aixm_5-1-1:rdfs}Class" />
    {
      for $superElement in utilities:getSuperElements($element, $modelSubset, ())
      return 
        if(fn:starts-with($superElement/@name/string(), "GM_")) then
          let $name:=fn:replace($superElement/@name/string(), "GM_", "")
          return 
            <rdfs:subClassOf rdf:resource="{$aixm_5-1-1:gml}{$name}" />
        else
          <rdfs:subClassOf rdf:resource="{$aixm_5-1-1:namespace}{$superElement/@name/string()}" />
    }
    <sh:and rdf:parseType="Collection">
      <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}AIXMTimeSlice" />
      {
        for $superElement in utilities:getSuperElements($element, $modelSubset, ())
        return
          if(fn:starts-with($superElement/@name/string(), "GM_")) then
            let $name:=fn:replace($superElement/@name/string(), "GM_", "")
            return 
              <sh:NodeShape rdf:about="{$aixm_5-1-1:gml}{$name}" />
          else
            <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$superElement/@name/string()}" />
      }
    </sh:and>
    { aixm_5-1-1:mapAttributes($element, ()) }
    { aixm_5-1-1:mapConnectors($element, $modelSubset) }
    { if(fn:count(aixm_5-1-1:mapConnectorsOfAssociationClass($element, $modelSubset))>0) then <oho/> }
  </sh:NodeShape>
};

declare %private function aixm_5-1-1:mapObject(
  $element as element(),
  $modelSubset as element()
) as element() {
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}">
    <rdf:type rdf:resource="{$aixm_5-1-1:rdfs}Class" />
    {
      for $superElement in utilities:getSuperElements($element, $modelSubset, ())
      return 
        if(fn:starts-with($superElement/@name/string(), "GM_")) then
          let $name:=fn:replace($superElement/@name/string(), "GM_", "")
          return 
            <rdfs:subClassOf rdf:resource="{$aixm_5-1-1:gml}{$name}" />
        else
          <rdfs:subClassOf rdf:resource="{$aixm_5-1-1:namespace}{$superElement/@name/string()}" />
    }
    {
      let $superElements:=utilities:getSuperElements($element, $modelSubset, ())
      return if(fn:exists($superElements)) then
        <sh:and rdf:parseType="Collection">
          {
            for $superElement in $superElements
            return
              if(fn:starts-with($superElement/@name/string(), "GM_")) then
                let $name:=fn:replace($superElement/@name/string(), "GM_", "")
                return 
                  <sh:NodeShape rdf:about="{$aixm_5-1-1:gml}{$name}" />
              else
                <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$superElement/@name/string()}" />
          }
        </sh:and>
    }
    { aixm_5-1-1:mapAttributes($element, ()) }
    { aixm_5-1-1:mapConnectors($element, $modelSubset) }
    { aixm_5-1-1:mapConnectorsOfAssociationClass($element, $modelSubset) }
  </sh:NodeShape>
};

declare %private function aixm_5-1-1:mapChoice(
  $element as element(),
  $modelSubset as element()
) {};

declare %private function aixm_5-1-1:mapCodeList(
  $element as element(),
  $modelSubset as element()
) as element() {
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}">
    <sh:in rdf:parseType="Resource">
      { utilities:getCollection($element/attributes/attribute) }
    </sh:in>
    {
      let $datatype:=utilities:getSuperElements($element, $modelSubset, "XSDsimpleType")
      return
        if(fn:exists($datatype)) then
          if(fn:count($datatype)>1) then
            fn:error(xs:QName("error"), "more than one datatype: "||$element/@name/string())
          else 
            <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}{$datatype/@name/string()}" />
    }
  </sh:NodeShape>
};

declare %private function aixm_5-1-1:mapDataType(
  $element as element(),
  $modelSubset as element()
) as element() {
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}">
    {
      let $superElements:=utilities:getSuperElements($element, $modelSubset, "DataType")
      return if(fn:exists($superElements)) then
        <sh:and rdf:parseType="Collection">
          {
            for $superElement in $superElements
            return 
              <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$superElement/@name/string()}" />
          }
        </sh:and>
    }
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:rdf}value" />
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
      {
        let $datatype:=utilities:getSuperElements($element, $modelSubset, "XSDsimpleType")
        return 
          if(fn:exists($datatype)) then
            if(fn:count($datatype)>1) then
              fn:error(xs:QName("error"), "more than one datatype: "||$element/@name/string())
            else if($datatype/@name/string()="token") then 
              <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}string" />
            else
              <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}{$datatype/@name/string()}" />
      }
      {
        let $superCodelist:=utilities:getSuperElements($element, $modelSubset, "CodeList")
        return 
          if(fn:exists($superCodelist)) then
            if(fn:count($superCodelist)>1) then
              fn:error(xs:QName("error"), "more than one super <<CodeList>>: "||$element/@name/string())
            else
              <sh:node rdf:resource="{$aixm_5-1-1:namespace}{$superCodelist/@name/string()}" />
      }
      {
        for $attribute in $element/attributes/attribute
        where $attribute/stereotype[@stereotype="XSDfacet"]
        return
          if($attribute/@name/string()="minLength") then
            <sh:minLength rdf:datatype="{$aixm_5-1-1:xsd}integer">
              { $attribute/initial/@body/string() }
            </sh:minLength>
          else if($attribute/@name/string()="maxLength") then
            <sh:maxLength rdf:datatype="{$aixm_5-1-1:xsd}integer">
              { $attribute/initial/@body/string() }
            </sh:maxLength>
          else if($attribute/@name/string()="minInclusive") then
            <sh:minInclusive rdf:datatype="{$aixm_5-1-1:xsd}integer">
              { $attribute/initial/@body/string() }
            </sh:minInclusive>
          else if($attribute/@name/string()="maxInclusive") then
            <sh:maxInclusive rdf:datatype="{$aixm_5-1-1:xsd}integer">
              { $attribute/initial/@body/string() }
            </sh:maxInclusive>
          else if($attribute/@name/string()="minExclusive") then
            <sh:minExclusive rdf:datatype="{$aixm_5-1-1:xsd}integer">
              { $attribute/initial/@body/string() }
            </sh:minExclusive>
          else if($attribute/@name/string()="maxExclusive") then
            <sh:maxExclusive rdf:datatype="{$aixm_5-1-1:xsd}integer">
              { $attribute/initial/@body/string() }
            </sh:maxExclusive>
          else if($attribute/@name/string()="pattern") then
            <sh:pattern rdf:datatype="{$aixm_5-1-1:xsd}string">
              {$attribute/initial/@body/string()}
            </sh:pattern>
      }
    </sh:property>
    { aixm_5-1-1:mapAttributes($element, "XSDfacet") }
    {
      if($element/attributes/attribute/properties[@type="NilReasonEnumeration"]) then 
        <sh:xone rdf:parseType="Collection">
          <rdf:Description>
            {
              for $attribute in $element/attributes/attribute
              where $attribute/properties[@type!="NilReasonEnumeration"]
              return 
                <sh:property rdf:parseType="Resource">
                  <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$attribute/@name/string()}" />
                </sh:property>
            }
            <sh:property rdf:parseType="Resource">
              <sh:path rdf:resource="{$aixm_5-1-1:rdf}value" />
              <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount> 
            </sh:property>
          </rdf:Description>
          <rdf:Description>
            {
              for $attribute in $element/attributes/attribute
              where $attribute/properties[@type="NilReasonEnumeration"]
              return 
                <sh:property rdf:parseType="Resource">
                  <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$attribute/@name/string()}" />
                  <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount> 
                </sh:property>
            }
          </rdf:Description>
        </sh:xone>
    }
  </sh:NodeShape>
};

declare %private function aixm_5-1-1:mapXSDsimpleType(
  $element as element(),
  $modelSubset as element()
) {};

declare %private function aixm_5-1-1:mapXSDcomplexType(
  $element as element(),
  $modelSubset as element()
) {};

declare %private function aixm_5-1-1:mapPlain(
  $element as element(),
  $modelSubset as element()
) {
  if(fn:starts-with($element/@name/string(), "GM_")) then
    let $name:=fn:replace($element/@name/string(), "GM_", "")
    return 
      <sh:NodeShape rdf:about="{$aixm_5-1-1:gml}{$name}">
        <rdf:type rdf:resource="{$aixm_5-1-1:rdfs}Class" />
      </sh:NodeShape>
  else
    <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}">
      <rdf:type rdf:resource="{$aixm_5-1-1:rdfs}Class" />
    </sh:NodeShape>
};

declare %private function aixm_5-1-1:getRoleName(
  $className as xs:string
) as xs:string {
    "the"||$className
};

declare %private function aixm_5-1-1:mapAttributes(
  $element as element(),
  $notStereotype as xs:string?
) as element()* {
  for $attribute in $element/attributes/attribute
  where (
    ( fn:exists($notStereotype)
      and (
        ( fn:exists($attribute/stereotype/@stereotype) 
          and $attribute/stereotype[@stereotype!=$notStereotype] ) 
        or ( fn:exists($attribute/stereotype/@stereotype)=false() )
      )
    ) or fn:exists($notStereotype)=false()
  )
  return 
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$attribute/@name/string()}" />
      <sh:node rdf:resource="{$aixm_5-1-1:namespace}{$attribute/properties/@type/string()}" />
      <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">0</sh:minCount>
      {
        let $maxCount:=$attribute/bounds/@upper/string()
        return if($maxCount!="*") then
          <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">{$maxCount}</sh:maxCount>
      }
    </sh:property>
};

declare %private function aixm_5-1-1:mapConnectors(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $connector in $modelSubset/connectors/connector
  where $connector/properties[@ea_type!="Generalization"]
  where (
    ( $connector/source[@xmi:idref=$element/@xmi:idref]
      and $connector/properties[@direction="Source -&gt; Destination"]
    ) or 
    ( $connector/target[@xmi:idref=$element/@xmi:idref] 
      and $connector/properties[@direction="Destination -&gt; Source"]
    ))
  let $targetElement:=
    if(fn:exists($connector/extendedProperties/@associationclass)) then
      $modelSubset/elements/element[@xmi:idref=$connector/extendedProperties/@associationclass]
    else
      if($connector/properties[@direction="Source -&gt; Destination"]) then
        $modelSubset/elements/element[@xmi:idref=$connector/target/@xmi:idref]
      else
        $modelSubset/elements/element[@xmi:idref=$connector/source/@xmi:idref]
  let $pathName:=
    if($connector/properties[@direction="Source -&gt; Destination"]) then
      if(fn:exists($connector/target/role/@name)) then
        $connector/target/role/@name
      else
        aixm_5-1-1:getRoleName($targetElement/@name/string())
    else
      if(fn:exists($connector/source/role/@name)) then
        $connector/source/role/@name
      else
        aixm_5-1-1:getRoleName($targetElement/@name/string())
    let $cardinality:=
      if($connector/properties[@direction="Source -&gt; Destination"]) then
        $connector/target/type/@multiplicity
      else
        $connector/source/type/@multiplicity
    return 
      if($targetElement/properties[@stereotype="choice"]) then (
        <sh:property rdf:parseType="Resource">
          <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$pathName}" />
          {
            let $minCount:=fn:substring-before($connector/target/type/@multiplicity, "..")
            return if(fn:exists($minCount) and $minCount!="*") then
              <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">{$minCount}</sh:minCount>
          }
          {
            let $maxCount:=fn:substring-after($connector/target/type/@multiplicity, "..")
            return if(fn:exists($maxCount) and $maxCount!="*") then
              <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">{$maxCount}</sh:maxCount> 
          }
        </sh:property>,
        <sh:xone rdf:parseType="Collection">
          {
            for $targetElementConnector in $modelSubset/connectors/connector
            where $targetElementConnector/properties[@ea_type!="Generalization"]
            where (
              ( $targetElementConnector/source[@xmi:idref=$targetElement/@xmi:idref]
                and $targetElementConnector/properties[@direction="Source -&gt; Destination"]
              ) or 
              ( $targetElementConnector/target[@xmi:idref=$targetElement/@xmi:idref] 
                and $targetElementConnector/properties[@direction="Destination -&gt; Source"]
              ))
            let $targetElementTargetName:=
              if($targetElementConnector/properties[@direction="Source -&gt; Destination"]) then
                $targetElementConnector/target/model/@name/string()
              else
                $targetElementConnector/source/model/@name/string()
            return 
              <rdf:Description>
                <sh:property rdf:parseType="Resource">
                  <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$pathName}" />
                  <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
                  <sh:class rdf:resource="{$aixm_5-1-1:namespace}{$targetElementTargetName}" />
                </sh:property>
              </rdf:Description>
         }
       </sh:xone>
      )
      else
        <sh:property rdf:parseType="Resource">
          <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$pathName}" />
          <sh:class rdf:resource="{$aixm_5-1-1:namespace}{$targetElement/@name/string()}" />
          {
            let $minCount:=fn:substring-before($cardinality, "..")
            return if(fn:exists($minCount) and $minCount!="*") then
              <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">{$minCount}</sh:minCount>
          }
          {
            let $maxCount:=fn:substring-after($cardinality, "..")
            return if(fn:exists($maxCount) and $maxCount!="*") then
              <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">{$maxCount}</sh:maxCount> 
          }
        </sh:property>
};

declare %private function aixm_5-1-1:mapConnectorsOfAssociationClass(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $connector in $modelSubset/connectors/connector
    where $element[@xmi:idref=$connector/extendedProperties/@associationclass]
    where $connector/properties[@ea_type!="Generalization"]
    let $targetName:=
      if($connector/properties[@direction="Source -&gt; Destination"]) then
        $connector/target/model/@name/string()
      else
        $connector/source/model/@name/string()
    let $pathName:=aixm_5-1-1:getRoleName($targetName)
    return 
      <sh:property rdf:parseType="Resource">
        <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$pathName}" />
        <sh:class rdf:resource="{$aixm_5-1-1:namespace}{$targetName}" />
        <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
        <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount> 
      </sh:property>
};

declare %private function aixm_5-1-1:getBasisElements(){
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}AIXMFeature">
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:namespace}timeSlice" />
    </sh:property>
  </sh:NodeShape>,
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}AIXMTimeSlice">
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:gml}validTime" />
      <sh:class rdf:resource="{$aixm_5-1-1:gml}TimePeriod" />
      <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
    </sh:property>
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:namespace}interpretation" />
      <sh:node rdf:resource="{$aixm_5-1-1:namespace}TimeSliceInterpretationType" />
      <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
     </sh:property>
     <sh:property rdf:parseType="Resource">
       <sh:path rdf:resource="{$aixm_5-1-1:namespace}sequenceNumber" />
       <sh:node rdf:resource="{$aixm_5-1-1:namespace}NoNumberType" />
       <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
       <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
     </sh:property>
     <sh:property rdf:parseType="Resource">
       <sh:path rdf:resource="{$aixm_5-1-1:namespace}correctionNumber" />
       <sh:node rdf:resource="{$aixm_5-1-1:namespace}NoNumberType" />
       <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
       <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
     </sh:property>
  </sh:NodeShape>,
  <sh:NodeShape rdf:about="{$aixm_5-1-1:gml}TimePeriod">
    <rdf:type rdf:resource="{$aixm_5-1-1:rdfs}Class" />
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:gml}beginPosition" />
      <sh:node rdf:resource="{$aixm_5-1-1:gml}TimePrimitive" />
      <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
    </sh:property>
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:gml}endPosition" />
      <sh:node rdf:resource="{$aixm_5-1-1:gml}TimePrimitive" />
      <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
    </sh:property>
  </sh:NodeShape>,
  <sh:NodeShape rdf:about="{$aixm_5-1-1:gml}TimePrimitive">
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:rdf}value" />
      <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}dateTime" />
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
    </sh:property>
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:gml}indeterminatePosition" />
      <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}string" />
      <sh:in rdf:parseType="Resource">
        <rdf:rest rdf:parseType="Resource">
          <rdf:first>after</rdf:first>
          <rdf:rest rdf:parseType="Resource">
            <rdf:first>before</rdf:first>
            <rdf:rest rdf:parseType="Resource">
               <rdf:first>now</rdf:first>
               <rdf:rest rdf:parseType="Resource">
                 <rdf:first>unknown</rdf:first>
                 <rdf:rest rdf:resource="{$aixm_5-1-1:rdf}nil"/>
               </rdf:rest>
            </rdf:rest>
          </rdf:rest>
        </rdf:rest>
      </sh:in>
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
    </sh:property>
    <sh:xone rdf:parseType="Collection">
      <rdf:Description>
        <sh:property rdf:parseType="Resource">
          <sh:path rdf:resource="{$aixm_5-1-1:rdf}value" />
          <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
        </sh:property>
      </rdf:Description>
      <rdf:Description>
          <sh:property rdf:parseType="Resource">
          <sh:path rdf:resource="{$aixm_5-1-1:gml}indeterminatePosition" />
          <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
        </sh:property>
      </rdf:Description>
    </sh:xone>
  </sh:NodeShape>,
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}TimeSliceInterpretationType">
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:rdf}value" />
      <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}string" />
      <sh:in rdf:parseType="Resource">
        <rdf:rest rdf:parseType="Resource">
          <rdf:first>BASELINE</rdf:first>
          <rdf:rest rdf:parseType="Resource">
            <rdf:first>TEMPDELTA</rdf:first>
            <rdf:rest rdf:resource="{$aixm_5-1-1:rdf}nil"/>
          </rdf:rest>
        </rdf:rest>
      </sh:in>
      <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
    </sh:property>
  </sh:NodeShape>,
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}NoNumberType">
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:rdf}value" />
      <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}unsignedInt" />
      <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
    </sh:property>
  </sh:NodeShape>
};