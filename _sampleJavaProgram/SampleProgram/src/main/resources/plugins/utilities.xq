module namespace utilities="http://www.aisa-project.eu/xquery/utilities";

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare variable $utilities:rdf:="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare function utilities:getCollection(
  $elements as element()*
) as element()? {
  if(fn:count($elements)>0) then
    <rdf:rest rdf:parseType="Resource">
      <rdf:first>{$elements[1]/@name/string()}</rdf:first>
      {
        utilities:getCollection(fn:subsequence($elements, 2))
      }
    </rdf:rest>
  else
    <rdf:rest rdf:resource="{$utilities:rdf}nil"/>
};

declare function utilities:getSuperElements(
  $element as element(),
  $modelSubset as element(),
  $stereotype as xs:string?
) as element()* {
  for $connector in $modelSubset/connectors/connector
  where $connector/properties[@ea_type="Generalization"]
  where (
      ( $connector/source[@xmi:idref=$element/@xmi:idref]
        and fn:exists($connector/properties/@direction)=false()
      ) or
      ( $connector/source[@xmi:idref=$element/@xmi:idref]
        and $connector/properties[@direction!="Destination -&gt; Source"]
      ) or  
      ( $connector/target[@xmi:idref=$element/@xmi:idref]
        and $connector/properties[@direction="Destination -&gt; Source"]
      )
    )
  let $superElement:=
    if($connector/properties[@direction="Destination -&gt; Source"]) then
      $modelSubset/elements/element[@xmi:idref=$connector/source/@xmi:idref]
    else
      $modelSubset/elements/element[@xmi:idref=$connector/target/@xmi:idref]
  where fn:exists($superElement)
  where (
    ( fn:exists($stereotype) 
      and $superElement/properties[@stereotype=$stereotype]
    ) or fn:exists($stereotype)=false()
  )
  return $superElement
};