var HalloWorldWidget = HalloWorldWidget || {};
$j.extend(HalloWorldWidget, {
    openWidgetForm : function (id) {
        var widget = Widgets[id];
        // dialog div-container is being intialized and appended to content;
        var dialogContainer = $j('<div class="ui-helper-clearfix"></div>').attr('id', 'addWidgetDialog');
        dialogContainer.html('<input type="text" name="text" id="halloWorldTextInput" "value="Hallo World!" disabled="disabled">');
        $j('#content').append(dialogContainer);
            
        // buttons object described dialog buttons and press actions for its; the object is to append as option to the dialog;
        var buttons = new Object();
        if (widget) {
            buttons['Save'] = function(){
                var formValuesObject = new Object();
                formValuesObject['text'] = $j('#halloWorldTextInput').val();
                var id = widget.id;
                var postdata = {
                    preferences: JSON.stringify(formValuesObject)
                    };
                saveWidget(id, 'hallo_world_widgets', postdata, dialogContainer)
                dialogContainer.dialog('disable');
            };
        }
        else {
            buttons['Create'] = function(){
                var formValuesObject = new Object();
                formValuesObject['text'] = $j('#halloWorldTextInput').val();
                createWidget(dialogContainer, "hallo_world_widgets", formValuesObject);
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
            height: 400,
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
    },
    getWidgetContent: function (id) {
        var widget = Widgets[id];
        var prefs = widget.preferences;
        var result = parseBBCode(prefs['text'])
        result = '<h1>'+result+'</h1>';
        $j('#'+id + " div.content-wrapper").html(result);
    }
});