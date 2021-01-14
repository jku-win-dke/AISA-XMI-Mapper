package at.jku.dke.samples;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.commons.io.FileUtils;
import org.basex.core.Context;
import org.basex.query.QueryException;
import org.basex.query.QueryProcessor;

public class RunMapper {

	public static void main(String[] args) throws QueryException, IOException {

		// adjust path to configuration file
		String configFile = "../../configurations/FIXM_EDDF-VHHH.xml";

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
	}
}
