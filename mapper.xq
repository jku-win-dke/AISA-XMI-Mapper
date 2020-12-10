declare namespace mapper="http://www.aisa-project.eu/xquery/mapper";

declare namespace extractor="http://www.aisa-project.eu/xquery/extractor";
declare namespace plain="http://www.aisa-project.eu/xquery/plain";
declare namespace aixm_5-1-1="http://www.aisa-project.eu/xquery/aixm_5-1-1";
declare namespace fixm_3-0-1_sesar="http://www.aisa-project.eu/xquery/fixm_3-0-1_sesar";

import module "http://www.aisa-project.eu/xquery/extractor" at "extractor.xq";
import module "http://www.aisa-project.eu/xquery/plain" at "plugins/plain.xq";
import module "http://www.aisa-project.eu/xquery/aixm_5-1-1" at "plugins/aixm_5-1-1.xq";
import module "http://www.aisa-project.eu/xquery/fixm_3-0-1_sesar" at "plugins/fixm_3-0-1_sesar.xq";

declare variable $config:=fn:doc("input/configuration2.xml")/configuration;

for $model in $config/selection/models/model
let $modelSubset:=extractor:getModelSubset($model)
let $mappedModel:=
  if($model/@type/string()="aixm_5-1-1") then
    aixm_5-1-1:map($modelSubset)
  else if($model/@type/string()="fixm_3-0-1_sesar") then
    fixm_3-0-1_sesar:map($modelSubset)
  else
    plain:map($modelSubset)
let $fileName:=
  "output/"
  ||fn:replace(
      fn:tokenize($model/@location, "/")[
        fn:count(fn:tokenize($model/@location, "/"))], 
      ".xmi", "")
  ||"_subset.xml"
return (
  $mappedModel, 
  file:write($fileName, $mappedModel)
)