var Services = new Object();
var Systems = new Object();
var ResponseData;
var dialogContainers = new Object();
var dialogContainersSize = 0;

$j(document).ready(function($) {
      
        // config-array mit Spaltennamen
         var colNames=['Name','Type', 'Description', 'Related Systems', 'Action'];
        //var colNames=['Name','DNS Name','Type','Group', 'Description', 'Related Systems', 'Action'];
        
        // config-array mit Spaltenmodel (sieh ColModel API von jqGrid)
        var colModel = [
              {name:'name', index:'name', width:55, editable: false, sorttype:'text'},
//              {name:'dns_name', index:'dns_name', width:80, editable: false, sorttype:'text'},
              {name:'type', index:'type', width:40, editable: false, sorttype:'text'},
//              {name:'group', index:'group', width:60, editable: false, sorttype:'text'},
              {name:'description', index:'description', width:120, editable: false, edittype: 'textarea', sorttype:'text'},
              {name:'systems_running_service', index:'systems_running_service', width:120, editable: false, sortable:false},
              {name:'action', index:'action', width:38, editable: false, sortable:false}
        ];

        // config-object für array-Mapping
        var localReader = {
            root: "services",
            page: "page",
            total: "total",
            records: "records",
            repeatitems: false,
            id: "id",
            userdata: "userdata"
        };

        // lädt die Daten für Tabelle (Auslagerung war wegen einer Umspeicherung der Systeme in Systems nötig)
        $j.ajax({
           url: '/services/',
           complete: function(data,stat){
              if(stat=="success") {
                ResponseData = JSON.parse(data.responseText);
                var services = ResponseData.services;
                var systems = ResponseData.userdata.systems;
//                console.log(services);
//                console.log(systems);
                // refactor services array (array indexe werden durch die service.id ersetzt)
                for (s in systems) {
                    if (systems[s].id)
                        Systems[systems[s].id] = systems[s];
                }
                // refactor systems array (array indexe werden durch die system.id ersetzt)
                for (s in services) {
                    Services[services[s].id] = services[s];
                }
//                console.log(Services);
//                console.log(Systems);
                loadGrid();
              }
           }
        });

        // jqGrid-Tabelle wird konfiguriert/initialisiert
        function loadGrid() {
            $j("#services_table").jqGrid({
                datatype: 'clientSide',
                data: ResponseData.services,
                localReader: localReader,
                colNames:colNames,
                colModel :colModel,
                //pager: '#pager',
                rowNum:100,
                rowList:[100,200,300],
                sortname: 'name',
                sortorder: 'asc',
                viewrecords: true,
//                caption: 'Services',
                caption: false,
                height: "100%",
                width: "70%",
                //altRows: true,
                autowidth: true,
                gridComplete: gridComplete,
                cellEdit: false
                //cellEdit: true
                //beforeSubmitCell: function (rowId, cellname, value) {
                //    paramsString = encodeURI("service["+cellname+"]="+value);
                //    params = {
                //        _method: "put"
                //    };
                //    $j("#services_table").jqGrid('setGridParam', {cellurl: "services/"+rowId});
                //}
            });
        }



        // Formular fürs Anlegen eines neuen Systems w. konfiguriert
        // TO DO: Fehlermeldungen des Servers abfangen
        $j("#addServiceButton").click(function(){
            loadService('new', false);
       });

        // Löschein eines Systems
        // TO DO: Fehlermeldungen des Servers abfangen
        $j("#delServiceButton").click(function(){
            deleteSelectedRow();
        });

        function deleteSelectedRow(){
            var id = $j("#services_table").jqGrid('getGridParam','selrow');
            if( id != null ) {
                params = {
                    _method: "delete"
                };
                var service = Services[id];
                var msg = "Are you really sure to delete the following service? <br/><br/>";
                msg += "<b>Name: </b>" +service.name+ "<br/>";
                msg += "<b>DNS Name: </b>" +service.dns_name+ "<br/>";
                msg += "<b>Type: </b>" +service.type+ "<br/>";
                msg += "<b>Group: </b>" +service.group+ "<br/>";
                msg += "<b>Description: </b>" +service.description+ "<br/>";
                // Konfigurieren vom Löschen
                options = {
                    top: 200,
                    left: 200,
                    width: 300, // the width of edit dialog - default 300
                    height: 200, // the height of edit dialog default 200
                    modal: true, // determine if the dialog should be in modal mode default is false
                    drag: true, // determine if the dialog is dragable default true
                    caption: "Delete service",
                    bSubmit: "Delete",  // the text of the button when you click to data default Submit
                    bCancel: "Cancel", // the text of the button when you click to close dialog default Cancel
                    url: "services/"+id,  // url where to post data. If set replace the editurl
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
                $j("#services_table").jqGrid('delGridRow', id, options);
            }
            else
                notify('notice', undefined, 'Please select a service first!');       
        }

        // baut Running Services-Wigdet auf
        function getSystemsRunningServiceEditWidget(dialogContainer, id) {
            // zugrundeliegendes select-Inputfeld wird erstellt
            var options = '<select class="multiselect" multiple="multiple" name="systems[]"  style="width:480px;height:300px;">';
//            console.log(Services);
            if (Services[id]) {
//                console.log(Services[id]);
//                console.log(Services[id].systems_running_service);
                for (rs in Services[id].systems_running_service) {
                    srs = Services[id].systems_running_service[rs];
//                    console.log(rs);
                    if (srs.id)
                        options += '<option value="'+rs+'" selected="selected" role="system_running_service" title="Running service comment: '+srs.comment+'">'+srs.name+'</option>';
                }
            }    
            for (idx in Systems) {
                s = Systems[idx];
                if (s.name && s.id)
                    options += '<option value="'+s.id+'" role="system">'+s.name+'</option>';
            }
            options += '</select>';
            dialogContainer.append(options);
            dialogContainer.children("select").multiselect();
        }

        // Aufruf wenn die Tabelle fertig ist
        function gridComplete() {
            $j("#services_table").jqGrid('setGridParam',{datatype:'local'});
            $j("#lui_services_table").appendTo($j("body")).hide(); // div #lui_systems_table (ajax overlay from grid) expand to whole body
            // Running Services-Zellen wird aufgebaut
            for (id in Services){
                showSystemsRunningServiceCell (id);
                showActionCell (id);
            }
        }

        // Running Services-Zellen wird aufgebaut
        // TO DO: was anderes überlegen... ist häßlich...
        function showSystemsRunningServiceCell (id) {
            var service = Services[id];
            var systems_running_service_array = new Array();
//            console.log(Services);
            var rscount = 0;

            for (idx in service.systems_running_service) {
                var srs = service.systems_running_service[idx];
                if (srs.name && Systems[srs.id]) {
                    var show_system_link = '<a href="'+'/systems/'+srs.id+'">';
                        show_system_link += Systems[srs.id].name;
                        show_system_link += '</a>';
                    systems_running_service_array.push(show_system_link);
                    rscount++;
                }
            }
            //var srs_cell_string = systems_running_service_array.join('<br/>');
            var srs_cell_string = systems_running_service_array.join(', ');
            srs_cell_string = srs_cell_string + " (" + rscount + ") ";
            $j('#services_table > tbody > tr[id="'+id+'"] > td[aria-describedby="services_table_systems_running_service"]').html(srs_cell_string).attr('title', '');
        }

        // Actions-Zelle wird aufgebaut
        function showActionCell (id) {
            var edit_service_link = $j('<img src="/images/noun_icons/'+iconColor+'/24x24/edit.png" />').click(function(){
                loadService(id, false);
            }).attr('title', 'Edit').css({display:'inline-block', cursor: 'pointer', margin: "2px"});
            var show_service_link = $j('<img src="/images/noun_icons/'+iconColor+'/24x24/eye.png" />').click(function(){
                var url = "/services/"+id;
                $(location).attr('href',url);
            }).attr('title', 'Show').css({display:'inline-block', cursor: 'pointer', margin: "2px"});
            $j('#services_table > tbody > tr[id="'+id+'"] > td[aria-describedby="services_table_action"]').empty().append(edit_service_link).append(show_service_link);
        }

        function loadService(id, RSonly){
            params = (id == 'new') ? {commit: 'create'} : {_method: 'put'};
            var dialogContainerId = "show_service_"+id;

            if (dialogContainers[dialogContainerId]) {
                dialogContainers[dialogContainerId].dialog('moveToTop');
                return;
            }

            var dialogContainer = $j("<div id='"+dialogContainerId+"'></div>").appendTo('body');
            dialogContainers[dialogContainerId] = dialogContainer;
            dialogContainersSize++;

            dialogContainer.html('Loading...');
            dialogContainer.dialog({
                position: [(50 + dialogContainersSize*20), (50 + dialogContainersSize*20)],
                width:525,
                height: ((RSonly || id=='new') ? 350 : 650),
                autoOpen: false,
                //modal:true,
                resizable: false,
                close: function(event, ui){
                    $j(this).dialog('destroy').html('').hide();
                    dialogContainers[dialogContainerId] = null;
                    dialogContainersSize--;
                    if (dialogContainersSize == 0)
                        $j("#services_table").jqGrid('setGridParam', {cellEdit: true});
                },
                buttons: {
                    "Save": function() {
                        var dialog = $j(this);
                        if (id == 'new')
                            dialog.find('input#new_id').remove();
                        paramsString = dialog.children('form').serialize();
                        var create_running_services = dialog.children("select").children('option[role="system"]').map(function(){
                            if  (this.selected)
                                return $(this).val();
                        }).get();
//                        console.log(create_running_services);
                        var destroy_running_services = dialog.children("select").children('option[role="system_running_service"]').map(function(){
                            if  (!this.selected)
                                return $(this).val();
                        }).get();
//                        console.log(destroy_running_services);

                        if (dialog.find('select[name=type]').val() == 'CollectdService')
                            controller = '/collectd_services/'
                        else
                            controller = '/services/'


                        $j.ajax({
                           url: ((id == 'new') ? controller : controller+id),
                           type: "POST",
                           data: {
                                create_running_services: create_running_services,
                                destroy_running_services: destroy_running_services
                           },
                           complete: function(data, stat){
                              if(stat=="success") {
                                 service = JSON.parse(data.responseText).service;
                                 new_id = service.id;
                                 Services[new_id] = service;
                                 position = (id == 'new') ? 'first' : '';
                                 cmd = (id == 'new') ? 'addRowData' : 'setRowData';
                                 $j('#services_table').jqGrid(cmd, new_id, service, position);
                                 showSystemsRunningServiceCell(new_id);
                                 dialog.dialog("close");
                              }
                           }
                        });
                    },
                    "Cancel": function() {$j(this).dialog("close");}
                }
            });
            dialogContainer.dialog('open');
            $j("#services_table").jqGrid('setGridParam', {cellEdit: false});

            if (!RSonly && id != 'new') {
                $j.ajax({
                   url: '/services/'+id,
                   complete: function(data,stat){
                      if(stat=="success") {
                         Services[id] = JSON.parse(data.responseText).service;
                         editService(dialogContainer, id);
                      }
                   }
                });
            }
            else
                editService(dialogContainer, id, RSonly);
        }

        function editService(dialogContainer, id, RSonly){
            if (id!='new') {
                var service = Services[id];
                var title = 'Edit service ' + service.name;
            }
            else {
                service = {id:'new', name:'', dns_name:'', type:'', group:'', description:'' };
                var title = 'Add service';
            }
            dialogContainer.dialog('option', 'title', title);

            var msg  = '<form class="ui-helper-clearfix">';
                msg += getInputField(service.id, 'id', service.id, true);
                if (!RSonly) {
                    msg += "<b>Name: </b>" +getInputField(service.id, 'name', service.name)+ "<br/><br/>";
                    msg += "<b>DNS Name: </b>" +getInputField(service.id, 'dns_name', service.dns_name)+ "<br/><br/>";
//                    msg += "<b>Typ: </b>" +getInputField(service.id, 'typ', service.typ)+ "<br/><br/>";
                    msg += "<b>Group: </b>" +getInputField(service.id, 'group', service.group)+ "<br/><br/>";
                    msg += "<b>Description: </b>" +getInputField(service.id, 'description', service.description)+ "<br/><br/>";
                    msg += "<b>Type: </b><select name='type' style='width:205px;float:right;margin-right:10px;'><option value=''></option><option value='CollectdService'>collectd service</option></select>"
           }
                msg += "</form>";
                msg += "<br></br>";
                if (id!='new') {
                    msg += "<b>Systems running service:</b>";
                }
                
            dialogContainer.html(msg);
            if (id!='new') {
                getSystemsRunningServiceEditWidget(dialogContainer, service.id);
            }
        }

        function getInputField(id, name, value, isHidden){
            return '<input id="'+id+'_'+name+'" name="service['+name+']" value="'+ (value ? value : "")+'" ' + (isHidden ? 'type="hidden"':'type="text"') + ' style="width:200px;float:right;margin-right:10px;" />';
        }

});