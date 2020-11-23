module namespace xmi2shacl = "http://www.aisa-project.eu/xquery/xmi2shacl";

import module "http://www.aisa-project.eu/xquery/xmiextractor" at "xmiExtractor.xqm";
import module "http://www.aisa-project.eu/xquery/xmiutilities" at "xmiUtilities.xqm";

declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";
declare namespace xmiExtractor="http://www.aisa-project.eu/xquery/xmiextractor";
declare namespace xmiUtilities="http://www.aisa-project.eu/xquery/xmiutilities";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace sh="http://www.w3.org/ns/shacl#";

declare function xmi2shacl:map(
  $fileName as xs:string
) as element() {
  <rdf:RDF
    xmlns:sh="http://www.w3.org/ns/shacl#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">
    {
      for $model in fn:doc($fileName)/models/model
        let $namespace:=xmiUtilities:getNamespace($model/@name/string())        
        return (
          (: mapping of UML classes to SHACL shapes :)
          for $element in $model/elements/element
            return 
              <sh:NodeShape rdf:about="{$namespace}{$element/@name/string()}Shape">
                {
                  if(( 
                    fn:exists($element/properties/@stereotype)
                    and $element/properties[@stereotype!="CodeList"]
                    and $element/properties[@stereotype!="enumeration"]
                    ) or fn:exists($element/properties/@stereotype)=false()) then
                    <sh:targetClass rdf:resource="{$namespace}{$element/@name/string()}" />
                } 
                <sh:closed rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">true</sh:closed>
                <sh:ignoredProperties rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" />
                {
                  (: mapping of attributes of UML classes to property shapes :) 
                  (:   except classes with stereotype <<CodeList>>, <<enumeration>>, <<DataType>> :)
                  for $attribute in $element/attributes/attribute
                    where ((
                      fn:exists($element/properties/@stereotype)
                      and $element/properties[@stereotype!="CodeList"]
                      and $element/properties[@stereotype!="enumeration"]
                      and $element/properties[@stereotype!="DataType"]
                    ) or fn:exists($element/properties/@stereotype)=false())
                    let $attributeClass:=$model/elements/element[@name=$attribute/properties/@type]
                    return
                      if(
                        ( fn:exists($attributeClass/properties/@stereotype)
                          and $attributeClass/properties[@stereotype!="CodeList"]
                          and $attributeClass/properties[@stereotype!="enumeration"]
                        ) or fn:exists($attributeClass/properties/@stereotype)=false()) then
                        <sh:property rdf:parseType="Resource">
                          <sh:path rdf:resource="{$namespace}{$attribute/@name/string()}" />
                          <sh:class rdf:resource="{$namespace}{$attribute/properties/@type/string()}" />
                          {
                            let $minCount:=$attribute/bounds/@lower/string()
                            return if(fn:exists($minCount) and $minCount!="*") then
                              <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$minCount}</sh:minCount>
                          }
                          {
                            let $maxCount:=$attribute/bounds/@upper/string()
                            return if(fn:exists($maxCount) and $maxCount!="*") then
                              <sh:maxCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$maxCount}</sh:maxCount> 
                          }
                        </sh:property>
                      else
                        <sh:and>{$attributeClass/@name/string()}</sh:and>
                }
                {
                  (: mapping of attributes of UML classes to property shapes :)
                  (:   classes with stereotype <<enumeration>>, <<CodeList>> :)
                  if($element/properties[@stereotype="enumeration" or @stereotype="CodeList"]) then
                    <sh:property rdf:parseType="Resource">
                      <sh:path rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#value" />
                      {
                        for $attribute in $element/attributes/attribute
                          return <sh:in>{$attribute/@name/string()}</sh:in>
                      }
                      <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">0</sh:minCount>
                      <sh:maxCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">1</sh:maxCount>
                    </sh:property>
                }
                {
                  (: mapping of attributes of UML classes to property shapes :)
                  (:   classes with stereotype <<DataType>> :)
                  if($element/properties[@stereotype="DataType"]) then (
                    for $attribute in $element/attributes/attribute
                    return <sh:property rdf:parseType="Resource">
                      <sh:path rdf:resource="{$namespace}{$attribute/@name/string()}" />
                      {
                        let $attributeClass:=$model/elements/element[@name=$attribute/properties/@type]
                        for $attribute in $attributeClass/attributes/attribute
                          return <sh:in>{$attribute/@name/string()}</sh:in>
                      }
                      <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">0</sh:minCount>
                      <sh:maxCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">1</sh:maxCount>
                    </sh:property>, 
                    <sh:property rdf:parseType="Resource">
                      <sh:path rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#value" />
                      {              
                        for $generalization in $element/links/Generalization
                          where $generalization[@start=$element/@xmi:idref]
                          let $superClass:=$model/elements/element[@xmi:idref=$generalization/@end]
                          where fn:exists($superClass)
                          for $attribute in $superClass/attributes/attribute
                            return <sh:in>{$attribute/@name/string()}</sh:in>
                      }
                      <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">0</sh:minCount>
                      <sh:maxCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">1</sh:maxCount>
                    </sh:property>,
                    <sh:xone rdf:parseType="Resource">
                      {
                        for $attribute in $element/attributes/attribute
                          return <sh:property>
                            <sh:path rdf:resource="{$namespace}{$attribute/@name/string()}" />
                            <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">1</sh:minCount>
                          </sh:property>
                      }
                      <sh:property rdf:parseType="Resource">
                        <sh:path rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#value" />
                        <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">1</sh:minCount>
                      </sh:property>
                    </sh:xone>
                  )
                }
                {
                  (: mapping of local connectors to property shapes :)
                  (:   except for connectors with the UML class as association class  :)
                  for $connector in $model/connectors/connector
                    where (
                      (
                        $connector/source[@xmi:idref=$element/@xmi:idref]
                        and $connector/properties[@direction="Source -&gt; Destination"])
                      )
                      or 
                      (
                        $connector/target[@xmi:idref=$element/@xmi:idref] 
                        and $connector/properties[@direction="Destination -&gt; Source"]
                      )
                    let $targetName:=
                      if(fn:exists($connector/extendedProperties/@associationclass)) then
                        $model/elements/element[@xmi:idref=$connector/extendedProperties/@associationclass]/@name/string()
                      else
                        if($connector/properties[@direction="Source -&gt; Destination"]) then
                          $connector/target/model/@name/string()
                        else
                          $connector/source/model/@name/string()
                    let $pathName:=
                      if(fn:exists($connector/extendedProperties/@associationclass)) then
                        xmiUtilities:getRoleName($targetName)
                      else
                        if($connector/properties[@direction="Source -&gt; Destination"]) then
                          if(fn:exists($connector/target/role/@name)) then
                            $connector/target/role/@name
                          else
                            xmiUtilities:getRoleName($targetName)
                        else
                          if(fn:exists($connector/source/role/@name)) then
                            $connector/source/role/@name
                          else
                            xmiUtilities:getRoleName($targetName)
                    let $cardinality:=
                      if(fn:exists($connector/extendedProperties/@associationclass)) then
                        if($connector/properties[@direction="Source -&gt; Destination"]) then
                          $connector/target/type/@multiplicity
                        else
                          $connector/source/type/@multiplicity
                      else
                        if($connector/properties[@direction="Source -&gt; Destination"]) then
                          $connector/target/type/@multiplicity
                        else
                          $connector/source/type/@multiplicity
                    return <sh:property rdf:parseType="Resource">
                      <sh:path rdf:resource="{$namespace}{$pathName}" />
                      <sh:class rdf:resource="{$namespace}{$targetName}" />
                      {
                        let $minCount:=fn:substring($cardinality, 1, 1)
                        return if(fn:exists($minCount) and $minCount!="*") then
                          <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$minCount}</sh:minCount>
                      }
                      {
                        let $maxCount:=fn:substring($cardinality, fn:string-length($cardinality), 1)
                        return if(fn:exists($maxCount) and $maxCount!="*") then
                          <sh:maxCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$maxCount}</sh:maxCount> 
                      }
                    </sh:property>
                }
                {
                  (: mapping of local connectors to property shapes :)
                  (:   for connectors with the UML class as association class  :)
                  for $connector in $model/connectors/connector
                    where $element[@xmi:idref=$connector/extendedProperties/@associationclass]
                    let $targetName:=
                      if($connector/properties[@direction="Source -&gt; Destination"]) then
                        $connector/target/model/@name/string()
                      else
                        $connector/source/model/@name/string()
                    let $pathName:=xmiUtilities:getRoleName($targetName)
                    let $cardinality:=
                      if($connector/properties[@direction="Source -&gt; Destination"]) then
                        $connector/target/type/@multiplicity
                      else
                        $connector/source/type/@multiplicity
                    return <sh:property rdf:parseType="Resource">
                      <sh:path rdf:resource="{$namespace}{$pathName}" />
                      <sh:class rdf:resource="{$namespace}{$targetName}" />
                      {
                        let $minCount:=fn:substring($cardinality, 1, 1)
                        return if(fn:exists($minCount) and $minCount!="*") then
                          <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$minCount}</sh:minCount>
                      }
                      {
                        let $maxCount:=fn:substring($cardinality, fn:string-length($cardinality), 1)
                        return if(fn:exists($maxCount) and $maxCount!="*") then
                          <sh:maxCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$maxCount}</sh:maxCount> 
                      }
                    </sh:property>
                }
              </sh:NodeShape>
          )
        }
   </rdf:RDF>
};