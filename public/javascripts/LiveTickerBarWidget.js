var LiveTickerBarWidget = LiveTickerBarWidget || {};

$j.extend(LiveTickerBarWidget, {
    openWidgetForm : function (id) {
        var widget = Widgets[id];
        var dialog_title;
        if (!widget || !widget.id) {
            if (!widget) widget = new Object();
            widget.id = "new";
            if (!widget.preferences) widget.preferences = new Object();
            widget.preferences.refresh_interval = 10;
            dialog_title = "Create new LiveTickerBarWidget"
        }
        else {
            dialog_title = "Edit LiveTickerBarWidget";
        }
        // dialog div-container is being intialized and appended to content;
        var dialogContainerId = 'livetickerbar_widget_form_' + widget.id;
        var dialogContainer = $j( "#"+dialogContainerId );
        if (dialogContainer.length == 0 ) {
            dialogContainer = $j('<div class="ui-helper-clearfix"></div>').attr('id', dialogContainerId);
            $j('#content').append(dialogContainer);
            // transforming dialog div-container to the jquery-ui dialog
            var dialog = dialogContainer.dialog({
                width: 950,
                height: 500,
                autoOpen: false,
                modal:false,
                resizable: false,
                zIndex: 50000,
                title: dialog_title,
                close: function(event, ui){
                    $j(this).dialog('destroy').empty().remove();
//                    $j('#addWidgetButton').button('enable').trigger('enable');
                }
            });
            dialogContainer.dialog('disable');
            dialogContainer.dialog('open');
        }
        else {
            dialogContainer.dialog('moveToTop');
        }

        var url = '/live_ticker_bar_widgets/form_step1';

        if (widget.preferences.system_id && typeof(widget.preferences.system_id) == "string")
            widget.preferences.system_id = JSON.parse(widget.preferences.system_id);
        if (widget.preferences.metrics && typeof(widget.preferences.metrics) == "string")
            widget.preferences.metrics = JSON.parse(widget.preferences.metrics);

        // fires ajax request to load systems for the systems selection input
        $j.ajax({
            url: url,
            type: "POST",
            complete: function(data, textStatus){
//                $j('#collectdImageWidgetForm_ajax-loader').remove();
                if(textStatus=="success") {
                    // callback for systems loading; create systems selection input
                    result = data.responseText;
                    dialogContainer.prepend(result);
                    dialogContainer.dialog('enable');
                    widget.dialogContainer = dialogContainer;
                    initLiveTickerBarWidgetSystemSelection(widget);
                    openLiveTickerBarWidgetSystemSelection(widget);
                }
            },
            error: function(data, textStatus) {
                notify('error', 'LiveTickerBarWidget#'+widget.id, textStatus + data);
                dialog.dialog({
                    buttons: null
                });
            }
        });
    },
    getWidgetContent: function (id) {
        var widget = Widgets[id];
        $j.ajax({
            url: '/live_ticker_bar_widgets/'+widget.id,
            type: "GET",
            complete: function(data, textStatus){
                if(textStatus=="success") {
                    // callback for systems loading; create systems selection input
                    var result = data.responseText;
                    $j('#'+widget.id+" div.content-wrapper").empty().append(result);
                    $j('#'+widget.id+" span.inline.sparkline").sparkline();
                    // mg/20110803: fade deactivated - not functional yet
                    //$j('#'+widget.id+" div.content-wrapper").fadeOut(100, function () {
                    //    $j(this).html(result).fadeIn()
                    //    $j('#'+widget.id+" span.inline.sparkline").sparkline();
                    //});
                }
            },
            error: function(data, textStatus) {
                notify('error', 'LiveTickerBarWidget#'+widget.id, textStatus + data);
            }
        });
        var result = "";
        result += "<div>";
        result += $j('#ajaxload').html();
        result += "</div>";
        $j('div#'+id+' div.content-wrapper').html(result);
        // mg/20110803: fade deactivated - not functional yet
        //$j('#'+widget.id+" div.content-wrapper").fadeOut(100, function () {$j(this).html(result).fadeIn()});
    }
});