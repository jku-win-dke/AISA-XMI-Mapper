package at.jku.dke.samples;

import java.io.FileOutputStream;

import org.apache.jena.graph.Graph;
import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.shacl.Shapes;

public class TransformXML2TTL {

	public static void main(String[] args) {
		
		try {
			
			// adjust path to RDFS/SHACL file 
			Graph shapesGraph = RDFDataMgr.loadGraph("../../output/FIXM_EDDF-VHHH.xml");
			Shapes shapes = Shapes.parse(shapesGraph);
			
			// adjust path for output file 
			FileOutputStream out = new FileOutputStream("../../output/FIXM_EDDF-VHHH.ttl");
			RDFDataMgr.write(out, shapes.getGraph(), Lang.TTL);
			
			out.close();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
}
