function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

// TODO
function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  /*$(link).parent().before(content.replace(regexp, new_id));*/
  var $dialog = $('<div></div>')
                        .load('/widgets/new #widget-form')
                        .dialog({
                                autoOpen: false,
                                title: 'Add Widget'
                        });
   $dialog.dialog('open');
}



// opens dialog when called by edit.js.rjs
// params:  id (e.g. widget-11)
//          title

function open_edit_dialog(id, title) {
    var element_id = "#form-" + id;
    var dialog_title = title;
    $(element_id).dialog({
        autoOpen: true,
        title: dialog_title
    });
    return false;
}

function notify(type, msg) {
    // jnotify is currently only aware of "error" & "message" type
    if (type == 'error') {
        $('#in-notification-widget').jnotifyAddMessage({
            text: msg,
            permanent: true,
            type: 'error'
         });
    } else {
        $('#in-notification-widget').jnotifyAddMessage({
            text: msg,
            permanent: false,
            type: 'message'
        });
    }
    return false;
}


// height of header to recalculate position of workspace
headerOffset = $('#header').height();


$(document).ready(function($) {
    // inititialize & configure the notification_widget
    // For jNotify Inizialization
    $('#in-notification-widget').jnotifyInizialize({
        oneAtTime: false,
        appendType: 'append'
    });

    // layout of basic page elements
    // http://wiki.jqueryui.com/Position
    //   
     $('#in-notification-widget').position({
        my: "right top",
        at: "right bottom",
        of: $('#main')
    });

      $('#workspace').position({
        my: "right top",
        at: "right bottom",
        of: $('#header')
    });
  
    $('#header').position({
        my: "left top",
        at: "left top",
        of: $('#main')
    });



    /* place workspace */
//    var windowWidth = $(document).width();
//    var windowHeight = $(document).height();
//    var workspaceHeight = windowHeight - headerOffset;
//    $('#workspace').css({width: windowWidth, height: workspaceHeight })



    /* ajax to edit widget */
    /* will load edit action for widget controller */
   /* $('.widget-opener').each(function() {
            // get widget id from parent div's id attribute
           // id needs to be like xyz-123
            var $widgetIDArr = $(this).attr('id').split(/-/);
            var $widgetID = $widgetIDArr[$widgetIDArr.length-1];
            var $widgetURL = '/widgets/' + $widgetID + '/edit #widget-form';
            // alert($widgetURL)
            var $dialog = $('<div></div>')
                    .load($widgetURL)
                    .dialog({
                            autoOpen: false,
                            title: $(this).attr('title')
                    });

            $(this).click(function() {
                    $dialog.dialog('open');

                    return false;
            });
    });
    */



// end document.ready function
});