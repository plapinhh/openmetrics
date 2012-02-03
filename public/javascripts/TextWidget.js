var TextWidget = TextWidget || {};
$j.extend(TextWidget, {
    openWidgetForm : function (id) {
        var widget = Widgets[id];
        // dialog div-container is being intialized and appended to content;
        var dialogContainer = $j('<div></div>').attr('id', 'addWidgetDialog');
            
        dialogContainer.html(   '<div>'+ this.getBackgroungColorsPicker() + this.getBorderStylePicker() + this.getSpeechBubblePicker() +
            '<div style="padding:0; margin:0;">'+
            '<textarea id="createMemoDialog_text" class="tinymce" style="width:650px; height:240px;">'+
            ((widget && widget.preferences) ? widget.preferences.text.replace(/\[br\/\]/g, '\u000a') : '') +
            '</textarea>'+
            '</div>'+
            '</div>');
        $j('#content').append(dialogContainer);
        $j('textarea.tinymce').markItUp(myBbcodeSettings);
        $j('#textWidgetForm_colors input, #textWidgetForm_borders input').focus(function(){
            $j(this).blur();
        }).blur();
            
        $j('#textWidgetForm_colors label').click(function () {
            var radio_id = $j(this).attr("for");
            $j('#textWidgetForm_colors input.#'+radio_id).attr("checked", true);
            $j('#textWidgetForm_colors label').removeClass("checked");
            $j(this).addClass("checked");
            $j('#createMemoDialog_text').css("background","none").css("background-color", $j(this).css("background-color"));

            $j('#textWidgetForm_bubbles input').attr("checked", false);
            $j('#textWidgetForm_bubbles label').removeClass("checked");
        }).css("cursor", "pointer");
        if (widget && widget.preferences && widget.preferences.background && widget.preferences.background != 'FFFFFF')
            $j('#textWidgetForm_colors label[for=bg-color-'+widget.preferences.background+']').trigger("click");
            
        $j('#textWidgetForm_borders label').click(function () {
            var radio_id = $j(this).attr("for");
            $j('#textWidgetForm_borders label').removeClass("checked");
            $j('#textWidgetForm_borders input').attr("checked", false);
            $j('#textWidgetForm_borders input.#'+radio_id).attr("checked", true);
  
            $j(this).addClass("checked");
            $j('#createMemoDialog_text').css("border","none").css("border", $j(this).css("border"));
                
            $j('#textWidgetForm_bubbles input').attr("checked", false);
            $j('#textWidgetForm_bubbles label').removeClass("checked");
        }).css("cursor", "pointer");
        if (widget && widget.preferences && widget.preferences.border && widget.preferences.border != 'transparent')
            $j('#textWidgetForm_borders label[for=border-style-'+widget.preferences.border+']').trigger("click");

        $j('#textWidgetForm_bubbles label').click(function () {
            var radio_id = $j(this).attr("title");
            $j('#textWidgetForm_bubbles input[value="'+radio_id+'"]').attr("checked", true);
            $j('#textWidgetForm_bubbles label').removeClass("checked");
            $j(this).addClass("checked");

            $j('#createMemoDialog_text').css("border","none").css("background","none");
            $j('#textWidgetForm_borders input, #textWidgetForm_colors input').attr("checked", false);
            $j('#textWidgetForm_borders label, #textWidgetForm_colors label').removeClass("checked");
        }).css("cursor", "pointer");
        if (widget && widget.preferences && widget.preferences.bubble && widget.preferences.bubble != "")
            $j('#textWidgetForm_bubbles label[title='+widget.preferences.bubble+']').trigger("click");

        // buttons object described dialog buttons and press actions for its; the object is to append as option to the dialog;
        var buttons = new Object();
        var title;
        if (widget && widget.id) {
            buttons['Save'] = function(){
                //                var text = tinyMCE.get('createMemoDialog_text').getContent();
                var text = $j('#createMemoDialog_text').val();
                text = text.replace(/\r/g, "");
                text = text.replace(/\n/g, "[br/]");
                text = text.replace(/\u000a/g, "[br/]");
                text = text.replace(/\</g, "&lt;");
                text = text.replace(/\>/g, "&gt;");
                var background = $j('#textWidgetForm_colors input:checked').val();
                var border = $j('#textWidgetForm_borders input:checked').val();
                var bubble = $j('#textWidgetForm_bubbles input:checked').val();
                var formValuesObject = new Object();
                formValuesObject['text'] = text;
                formValuesObject['background'] = background;
                formValuesObject['border'] = border;
                formValuesObject['bubble'] = bubble;
                var id = widget.id;
                var postdata = {
                    preferences: JSON.stringify(formValuesObject)
                    };
                saveWidget(id, 'text_widgets', postdata, dialogContainer)
                dialogContainer.dialog('disable');
            };
            title = "Edit text note";
        }
        else {
            buttons['Create'] = function(){
                //                var text = tinyMCE.get('createMemoDialog_text').getContent();
                var text = $j('#createMemoDialog_text').val();
                text = text.replace(/\r/g, "");
                text = text.replace(/\n/g, "[br/]");
                text = text.replace(/\u000a/g, "[br/]");
                text = text.replace(/\</g, "&lt;");
                text = text.replace(/\>/g, "&gt;");
                var background = $j('#textWidgetForm_colors input:checked').val();
                var border = $j('#textWidgetForm_borders input:checked').val();
                var bubble = $j('#textWidgetForm_bubbles input:checked').val();
                var formValuesObject = new Object();
                formValuesObject['text'] = text;
                formValuesObject['background'] = background;
                formValuesObject['border'] = border;
                formValuesObject['bubble'] = bubble;
                createWidget(dialogContainer, "text_widgets", formValuesObject, null, null, 300, 300);
                dialogContainer.dialog('disable');
            };
            title = "Add text note";
        }
        buttons['Cancel'] = function() {
            dialogContainer.dialog('close');
        }

        // transforming dialog div-container to the jquery-ui dialog
        dialogContainer.dialog({
            modal: true,
            zIndex: 50000,
            height: 600,
            width: 740,
            title: title,
            autoOpen: false,
            buttons: buttons,
            beforeclose: function(event, ui) {
                //                        tinyMCE.get('createMemoDialog_text').remove();
                $j('#createMemoDialog_text').remove();
            },
            close: function(event, ui) {
                $j(this).dialog('destroy');
                dialogContainer.remove();
                $j('#addWidgetButton').button('enable').trigger('enable');
            },
            open: function(event, ui) {
                //$j('textarea.tinymce').markItUp(myBbcodeSettings);
                //$j('textarea.tinymce').css("background","none").css("padding","5px");
                $j('textarea.tinymce').css("padding","10px");
            }
        });
        dialogContainer.dialog('open');
    },
    getWidgetContent: function (id) {
        var widget = Widgets[id];
        var prefs = widget.preferences;
        var text = prefs['text'];
        text = text.replace(/\</g, "&lt;");
        text = text.replace(/\>/g, "&gt;");
                
        text = parseBBCode(text);
            
        text = text.replace(/\[br\/\]/g, "<br/>");
        text = text.replace(/\[h(\d)\]/g, "<h$1>");
        text = text.replace(/\[\/h(\d)\]/g, "</h$1>");
        text = text.replace(/(\<\/ol\>|\<\/ul\>|\<\/li\>|\<\/h\d\>)\s*\<br\/\>/g, "$1");
        text = text.replace(/\<br\/\>\s*(\<ol\>|\<ul\>|\<li\>|\<h\d\>)/g, "$1");
        var result = '<div style="height:100%;"><div style="padding: 10px;">'+text+'</div></div>';
        $j('#'+widget.id+" div.content-wrapper").fadeOut(100, function () {$j(this).html(result).fadeIn()});
    },
    getBackgroungColorsPicker: function () {
        var result = "<div id='textWidgetForm_colors'><div class='border-wrapper'>";
        result += "<div class='legend' style='margin-right: 10px;'>Background:</div>";
        //            var colors = ["#FFFFFF", "#FCF0AD", "#E9E74A", "#EE5E9F", "#FFDD2A", "#F59DB9", "#F9A55B", "#D0E17D", "#36A9CE", "#EF5AA1", "#AE86BC", "#FFDF25", "#56C4E8", "#D0E068", "#CD9EC0", "#ED839D", "#FFE476", "#CDDD73", "#F35F6D", "#FAA457", "#35BEB7", "#D189B9", "#99C7BC", "#89B18C", "#738FA7", "#8A8FA3", "#82ACB8 ", "#F9D6AC", "#E9B561", "#E89132", "#DA7527", "#DEAC2F", "#BAB7A9", "#BFB4AF", "#CDC4C1", "#CFB69E", "#D0AD87"];
        var colors = ["FFFFFF", "FCF0AD", "E9E74A", "F59DB9", "56C4E8", "35BEB7", "99C7BC", "89B18C", "738FA7", "8A8FA3", "82ACB8", "F9D6AC", "BFB4AF"];

        for (var i=0; i < colors.length; i++) {
            result += "<input type='radio' name='bg-color' id='bg-color-"+colors[i]+"' value='"+colors[i]+"'/>";
            result += "<label for='bg-color-"+colors[i]+"' style='background-color: #"+colors[i]+";'></label>";
        }
        result += "<div style='clear:both;' />";
        result += "</div></div>";
        return result;
    },
    getBorderStylePicker: function () {
        var result = "<div id='textWidgetForm_borders'><div class='border-wrapper'>";
        result += "<div class='legend' style='margin-right: 10px;'>Border:</div>";

        var styles = ["transparent", "dashed", "dotted", "solid", "double", "groove", "ridge", "inset", "outset"];
        for (var i=0; i < styles.length; i++) {
            result += "<input type='radio' name='border-style' id='border-style-"+styles[i]+"' value='"+styles[i]+"'/>";
            result += "<label for='border-style-"+styles[i]+"' style='border:4px "+styles[i]+";' title='"+styles[i]+"'></label>";
        }
        result += "<div style='clear:both;' />";
        result += "</div>";
        result += "</div>";
        return result;
    },
    getSpeechBubblePicker: function () {
        var result = "<div id='textWidgetForm_bubbles'><div class='border-wrapper'>";
        result += "<div class='legend' style='margin-right: 10px;'>Speech bubble:</div>";

        //            var classes = ["none", "triangle-right", "triangle-right top", "triangle-right left", "triangle-right right", "example-right", "example-obtuse", "example-number", "triangle-border top"];
        var classes = ["", "triangle-right", "triangle-right top", "triangle-right left", "triangle-right right", "example-right", "example-obtuse", "example-number", "triangle-border top"];
        for (var i=0; i < classes.length; i++) {
            result += "<input type='radio' name='bubble-style' value='"+classes[i]+"'/>";
            result += "<label class='"+classes[i]+"' title='"+classes[i]+"'></label>";
        }
        result += "<div style='clear:both;' />";
        result += "</div>";
        result += "</div>";
        return result;
    }

});