var map = null;

function init(){

            var options = {
                     controls: [
                                new OpenLayers.Control.Navigation(),
                                new OpenLayers.Control.ZoomPanel(),
                                new OpenLayers.Control.KeyboardDefaults()
                            ]
            };

            map = new OpenLayers.Map('map', options);

            var graphic = new OpenLayers.Layer.Image(
                'Plain Map',
                '/images/openlayers_poc/hamburg_map.png',
                new OpenLayers.Bounds(52, 9, 54, 11),
               new OpenLayers.Size(300, 252),
                options
            );

            var graphic2 = new OpenLayers.Layer.Image(
                'Display User Distribution',
                '/images/openlayers_poc/hamburg_map_sized2.png',
                new OpenLayers.Bounds(52, 9, 54, 11),
                new OpenLayers.Size(300, 252),
                {numZoomLevels: 6, isBaseLayer: false,  visibility:false}
            );

            var graphic3 = new OpenLayers.Layer.Image(
                'Display User Locations',
                '/images/openlayers_poc/hamburg_users.png',
                new OpenLayers.Bounds(52, 9, 54, 11),
                new OpenLayers.Size(300, 252),
                {numZoomLevels: 6, isBaseLayer: false, visibility:false}
            );

            var graphic4 = new OpenLayers.Layer.Image(
                'Display User Distribution Smooth',
                '/images/openlayers_poc/hamburg16_layer.png',
                new OpenLayers.Bounds(52, 9, 54, 11),
                new OpenLayers.Size(300, 252),
                {numZoomLevels: 6, isBaseLayer: false, visibility:false}
            );

            graphic.events.on({
                loadstart: function() {
                    OpenLayers.Console.log("loadstart");
                },
                loadend: function() {
                    OpenLayers.Console.log("loadend");
                }
            });



            map.addLayers([graphic, graphic2, graphic4]);
            map.addControl(new OpenLayers.Control.LayerSwitcher());
            map.zoomToMaxExtent();
            map.zoomTo(map.getZoom()+1);
}