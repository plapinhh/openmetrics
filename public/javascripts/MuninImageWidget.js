var MuninImageWidget = MuninImageWidget || {};
$j.extend(MuninImageWidget, {
    openWidgetForm : function (id) {
        var widget = Widgets[id];
        // dialog div-container is being intialized and appended to content;
        var dialogContainer = $j('<div class="ui-helper-clearfix"></div>').attr('id', 'addWidgetDialog');
        dialogContainer.html('<img id="muninImageWidgetForm_ajax-loader" src="/images/ajax-loader.gif"/>');
        $j('#content').append(dialogContainer);

        // transforming dialog div-container to the jquery-ui dialog
        var dialog = dialogContainer.dialog({
            width: 500,
            height: 600,
            autoOpen: false,
            modal:true,
            resizable: false,
            zIndex: 50000,
            close: function(event, ui){
                $j(this).dialog('destroy').html('').hide().remove();
                $j('#addWidgetButton').button('enable').trigger('enable');
            }
        });
        dialogContainer.dialog('open');
        if (!widget || !widget.id) {
            dialogContainer.dialog({
                title: "Create new MuninImageWidget(s)"
            });
            // fires ajax request to load systems for the systems selection input
            $j.ajax({
                url: '/systems/list_only',
                type: "POST",
                complete: function(data, textStatus){
                    if(textStatus=="success") {
                        //                          notify('notice', textStatus + ' list_only');
                        var systems = JSON.parse(data.responseText).systems;
                        //                      var Systems = [];
                        var Systems = {};
                        for (var i= 0; i < systems.length; i++) {
                            if (systems[i].munin_group)
                                //                                Systems.push(systems[i]);
                                Systems[systems[i].id] = systems[i];
                        }
                        // callback for systems loading; create systems selection input
                        createSystemSelectionInput(dialog, dialogContainer, Systems, widget);
                    }
                },
                error: function(data, textStatus) {
                    notify('error', textStatus + data  );
                    dialog.dialog({
                        buttons: null
                    });
                }
            });
            
            // fires ajax request to load system groups for the system groups selection input
            $j.ajax({
                url: '/system_groups/list_only',
                type: "POST",
                complete: function(data, textStatus){
                    if(textStatus=="success") {
                        //                          notify('notice', textStatus + ' list_only');
                        var system_groups = JSON.parse(data.responseText).system_groups;
                        var SystemGroups = {};
                        for (var i= 0; i < system_groups.length; i++) {
                            if (system_groups[i].id && system_groups[i].system_group_maps.length > 0)
                                SystemGroups[system_groups[i].id] = system_groups[i];
                        //                                    SystemGroups.push(system_groups[i]);
                        }
                        // callback for system groups loading; create system groups selection input
                        createSystemGroupSelectionInput(dialog, dialogContainer, SystemGroups, widget);
                    }
                },
                error: function(data, textStatus) {
                    notify('error', textStatus + data  );
                    dialog.dialog({
                        buttons: null
                    });
                }
            });
        }
        else {
            dialogContainer.dialog({
                title: "Edit MuninImageWidget"
            });
            var result = '<p id="system_selection_container"><b>Selected a system: </b>';
            result += widget.preferences.system_name;
            dialogContainer.prepend(result);
            $j.ajax({
                url: '/telnet/get_munin_services',
                data: {
                    id: widget.preferences.system_id
                    },
                type: "GET",
                complete: function(data, textStatus){
                    if(textStatus=="success") {
                        $j('#muninImageWidgetForm_ajax-loader').hide();
                        //                          notify('notice', textStatus + ' list_only');
                        var MuninServices = JSON.parse(data.responseText).MuninServices;
                        //console.log(_Systems);
                        // callback for munin services; create second select input for munin services;
                        createMuninServiceSelectionInput(dialog, dialogContainer, MuninServices, {}, widget);
                    }
                },
                error: function(data, textStatus) {
                    notify('error', textStatus + data  );
                    dialogContainer.children("#dateRange_selection_container").remove();
                    dialog.dialog({
                        buttons: null
                    });
                }
            });
        }
    },
    getWidgetContent: function (id) {
        var widget = Widgets[id];
        var muninUrl = 'http://munin.example.com/munin/';
        var prefs = widget.preferences;
        var system_name = prefs['system_name'];
        var munin_group = prefs['munin_group'];
        var munin_service = prefs['munin_service'];
        var dateRange = prefs['dateRange'];
        var imgUrl = muninUrl+munin_group+'/'+system_name+'-'+munin_service+'-'+dateRange+'.png';
        var result = '<img src="'+imgUrl+'" />';
        
        // like a resize event for collectd widget, it might be a possibility to resize munin image on widget resize...
        // trigger doesn't work!
        //            $j('#'+widget.id+" div.content-wrapper").live("resize", function(){
        //                console.log($j(this).children(':first-child'));
        //                console.log($j(this).children(':first-child').width());
        //                $j(this).children(':first-child').width($j(this).width());
        //                console.log($j(this).width());
        //                console.log($j(this).children(':first-child').width());
        //                $j(this).children(':first-child').height($j(this).height());
        //            }).resize();
        //            return result;
        $j('#'+widget.id+" div.content-wrapper").fadeOut(100, function () {$j(this).html(result).fadeIn()});
    }
});

