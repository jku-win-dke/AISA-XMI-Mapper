module namespace extractor="http://www.aisa-project.eu/xquery/extractor";

declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare function extractor:getModelSubset(
  $model as element()
) as element()* {
  let $xmiFile:=fn:doc($model/@input)
  let $classNames:=fn:distinct-values($model/classes/class/string()) 
  (: get selected classes :)
  let $selectedElements:=
    for $className in $classNames
    let $element:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
      [@name=$className]
      [@xmi:type="uml:Class" or @xmi:type="uml:Enumeration"]
    return
      if(fn:count($element)=1)
      then $element
      else if (fn:count($element)<1) 
      then fn:error(xs:QName("error"), "element not found: "||$className)
      else fn:error(xs:QName("error"), "unique name assumption violated: "||$className)
  (: run extraction process based on selected classes :)
  return extractor:getModelSubsetRecursive($xmiFile, $selectedElements, (), $model/classes/@connectorLevel/string())
};

declare %private function extractor:getModelSubsetRecursive(
  $xmiFile as document-node(),
  $elements as element()*,
  $connectors as element()*,
  $connectorLevel as xs:string
) as element()* {
  (: size of selected subset :)
  let $oldCount:=fn:count($elements)+fn:count($connectors)
  (: get outgoing connections from the selected subset :)
  let $connectors:=$connectors union (
    for $connector in $xmiFile/xmi:XMI/xmi:Extension/connectors/connector
    where fn:exists($connectors[@xmi:idref=$connector/@xmi:idref])=false()
    where $connector/properties[@ea_type!="Dependency"]
    where $connector/source/model[@type="Class"]
    where $connector/target/model[@type="Class"]
    where (
      ( $connector/source[@xmi:idref=$elements/@xmi:idref]
        and fn:exists($connector/properties/@direction)=false()
      ) or
      ( $connector/source[@xmi:idref=$elements/@xmi:idref]
        and $connector/properties[@direction!="Destination -&gt; Source"]
      ) or  
      ( $connector/target[@xmi:idref=$elements/@xmi:idref]
        and $connector/properties[@direction="Destination -&gt; Source"]
      )
    )
    return $connector
  )
  (: get classes which are target of outgoing connections :)
  let $elements:=$elements union (
    for $connector in $connectors
    let $connectedElement:=
      if(fn:exists($connector/properties/@direction)=false()) then
        $xmiFile/xmi:XMI/xmi:Extension/elements/element[@xmi:idref=$connector/target/@xmi:idref]
      else if($connector/properties[@direction!="Destination -&gt; Source"]) then
        $xmiFile/xmi:XMI/xmi:Extension/elements/element[@xmi:idref=$connector/target/@xmi:idref]
      else
        $xmiFile/xmi:XMI/xmi:Extension/elements/element[@xmi:idref=$connector/source/@xmi:idref]
    where fn:exists($elements[@xmi:idref=$connectedElement/@xmi:idref])=false()
    return $connectedElement
  )
  (: get classes which are association classes of outgoing connections :)
  let $elements:=$elements union (
    for $connector in $connectors
    where $connector/extendedProperties[@associationclass]
    let $associationElement:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
      [@xmi:idref=$connector/extendedProperties/@associationclass]
    where fn:exists($elements[@xmi:idref=$associationElement/@xmi:idref])=false()
    return $associationElement
  )
  (: get classes which are attribute classes of the selected subset :)
  let $elements:=$elements union (
    for $element in $elements
      for $attribute in $element/attributes/attribute
      let $attributeElement:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
        [@name=$attribute/properties/@type]
        [@xmi:type="uml:Class" or @xmi:type="uml:Enumeration"]
      where fn:exists($elements[@xmi:idref=$attributeElement/@xmi:idref])=false()
      return $attributeElement
  )
  (: new size of the selected subset :)
  let $newCount:=fn:count($elements)+fn:count($connectors)
  return 
    if($connectorLevel="n")
    then 
      (: run extraction again if size of the selected subset increased :)
      if($newCount>$oldCount) 
      then extractor:getModelSubsetRecursive($xmiFile, $elements, $connectors, $connectorLevel)
      else extractor:returnFormat($elements, $connectors)
    else
      (: run extraction again if size of the selected subset increased and connectorLevel is still > 1 :)
      if($newCount>$oldCount and xs:integer($connectorLevel)>1) 
      then extractor:getModelSubsetRecursive($xmiFile, $elements, $connectors, xs:string(xs:integer($connectorLevel)-1))
      else extractor:returnFormat($elements, $connectors)
};

declare %private function extractor:returnFormat(
  $elements as element()*,
  $connectors as element()*
) as element() {
  <model>
    <elements>
      { $elements }
    </elements>
    <connectors>
      { $connectors }
    </connectors>
  </model>
};