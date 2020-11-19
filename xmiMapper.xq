import module "http://www.aisa-project.eu/xquery/xmi2rdfs" at "xmi2rdfs.xqm";
import module "http://www.aisa-project.eu/xquery/xmi2shacl" at "xmi2shacl.xqm";

declare namespace xmiExtractor="http://www.aisa-project.eu/xquery/xmiextractor";
declare namespace xmi2rdfs="http://www.aisa-project.eu/xquery/xmi2rdfs";
declare namespace xmi2shacl="http://www.aisa-project.eu/xquery/xmi2shacl";

declare variable $config:=fn:doc("input/configuration.xml")/configuration;

file:write("output/subset.xmi", xmiExtractor:extractSubsetOfModels($config)),
file:write("output/rdfs.xml", xmi2rdfs:map("output/subset.xmi"))
(:file:write("output/shacl.xml", xmi2shacl:map("output/subset.xmi")),:)