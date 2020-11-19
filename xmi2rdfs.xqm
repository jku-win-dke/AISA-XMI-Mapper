module namespace xmi2rdfs = "http://www.aisa-project.eu/xquery/xmi2rdfs";

import module "http://www.aisa-project.eu/xquery/xmiextractor" at "xmiExtractor.xqm";
import module "http://www.aisa-project.eu/xquery/xmiutilities" at "xmiUtilities.xqm";

declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";
declare namespace xmiExtractor="http://www.aisa-project.eu/xquery/xmiextractor";
declare namespace xmiUtilities="http://www.aisa-project.eu/xquery/xmiutilities";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace owl="http://www.w3.org/2002/07/owl#";

declare function xmi2rdfs:map(
  $fileName as xs:string
) as element() {
  <rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#">   
    {
      for $model in fn:doc($fileName)/models/model
        let $namespace:=xmiUtilities:getNamespace($model/@name/string())     
        return (
          
          (: mapping of UML classes to RDFS classes :) 
          (:   except classes with names containing "BaseType" :)
          for $element in $model/elements/element
            where fn:contains($element/@name/string(),"BaseType")=false()
            return <rdfs:Class rdf:about="{$namespace}{$element/@name/string()}">
              <rdfs:label>{$element/@name/string()}</rdfs:label>
              <rdfs:comment>{fn:normalize-space($element/properties/@documentation/string())}</rdfs:comment>
              {
                (: mapping of generalizations from a UML class :)
                (:   except generalization to UML classes with names containing "BaseType" :)
                for $generalization in $element/links/Generalization
                  where $generalization[@start=$element/@xmi:idref]
                  let $superClass:=$model/elements/element[@xmi:idref=$generalization/@end]
                  where fn:exists($superClass)
                  where fn:contains($superClass/@name/string(),"BaseType")=false()
                  return <rdfs:subClassOf rdf:resource="{$namespace}{$superClass/@name/string()}" />
              }
              {
                (: adding OWL for attributes of an UML class :)
                (:   except classes with stereotype <<CodeList>>, <<enumeration>>, <<DataType>> :)
                for $attribute in $element/attributes/attribute
                  where (
                    ( fn:exists($element/properties/@stereotype)
                      and $element/properties[@stereotype!="CodeList"]
                      and $element/properties[@stereotype!="enumeration"] 
                      and $element/properties[@stereotype!="DataType"]
                    ) or fn:exists($element/properties/@stereotype)=false())
                  return <rdfs:subClassOf>
                    <owl:Restriction>
                      <owl:onProperty rdf:resource="{$namespace}{$attribute/@name/string()}"/>
                      <owl:allValuesFrom rdf:resource="{$namespace}{$attribute/properties/@type/string()}"/>
                    </owl:Restriction>
                  </rdfs:subClassOf>
              }
              {
                (: adding OWL for connectors of an UML class :)
                (:   except association classes :)
                for $connector in $model/connectors/connector
                  where (
                    (
                       $connector/source[@xmi:idref=$element/@xmi:idref]
                       and $connector/properties[@direction="Source -&gt; Destination"]
                    ) 
                    or
                    (
                      $connector/target[@xmi:idref=$element/@xmi:idref]
                       and $connector/properties[@direction="Destination -&gt; Source"]
                    )
                  )
                  return <rdfs:subClassOf>
                    <owl:Restriction>
                    {
                      if($connector/properties[@ea_type="Association" and @subtype="Class"]) then
                        let $associationClass:=$model/elements/element[@xmi:idref=$connector/extendedProperties/@associationclass]
                        return (
                          <owl:onProperty rdf:resource="{$namespace}{xmiUtilities:getRoleName($associationClass/@name/string())}"/>,
                          <owl:allValuesFrom rdf:resource="{$namespace}{$associationClass/@name/string()}"/>
                        )
                      else
                        if($connector/properties[@direction="Source -&gt; Destination"]) then
                          if(fn:exists($connector/target/role/@name)) then
                            (
                              <owl:onProperty rdf:resource="{$namespace}{$connector/target/role/@name/string()}"/>,
                              <owl:allValuesFrom rdf:resource="{$namespace}{$connector/target/model/@name/string()}"/>
                            )
                          else
                            (
                              <owl:onProperty rdf:resource="{$namespace}{xmiUtilities:getRoleName($connector/target/model/@name/string())}"/>,
                              <owl:allValuesFrom rdf:resource="{$namespace}{$connector/target/model/@name/string()}"/>
                            )     
                        else 
                          if(fn:exists($connector/source/role/@name)) then
                            (
                              <owl:onProperty rdf:resource="{$namespace}{$connector/source/role/@name/string()}"/>,
                              <owl:allValuesFrom rdf:resource="{$namespace}{$connector/source/model/@name/string()}"/>
                            )
                          else
                            (
                              <owl:onProperty rdf:resource="{$namespace}{xmiUtilities:getRoleName($connector/source/model/@name/string())}"/>,
                              <owl:allValuesFrom rdf:resource="{$namespace}{$connector/source/model/@name/string()}"/>
                            ) 
                    }
                    </owl:Restriction>
                  </rdfs:subClassOf> 
              }
              {
                (: adding OWL for connectors of an UML association class :)
                for $connector in $model/connectors/connector
                  where $connector/extendedProperties[@associationclass=$element/@xmi:idref]
                  return <rdfs:subClassOf>
                    <owl:Restriction>
                      {
                        if($connector/properties[@direction="Source -&gt; Destination"]) then
                          (
                            <owl:onProperty rdf:resource="{$namespace}{xmiUtilities:getRoleName($connector/target/model/@name/string())}"/>,
                            <owl:allValuesFrom rdf:resource="{$namespace}{$connector/target/model/@name/string()}"/>
                          )
                        else
                          (
                            <owl:onProperty rdf:resource="{$namespace}{xmiUtilities:getRoleName($connector/source/model/@name/string())}"/>,
                            <owl:allValuesFrom rdf:resource="{$namespace}{$connector/source/model/@name/string()}"/>
                          )
                      }
                    </owl:Restriction>
                  </rdfs:subClassOf>
              }
            </rdfs:Class>,
            
            (: mapping of global attributes :)
            (:   except attributes of <<CodeList>>, <<enumeration>> :)
            let $attributes:=fn:distinct-values(
              for $element in $model/elements/element
                for $attribute in $element/attributes/attribute
                  where(
                    ( fn:exists($element/properties/@stereotype) 
                      and $element/properties[@stereotype!="CodeList"]
                      and $element/properties[@stereotype!="enumeration"]
                    ) or fn:exists($element/properties/@stereotype)=false())
                  return $attribute/@name/string()
              )
            for $attribute in $attributes
              return <rdf:Property rdf:about="{$namespace}{$attribute}" />,
              
            (: mapping of global connectors :)
            let $connectors:=fn:distinct-values(
              for $connector in $model/connectors/connector
                return
                  (: associations with association class :)
                  if($connector/properties[@ea_type="Association" and @subtype="Class"]) then
                    let $associationClass:=$model/elements/element[@xmi:idref=$connector/extendedProperties/@associationclass]
                    return 
                      if($connector/properties[@direction="Source -&gt; Destination"]) then
                      (
                        xmiUtilities:getRoleName($associationClass/@name/string()), 
                        xmiUtilities:getRoleName($connector/target/model/@name/string())
                      )
                      else
                      (
                        xmiUtilities:getRoleName($associationClass/@name/string()), 
                        xmiUtilities:getRoleName($connector/source/model/@name/string())
                      )
                  (: connectors without association class :)
                  else
                    if($connector/properties[@direction="Source -&gt; Destination"]) then
                      if(fn:exists($connector/target/role/@name)) then
                        $connector/target/role/@name/string()
                      else
                        xmiUtilities:getRoleName($connector/target/model/@name/string())
                    else 
                      if(fn:exists($connector/source/role/@name)) then
                        $connector/source/role/@name/string()
                      else
                        xmiUtilities:getRoleName($connector/source/model/@name/string())
            )
            for $connector in $connectors
              return <rdf:Property rdf:about="{$namespace}{$connector}"/>
      )
    }
  </rdf:RDF>
};