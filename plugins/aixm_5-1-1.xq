module namespace aixm_5-1-1="http://www.aisa-project.eu/xquery/aixm_5-1-1";

declare namespace gml="http://www.opengis.net/gml/3.2#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace sh="http://www.w3.org/ns/shacl#";
declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare variable $aixm_5-1-1:namespace:="http://www.aixm.aero/schema/5.1.1#"; 
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
    xmlns:aixm="http://www.aixm.aero/schema/5.1.1#">
    {
      if(fn:exists($modelSubset/elements/element/properties[@stereotype="feature"])) then
        aixm_5-1-1:getGMLBasisElementsForAIXMFeatures()
    }
    {
      for $element in $modelSubset/elements/element
      return 
        if($element/properties/@stereotype="feature") then
          aixm_5-1-1:mapFeature($element, $modelSubset)
        else if($element/properties/@stereotype="object") then
          aixm_5-1-1:mapObject($element, $modelSubset)
        else if($element/properties/@stereotype="choice") then
          aixm_5-1-1:mapChoice($element, $modelSubset)
        else if($element/properties/@stereotype="CodeList") then
          aixm_5-1-1:mapCodeList($element, $modelSubset)
        else if($element/properties/@stereotype="DataType") then
          aixm_5-1-1:mapDataType($element, $modelSubset)
        else if($element/properties/@stereotype="XSDsimpleType") then
          aixm_5-1-1:mapXSDsimpleType($element, $modelSubset)
        else if($element/properties/@stereotype="XSDcomplexType") then
          aixm_5-1-1:mapXSDcomplexType($element, $modelSubset)
        else
          aixm_5-1-1:mapPlain($element, $modelSubset)
    }
  </rdf:RDF>
};

declare function aixm_5-1-1:mapFeature(
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
    <sh:and rdf:parseType="Collection">
      <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}AIXMTimeSlice" />
    </sh:and>
    {
      aixm_5-1-1:mapComplexAttributes($element, ())
    }
    {
      aixm_5-1-1:mapDirectConnectors($element, $modelSubset)
    }
    {
      aixm_5-1-1:mapIndirectConnectors($element, $modelSubset)
    }
  </sh:NodeShape>
};

declare function aixm_5-1-1:mapObject(
  $element as element(),
  $modelSubset as element()
) as element() {
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}">
    <rdf:type rdf:resource="{$aixm_5-1-1:rdfs}Class" />
    {
      for $superElement in aixm_5-1-1:getSuperElements($element, $modelSubset, ())
      return 
        if(fn:starts-with($superElement/@name/string(), "GM_")) then
          let $name:=fn:replace($superElement/@name/string(), "GM_", "")
          return <rdfs:subClassOf rdf:resource="{$aixm_5-1-1:gml}{$name}" />
        else
          <rdfs:subClassOf rdf:resource="{$aixm_5-1-1:namespace}{$superElement/@name/string()}" />
    }
    {
      for $superElement in aixm_5-1-1:getSuperElements($element, $modelSubset, ())
      return <sh:and rdf:parseType="Collection">
        {
          if(fn:starts-with($superElement/@name/string(), "GM_")) then
            let $name:=fn:replace($superElement/@name/string(), "GM_", "")
            return <sh:NodeShape rdf:about="{$aixm_5-1-1:gml}{$name}" />
          else
            <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$superElement/@name/string()}" />
        } 
      </sh:and>
    }
    {
      aixm_5-1-1:mapComplexAttributes($element, ())
    }
    {
      aixm_5-1-1:mapDirectConnectors($element, $modelSubset)
    }
    {
      aixm_5-1-1:mapIndirectConnectors($element, $modelSubset)
    }
  </sh:NodeShape>
};

declare function aixm_5-1-1:mapChoice(
  $element as element(),
  $modelSubset as element()
) {
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}">
    {
      aixm_5-1-1:mapComplexAttributes($element, ())
    }
    {
      aixm_5-1-1:mapDirectConnectors($element, $modelSubset)
    }
    {
      <sh:xone rdf:parseType="Collection">
        {
          for $connector in $modelSubset/connectors/connector
          where (
            ( $connector/source[@xmi:idref=$element/@xmi:idref]
              and $connector/properties[@direction="Source -&gt; Destination"]
            ) or 
            ( $connector/target[@xmi:idref=$element/@xmi:idref] 
              and $connector/properties[@direction="Destination -&gt; Source"]
            ))
          return <rdf:Description>
            <sh:property rdf:parseType="Resource">
              {
                let $pathName:=
                  if($connector/properties[@direction="Source -&gt; Destination"]) then
                    if(fn:exists($connector/target/role/@name)) then
                      $connector/target/role/@name
                    else
                      aixm_5-1-1:getRoleName($connector/target/model/@name/string())
                  else
                    if(fn:exists($connector/source/role/@name)) then
                      $connector/source/role/@name
                    else
                      aixm_5-1-1:getRoleName($connector/source/model/@name/string())
                return <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$pathName}" />
              }
              <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount> 
            </sh:property>
          </rdf:Description>
        }
      </sh:xone>
    }
  </sh:NodeShape>
};

