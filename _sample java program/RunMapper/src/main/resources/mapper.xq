import module "http://www.aisa-project.eu/xquery/extractor" at "src/main/resources/extractor.xq";
import module "http://www.aisa-project.eu/xquery/plain" at "src/main/resources/plugins/plain.xq";
import module "http://www.aisa-project.eu/xquery/aixm_5-1-1" at "src/main/resources/plugins/aixm_5-1-1.xq";
import module "http://www.aisa-project.eu/xquery/fixm_3-0-1_sesar" at "src/main/resources/plugins/fixm_3-0-1_sesar.xq";

declare namespace mapper="http://www.aisa-project.eu/xquery/mapper";
declare namespace extractor="http://www.aisa-project.eu/xquery/extractor";
declare namespace plain="http://www.aisa-project.eu/xquery/plain";
declare namespace aixm_5-1-1="http://www.aisa-project.eu/xquery/aixm_5-1-1";
declare namespace fixm_3-0-1_sesar="http://www.aisa-project.eu/xquery/fixm_3-0-1_sesar";

declare variable $config external;
declare variable $configuration:=fn:doc($config)/configuration;

for $model in $configuration/selection/models/model
let $modelSubset:=extractor:getModelSubset($model)
let $mappedModel:=
  if($model/@type/string()="aixm_5-1-1") then
    aixm_5-1-1:map($modelSubset)
  else if($model/@type/string()="fixm_3-0-1_sesar") then
    fixm_3-0-1_sesar:map($modelSubset)
  else
    plain:map($modelSubset)
return file:write($model/@output, $mappedModel)