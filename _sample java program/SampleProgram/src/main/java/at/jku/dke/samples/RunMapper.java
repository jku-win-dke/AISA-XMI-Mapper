package at.jku.dke.samples;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.basex.core.Context;
import org.basex.query.QueryException;
import org.basex.query.QueryProcessor;

public class RunMapper {

	public static void main(String[] args) throws QueryException, IOException {

		String configFile = "src/main/resources/configurations/FIXM_EDDF-VHHH.xml";

		String query = Files.readString(Paths.get("src/main/resources/mapper.xq"));
		
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
