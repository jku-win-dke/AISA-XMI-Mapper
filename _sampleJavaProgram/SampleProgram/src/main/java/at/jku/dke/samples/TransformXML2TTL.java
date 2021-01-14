package at.jku.dke.samples;

import java.io.FileOutputStream;

import org.apache.jena.graph.Graph;
import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.shacl.Shapes;

public class TransformXML2TTL {

	public static void main(String[] args) {
		
		try {
			
			// change path to RDFS/SHACL file accordingly
			Graph shapesGraph = RDFDataMgr.loadGraph("src/main/resources/output/FIXM_EDDF-VHHH.xml");
			Shapes shapes = Shapes.parse(shapesGraph);
			
			// change path for output file accordingly
			FileOutputStream out = new FileOutputStream("src/main/resources/output/FIXM_EDDF-VHHH.ttl");
			RDFDataMgr.write(out, shapes.getGraph(), Lang.TTL);
			
			out.close();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
}
