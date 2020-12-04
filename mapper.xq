declare namespace mapper="http://www.aisa-project.eu/xquery/mapper";

import module "http://www.aisa-project.eu/xquery/extractor" at "extractor.xq";
import module "http://www.aisa-project.eu/xquery/plain" at "plugins/plain.xq";
import module "http://www.aisa-project.eu/xquery/aixm_5-1-1" at "plugins/aixm_5-1-1.xq";

declare namespace extractor="http://www.aisa-project.eu/xquery/extractor";
declare namespace plain="http://www.aisa-project.eu/xquery/plain";
declare namespace aixm_5-1-1="http://www.aisa-project.eu/xquery/aixm_5-1-1";

declare variable $config:=fn:doc("input/configuration2.xml")/configuration;

for $model in $config/selection/models/model
let $modelSubset:=extractor:getModelSubset($model)
let $mappedModel:=
  if($model/@type/string()="aixm_5-1-1") then
    aixm_5-1-1:map($modelSubset)
  else
    plain:map($modelSubset)
return (
  $mappedModel, 
  file:write("output/schema.xml", $mappedModel)
)