// create system's selection input in dialog; load munin services for selected system;
function createSystemSelectionInput(dialog, dialogContainer, Systems, widget) {
    var result = '<p id="system_selection_container"><b>Select a system:</b>';
    result += '<select class="multiselect systems" multiple="multiple" name="services[]"  style="width:470px;height:200px;" id="system_selection" style="float: right; margin-right: 10px;">';
    for (id in Systems) {
        if (Systems[id] && Systems[id].name) {
            result += '<option value="'+id+'">'+Systems[id].name+'</option>';
        }
    }
    result += '</select></p>';
    if (widget)
        $j('#muninImageWidgetForm_ajax-loader').hide();
    dialogContainer.prepend(result);
    // if dialog is a edit widget dialog, system selection is being trigged to select the saved system;
    if (widget && widget.preferences && widget.preferences.system_id) {
        $j("#system_selection").val(widget.preferences.system_id);
    }
    $j("#system_selection").multiselect();

    // rises on system's selection change and load munin services for selected system;
    // by void selection destructs buttons, data range selection input and munin services selection input
    $j("#system_selection").change(function () {
        systemSelectionChangeEvent(this, dialog, dialogContainer, Systems, widget);
    });
    // selection change event is being fired;
    if (widget) {
        $j("#system_selection").trigger("change");
    }
}

function systemSelectionChangeEvent (ui, dialog, dialogContainer, Systems, widget) {
    dialogContainer.children("#service_selection_container").remove();
    var checked_systems = $j(ui).children('option').map(function(){
        if  (this.selected)
            return $j(ui).val();
    }).get();
    if (checked_systems.length > 0) {
        dialogContainer.children("#dateRange_selection_container").remove();
        $j("#system_group_selection").val('');
        var _Systems = {};
        for (var j=0; j < checked_systems.length; j++) {
            var id = checked_systems[j];
            _Systems[id] = Systems[id];
        }
        $j.ajax({
            url: '/telnet/get_munin_services',
            data: {
                id: checked_systems[0]
                },
            type: "GET",
            complete: function(data, textStatus){
                if(textStatus=="success") {
                    //                      notify('notice', textStatus + ' list_only');
                    var MuninServices = JSON.parse(data.responseText).MuninServices;
                    //console.log(_Systems);
                    // callback for munin services; create second select input for munin services;
                    createMuninServiceSelectionInput(dialog, dialogContainer, MuninServices, _Systems, widget);
                }
            },
            error: function(data, textStatus) {
                notify('error', textStatus + data  );
                dialogContainer.children("#dateRange_selection_container").remove();
                dialog.dialog({
                    buttons: null
                });
            }
        });
    }
    else {
        dialogContainer.children("#dateRange_selection_container").remove();
        dialog.dialog({
            buttons: null
        });
    }
}

