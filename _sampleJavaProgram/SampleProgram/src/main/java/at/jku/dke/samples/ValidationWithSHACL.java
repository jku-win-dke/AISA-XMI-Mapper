package at.jku.dke.samples;

import org.apache.jena.rdf.model.InfModel;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.shacl.ShaclValidator;
import org.apache.jena.shacl.Shapes;
import org.apache.jena.shacl.ValidationReport;

public class ValidationWithSHACL {

	public static void main(String[] args) {

		try {
			// adjust path to RDFS/SHACL file 
			Model schema = RDFDataMgr.loadModel("../../output/FIXM_EDDF-VHHH.xml");
			//Model schema = RDFDataMgr.loadModel("../../output/AIXM_DONLON.xml");
			Shapes shapes = Shapes.parse(schema);

			// adjust path to instance data 
			Model data = RDFDataMgr.loadModel("../../_exampleData/FIXM_EDDF-VHHH.ttl");
			//Model data = RDFDataMgr.loadModel("../../_exampleData/AIXM_DONLON.ttl");
			
			InfModel infmodel = ModelFactory.createRDFSModel(schema, data);

			ValidationReport report = ShaclValidator.get().validate(shapes, infmodel.getGraph());
			RDFDataMgr.write(System.out, report.getModel(), Lang.TTL);
			
			System.out.println("Errors: " + report.getEntries().size());
			
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
}