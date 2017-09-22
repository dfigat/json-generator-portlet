package pl.psnc.indigo.customisable.portlet.generator.portlet;

import pl.psnc.indigo.customisable.portlet.generator.portlet.converter.Converter;
import pl.psnc.indigo.customisable.portlet.generator.constants.JsonGeneratorPortletKeys;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;
import com.liferay.portal.kernel.util.ParamUtil;

import javax.portlet.*;
import java.io.IOException;
import java.io.PrintWriter;

import org.osgi.service.component.annotations.Component;


/**
 * @author daniel
 */
@Component(
	immediate = true,
	property = {
		"com.liferay.portlet.display-category=category.sample",
		"com.liferay.portlet.instanceable=true",
		"javax.portlet.display-name=json-generator portlet",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/view.jsp",
		"javax.portlet.name=" + JsonGeneratorPortletKeys.JsonGenerator,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class JsonGeneratorPortlet extends MVCPortlet {

    @Override
    public final void serveResource(final ResourceRequest resourceRequest,
            final ResourceResponse resourceResponse)
    throws IOException, PortletException {
    try {
        String content = ParamUtil.getString(resourceRequest, "yaml_content");
        Converter converter = new Converter();
        String newJson = converter.readYamlToJsonArray(content).toString();
        PrintWriter writer = resourceResponse.getWriter();
        writer.write(newJson);
    } catch (Exception e) {
        e.printStackTrace(System.out);
    }
    super.serveResource(resourceRequest, resourceResponse);
    }
}
