module namespace plain="http://www.aisa-project.eu/xquery/plain";

declare namespace gml="http://www.opengis.net/gml/3.2#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace sh="http://www.w3.org/ns/shacl#";
declare namespace xmi="http://schema.omg.org/spec/XMI/2.1";

declare variable $plain:xsd:="http://www.w3.org/2001/XMLSchema#";

declare function plain:map(
  $modelSubset as element()
) as element() {
};
