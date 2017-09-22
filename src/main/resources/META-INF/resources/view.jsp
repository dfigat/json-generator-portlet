<%@ include file="/init.jsp" %>
<p>
	<b><liferay-ui:message key="json-generator.caption"/></b>
</p>
<script>
	var appJSON = {};
	function readJSON() {
		var jsonContent = $('#content_textarea').val();
		if(jsonContent == "") {
			jsonContent = '{"parameters":[]}';
		}
		appJSON = JSON.parse(jsonContent);
		$('#json_name').val('');
		$('#json_value').val('');
		$('#json_type').val('text');
		$('#json_display').val('');
		$('#json_chosen').val('');
		$('#json_maxlength').val('');
		$('#tabs_content').val('');
		var newJSON = JSON.stringify(appJSON, null ,2);
		$('#content_textarea').val(newJSON);

		changeParameterList(JSON.parse($('#content_textarea').val()));
		changeTabList(JSON.parse($('#content_textarea').val()));
		changeToSelectedParameter();
	}
	function updateTabs() {
		var T =	{"tabs": $('#tabs_content').val().split(',') };
		for(var i=0; i<T.tabs.length; i++) {
			T.tabs[i] = T.tabs[i].replace(/\n/g, "");
		}
		changeTabList(T);
	}
	function changeTabList(jsonContent) {
		var newTabList = [];
		var newTabList2JSON = [];
		var i=0;
		if(jsonContent.tabs) {
			if(jsonContent.tabs[0] == "") {
				$('#json_tabs').html('');
			}
			else {
				for(i=0; i<jsonContent.tabs.length; i++) {
					newTabList[i] = '<option>' + jsonContent.tabs[i] + '</option>';
					newTabList2JSON[i] = jsonContent.tabs[i];
				}
			}
			appJSON.tabs = newTabList2JSON;
			var newJSON = JSON.stringify(appJSON, null ,2)
			$('#content_textarea').val(newJSON);

			newTabList[i] = '<option>---</option>';
			$('#json_tabs').html(newTabList);
			$('#tabs_content').val(jsonContent.tabs);
			var x = $('#tabs_content').val().replace(/\n/g , "");
			x = x.replace(/,/g , ",\n");
			$('#tabs_content').val(x);	    	
		}
		else {
			$('#json_tabs').html('');
		}
	}
	function changeParameterList(jsonContent) {
		var newParameterList = [];
		if(jsonContent.parameters) {
			for(var i=0; i<jsonContent.parameters.length; i++) {
				newParameterList[i] = '<option>' + jsonContent.parameters[i].name + '</option>';
			}
			$('#json_parameters').html(newParameterList);
		}
		else {
			$('#json_parameters').html('')
		}
	}
	function readYAML() {
		var yaml_file_content = $('#content_textarea').val();
		var myData = {
			<portlet:namespace />yaml_content: yaml_file_content
		};
		AUI().use('aui-io-request', function(A){
			A.io.request('<%=resourceURL.toString()%>', {
				method: 'post',
				data: myData,
				on: {
					success: function() {
						var content = this.get('responseData');
						$('#content_textarea').val(content);
						readJSON();
					},
				}    
			});
		});
	}
	function changeToSelectedParameter() {
		var selected = $('#json_parameters option:selected').val();
		var jsonItem = null;
		if(appJSON.parameters) {
			for(var i=0; i<appJSON.parameters.length; i++) {
				if(appJSON.parameters[i].name == selected) {
					jsonItem = appJSON.parameters[i];
					break;
				}
			}
		}
		if(jsonItem != null) {
			$('#json_name').val(jsonItem.name);
			$('#json_value').val(jsonItem.value);
			$('#json_type').val(jsonItem.type);
			$('#json_display').val(jsonItem.display);
			$('#json_chosen').val(jsonItem.choosen);
			$('#json_maxlength').val(jsonItem.maxlength);
			var L = $('#json_tabs')[0].options.length;
			if(L > 0) {
				if(jsonItem.tab != null) {
					newPosition = jsonItem.tab;
					if((newPosition) < (L-1)) {
						$('#json_tabs').val($('#json_tabs')[0].options[newPosition].text);
					}
					else {
						$('#json_tabs').val($('#json_tabs')[0].options[L-1].text);
						alert("tab value out of range !");
					}
				}
				else {
					$('#json_tabs').val($('#json_tabs')[0].options[L-1].text);
				}
			}
		}
		return jsonItem;
	}
	function deleteParameter(current_name) {
		if(appJSON.parameters) {
			for(var i=0; i<appJSON.parameters.length; i++) {
				if(appJSON.parameters[i].name == current_name) {
					delete appJSON.parameters[i];
					appJSON.parameters = appJSON.parameters.filter(function(n){ return n != undefined });
					$('#content_textarea').val(JSON.stringify(appJSON, null, 2));
					readJSON();
					break;
				}
			}
		}
	}
	function updateParameter() {
		var current_name = $('#json_name').val();

		if(current_name != "") {
			var newItem = {};
			newItem.name = current_name;
			newItem.type = $('#json_type').val();
			if($('#json_value').val() != "") {
				if(newItem.type == "list" || newItem.type == "radio") {
					newItem.value = $('#json_value').val().split(',');
				}
				else {
					newItem.value = $('#json_value').val();
				}
			}
			else {
				newItem.value = current_name;
			}
			if($('#json_tabs').val() != "---") {
				var tab_position = -1;
				for(var i=0; i<$('#json_tabs')[0].options.length; i++) {
					if($('#json_tabs')[0].options[i].text == $('#json_tabs').val()) {
						tab_position = i;
						break;
					}
				}
				if(tab_position != -1) {
					newItem.tab = tab_position;
				}
			}
			if($('#json_display').val() != "") {
				newItem.display = $('#json_display').val();
			}
			else {
				newItem.value = current_name;
			}
			if($('#json_chosen').val() != "") {
				newItem.choosen = $('#json_chosen').val();
			}
			if($('#json_maxlength').val() != "") {
				newItem.choosen = $('#json_maxlength').val();
			}


			var test = false;
			if(appJSON.parameters) {
				var i=0;
				for(i=0; i<appJSON.parameters.length; i++) {
					if(appJSON.parameters[i].name == current_name) {
						appJSON.parameters[i] = newItem;
						test = true;
						break;
					}
				}
				if(test == false) {
					appJSON.parameters[i] = newItem;
				}
			}
			else {
				appJSON.parameters = [newItem];
			}
			$('#content_textarea').val(JSON.stringify(appJSON, null, 2));
		}
		readJSON();
	}
