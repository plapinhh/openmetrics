/*  */
var $j = jQuery.noConflict();



// opens dialog with content of DOM element
// params:  id - of element in DOM
//          title - title of dialog
function open_dialog(id, title, submit_text) {
    var element_id = id;
    var dialog_title = title;
    var buttons = {};
    if (submit_text) { 
        buttons[submit_text] = function(){$j(this).children('form').submit()}
    }
    $j('#' + id).dialog({
        autoOpen: true,
        title: dialog_title,
        resizable: false,
        width: 400,
        height: 200,
        buttons: buttons
    });
    return false;
}


// display notifications
// e.g. notify('error', 'some title', 'something went wrong!');
// TODO extend with other severities
function notify(type, title, message) {
    var image = undefined;
    
    switch(type) {
        case "error":
            if(!title) { var title = "Error"; }
            image = "/images/gritter/error.png";
            break;
        case "warning":
            if(!title) { var title = "Warning"; }
            image = "/images/gritter/warning.png";
            break;  
        case "notice":
            if(!title) { var title = "Notice"; }
            image = "/images/gritter/notice.png";
            break;
        case "success":
            if(!title) { var title = "Success"; }
            image = "/images/gritter/success.png";
            break;
        }       
    
     if(!image) {
         $j.gritter.add({title: title, text: message});
     } else {
         $j.gritter.add({image: image, title: title, text: message});
     }
}

// The function mapIconsSetToTheme(theme) manage the mapping between themes and
// icons sets. The mapping is customizable.
function mapIconsSetToTheme(theme) {
    switch(theme) {
        case "blitzer": iconColor = "red3";break; 
        case "cupertino": iconColor = "steelblue3";break;
        case "darkhive": iconColor = "orange";break;
        case "flick": iconColor = "violetred2";break;
        case "redmond": iconColor = "steelblue3";break;
        case "southstreet": iconColor = "orange";break;
        case "blacktie": iconColor = "orange";break;
        case "sunny": iconColor = "steelblue3";break;
        case "hotsneaks": iconColor = "violetred2";break;
        default: iconColor = "darkgrey";break;
    }
}

$j.fn.compareArray = function(t) {
    if (this.length != t.length) { return false; }
    var a = this.sort(),
        b = t.sort();
    for (var i = 0; t[i]; i++) {
        if (a[i] !== b[i]) {
                return false;
        }
    }
    return true;
};

// to extend ajax requests with auth token
var params, paramsString, omTheme;


// begin jquery document ready function
//
$j(document).ready(function($) {

        //ui states
        $j('.ui-state-default').hover(function(){
                        $(this).addClass('ui-state-hover');
                }, function(){
                        $(this).removeClass('ui-state-hover');
                }
        );

    // init & apply themes
    $j.themes.init();
    $j('#namedThemes').themes({compact: true});

    // A current theme is needed to be saved for manage icons set (by color), which are coming not from jquery ui.
    // Current theme is saved on document load or by changing it on the 'you' page.
    // The function mapIconsSetToTheme(theme) manage the mapping between themes and icons sets. The mapping is customizable.
    omTheme = jQuery.themes.currentTheme;
    mapIconsSetToTheme(omTheme);// border-color of links should be taken from ui-state-active


    $j('#namedThemes a').click(function () {
        omTheme = jQuery.themes.currentTheme;
        mapIconsSetToTheme(omTheme);
    });
    
    // inititialize & configure the notification_widget
    // For jNotify Inizialization
    $j('#notification').jnotifyInizialize({
        oneAtTime: false,
        appendType: 'append'
    });

        $j.ajaxSetup ({
            // Disable caching of AJAX responses
            cache: false
        });

       //  AJAX loading image
       // on ajax request show loading images + remove on complete
        $j(document).ajaxSend(function(event, request, settings) {
            $('#ajaxload').show();
        });
        $j(document).ajaxComplete(function(event, request, settings){
           //alert("ajax complete");
           $('#ajaxload').fadeOut("slow");

         });

      // Alle Ajax-Requests um authenticity_token und evt. vorhandene Parameter erweitern
      // http://brandonaaron.net/blog/2009/02/24/jquery-rails-and-ajax
      $j(document).ajaxSend(function(event, request, settings) {
            if (typeof(AUTH_TOKEN) == "undefined") return;
            if ( settings.type == 'post' || settings.type == 'POST' ) {
                settings.data = settings.data || "";
                settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);                
            }
            // Handling for session expires on ajax request
            // If a login session is expired, rails sends the custom http code 278 (it's not a standard http code).
            // We override the success function defined in concrete ajax requests to check the response code.
            // If the code is 278, the actual page is reloaded and rails redirects to the login page setting by the way correct referer in header.
            // Else the defined success actions, which are saved in intercepted_success, are executed.
            if (settings.success)
                var intercepted_success = settings.success;
            settings.success = function( a, b, c ) {
                if( request.status.toString() == "278") {
                    //window.location = window.location; // doesn't work with anchor
                    window.location.reload();
                    return;
                }
                else if (intercepted_success)
                    intercepted_success( a, b, c );
            }
                
            for (param in params) {
                 if (param) settings.data += (settings.data ? "&" : "") + param + "=" + encodeURIComponent(params[param]);
            }

            if (paramsString) settings.data += (settings.data ? "&" : "") + paramsString;

            request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            // we accept js and json, see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
            request.setRequestHeader("Accept", "text/javascript,application/json");
            request.dataType = "json";
        });


    // visual highlight on focus for input fields of type text
    $j('input:text').focusin(function(){
            $(this).addClass('ui-state-highlight');
    });

    $j('input:text').focusout(function(){
            $(this).removeClass('ui-state-highlight');
    });



// end jquery document ready function
});
