var AlertWidget = LogtailWidget || {};
$j.extend(AlertWidget, {
    openWidgetForm : function (id) {
        var widget = Widgets[id];
        // dialog div-container is being intialized and appended to content;
        var dialogContainer = $j('<div class="ui-helper-clearfix"></div>').attr('id', 'addWidgetDialog');
        //dialogContainer.html('<img id="alertWidgetForm_ajax-loader" src="/images/ajax-loader.gif"/>');
        $j('#content').append(dialogContainer);

        // buttons object described dialog buttons and press actions for its; the object is to append as option to the dialog;
        var buttons = new Object();
        if (widget.id) {
            buttons['Save'] = function(){
                var formValuesObject = new Object();
                formValuesObject['refresh_interval'] = $j("#refreshinterval_selection_container select").val();
                var id = widget.id;
                var postdata = {
                    preferences: JSON.stringify(formValuesObject)
                };
                saveWidget(id, 'alert_widgets', postdata, dialogContainer)
                dialogContainer.dialog('disable');
            };
        }
        else {
            buttons['Create'] = function(){
                var formValuesObject = new Object();
                formValuesObject['refresh_interval'] = $j("#refreshinterval_selection_container select").val();
                createWidget(dialogContainer, "alert_widgets", formValuesObject);
                dialogContainer.dialog('disable');
            };
        }
        buttons['Cancel'] = function() {
            dialogContainer.dialog('close');
        }

        // transforming dialog div-container to the jquery-ui dialog
        var dialog = dialogContainer.dialog({
            //position: [(50 + dialogContainersSize*20), (50 + dialogContainersSize*20)],
            width: 500,
            height: 333,
            autoOpen: false,
            modal:true,
            resizable: false,
            zIndex: 50000,
            buttons: buttons,
            close: function(event, ui){
                $j(this).dialog('destroy').html('').hide().remove();
                $j('#addWidgetButton').button('enable').trigger('enable');
            }
        });
        dialogContainer.dialog('open');

        if (!widget || !widget.id) {
            dialogContainer.dialog({
                title: "Create new alert widget"
            });
        }
        else {
            dialogContainer.dialog({
                title: "Edit alert widget"
            });
        }

        $j.ajax({
            url: '/alert_widgets/new',
            type: "GET",
            complete: function(data, textStatus){
                if(textStatus=="success") {
                    //                    notify('notice', textStatus + ' list_only');
                    // callback for systems loading; create systems selection input

                    result = data.responseText;
                    dialogContainer.prepend(result);
                }
            },
            error: function(data, textStatus) {
                notify('error', 'Something went wrong', textStatus + data  );
                dialog.dialog({
                    buttons: null
                });
            }
        });

    },
    // sets widget.data with responsedata
    getWidgetContent: function (id) {
        var widget = Widgets[id];
        var prefs = widget.preferences;
        // get alerts that are generated within latest refresh
        var now = Math.round(+new Date()/1000); // unix like timestamp
        var start_date = now - prefs.refresh_interval;
        $j.ajax({
            type: "GET",
            url: '/recentalerts?start_date=' + start_date,
            success: function(data, textStatus){
                if(textStatus=="success") {
                    notify('notice', 'AlertWidget#'+widget.id, 'Fresh data received.');
                    // prepend alerts to widget content
                    $j.each(data, function(i, obj) {
                        //console.log(alert.alert.created_at);
                        if (obj.alert.severity == 'ERROR') {
                            var sev_class = 'error_alert';
                        } else if (obj.alert.severity == 'WARN') {
                            var sev_class = 'warn_alert';
                        }
                        // parse date with date.js
                        var date = Date.parse(obj.alert.created_at_js);
                        date = date.toString("MMMM dd, yyyy HH:mm:ss");
                        var result = '<div class="'+sev_class+'" id="alert-'+obj.alert.id+'">'+
                                        // FIXME link is not clickable because click event is binded to z-index (Widget.js:275)
                                        '<a href="/systems/'+obj.alert.system_id+'">' +
                                        date+' '+obj.alert.severity+' '+
                                        obj.alert.system.fqdn + ' ' +
                                        obj.alert.metric_identifier+' is '+obj.alert.value+
                                        '</a>'+
                                      '</div>';
                        $j('#'+widget.id).find("div.content-wrapper").prepend(result);
                        $j('#'+widget.id).find("div.content-wrapper #alert-"+obj.alert.id).effect("slide", 800).effect("pulsate", { times:6 }, 1250);
            });

                    //$j('#'+id).find("div.content-wrapper").prepend('<div><code>'+data+'</code></div>');
                }
            },
            error: function(data, textStatus) {
                notify('error', 'AlertWidget#'+widget.id, 'Refreshing failed. No new data received.');
            }
        });
    }
});