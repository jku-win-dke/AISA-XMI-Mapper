package at.jku.dke.samples;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.jena.graph.Graph;
import org.apache.jena.rdf.model.InfModel;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.shacl.ShaclValidator;
import org.apache.jena.shacl.Shapes;
import org.apache.jena.shacl.ValidationReport;
import org.basex.core.Context;
import org.basex.query.QueryException;
import org.basex.query.QueryProcessor;

public class TestRunner {

	public static void main(String[] args) throws QueryException, IOException {

		// adjust path to configuration file
		String configFile = "../../configurations/FIXM_EDDF-VHHH.xml";
		//String configFile = "../../configurations/AIXM_DONLON.xml";

		// adjust path to mapper.xq
		String query = Files.readString(Paths.get("../../mapper.xq"));
		// adjust module paths
		query = query
				.replaceFirst("at \"extractor.xq\"", "at \"../../extractor.xq\"")
				.replaceFirst("at \"plugins/plain.xq\"", "at \"../../plugins/plain.xq\"")
				.replaceFirst("at \"plugins/fixm_3-0-1_sesar.xq\"", "at \"../../plugins/fixm_3-0-1_sesar.xq\"")
				.replaceFirst("at \"plugins/aixm_5-1-1.xq\"", "at \"../../plugins/aixm_5-1-1.xq\"");
		// adjust path to output folder
		query = query
				.replaceFirst("\\$model/@output", "\"../../\"||\\$model/@output");
		
		Context context = new Context();

		try (QueryProcessor proc = new QueryProcessor(query, context)) {
			
			proc.bind("config", configFile);
			
			proc.value();

		} catch (Exception ex) {
			ex.printStackTrace();
		}
		
		context.close();
		
		try {
			// adjust path to RDFS/SHACL file 
			Graph shapesGraph = RDFDataMgr.loadGraph("../../output/FIXM_EDDF-VHHH.xml");
			//Graph shapesGraph = RDFDataMgr.loadGraph("../../output/AIXM_DONLON.xml");
			Shapes shapes = Shapes.parse(shapesGraph);
			
			// adjust path for output file 
			FileOutputStream out = new FileOutputStream("../../output/FIXM_EDDF-VHHH.ttl");
			//FileOutputStream out = new FileOutputStream("../../output/AIXM_DONLON.ttl");
			RDFDataMgr.write(out, shapes.getGraph(), Lang.TTL);
			
			out.close();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		
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
