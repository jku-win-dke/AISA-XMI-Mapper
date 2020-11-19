module namespace xmiExtractor = "http://www.aisa-project.eu/xquery/xmiextractor";

declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare function xmiExtractor:extractSubsetOfModels(
  $config as element()
) as element()* {
  <models>
    {
      for $model in $config/selection/models/model    
        let $xmiFile:=fn:doc($model/@location)
        let $classNames:=$model/classes/class/string()
        let $classes:=xmiExtractor:getSelectedClasses($xmiFile, $classNames)
        let $connectors:=xmiExtractor:getSelectedConnectors($xmiFile, $classes)
        let $superClasses:=xmiExtractor:getSuperClasses($xmiFile, $classes)
        let $associationClasses:=xmiExtractor:getAssociationClasses($xmiFile, $connectors)
        let $attributeClasses:=xmiExtractor:getAttributeClasses($xmiFile, ($classes union $superClasses union $associationClasses))
        return <model name="{$model/@name/string()}">
          <elements>
            {$classes union $superClasses union $associationClasses union $attributeClasses}
          </elements>
          <connectors>
            {$connectors}
          </connectors>
      </model>
    }
  </models>
};

declare %private function xmiExtractor:getSelectedClasses(
  $xmiFile as document-node(),
  $classNames as xs:string*
) as element()* {
  for $className in fn:distinct-values($classNames)
    let $element:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
      [@name=$className]
      [@xmi:type="uml:Class"]
    let $count:=fn:count($element)
    return
      if($count=1) then $element
      else if ($count<1) then fn:error(xs:QName("ENF"), "element not found: "||$className)
      else if ($count>1) then fn:error(xs:QName("UNAV"), "unique name assumption violated: "||$className)
};

declare %private function xmiExtractor:getSelectedConnectors(
  $xmiFile as document-node(),
  $classes as element()*
) as element()* {
   for $connector in $xmiFile/xmi:XMI/xmi:Extension/connectors/connector
     where $connector/properties[@ea_type!="Generalization"]
     where $connector/properties[@ea_type!="Dependency"]
     where $connector/source[@xmi:idref=$classes/@xmi:idref]
     where $connector/target[@xmi:idref=$classes/@xmi:idref]
     return $connector
};

declare %private function xmiExtractor:getSuperClasses(
  $xmiFile as document-node(),
  $subClasses as element()*
) as element()* {
  for $subClass in $subClasses
    for $generalization in $subClass/links/Generalization
      where $generalization[@start=$subClass/@xmi:idref]
      let $superClass:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
        [@xmi:idref=$generalization/@end]
      return
        if($superClass/properties[@stereotype="XSDsimpleType"]) then 
          ()
        else if($superClass/properties[@stereotype="CodeList" or @stereotype="enumeration"]
          or fn:contains($superClass/@name/string(), "BaseType")) then
          $superClass
        else (
          $superClass,
          xmiExtractor:getSuperClasses($xmiFile, $superClass) 
        )
};

declare %private function xmiExtractor:getAssociationClasses(
  $xmiFile as document-node(),
  $connectors as element()*
){
  for $connector in $connectors
    where $connector/extendedProperties[@associationclass]
    let $associationClass:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
      [@xmi:idref=$connector/extendedProperties/@associationclass]
    return (
      $associationClass,
      xmiExtractor:getSuperClasses($xmiFile, $associationClass) 
    )
};

declare %private function xmiExtractor:getAttributeClasses(
  $xmiFile as document-node(),
  $classes as element()*
) as element()* {
  for $class in $classes
    for $attribute in $class/attributes/attribute
      let $attributeClass:=$xmiFile/xmi:XMI/xmi:Extension/elements/element
        [@name=$attribute/properties/@type]
        [@xmi:type="uml:Class"]
      return 
        if($attributeClass/properties[@stereotype="XSDsimpleType"]) then
          ()
        else if (fn:contains($attributeClass/@name/string(), "BaseType")) then (
          $attributeClass,
          xmiExtractor:getAttributeClasses($xmiFile, $attributeClass)
        )
        else (
          $attributeClass, 
          xmiExtractor:getSuperClasses($xmiFile, $attributeClass), 
          xmiExtractor:getAttributeClasses($xmiFile, $attributeClass)
        )
};

