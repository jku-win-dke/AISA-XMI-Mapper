module namespace xmiUtilities = "http://www.aisa-project.eu/xquery/xmiutilities";

declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare function xmiUtilities:getNamespace(
  $modelName as xs:string
) as xs:string {
  "http://www.aisa-project.eu/"||$modelName||"/"
};

declare function xmiUtilities:getRoleName(
  $className as xs:string
) as xs:string {
  fn:concat(fn:lower-case(fn:substring($className, 1, 1)), fn:substring($className, 2))
};