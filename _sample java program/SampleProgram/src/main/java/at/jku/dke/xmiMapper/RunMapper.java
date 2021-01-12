package at.jku.dke.xmiMapper;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.basex.core.Context;
import org.basex.query.QueryException;
import org.basex.query.QueryProcessor;

public class RunMapper {
	
	// for more examples of using BaseX library in Java, see: https://docs.basex.org/wiki/Java_Examples

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
