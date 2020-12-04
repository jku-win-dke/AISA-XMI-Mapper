module namespace extractor="http://www.aisa-project.eu/xquery/extractor";

declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare function extractor:getModelSubset(
  $model as element()
) as element()*{
  let $xmiFile:=fn:doc($model/@location)
  let $classNames:=fn:distinct-values($model/classes/class/string()) 
  
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
    
  let $connectors:=
    for $connector in $xmiFile/xmi:XMI/xmi:Extension/connectors/connector
    where $connector/properties[@ea_type!="Generalization"]
    where $connector/properties[@ea_type!="Dependency"]
    where $connector/source[@xmi:idref=$elements/@xmi:idref]
    where $connector/target[@xmi:idref=$elements/@xmi:idref]
    return $connector
  
  let $elements:=$elements union extractor:getSuperClasses($xmiFile, $elements)
  let $elements:=$elements union extractor:getAssociationClasses($xmiFile, $connectors)       
  let $elements:=$elements union extractor:getAttributeClasses($xmiFile, $elements)
  
  return <model>
    <elements>
      {$elements}
    </elements>
    <connectors>
      {$connectors}
    </connectors>
  </model>
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
    return (
      $superElement,
      extractor:getSuperClasses($xmiFile, $superElement) 
    )
};

declare function extractor:getAssociationClasses(
  $xmiFile as document-node(),
  $connectors as element()*
){
  for $connector in $connectors
  where $connector/extendedProperties[@associationclass]
  let $associationClass:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
    [@xmi:idref=$connector/extendedProperties/@associationclass]
  return (
    $associationClass,
    extractor:getSuperClasses($xmiFile, $associationClass) 
  )
};

declare function extractor:getAttributeClasses(
  $xmiFile as document-node(),
  $classes as element()*
) as element()* {
  for $class in $classes
    for $attribute in $class/attributes/attribute
    let $attributeClass:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
      [@name=$attribute/properties/@type]
      [@xmi:type="uml:Class"]
    return (
        $attributeClass, 
        extractor:getSuperClasses($xmiFile, $attributeClass), 
        extractor:getAttributeClasses($xmiFile, $attributeClass)
      )
};