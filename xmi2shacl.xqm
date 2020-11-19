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
          for $element in $model/elements/element
            let $name:=$element/@name/string()
            return 
              <sh:NodeShape rdf:about="{$namespace}{$name}Shape">
                <sh:targetClass rdf:resource="{$namespace}{$name}" />
                {
                  (:attributes:)
                  for $attribute in $element/attributes/attribute
                    let $attributeName:=$attribute/@name/string()
                    where $attributeName!="minInclusive"
                    where $attributeName!="maxInclusive"
                    where $attributeName!="minExclusive"
                    where $attributeName!="maxExclusive"
                    where $attributeName!="pattern"
                    let $attributeType:=$attribute/properties/@type/string()
                    let $minCount:=$attribute/bounds/@lower/string()
                    let $maxCount:=$attribute/bounds/@upper/string()
                    return
                      if($element/properties[@stereotype!="CodeList" and @stereotype!="enumeration"]
                        or fn:exists($element/properties/@stereotype)=false()) then
                        <sh:property rdf:parseType="Resource">
                          <sh:path rdf:resource="{$namespace}{$attributeName}" />
                          <sh:class rdf:resource="{$namespace}{$attributeType}" />
                          {
                            if(fn:exists($minCount) and $minCount!="*") then
                              <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$minCount}</sh:minCount>
                          }
                          {
                            if(fn:exists($maxCount) and $maxCount!="*") then
                              <sh:maxCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$maxCount}</sh:maxCount> 
                          }
                        </sh:property>
                      else 
                        <sh:in>{$attributeName}</sh:in>
                }
                {
                  (: connections :)
                  for $connector in $model/connectors/connector
                    where ($connector/source[@xmi:idref=$element/@xmi:idref]
                      and $connector/properties[@direction="Source -&gt; Destination"])
                      or ($connector/target[@xmi:idref=$element/@xmi:idref] 
                      and $connector/properties[@direction="Destination -&gt; Source"])
                    let $rangeClassName:=
                      if($connector/properties[@ea_type="Association" and @subtype="Class"]) then
                        $model/elements/element[@xmi:idref=$connector/extendedProperties/@associationclass]/@name/string()
                      else
                        if($connector/properties[@direction="Source -&gt; Destination"]) then
                          $connector/target/model/@name/string()
                        else
                          $connector/source/model/@name/string()
                    let $roleName:=
                      if($connector/properties[@ea_type="Association" and @subtype="Class"]) then
                        xmiUtilities:getRoleName($rangeClassName)
                      else
                        if($connector/properties[@direction="Source -&gt; Destination"]) then
                          if(fn:exists($connector/target/role/@name)) then
                            $connector/target/role/@name
                          else
                            xmiUtilities:getRoleName($rangeClassName)
                        else
                          if(fn:exists($connector/source/role/@name)) then
                            $connector/source/role/@name
                          else
                            xmiUtilities:getRoleName($rangeClassName)
                    let $multiplicity:=
                      if($connector/properties[@direction="Source -&gt; Destination"]) then
                        $connector/target/type/@multiplicity
                      else
                        $connector/source/type/@multiplicity
                    return <sh:property rdf:parseType="Resource">
                      <sh:path rdf:resource="{$namespace}{$roleName}" />
                      <sh:class rdf:resource="{$namespace}{$rangeClassName}" />
                      {
                        let $minCount:=fn:substring($multiplicity, 1, 1)
                        return if(fn:exists($minCount) and $minCount!="*") then
                          <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$minCount}</sh:minCount>
                      }
                      {
                        let $maxCount:=fn:substring($multiplicity, fn:string-length($multiplicity), 1)
                        return if(fn:exists($maxCount) and $maxCount!="*") then
                          <sh:maxCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$maxCount}</sh:maxCount> 
                      }
                    </sh:property>
                }
                {
                  (: connections of association classes :)
                  for $connector in $model/connectors/connector
                    where $element[@xmi:idref=$connector/extendedProperties/@associationclass]
                    let $rangeClassName:=
                      if($connector/properties[@direction="Source -&gt; Destination"]) then
                        $connector/target/model/@name/string()
                      else
                        $connector/source/model/@name/string()
                    let $roleName:=xmiUtilities:getRoleName($rangeClassName)
                    let $multiplicity:=
                      if($connector/properties[@direction="Source -&gt; Destination"]) then
                        $connector/target/type/@multiplicity
                      else
                        $connector/source/type/@multiplicity
                    return <sh:property rdf:parseType="Resource">
                      <sh:path rdf:resource="{$namespace}{$roleName}" />
                      <sh:class rdf:resource="{$namespace}{$rangeClassName}" />
                      {
                        let $minCount:=fn:substring($multiplicity, 1, 1)
                        return if(fn:exists($minCount) and $minCount!="*") then
                          <sh:minCount rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$minCount}</sh:minCount>
                      }
                      {
                        let $maxCount:=fn:substring($multiplicity, fn:string-length($multiplicity), 1)
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