package at.jku.dke.xmiMapper;

import org.apache.jena.graph.Graph;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.shacl.ShaclValidator;
import org.apache.jena.shacl.Shapes;
import org.apache.jena.shacl.ValidationReport;

public class ValidationWithSHACL {

	public static void main(String[] args) {

		try {
			Model generatedSchema = RDFDataMgr.loadModel("src/main/resources/output/FIXM_EDDF-VHHH.xml");
			Shapes shapes = Shapes.parse(generatedSchema);

			Graph dataGraph = RDFDataMgr.loadGraph("../../_example data/FIXM_EDDF-VHHH.ttl");

			ValidationReport report = ShaclValidator.get().validate(shapes, dataGraph);
			RDFDataMgr.write(System.out, report.getModel(), Lang.TTL);
			
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
}