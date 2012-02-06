Widgets = new Object();
var ResponseData;
var maxZindex = 10001;
var ctrlKeyPressed = false;
var selected = new Array();
var focusedInput;

$j(document).ready(function($) {
    if (typeof(AUTH_TOKEN) == "undefined") return;
    if (typeof(dashboardId) == "undefined") return;
    
    $j('input, textarea, select').live("focus", function() {
        focusedInput = this;
    });

    $j('input, textarea, select').live("focusout", function() {
        focusedInput = null;
    });

    // setting variable to hold press state of the Shift Key
    // it is needed for multiselection and dragging of widgets
    $j(document).keydown(function(event) {
        if (event.keyCode == '17') {
            ctrlKeyPressed = true;
        }
    });
    $j(document).keyup(function(event) {
        if (event.keyCode == '17') {
            ctrlKeyPressed = false;
        }
    });

    // Press ESC-Key to deactivate edit mode
    $j(document).keyup(function(event) {
        if (event.keyCode == '27') {
//            if ($j('#editDashboardInput :checked')) {
            if ($j('#editDashboardInput').attr("checked")) {
                $j('#editDashboardInput').attr('checked', "");
                $j('#editDashboardInput').button("refresh");
                forceDashboardEditMode(false);
            }
        }
    });

    // Press E-Key to deactivate edit mode
    $j(document).keyup(function(event) {
        if (event.keyCode == '69') {
            if (!focusedInput && !$j('#editDashboardInput').attr("checked")) {
//                console.log($j('#editDashboardInput').attr("checked"));
                $j('#editDashboardInput').attr('checked', "checked");
                $j('#editDashboardInput').button("refresh");
                forceDashboardEditMode(true);
            }
        }
    });

    // Press A-Key to deactivate edit mode
    $j(document).keyup(function(event) {
//        console.log(event.keyCode);
        if (event.keyCode == '65') {
            if (!focusedInput) {
                $j( "button#openWidgetsGalleryDialog" ).click();
            }
        }
    });

    // create edit-button and add new widget drop-down menu in toolbar area;
    initToolBar();

    // lädt das Widgetarray für Dashboard und ruft die Rendering-Funktion
    $j.ajax({
       url: "/dashboards/"+dashboardId,
       type: "GET",
       complete: function(data,stat){
          if(stat=="success") {
            ResponseData = JSON.parse(data.responseText);
            var widgets = ResponseData.widgets;
            // refactor widgets array (array indexe werden durch die widget.id ersetzt)
            for (var i= 0; i < widgets.length; i++) {
                if (widgets[i].id)
                    Widgets[widgets[i].id] = widgets[i];
                    renderWidget(widgets[i].id); // function is defined in Widget.js
            }
            // set div#content css parameter
            // set ui-selectable container for div#content
            initContentParams();
          }
       }
    });

    // click events for add new widgets menu
    $j('.newMuninImageWidget').click(function () {
        $j("#widgetsGalleryDialog").dialog("close");
        getAddWidgetForm(MuninImageWidget);
    });
    $j('.newCollectdImageWidget').click(function () {
        $j("#widgetsGalleryDialog").dialog("close");
        getAddWidgetForm(CollectdImageWidget);
    });
    $j('.newTextWidget').click(function () {
        $j("#widgetsGalleryDialog").dialog("close");
        getAddWidgetForm(TextWidget);
    });
    $j('.newLogtailWidget').click(function () {
        $j("#widgetsGalleryDialog").dialog("close");
        getAddWidgetForm(LogtailWidget);
    });
    $j('.newLiveTickerBarWidget').click(function () {
        $j("#widgetsGalleryDialog").dialog("close");
        getAddWidgetForm(LiveTickerBarWidget);
    });
    $j('.newAlertWidget').click(function () {
        $j("#widgetsGalleryDialog").dialog("close");
        getAddWidgetForm(AlertWidget);
    });

//    $j('.newHalloWorldWidget').click(function () {
//        $j("#widgetsGalleryDialog").dialog("close");
//        getAddWidgetForm(HalloWorldWidget);
//    });

}); // end of ready


    // force edit mode for all widgets in dashboard
    function forceDashboardEditMode (isChecked) {   
        if (isChecked) {        
            notify('notice', 'Edit mode is activated!', 'Press "Edit" button or "Esc" key to deactivate edit mode.' );
            $j("#content").selectable({disabled: false});

            $j('#editDashboardButtonWrapper label').addClass("ui-state-active");
            $j( "button#deleteWidgetsButton" ).show();

            $j.each(Widgets, function (id, val) {
                setEditMode(id); // function is defined in Widget.js
            });

            $j('.ui-resizable-handle').show();
        }
        else {
            notify('notice', 'Edit mode is deactivated!', 'Hit "edit" button or press the "e" key to activate edit mode again.' );
            $j("#content").selectable({disabled: true}).removeClass("ui-state-disabled");
            $j( "button#deleteWidgetsButton" ).hide();
            $j('#editDashboardButtonWrapper label').removeClass("ui-state-active");

            $j.each(Widgets, function (id, val) {
                unsetEditMode(id); // function is defined in Widget.js
            });
            $j('.ui-resizable-handle').hide();
        }
        fitContentDivSizeToContent();
    }

    // create edit-button and add new widget drop-down menu in toolbar area;
    function initToolBar() {
        $j('#editDashboardButtonWrapper, button').css({'float': 'left', 'margin': '5px 0 0 10px'});
        $j( "button#openWidgetsGalleryDialog" ).button();
	$j( "button#openWidgetsGalleryDialog" ).click(function() { 
            $j("#widgetsGalleryDialog").dialog("open");
            $j( "button#openWidgetsGalleryDialog" ).removeClass("ui-state-focus");
        });


        $j( "button#deleteWidgetsButton" ).button().hide();
	$j( "button#deleteWidgetsButton" ).click(function() {
            selected = $j(".ui-selected");
            
            if (selected.length > 0) {
                var ids = selected.map(function(){
                    return parseInt($j(this).attr("id"));
                }).get();
                deleteWidgets(ids);
                $j( "button#deleteWidgetsButton" ).removeClass("ui-state-focus");
            }
            else {
                alert("No widgets have been selected to delete!");
            }
        });

        $j("#widgetsGalleryDialog").dialog({
            width: 550,
            height: 400,
            autoOpen: false,
            modal: false,
            resizable: false,
            zIndex: 50000
        });

        // Toggle-Button für Dashboard Edit Modus
        $j('#editDashboardInput').attr('checked', "");
        $j('#editDashboardInput').focus(function(){
          $(this).blur();
        });
        $j('#editDashboardInput').button();
        $j('.ui-button span').css('margin', '0 1px 1px 0').css('line-height', '0.6').css('padding-bottom', '0.45em').css('padding-top', '0.45em');
        
        $j('#editDashboardInput').bind("change", function() {
            forceDashboardEditMode($j('#editDashboardInput').attr('checked'));
        });
    }

    function initContentParams(){
            $j("#content").css({padding: 0, margin: 0 });
            $j("#content").css({"min-width": "100%"});

        // initiate the selectable id to be recognized by UI
        $j("#content").selectable({
            filter: 'div.dnd-wrapper',
            disabled: true
        });
        
        fitContentDivSizeToContent();
    }

    function fitContentDivSizeToContent() {
        var maxX=0, maxY=0;
        $j(".dnd-wrapper").each(function (){
            var el = $j(this);
            var bottom = el.position().top + el.height();
            var right = el.position().left + el.width();
            if (bottom >= maxY) maxY = bottom;
            if (right >= maxX) maxX = right;
        });
        $j("#content").height("100%");
        var delta = $j("#content").height()-$j("#header").height();
        $j("#content").css("min-height", delta);
        $j("#content").height(maxY-$j("#header").height()+30);
        $j("#content").width(maxX+30);
    }