declare function aixm_5-1-1:mapCodeList(
  $element as element(),
  $modelSubset as element()
) as element() {
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}">
    <sh:in rdf:parseType="Resource">
      {
        aixm_5-1-1:getCollection($element/attributes/attribute)
      }
    </sh:in>
    {
      for $superElement in aixm_5-1-1:getSuperElements($element, $modelSubset, "XSDsimpleType")
      return <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}{$superElement/@name/string()}" />
    }
  </sh:NodeShape>
};

declare function aixm_5-1-1:mapDataType(
  $element as element(),
  $modelSubset as element()
) as element() {
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}">
    {
      for $superElement in aixm_5-1-1:getSuperElements($element, $modelSubset, "DataType")
      return <sh:and rdf:parseType="Collection"> 
        <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$superElement/@name/string()}" />
      </sh:and>
    }
    <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:rdf}value" />
      {
        for $attribute in $element/attributes/attribute
        where $attribute/stereotype[@stereotype="XSDfacet"]
        return
          if($attribute/@name/string()="minLength") then
            <sh:minLength rdf:datatype="{$aixm_5-1-1:xsd}integer">{$attribute/initial/@body/string()}</sh:minLength>
          else if($attribute/@name/string()="maxLength") then
            <sh:maxLength rdf:datatype="{$aixm_5-1-1:xsd}integer">{$attribute/initial/@body/string()}</sh:maxLength>
          else if($attribute/@name/string()="minInclusive") then
            <sh:minInclusive rdf:datatype="{$aixm_5-1-1:xsd}integer">{$attribute/initial/@body/string()}</sh:minInclusive>
          else if($attribute/@name/string()="maxInclusive") then
            <sh:maxInclusive rdf:datatype="{$aixm_5-1-1:xsd}integer">{$attribute/initial/@body/string()}</sh:maxInclusive>
          else if($attribute/@name/string()="minExclusive") then
            <sh:minExclusive rdf:datatype="{$aixm_5-1-1:xsd}integer">{$attribute/initial/@body/string()}</sh:minExclusive>
          else if($attribute/@name/string()="maxExclusive") then
            <sh:maxExclusive rdf:datatype="{$aixm_5-1-1:xsd}integer">{$attribute/initial/@body/string()}</sh:maxExclusive>
          else if($attribute/@name/string()="pattern") then
            <sh:pattern rdf:datatype="{$aixm_5-1-1:xsd}string">{$attribute/initial/@body/string()}</sh:pattern>
      }
      {
        for $superElement in aixm_5-1-1:getSuperElements($element, $modelSubset, "XSDsimpleType")
        return 
          if($superElement/@name/string()="token") then 
            <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}string" />
          else
            <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}{$superElement/@name/string()}" />
      }
      {
        for $superElement in aixm_5-1-1:getSuperElements($element, $modelSubset, "CodeList")
        return <sh:node rdf:resource="{$aixm_5-1-1:namespace}{$superElement/@name/string()}" />
      }
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
    </sh:property>
    {
      aixm_5-1-1:mapComplexAttributes($element, "XSDfacet")
    }
    {
      if($element/attributes/attribute/properties[@type="NilReasonEnumeration"]) then 
        <sh:xone rdf:parseType="Collection">
          <rdf:Description>
            {
              for $attribute in $element/attributes/attribute
              where $attribute/properties[@type!="NilReasonEnumeration"]
              return <sh:property rdf:parseType="Resource">
                <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$attribute/@name/string()}" />
                <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">0</sh:minCount> 
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
              return <sh:property rdf:parseType="Resource">
                <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$attribute/@name/string()}" />
                <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount> 
              </sh:property>
            }
          </rdf:Description>
        </sh:xone>
    }
  </sh:NodeShape>
};

declare function aixm_5-1-1:mapXSDsimpleType(
  $element as element(),
  $modelSubset as element()
) {};

declare function aixm_5-1-1:mapXSDcomplexType(
  $element as element(),
  $modelSubset as element()
) {};

declare function aixm_5-1-1:mapPlain(
  $element as element(),
  $modelSubset as element()
) {
  if(fn:starts-with($element/@name/string(), "GM_")) then
    let $name:=fn:replace($element/@name/string(), "GM_", "")
    return <sh:NodeShape rdf:about="{$aixm_5-1-1:gml}{$name}">
      <rdf:type rdf:resource="{$aixm_5-1-1:rdfs}Class" />
    </sh:NodeShape>
  else
    <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}{$element/@name/string()}">
      <rdf:type rdf:resource="{$aixm_5-1-1:rdfs}Class" />
    </sh:NodeShape>
};

