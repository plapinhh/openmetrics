var LogtailWidget = LogtailWidget || {};
$j.extend(LogtailWidget, {
    openWidgetForm : function (id) {
        var widget = Widgets[id];
        // dialog div-container is being intialized and appended to content;
        var dialogContainer = $j('<div class="ui-helper-clearfix"></div>').attr('id', 'addWidgetDialog');
        dialogContainer.html('<img id="logtailWidgetForm_ajax-loader" src="/images/ajax-loader.gif"/>');
        $j('#content').append(dialogContainer);
           
        // buttons object described dialog buttons and press actions for its; the object is to append as option to the dialog;
        var buttons = new Object();
        if (widget.id) {
            buttons['Save'] = function(){
                var formValuesObject = new Object();
                formValuesObject['text'] = $j('#halloWorldTextInput').val();
                var id = widget.id;
                var postdata = {
                    preferences: JSON.stringify(formValuesObject)
                };
                saveWidget(id, 'logtail_widgets', postdata, dialogContainer)
                dialogContainer.dialog('disable');
            };
        }
        else {
            buttons['Create'] = function(){
                var formValuesObject = new Object();
                formValuesObject['filepath'] = $j('#filepathinput').val();
                formValuesObject['system_id'] = $j("#system_selection_container select").val();
                formValuesObject['refresh_interval'] = $j("#refreshinterval_selection_container select").val();
                createWidget(dialogContainer, "logtail_widgets", formValuesObject);
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
                title: "Create new logtail widget"
            });
        }
        else {
            dialogContainer.dialog({
                title: "Edit logtail widget"
            });
        }

        $j.ajax({
            url: '/logtail_widgets/new',
            type: "GET",
            complete: function(data, textStatus){
                if(textStatus=="success") {
                    //                    notify('notice', textStatus + ' list_only');
                    // callback for systems loading; create systems selection input

                    result = data.responseText;
                    dialogContainer.prepend(result);
                    openLogtailWidgetSystemSelection(widget);
                }
            },
            error: function(data, textStatus) {
                notify('error', 'LogtailWidget#'+widget.id, textStatus + data);
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

        // to render logtail header onlöy one if the widget is initially loaded
        if ($j('#'+id + " div.content-wrapper div.logtail_header").length == 0) {
            var result = '<div class="logtail_header">system_id: '+prefs.system_id+'<br />filepath:'+prefs.filepath+'<br />refresh_interval: '+prefs.refresh_interval+'<hr/></div>';
            $j('#'+id + " div.content-wrapper").html(result);
        }

        $j.ajax({
            type: "GET",
            url: '/logtail/'+ prefs.system_id,
            success: function(data,textStatus){
                if(textStatus=="success") {
                    notify('notice', 'LogtailWidget#'+widget.id, 'Fresh data received.');
                    $j('#'+id).find("div.content-wrapper").append('<div><code>'+data+'</code></div>');
                }
            },
            error: function(data, textStatus) {
                notify('error', 'LogtailWidget#'+widget.id, 'Refreshing failed. No new data received.');
            }
        });
    }
});