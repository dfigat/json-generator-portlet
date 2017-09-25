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
		try {
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
		catch(err) {
			alert(err);
		}
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
			appJSON.parameters = [];
			$('#content_textarea').val(JSON.stringify(appJSON, null ,2));
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
				newItem.display = current_name;
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

	function printJsonArray() {
		jsonArr = [];
		jsonTab = [];
		if(appJSON.parameters) {
			jsonArr = appJSON.parameters;
		}
		if(appJSON.tabs) {
			jsonTab = appJSON.tabs;
		}
		
		var i;
		var k;
		tabBegin = '<ul class="nav nav-tabs">'; 
		var tabs = null;
		var makeTabs = false;
		var maxTab = 0;
		if(jsonTab != null) {
			maxTab = jsonTab.length;
			tabs = new Array(maxTab);
			makeTabs = true;
			for(var i=0; i<maxTab; i++) {
				if(i == 0) {
					tabBegin += '<li class="active"><a data-toggle="tab" href="#menu'+i+'">'+jsonTab[i]+'</a></li>';
				}
				else {
					tabBegin += '<li><a data-toggle="tab" href="#menu'+i+'">'+jsonTab[i]+'</a></li>';
				}
				tabs[i] = '';
			}
		}
		tabBegin += '</ul>'; 
		var out;
		var globalOut='';
		for(var i = 0; i < jsonArr.length; i++) {
			out = '';
			if(jsonArr[i].hasOwnProperty('display')){
				out += '<p><b>' + jsonArr[i].display + '</b>';
			}
			else {
				out += '<p><b>' + jsonArr[i].name + '</b>';
			}
			switch(jsonArr[i].type) {
				case "password":
					out += '<input type="password" maxlength="50" id="param_'+jsonArr[i].name
					+'" class="form-control" value="' + jsonArr[i].value + '"/></br>';
					break;
				case "radio":    
					out += '<div id="param_'+jsonArr[i].name+'" class="radio">';
					for(k = 0; k < jsonArr[i].value.length; k++) {
						out += '<label><input type="radio" name="'+jsonArr[i].name 
						+'" value="'+jsonArr[i].value[k]+'"';
						if(k == 0) {
							out += ' checked';
						}
						out += '>'+jsonArr[i].value[k]+'</label></br>';
					}
					out += '</div>';
					break;
				case "list":
					out += '<div class="form-group">';
					out += '<select class="form-control" id="param_'+jsonArr[i].name+'">'
					for(k = 0; k < jsonArr[i].value.length; k++) {
						out += '<option>'+jsonArr[i].value[k]+'</option>'
					}
					out += '</select></div>';
					break;
				case "onedata":
					out += '<div class="form-group">';
					out += '<select id="param_'+jsonArr[i].name
					+'" onchange="<portlet:namespace />updateOneDataTree(\'param_'+jsonArr[i].name+'\', \'param_tree_'+jsonArr[i].name+'\')" class="form-control">';
					out += '<option value="">Select the OneZone</option>';
					var onezone;
					for(onezone in jsonArr[i].value) {
						out += '<option value="' + jsonArr[i].value[onezone] + '">' + jsonArr[i].value[onezone] + '</option>';
					} 
					out += '</select></br>';
					out += '<div id="param_tree_'+jsonArr[i].name+'"></div>';
					out += '</div>';
					break;
				case "text":
				default:
					out += '<input type="text" id="param_'+jsonArr[i].name
					+'" class="form-control" value="' + jsonArr[i].value + '"/></br>';
					break;
			}
			out += '</p>';
			if((jsonArr[i].tab != null) && makeTabs) {
				var index = jsonArr[i].tab;
				if(index < maxTab) {
					tabs[index] += out;
				}
				else {
					globalOut += out;
				}
			}
			else {
				globalOut += out;
			}
		}
		if(jsonTab != null) {
			out = '<div id="params-modal">';
			out += globalOut;
			out += tabBegin;
			out += '<div class="tab-content">';
			for(var i=0; i < jsonTab.length; i++) {
				if(i == 0) {
					out += '<div id="menu'+i+'" class="tab-pane fade in active">';
				}
				else {
					out += '<div id="menu'+i+'" class="tab-pane fade">';
				}
				out += tabs[i];
				out += '</div>';
			}
			out += '</div>';
			out += '</div>';
		}
		else {
			out = '<div id="params-modal">';
			out += globalOut;
			out += '</div>';
		}
		var myDiv = document.getElementById("modal-body");
		myDiv.innerHTML = out;
		for(var i = 0; i < jsonArr.length; i++) {
			switch(jsonArr[i].type) {
				case "password":
				if(jsonArr[i].maxlength) {
					$("#param_"+jsonArr[i].name).prop("maxLength",jsonArr[i].maxlength);
				}
				break;
				case "password":
				if(jsonArr[i].maxlength) {
					$("#param_"+jsonArr[i].name).prop("maxLength",jsonArr[i].maxlength);
				}
				break;
				case "list":
				if(jsonArr[i].choosen) {
					$("#param_"+jsonArr[i].name).val(jsonArr[i].choosen);
				}
				break;
				case "radio":
				if(jsonArr[i].choosen) {
					var radio_length = $('input[name='+jsonArr[i].name+']').length;
					for(var j=0; j<radio_length; j++) {
						if($('input[name='+jsonArr[i].name+']')[j].defaultValue == jsonArr[i].choosen) {
							$('input[name='+jsonArr[i].name+']')[j].checked=true;
							break;
						}
					}
				}
				break;
			}
		}
	}
</script>

<div class="container">
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
			<br>
			<br>
			<div class="form-group">
				<label for="comment">tab content</label>
				<textarea class="form-control" rows="10" id="tabs_content"></textarea>
			</div>

			<div align="center">
				<button type="button" class="btn btn-success" onClick="updateTabs()">Update tabs</button>
			</div>
			<br>

			<br>
			<div align="center">
				<button type="button" class="btn btn-default" data-toggle="modal" data-target="#myModal" onclick="printJsonArray()">Generate !</button>
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

	<div class="modal fade modal-hidden" role="dialog" id="myModal" role="dialog">
		<div class="modal-dialog modal-lg">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">&times;</button>
					<center>
						<h4 class="modal-title">Generated parameters list</h4>
					</center>
				</div>
				<div class="modal-body" id="modal-body">
				</div>
				<div class="modal-footer">
					<center>
						<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
					</center>
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