declare function aixm_5-1-1:getSuperElements(
  $element as element(),
  $modelSubset as element(),
  $stereotype as xs:string*
) as element()* {
  for $generalization in $element/links/Generalization
  where $generalization[@start=$element/@xmi:idref]
  let $superElement:=$modelSubset/elements/element[@xmi:idref=$generalization/@end]
  where (
    ( fn:exists($stereotype) 
      and $superElement/properties[@stereotype=$stereotype]
    ) or
    fn:exists($stereotype)=false())
  return $superElement
};

declare function aixm_5-1-1:getCollection(
  $elements as element()*
) as element()? {
  if(fn:count($elements)>0) then
    <rdf:rest rdf:parseType="Resource">
      <rdf:first>{$elements[1]/@name/string()}</rdf:first>
      {
        aixm_5-1-1:getCollection(fn:subsequence($elements, 2))
      }
    </rdf:rest>
  else
    <rdf:rest rdf:resource="{$aixm_5-1-1:rdf}nil"/>
};

declare function aixm_5-1-1:getRoleName(
  $className as xs:string
) as xs:string {
    "the"||$className
};

declare function aixm_5-1-1:mapComplexAttributes(
  $element as element(),
  $notStereotype as xs:string*
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
  return <sh:property rdf:parseType="Resource">
    <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$attribute/@name/string()}" />
    <sh:node rdf:resource="{$aixm_5-1-1:namespace}{$attribute/properties/@type/string()}" />
    <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">0</sh:minCount>
    <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount> 
  </sh:property>
};

declare function aixm_5-1-1:mapDirectConnectors(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $connector in $modelSubset/connectors/connector
  where (
    ( $connector/source[@xmi:idref=$element/@xmi:idref]
      and $connector/properties[@direction="Source -&gt; Destination"]
    ) or 
    ( $connector/target[@xmi:idref=$element/@xmi:idref] 
      and $connector/properties[@direction="Destination -&gt; Source"]
    ))
  let $targetName:=
    if(fn:exists($connector/extendedProperties/@associationclass)) then
      $modelSubset/elements/element[@xmi:idref=$connector/extendedProperties/@associationclass]/@name/string()
    else
      if($connector/properties[@direction="Source -&gt; Destination"]) then
        $connector/target/model/@name/string()
      else
        $connector/source/model/@name/string()
  let $pathName:=
    if($connector/properties[@direction="Source -&gt; Destination"]) then
      if(fn:exists($connector/target/role/@name)) then
        $connector/target/role/@name
      else
        aixm_5-1-1:getRoleName($targetName)
    else
      if(fn:exists($connector/source/role/@name)) then
        $connector/source/role/@name
      else
        aixm_5-1-1:getRoleName($targetName)
    let $cardinality:=
      if($connector/properties[@direction="Source -&gt; Destination"]) then
        $connector/target/type/@multiplicity
      else
        $connector/source/type/@multiplicity
    return <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$pathName}" />
      <sh:class rdf:resource="{$aixm_5-1-1:namespace}{$targetName}" />
      {
        let $minCount:=fn:substring($cardinality, 1, 1)
        return if(fn:exists($minCount) and $minCount!="*") then
          <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">{$minCount}</sh:minCount>
      }
      {
        let $maxCount:=fn:substring($cardinality, fn:string-length($cardinality), 1)
        return if(fn:exists($maxCount) and $maxCount!="*") then
          <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">{$maxCount}</sh:maxCount> 
        }
    </sh:property>
};

declare function aixm_5-1-1:mapIndirectConnectors(
  $element as element(),
  $modelSubset as element()
) as element()* {
  for $connector in $modelSubset/connectors/connector
    where $element[@xmi:idref=$connector/extendedProperties/@associationclass]
    let $targetName:=
      if($connector/properties[@direction="Source -&gt; Destination"]) then
        $connector/target/model/@name/string()
      else
        $connector/source/model/@name/string()
    let $pathName:=aixm_5-1-1:getRoleName($targetName)
    let $cardinality:=
      if($connector/properties[@direction="Source -&gt; Destination"]) then
        $connector/target/type/@multiplicity
      else
        $connector/source/type/@multiplicity
    return <sh:property rdf:parseType="Resource">
      <sh:path rdf:resource="{$aixm_5-1-1:namespace}{$pathName}" />
      <sh:class rdf:resource="{$aixm_5-1-1:namespace}{$targetName}" />
      <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount> 
    </sh:property>
};

declare function aixm_5-1-1:getGMLBasisElementsForAIXMFeatures(){
  
  <sh:NodeShape rdf:about="{$aixm_5-1-1:namespace}AIXMFeature" />,
  
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
      <sh:datatype rdf:resource="{$aixm_5-1-1:xsd}integer" />
      <sh:minCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:minCount>
      <sh:maxCount rdf:datatype="{$aixm_5-1-1:xsd}integer">1</sh:maxCount>
    </sh:property>
  </sh:NodeShape>
};