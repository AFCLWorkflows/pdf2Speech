package function;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.google.cloud.functions.HttpFunction;
import com.google.cloud.functions.HttpRequest;
import com.google.cloud.functions.HttpResponse;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.apache.commons.io.FilenameUtils;
import shared.Configuration;
import shared.Credentials;
import shared.Provider;
import storage.Storage;
import storage.StorageImpl;
import ocr.*;

public class ExtractFunction implements HttpFunction, RequestHandler<ExtractInput, ExtractOutput> {

    private static final Gson gson = new Gson();

    @Override
    public ExtractOutput handleRequest(ExtractInput input, Context context) {
        try {
            return doWork(input);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public void service(HttpRequest request, HttpResponse response) throws Exception {
        JsonObject body = gson.fromJson(request.getReader(), JsonObject.class);
        ExtractInput input = gson.fromJson(body.toString(), ExtractInput.class);
        ExtractOutput output = doWork(input);
        response.getWriter().write(gson.toJson(output));
    }

    public ExtractOutput doWork(ExtractInput input) throws Exception {
        // construct output file url
        String baseName = FilenameUtils.getBaseName(input.getInputFile());
        String outputFile = input.getOutputBucket() + "extract/" + baseName + "." + "txt";
        // invoke translation
        Credentials credentials = Credentials.loadDefaultCredentials();
        Configuration configuration = Configuration.builder().build();
        OcrService ocrService = new OcrService(configuration, credentials);
        OcrRequest request = OcrRequest.builder()
                .inputFile(input.getInputFile())
                .build();
        OcrResponse response = ocrService.extract(request, Provider.valueOf(input.getProvider()));
        // write result to output bucket
        Storage storage = new StorageImpl(Credentials.loadDefaultCredentials());
        storage.write(response.getText().getBytes(), outputFile);
        // return response
        return ExtractOutput.builder().outputFile(outputFile).build();
    }

}