// create system's selection input in dialog; load munin services for selected system;
function createSystemGroupSelectionInput(dialog, dialogContainer, SystemGroups, widget) {
    if ($j('#system_selection'))
        $j('#muninImageWidgetForm_ajax-loader').hide();
    var result = '<p id="system_group_selection_container"><b>OR<br/>Select a system group:</b>';
    result += '<select id="system_group_selection" style="float: right; margin-right: 10px;">';
    result += '<option value=""></option>';
    //        for (var i= 0; i < SystemGroups.length; i++) {
    var firstSystemGroupId = null;
    for (id in SystemGroups) {
        if (SystemGroups[id] && SystemGroups[id].id && SystemGroups[id].name) {
            if (firstSystemGroupId == null)
                firstSystemGroupId = SystemGroups[id].id;
            result += '<option value="'+SystemGroups[id].id+'">'+SystemGroups[id].name+'</option>';
        }
    }
    result += '</select></p>';
    dialogContainer.append(result);

    // rises on system's selection change and load munin services for selected system;
    // by void selection destructs buttons, data range selection input and munin services selection input
    $j("#system_group_selection").change(function (){
        dialogContainer.children("#service_selection_container").remove();
        if ($j(this).val() != '') {
            var SystemGroup = SystemGroups[$j(this).val()];
            dialogContainer.children("#dateRange_selection_container").remove();
            $j("#system_selection").unbind("change");
            $j("#system_selection").val('');
            $j('#system_selection_container a.remove-all').trigger('click');
            $j("#system_selection").multiselect('destroy');
            var Systems = {};
            for (var j=0; j < SystemGroup.system_group_maps.length; j++) {
                if (SystemGroup.system_group_maps[j].system.munin_group) {
                    var id = SystemGroup.system_group_maps[j].system.id.toString();
                    Systems[id] = SystemGroup.system_group_maps[j].system;
                    $j("#system_selection").children("option[value="+id+"]").attr('selected', 'selected');
                }
            }
            $j("#system_selection").multiselect();
            $j("#system_selection").change(function () {
                systemSelectionChangeEvent(this, dialog, dialogContainer, Systems, widget);
            });
            $j.ajax({
                url: '/telnet/get_munin_services',
                data: {
                    id: SystemGroups[firstSystemGroupId].system_group_maps[0].system.id
                    },
                type: "GET",
                complete: function(data, textStatus){
                    if(textStatus=="success") {
                        //                          notify('notice', textStatus + ' list_only');
                        var MuninServices = JSON.parse(data.responseText).MuninServices;
                        // callback for munin services; create second select input for munin services;
                        createMuninServiceSelectionInput(dialog, dialogContainer, MuninServices, Systems, widget);
                    }
                },
                error: function(data, textStatus) {
                    notify('error', textStatus + data  );
                    dialogContainer.children("#dateRange_selection_container").remove();
                    dialog.dialog({
                        buttons: null
                    });
                }
            });
        }
        else {
            dialogContainer.children("#dateRange_selection_container").remove();
            dialog.dialog({
                buttons: null
            });
        }
    });
}