</script>

<div class="container">
	<h2>Form control: select</h2>
	<p>The form below contains two dropdown menus (select lists):</p>
	<div class="row">
		<div class="col-sm-4">
			<form>
				<div class="form-group">
					<label for="json-options">tab:</label>
					<select class="form-control" id="json_tabs">
					</select>
					<br>
				</div>
			</form>
			<form>
				<div class="form-group">
					<label for="json_type">type:</label>
					<select class="form-control" id="json_type">
						<option>text</option>
						<option>password</option>
						<option>list</option>
						<option>radio</option>
					</select>
					<br>
				</div>
			</form>
			<div class="form-group">
				<label for="usr">value:</label>
				<input type="text" class="form-control" id="json_value">
			</div>
			<div class="form-group">
				<label for="usr">name:</label>
				<input type="text" class="form-control" id="json_name">
			</div>
			<div class="form-group">
				<label for="usr">display:</label>
				<input type="text" class="form-control" id="json_display">
			</div>
			<div class="form-group">
				<label for="usr">chosen:</label>
				<input type="text" class="form-control" id="json_chosen">
			</div>
			<div class="form-group">
				<label for="usr">max length:</label>
				<input type="text" class="form-control" id="json_maxlength">
			</div>
		</div>
		<div class="col-sm-4">
			<form>
				<div class="form-group">
					<label for="json-options">parameter:</label>
					<select class="form-control" id="json_parameters">
					</select>
					<br>
				</div>
			</form>
			<div align="center">
				<button type="button" class="btn btn-success" onClick="updateParameter()">Update parameter</button>
			</div>
			<br>
			<div align="center">
				<button type="button" class="btn btn-danger" onClick="deleteParameter($('#json_parameters').val())">Delete parameter</button>
			</div>

			<div class="form-group">
				<label for="comment">tab content</label>
				<textarea class="form-control" rows="10" id="tabs_content"></textarea>
			</div>

			<div align="center">
				<button type="button" class="btn btn-success" onClick="updateTabs()">Update tabs</button>
			</div>
			<br>
		</div>
		<div class="col-sm-4">
			<div class="form-group">
				<label for="comment">Content</label>
				<textarea class="form-control" rows="25" id="content_textarea"></textarea>
			</div>
			<div align="center">
				<div class="btn-group">
					<button type="button" class="btn btn-default" onClick="readJSON()">Read JSON</button>
					<button type="button" class="btn btn-default" onClick="readYAML()">Read YAML</button>
				</div>
			</div>
		</div>
	</div>
</div>
<script>
	$("#json_parameters").change(function(){
		var X = changeToSelectedParameter();
	});
	$("#json_type").change(function(){
		if($('#json_type') == "list" || $('#json_type') == "radio") {
			$("json_maxlength").prop('disabled', true);
			$("json_chosen").prop('disabled', false);
		}
		if($('#json_type') == "text" || $('#json_type') == "password") {
			$("json_maxlength").prop('disabled', false);
			$("json_chosen").prop('disabled', true);
		}
	});
	$('#json_tabs').html('<option>---</option>');
</script>