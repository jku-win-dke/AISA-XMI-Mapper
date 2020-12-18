module namespace extractor="http://www.aisa-project.eu/xquery/extractor";

declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare function extractor:getModelSubset(
  $model as element()
) as element()*{
  let $xsdDatatypes:=fn:doc("input/datatypes.xsd")/xs:schema/xs:simpleType
  let $xmiFile:=fn:doc($model/@location)
  let $classNames:=fn:distinct-values($model/classes/class/string()) 
  
  (: selected classes :)
  let $elements:=
    for $className in $classNames
    let $element:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
      [@name=$className]
      [@xmi:type="uml:Class"]
    return
      if(fn:count($element)=1) then 
        $element
      else if (fn:count($element)<1) then 
        fn:error(xs:QName("error"), "element not found: "||$className)
      else
        fn:error(xs:QName("error"), "unique name assumption violated: "||$className)
  
  (: connectors :)
  let $connectors:=
    if($model/classes[@connectorLevel="1"]) then
      for $connector in $xmiFile/xmi:XMI/xmi:Extension/connectors/connector
      where $connector/properties[@ea_type!="Generalization"]
      where $connector/properties[@ea_type!="Dependency"]
      where $connector/source[@xmi:idref=$elements/@xmi:idref]
      where $connector/target[@xmi:idref=$elements/@xmi:idref]
      where $connector/source/model[@type="Class"]
      where $connector/target/model[@type="Class"]
      return $connector
    else if($model/classes[@connectorLevel="2"]) then
      for $connector in $xmiFile/xmi:XMI/xmi:Extension/connectors/connector
      where $connector/properties[@ea_type!="Generalization"]
      where $connector/properties[@ea_type!="Dependency"]
      where (
        ( $connector/source[@xmi:idref=$elements/@xmi:idref]
          and $connector/properties[@direction!="Destination -&gt; Source"]
        ) or 
        ( $connector/source[@xmi:idref=$elements/@xmi:idref]
          and fn:exists($connector/properties/@direction)=false())
        ) or
        ( $connector/target[@xmi:idref=$elements/@xmi:idref]
          and $connector/properties[@direction="Destination -&gt; Source"]
      )
      where $connector/source/model[@type="Class"]
      where $connector/target/model[@type="Class"]
      return $connector
    else if($model/classes[@connectorLevel="n"]) then
      extractor:get3rdLevelConnectors($xmiFile, $elements)
    else
      ()
    
  (: indirectly selected classes by connectors :)
  let $elements:=$elements union (
    if($model/classes[@connectorLevel!="0" or @connectorLevel!="1"]) then
      for $connector in $connectors
      return 
        if(fn:exists($connector/properties/@direction)=false()) then
          $xmiFile/xmi:XMI/xmi:Extension/elements/element[@xmi:idref=$connector/target/@xmi:idref]
        else if($connector/properties[@direction="Source -&gt; Destination"]) then
          $xmiFile/xmi:XMI/xmi:Extension/elements/element[@xmi:idref=$connector/target/@xmi:idref]
        else
          $xmiFile/xmi:XMI/xmi:Extension/elements/element[@xmi:idref=$connector/source/@xmi:idref]
    )
  
  (: association classes :)
  let $elements:=$elements union (
    for $connector in $connectors
    where $connector/extendedProperties[@associationclass]
    let $associationElement:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
      [@xmi:idref=$connector/extendedProperties/@associationclass]
    return $associationElement
  )
  
  (: super classes and their super classes ... :)
  let $elements:=$elements union extractor:getSuperClasses($xmiFile, $elements)
  
  (: attribute classes, their super classes and their attribute classes, ... :)
  let $elements:=$elements union extractor:getAttributeClasses($xmiFile, $elements, $xsdDatatypes)
    
  return <model>
    <elements>
      {$elements}
    </elements>
    <connectors>
      {$connectors}
    </connectors>
  </model>
};

declare function extractor:get3rdLevelConnectors(
  $xmiFile as document-node(),
  $elements as element()*
) as element()*{
  for $connector in $xmiFile/xmi:XMI/xmi:Extension/connectors/connector
  where $connector/properties[@ea_type!="Generalization"]
  where $connector/properties[@ea_type!="Dependency"]
  where (
    ( $connector/source[@xmi:idref=$elements/@xmi:idref]
      and $connector/properties[@direction!="Destination -&gt; Source"]
    ) or 
    ( $connector/source[@xmi:idref=$elements/@xmi:idref]
      and fn:exists($connector/properties/@direction)=false())
    ) or
    ( $connector/target[@xmi:idref=$elements/@xmi:idref]
      and $connector/properties[@direction="Destination -&gt; Source"]
    )
  where $connector/source/model[@type="Class"]
  where $connector/target/model[@type="Class"]
  return
    if($connector/source[@xmi:idref=$elements/@xmi:idref]
      and $connector/properties[@direction!="Destination -&gt; Source"]
      and $connector/source[@xmi:idref!=$connector/target/@xmi:idref]) then (
        $connector, 
        extractor:get3rdLevelConnectors($xmiFile, $xmiFile/xmi:XMI/xmi:Extension/elements/element[@xmi:idref=$connector/target/@xmi:idref])
    )
    else if($connector/target[@xmi:idref=$elements/@xmi:idref]
      and $connector/properties[@direction="Destination -&gt; Source"]
      and $connector/source[@xmi:idref!=$connector/target/@xmi:idref]) then (
        $connector,
        extractor:get3rdLevelConnectors($xmiFile, $xmiFile/xmi:XMI/xmi:Extension/elements/element[@xmi:idref=$connector/source/@xmi:idref])
    )
    else $connector
};

declare function extractor:getSuperClasses(
  $xmiFile as document-node(),
  $elements as element()*
) as element()* {
  for $element in $elements
    for $generalization in $element/links/Generalization
    where $generalization[@start=$element/@xmi:idref]
    let $superElement:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
      [@xmi:idref=$generalization/@end]
      [@xmi:type="uml:Class"]
    where fn:exists($superElement)
    return (
      $superElement,
      extractor:getSuperClasses($xmiFile, $superElement) 
    )
};

declare function extractor:getAttributeClasses(
  $xmiFile as document-node(),
  $elements as element()*,
  $xsdDatatypes as element()*
) as element()* {
  for $element in $elements
    for $attribute in $element/attributes/attribute
    let $attributeElement:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
      [@name=$attribute/properties/@type]
      [@xmi:type="uml:Class"]
    where fn:exists($attributeElement)
    return 
      if($attribute/properties[@type=$xsdDatatypes/@name/string()]) then
        $attributeElement
      else (
        $attributeElement,
        extractor:getSuperClasses($xmiFile, $attributeElement),
        extractor:getAttributeClasses($xmiFile, $attributeElement, $xsdDatatypes)
      )
};