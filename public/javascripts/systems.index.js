var Services = new Object();
var Systems = new Object();
var SystemGroups = new Object();
var ResponseData;
var dialogContainers = new Object();
var dialogContainersSize = 0;

$j(document).ready(function($) {

        // config-array mit Spaltennamen
        var colNames=['Name', 'IP', 'FQDN', 'Description', 'Running Services','Action'];

        // config-array mit Spaltenmodel (sieh ColModel API von jqGrid)
        var colModel = [
              {name:'name', index:'name', width:60, editable: false, sorttype:'text'},
              {name:'ip', index:'ip', width:45, editable: false, sorttype:'text'},
              {name:'fqdn', index:'fqdn', width:70, editable: false, sorttype:'text'},
              //{name:'environment', index:'environment', width:80, editable: true, sorttype:'text'},
              //{name:'operating_system', index:'operating_system', width:150, editable: true, sorttype:'text'},
              //{name:'operating_system_flavour', index:'operating_system_flavour', width:150, editable: true, sorttype:'text'},
              {name:'description', index:'description', width:120, editable: false, edittype: 'textarea', sorttype:'text'},
              {name:'running_services', index:'running_services', width:100, sortable:false},
              {name:'action', index:'action', width:48, editable: false, sortable:false}
              //{name:'sshuser', index:'sshuser', width:150, editable: true, sorttype:'text'}
        ];

        // config-object für array-Mapping
        var localReader = {
            root: "systems",
            page: "page",
            total: "total",
            records: "records",
            repeatitems: false,
            id: "id",
            userdata: "userdata"
        };

        // lädt die Daten für Tabelle (Auslagerung war wegen einer Umspeicherung der Systeme in Systems nötig)
        $j.ajax({
           url: '/systems/',
           complete: function(data,stat){
              if(stat=="success") {
                ResponseData = JSON.parse(data.responseText);
                var systems = ResponseData.systems;
                var services = ResponseData.userdata.services;
                var system_groups = ResponseData.userdata.system_groups;
                // refactor services array (array indexe werden durch die service.id ersetzt)
                for (sg in system_groups) {
                    if (system_groups[sg].id)
                        SystemGroups[system_groups[sg].id] = system_groups[sg];
                }
                // refactor services array (array indexe werden durch die service.id ersetzt)
                for (s in services) {
                    if (services[s].id)
                        Services[services[s].id] = services[s];
                }
                // refactor systems array (array indexe werden durch die system.id ersetzt)
                for (s in systems) {
                    if (systems[s].running_services)
                        Systems[systems[s].id] = systems[s];
                }

                loadGrid();
                $j("#gview_systems_table input").live("focusout",function(){
                    var id = $j(this).attr("id");
                    var iRow = id.split("_")[0];
                    var iCal = $j(this).attr("name");
                    $j("#systems_table").restoreCell(iRow, iCal);
                });
              }
           }
        });

        // jqGrid-Tabelle wird konfiguriert/initialisiert
        function loadGrid() {
            $j("#systems_table").jqGrid({
                datatype: 'clientSide',
                data: ResponseData.systems,
                localReader: localReader,
                colNames:colNames,
                colModel :colModel,
                //pager: '#pager',
                rowNum:100,
                rowList:[100,200,300],
                sortname: 'name',
                sortorder: 'asc',
                viewrecords: true,
//                caption: 'Systems',
                caption: false,
                height: "100%",
                //altRows: true,
                autowidth: true,
                gridComplete: gridComplete,
                multiselect: true,
                cellEdit: false
                //cellEdit: true
//                ,
//                beforeEditCell: function (rowId, cellname){
//                    console.log('before edit');
//                    actEditIds[rowId] = true;
//                }
//                ,
//                beforeSubmitCell: function (rowId, cellname, value) {
//                    paramsString = encodeURI("system["+cellname+"]="+value);
//                    params = {
//                        _method: "put"
//                    };
//                    $j("#systems_table").jqGrid('setGridParam', {cellurl: "systems/"+rowId});
//                }
//                ,
//                afterSaveCell: function (rowId, cellname) {
//                    console.log('after save');
//                    actEditIds[rowId] = false;
//                    if (loadEditSystemId) loadSystem(loadEditSystemId, true);
//                },
//                afterRestoreCell: function (rowId, val, iRow, iCol) {
//                    console.log('after restore');
//                    actEditIds[rowId] = false;
//                }
            });
        }



        // Formular fürs Anlegen eines neuen Systems w. konfiguriert
        // TO DO: Fehlermeldungen des Servers abfangen
        $j("#addSystemButton").click(function(){
            loadSystem('new', null, false);
       });

        // Löschein eines Systems
        // TO DO: Fehlermeldungen des Servers abfangen
        $j("#delSystemButton").click(function(){
            deleteSelectedRow();
        });

        // Klonen eines Systems
        // TO DO: Fehlermeldungen des Servers abfangen
        $j("#cloneSystemButton").click(function(){
            var id = $j("#systems_table").jqGrid('getGridParam','selrow');
            if( id == null ) {
                notify('info', 'Please select a system first!');
                return;
            }
            loadSystem('clone', id, false);
        });

        function deleteSelectedRow(){
            var id = $j("#systems_table").jqGrid('getGridParam','selrow');
            if( id != null ) {
                params = {
                    _method: "delete"
                };
                var msg = "Are you really sure to delete the following system? <br/><br/>";
                msg += "<b>Name: </b>" +Systems[id].name+ "<br/>";
                msg += "<b>IP: </b>" +Systems[id].ip+ "<br/>";
                msg += "<b>FQDN: </b>" +Systems[id].fqdn+ "<br/>";
                // Konfigurieren vom Löschen
                options = {
                    top: 200,
                    left: 200,
                    width: 300, // the width of edit dialog - default 300
                    height: 200, // the height of edit dialog default 200
                    modal: true, // determine if the dialog should be in modal mode default is false
                    drag: true, // determine if the dialog is dragable default true
                    caption: "Delete system",
                    bSubmit: "Delete",  // the text of the button when you click to data default Submit
                    bCancel: "Cancel", // the text of the button when you click to close dialog default Cancel
                    url: "systems/"+id,  // url where to post data. If set replace the editurl
                    reloadAfterSubmit : false,
                    closeOnEscape: true,
                    // Events
                    beforeShowForm: function() {
                        $j(".delmsg").html(msg);
                    },
                    afterComplete: function(response, postdata, id) {
                        if (response.responseText == "false") {
                            options = null;
                            return false;
                        }
                        else {
                            return true;
                        }
                    }
                };
                $j("#systems_table").jqGrid('delGridRow', id, options);
            }
            else
                notify('info', '<strong>INFO</strong> Please select a system first!');
        }

        // baut Running Services multiselect auf
        function getRunningServicesEditWidget(dialogContainer, id) {
            // zugrundeliegendes select-Inputfeld wird erstellt
            var options = '<select class="multiselect services" multiple="multiple" name="services[]"  style="width:470px;height:200px;">';

            if (Systems[id]) {
                for (idx in Systems[id].running_services) {
                    rs = Systems[id].running_services[idx];
                    if (rs.id && rs.service_id)
                        options += '<option value="'+rs.id+'" selected="selected" role="running_service" title="'+rs.comment+'">'+Services[rs.service_id].name+'</option>';
                }
            }

            for (idx in Services) {
                s = Services[idx];
                if (s.name && s.id)
                    options += '<option value="'+s.id+'" role="service">'+s.name+'</option>';
            }
            options += '</select>';
            dialogContainer.append(options);
            dialogContainer.children("select.services").multiselect();
        }

         // baut group multiselect auf
        function getSystemGroupMapsEditWidget(dialogContainer, id) {
            // zugrundeliegendes select-Inputfeld wird erstellt
            var options = '<select class="multiselect system_group_maps" multiple="multiple" name="system_group_maps[]"  style="width:470px;height:200px;">';
            var checkedSystemGroups = {};
            if (Systems[id]) {
                for (idx in Systems[id].system_group_maps) {
                    sgm = Systems[id].system_group_maps[idx];
                    if (sgm.system_id) {
                        options += '<option value="'+sgm.id+'" selected="selected" role="system_group_map">'+SystemGroups[sgm.system_group_id].name+'</option>';
                        checkedSystemGroups[sgm.system_group_id] = true;
                    }
                }
            }
            for (idx in SystemGroups) {
                sg = SystemGroups[idx];
                if (sg.name && typeof(checkedSystemGroups[idx]) == "undefined")
                    options += '<option value="'+sg.id+'" role="system_group">'+sg.name+'</option>';
            }
            options += '</select>';
            dialogContainer.append(options);
            dialogContainer.children("select.system_group_maps").multiselect();
        }

        // Aufruf wenn die Tabelle fertig ist
        function gridComplete() {
            $j("#systems_table").jqGrid('setGridParam',{datatype:'local'});
            $j("#lui_systems_table")
                .appendTo($j("body"))
                .hide(); // div #lui_systems_table (ajax overlay from grid) expand to whole body

            // Running Services-Zellen wird aufgebaut
            for (id in Systems){
                showRunningServicesCell (id);
                showActionCell (id);
            }
        }

        // Running Services-Zellen wird aufgebaut
        // TO DO: was anderes überlegen... ist häßlich...
        function showRunningServicesCell (id) {
            var system = Systems[id];
            var running_services_array = new Array();

            for (idx in system.running_services) {
                var rs = system.running_services[idx];
                if (rs.service_id && Services[rs.service_id]) {
                    var show_service_link = '<a href="'+'/services/'+rs.service_id+'">';
                        show_service_link += Services[rs.service_id].name;
                        show_service_link += '</a>';
                    running_services_array.push(show_service_link);
                }
            }
            //var rs_cell_string = running_services_array.join('<br/>');
            var rs_cell_string = running_services_array.join(', ');
            $j('#systems_table > tbody > tr[id="'+id+'"] > td[aria-describedby="systems_table_running_services"]').html(rs_cell_string).attr('title', '');
        }

        // Actions-Zelle wird aufgebaut
        function showActionCell (id) {
//            var edit_system_link = $j('<span class="ui-icon ui-icon-gear" title="Edit"></span>')
            var edit_system_link = $j('<img src="/images/noun_icons/'+iconColor+'/24x24/edit.png" />')
                .attr("title", "Edit")
                .css({display:'inline-block', cursor: 'pointer', margin: "2px"})
                .click(function(){
                    loadSystem("edit", id, true);
                });
//            var show_system_link = $j('<span class="ui-icon ui-icon-newwin" title="Show"></span>')
            var show_system_link = $j('<img src="/images/noun_icons/'+iconColor+'/24x24/eye.png" />')
                .attr("title", "Show")
                .css({display:'inline-block', cursor: 'pointer', margin: "2px"})
                .click(function(){
                    var url = "/systems/"+id;
                    $j(location).attr('href',url);
                });
            var generate_dashboard_link = $j('<img src="/images/noun_icons/'+iconColor+'/24x24/linechart.png" />')
                .attr("title", "Generate dashboard")
                .css({display:'inline-block', cursor: 'pointer', margin: "2px"})
                .click(function(){
                    var url = "/systems/generate_dashboard/";
                    $j.ajax({
                       url: url,
                       type: "POST",
                       data: {
                            id: id
                       },
                       complete: function(data, stat){
                          if(stat=="success") {
                             var dashboard =  JSON.parse(data.responseText).dashboard;
                             $j(location).attr('href',"/dashboards/"+dashboard.id);
                          }
                       }
                    });
                });
            // you can customize the order of show, edit & graph icon here
            $j('#systems_table > tbody > tr[id="'+id+'"] > td[aria-describedby="systems_table_action"]')
                .empty()
                .append(show_system_link)
                .append(edit_system_link)
                .append(generate_dashboard_link);
        }

        function loadSystem(oper, id, extended){
//            switch (oper) {
//                case "new":
//                case "clone":
//                    params = {commit: 'create'};
//                    break;
//                case "edit":
//                    params = {_method: 'put'};
//                    break;
//                default:
//                    return;
//            }

//            params = (oper == 'new') ? {commit: 'create'} : {_method: 'put'};
//            if (oper == 'clone') {
//                    params = {commit: 'create'};
//            }

            var dialogContainerId = "show_system_"+oper+(id)?("_"+id):"";

            if (dialogContainers[dialogContainerId]) {
                dialogContainers[dialogContainerId].dialog('moveToTop');
                return;
            }

            var dialogContainer = $j("<div id='"+dialogContainerId+"'></div>").appendTo('body');
            dialogContainers[dialogContainerId] = dialogContainer;
            dialogContainersSize++;

            // display ajax loading icon
            dialogContainer.html('<img src="/images/ajax-loader.gif"/>');
            dialogContainer.dialog({
                position: [(50 + dialogContainersSize*20), (50 + dialogContainersSize*20)],
                width: 525,
                height: ((extended) ? 650 : 490),
                autoOpen: false,
                //modal:true,
                resizable: false,
                close: function(event, ui){
                    $j(this).dialog('destroy').html('').hide();
                    dialogContainers[dialogContainerId] = null;
                    dialogContainersSize--;
                    if (dialogContainersSize == 0)
                        $j("#systems_table").jqGrid('setGridParam', {cellEdit: true});
                },
                buttons: {
                    "Save": function() {
                        switch (oper) {
                            case "new":
                            case "clone":
                                params = {commit: 'create'};
                                break;
                            case "edit":
                                params = {_method: 'put'};
                                break;
                            default:
                                return;
                        }
                        var dialog = $j(this);
                        paramsString = dialog.children('form').serialize();

                        var create_running_services = dialog.children("select.services").children('option[role="service"]').map(function(){
                            if  (this.selected)
                                return $j(this).val();
                        }).get();

                        if (oper=='clone' && $j('#include_rs').attr('checked')) {
                            create_running_services = getRunningServicesToClone(id);
                        }

                        var destroy_running_services = dialog.children("select.services").children('option[role="running_service"]').map(function(){
                            if  (!this.selected)
                                return $j(this).val();
                        }).get();

                        var add_system_group_maps = dialog.children("select.system_group_maps").children('option[role="system_group"]').map(function(){
                            if  (this.selected)
                                return $j(this).val();
                        }).get();

                        if (oper == 'clone' && $j('#include_sg').attr('checked')) {
                            add_system_group_maps = getSystemGroupMapsToClone(id);
                        }

                        var destroy_system_group_maps = dialog.children("select.system_group_maps").children('option[role="system_group_map"]').map(function(){
                            if  (!this.selected)
                                return $j(this).val();
                        }).get();
                        
                        var clone_metric_plugins = false;                    
                        if (oper == 'clone' && $j('#include_rcp').attr('checked')) {
                            clone_metric_plugins = id;
                        };

                        $j.ajax({
                           url: ((oper == 'new' || oper == 'clone') ? '/systems/' : '/systems/'+id),
                           type: "POST",
                           data: {
                                create_running_services: create_running_services,
                                destroy_running_services: destroy_running_services,
                                add_system_group_maps: add_system_group_maps,
                                destroy_system_group_maps: destroy_system_group_maps,
                                clone_metric_plugins: clone_metric_plugins
                           },
                           complete: function(data, stat){
                              if(stat=="success") {
                                 system =  JSON.parse(data.responseText).system;
                                 new_id = system.id;
                                 Systems[new_id] = system;
                                 position = (oper != 'edit') ? 'first' : '';
                                 cmd = (oper != 'edit') ? 'addRowData' : 'setRowData';
                                 $j('#systems_table').jqGrid(cmd, new_id, system, position);
                                 showRunningServicesCell(new_id);
                                 dialog.dialog("close");
                              }
                           }
                        });
                    },
                    "Cancel": function() {$j(this).dialog("close");}
                }
            });
            dialogContainer.dialog('open');
            $j("#systems_table").jqGrid('setGridParam', {cellEdit: false});

            if (oper == 'new')
                editSystem(dialogContainer, oper, id, extended);
            else if (id) {
                $j.ajax({
                   url: '/systems/'+id,
                   complete: function(data,stat){
                      if(stat=="success") {
                         Systems[id] =  JSON.parse(data.responseText).system;
                         editSystem(dialogContainer, oper, id, extended);
                      }
                   }
                });
            }
        }

        function editSystem(dialogContainer, oper, id, extended){
            if (oper=='new') {
                var system = {id:'new', name:'', ip:'', fqdn:'', operating_system:'', operating_system_flavour:'', environment:'', description:'', sshuser:'' };
                var title = 'Add system';
            } else if (oper=='clone') {
                system = Systems[id];
                system.id = "clone";
                title = 'Clone system ' + system.name;
            }
            else {
                system = Systems[id];
                title = 'Edit system ' + system.name;
            }
            dialogContainer.dialog('option', 'title', title);

            var msg  = '<form class="ui-helper-clearfix">';
                //msg += getInputField(system.id, 'id', system.id, true);
                    msg += "<b>Name: </b>" +getInputField(system.id, 'name', system.name)+ "<br/><br/>";
                    msg += "<b>FQDN: </b>" +getInputField(system.id, 'fqdn', system.fqdn)+ "<br/><br/>";
                    msg += "<b>IP: </b>" +getInputField(system.id, 'ip', system.ip)+ "<br/><br/>";
                    msg += "<b>Operating system: </b>" +getInputField(system.id, 'operating_system', system.operating_system)+ "<br/><br/>";
                    msg += "<b>Operating system flavour: </b>" +getInputField(system.id, 'operating_system_flavour', system.operating_system_flavour)+ "<br/><br/>";
                    msg += "<b>Environment: </b>" +getInputField(system.id, 'environment', system.environment)+ "<br/><br/>";
                    msg += "<b>Description: </b>" +getInputField(system.id, 'description', system.description)+ "<br/><br/>";
                    msg += "<b>SSH user: </b>" +getInputField(system.id, 'sshuser', system.sshuser)+ "<br/><br/>";
//                    munin_group is used for MuninImageWidget
                    msg += "<b>Munin Group: </b>" +getInputField(system.id, 'munin_group', system.munin_group)+ "<br/><br/>";
                msg += "</form>";
            dialogContainer.html(msg);

            if (oper=='clone') {
                msg = "";
                msg += '<div class="ui-helper-clearfix">';
                msg += '<span style="float:left;margin-left:10px;">Include running services: </span>';
                msg += '<input id="include_rs" type="checkbox" style="float:left;margin-left:10px;" checked="checked" />';
                msg += '<span style="float:left;margin-left:10px;">Include system groups: </span>';
                msg += '<input id="include_sg" type="checkbox" style="float:left;margin-left:10px;" checked="checked" />';
                msg += '<span style="float:left;margin-left:10px;">Include metric plugins: </span>';
                msg += '<input id="include_rcp" type="checkbox" style="float:left;margin-left:10px;" checked="checked" />';
                msg += '</div>';
                dialogContainer.append(msg);
            }

            if (extended) {
                msg = "<br></br>";
                msg += "<b>Running services:</b>";
                dialogContainer.append(msg);
                getRunningServicesEditWidget(dialogContainer, system.id);
                msg = "<br></br>";
                msg += "<b>System groups:</b>";
                dialogContainer.append(msg);
                getSystemGroupMapsEditWidget(dialogContainer, system.id);
            }
        }

        function getInputField(id, name, value, isHidden){
            return '<input id="'+id+'_'+name+'" name="system['+name+']" value="'+ (value ? value : "")+'" ' + (isHidden ? 'type="hidden"':'type="text"') + ' style="float:right;margin-right:10px;" />';
        }

        function getRunningServicesToClone(id) {
            var system = Systems[id];
            var result = [];
            for (var i=0; i<system.running_services.length; i++) {
                result.push(system.running_services[i].service_id);
            }
            return result;
        }

        function getSystemGroupMapsToClone(id) {
            var system = Systems[id];
            var result = [];
            for (var i=0; i<system.system_group_maps.length; i++) {
                result.push(system.system_group_maps[i].id);
            }
            return result;
        }

}); 