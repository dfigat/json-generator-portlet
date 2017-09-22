package pl.psnc.indigo.customisable.portlet.generator.portlet.converter;

import java.io.IOException;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * Manipulate YAML files.
 */
public class Converter {

    /**
     * Inputs element in TOSCA document.
     */
    private final String inputs = "inputs";

    /**
     * Topology element in TOSCA document.
     */
    private final String topology = "topology_template";


    /**
     * Retrieves the parameters from the YAML.
     * The parameters defined in the YAML are extracted and inserted in a
     * JSON object compliant with the portlet interface specification
     *
     * @param yamlFile The YAML document
     * @return The JSON object
     */
    public final JsonObject readYamlToJsonArray(final String yamlFile) {
        JsonObject finalObject = new JsonObject();
        JsonParser parser = new JsonParser();
        finalObject.add("parameters", parser.parse("{}").getAsJsonObject());
        String json = convertYamlToJson(yamlFile);
        JsonArray array = new JsonArray();
        JsonObject jsonObject = parser.parse(json).getAsJsonObject();

        if (jsonObject.has(topology)) {
            jsonObject = (JsonObject) jsonObject.get(topology);
        } else {
            return finalObject;
        }
        if (jsonObject.has(inputs)) {
            jsonObject = (JsonObject) jsonObject.get(inputs);
        } else {
            return finalObject;
        }
        Set<Entry<String, JsonElement>> entrySet = jsonObject.entrySet();
        for (Map.Entry<String, JsonElement> entry : entrySet) {
            JsonElement el = entry.getValue();
            adaptToStandard(el, "default", "value");
            adaptToStandard(el, "description", "display");
            el.getAsJsonObject().addProperty("name", entry.getKey());
            array.add(el);
        }
        finalObject.add("parameters", array);
        return finalObject;
    }

    /**
     * Convert element name in a JSON element.
     * @param el The JSON element
     * @param oldTag The name to replace
     * @param newTag The new name
     */
    private void adaptToStandard(
            final JsonElement el, final String oldTag, final String newTag) {
        Gson gson = new GsonBuilder().serializeNulls().create();
        JsonElement obj = el.getAsJsonObject().get(oldTag);
        if (obj == null) {
            obj = gson.toJsonTree("");
        }
        el.getAsJsonObject().add(newTag, obj);
        el.getAsJsonObject().remove(oldTag);
    }

    /**
     * Convert a YAML to a JSON.
     *
     * @param yamlContent The YAML document
     * @return The corresponding JSON
     */
    private String convertYamlToJson(final String yamlContent) {
        if ((yamlContent == null) || (yamlContent.isEmpty())) {
            return "{}";
        }
        try {
            ObjectMapper yamlReader = new ObjectMapper(new YAMLFactory());
            Object obj = yamlReader.readValue(yamlContent, Object.class);
            ObjectMapper jsonWriter = new ObjectMapper();
            return jsonWriter.writeValueAsString(obj);
        } catch (JsonProcessingException ex) {
            ex.printStackTrace();
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return "{}";
    }
}