// create second select input for munin services;
function createMuninServiceSelectionInput(dialog, dialogContainer, MuninServices, Systems, widget) {
    var result = '<p id ="service_selection_container">';
    result += '<br/><br/><b>Select a munin service:</b>';
    result += '<select id="service_selection" style="float: right; margin-right: 10px;">';
    result += '<option value=""></option>';
    for (var i=0; i<MuninServices.length; i++) {
        result += '<option value="'+MuninServices[i]+'">'+MuninServices[i]+'</option>';
    }
    result += '</select></p>';
    dialogContainer.append(result);
        
    // rises on munin service' selection change and create data range selection input;
    // by void selection destructs buttons and data range selection input
    $j("#service_selection").change(function (){
        dialogContainer.children("#dateRange_selection_container").remove();
        if ($j(this).val() != '') {
            createDateRangeSelectionInput(dialog, dialogContainer, null, Systems, widget);
        }
        else {
            dialog.dialog({
                buttons: null
            });
        }
    });
    // if dialog is a edit widget dialog, service selection is being trigged to select the saved system;
    // selection change event is being fired;
    if (widget.preferences && widget.preferences.munin_service) {
        $j("#service_selection").val(widget.preferences.munin_service);
        $j("#service_selection").trigger("change");
    }
}

// create data range selection input;
function createDateRangeSelectionInput(dialog, dialogContainer, DateRange, Systems, widget) {
    var result = '<p id ="dateRange_selection_container">';
    result += '<br/><br/><b>Select a data date range:</b>';
    result += '<select id="dateRange_selection" style="float: right; margin-right: 10px;">';
    result += '<option value=""></option>';
    result += '<option value="day">day</option>';
    result += '<option value="week">week</option>';
    result += '<option value="month">month</option>';
    result += '<option value="year">year</option>';
    result += '</select></p>';
    dialogContainer.append(result);

    // buttons object described dialog buttons and press actions for its; the object is to append as option to the dialog;
    var buttons = new Object();
    if (widget && widget.id) {
        buttons['Save'] = function(){
            var formValuesObject = new Object();
            formValuesObject['system_id'] = widget.preferences.system_id;
            formValuesObject['munin_group'] = widget.preferences.munin_group;
            formValuesObject['system_name'] = widget.preferences.system_name;
            formValuesObject['munin_service'] = $j('#service_selection').val();
            formValuesObject['dateRange'] = $j('#dateRange_selection').val();
            var id = widget.id;
            var postdata = {
                preferences: JSON.stringify(formValuesObject)
                };
            saveWidget(id, 'munin_image_widgets', postdata, dialogContainer)
            dialogContainer.dialog('disable');
        };
    }
    else {
        buttons['Create'] = function() {
            dialogContainer.dialog('disable');
            var formValuesObject = new Object();
            formValuesObject['munin_service'] = $j('#service_selection').val();
            formValuesObject['dateRange'] = $j('#dateRange_selection').val();
            if (!Systems)
                return dialogContainer.dialog('close');
            //            for (var j=0; j < Systems.length; j++) {
            var top = 0;
            var left = 0;
            var sizex = 300;
            var sizey = 400;
            for (id in Systems) {
                if (Systems[id] && Systems[id].id && Systems[id].name && Systems[id].munin_group) {
                    var system = Systems[id];
                    top += 40;
                    left += 40;
                    formValuesObject['system_id'] = system.id;
                    formValuesObject['munin_group'] = system.munin_group;
                    formValuesObject['system_name'] = system.name;
                    createWidget(null, "munin_image_widgets", formValuesObject, top, left, sizex, sizey);
                }
            }
            dialogContainer.dialog('close');
        };
    }
    buttons['Cancel'] = function() {
        dialogContainer.dialog('close');
    }
        
    // rises on data range's selection change and puts buttons object to the dialog;
    // by void selection destructs buttons in the dialog
    $j("#dateRange_selection").change(function (){
        if ($j(this).val() != '') {
            dialog.dialog({
                buttons: buttons
            });
        }
        else {
            dialog.dialog({
                buttons: null
            });
        }
    });
    // if dialog is a edit widget dialog, data range selection is being trigged to select the saved system;
    // selection change event is being fired;
    if (widget.preferences && widget.preferences.dateRange) {
        $j("#dateRange_selection").val(widget.preferences.dateRange);
        $j("#dateRange_selection").trigger("change");
    }
}