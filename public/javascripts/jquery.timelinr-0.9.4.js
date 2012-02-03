/* ----------------------------------
jQuery Timelinr 0.9.4

tested with jQuery v1.6+
©2011 CSSLab.cl
free for any use, of course... :D
instructions: http://www.csslab.cl/2011/08/18/jquery-timelinr/
---------------------------------- */

jQuery.fn.timelinr = function(options){
	// default plugin settings
	settings = jQuery.extend({
		orientation: 				'horizontal',		// value: horizontal | vertical, default to horizontal
		containerDiv: 				'#timeline',		// value: any HTML tag or #id, default to #timeline
		datesDiv: 					'#dates',			// value: any HTML tag or #id, default to #dates
		datesSelectedClass: 		'selected',			// value: any class, default to selected
		datesSpeed: 				500,				// value: integer between 100 and 1000 (recommended), default to 500 (normal)
		issuesDiv: 					'#issues',			// value: any HTML tag or #id, default to #issues
		issuesSelectedClass: 		'selected',			// value: any class, default to selected
		issuesSpeed: 				300,				// value: integer between 100 and 1000 (recommended), default to 200 (fast)
		issuesTransparency: 		0.2,				// value: integer between 0 and 1 (recommended), default to 0.2
		issuesTransparencySpeed: 	500,				// value: integer between 100 and 1000 (recommended), default to 500 (normal)
		prevButton: 				'#prev',			// value: any HTML tag or #id, default to #prev
		nextButton: 				'#next',			// value: any HTML tag or #id, default to #next
		arrowKeys: 					'false',			// value: true | false, default to false
		startAt: 					1,					// value: integer, default to 1 (first)
		autoPlay: 					'false',			// value: true | false, default to false
		autoPlayDirection: 			'forward',			// value: forward | backward, default to forward
		autoPlayPause: 				7000				// value: integer (1000 = 1 seg), default to 2000 (2segs)
		
	}, options);

	$j(function(){
		// setting variables... many of them
		var howManyDates = $j(settings.datesDiv+' li').length;
		var howManyIssues = $j(settings.issuesDiv+' li').length;
		var currentDate = $j(settings.datesDiv).find('a.'+settings.datesSelectedClass);
		var currentIssue = $j(settings.issuesDiv).find('li.'+settings.issuesSelectedClass);
		var widthContainer = $j(settings.containerDiv).width();
		var heightContainer = $j(settings.containerDiv).height();
		var widthIssues = $j(settings.issuesDiv).width();
		var heightIssues = $j(settings.issuesDiv).height();
		var widthIssue = $j(settings.issuesDiv+' li').width();
		var heightIssue = $j(settings.issuesDiv+' li').height();
		var widthDates = $j(settings.datesDiv).width();
		var heightDates = $j(settings.datesDiv).height();
		var widthDate = $j(settings.datesDiv+' li').width();
		var heightDate = $j(settings.datesDiv+' li').height();
		
		// set positions!
		if(settings.orientation == 'horizontal') {	
			$j(settings.issuesDiv).width(widthIssue*howManyIssues);
			$j(settings.datesDiv).width(widthDate*howManyDates).css('marginLeft',widthContainer/2-widthDate/2);
			var defaultPositionDates = parseInt($j(settings.datesDiv).css('marginLeft').substring(0,$j(settings.datesDiv).css('marginLeft').indexOf('px')));
		} else if(settings.orientation == 'vertical') {
			$j(settings.issuesDiv).height(heightIssue*howManyIssues);
			$j(settings.datesDiv).height(heightDate*howManyDates).css('marginTop',heightContainer/2-heightDate/2);
			var defaultPositionDates = parseInt($j(settings.datesDiv).css('marginTop').substring(0,$j(settings.datesDiv).css('marginTop').indexOf('px')));
		}
		
		$j(settings.datesDiv+' a').click(function(event){
			event.preventDefault();
			// first vars
			var whichIssue = $j(this).text();
			var currentIndex = $j(this).parent().prevAll().length;

			// moving the elements
			if(settings.orientation == 'horizontal') {
				$j(settings.issuesDiv).animate({'marginLeft':-widthIssue*currentIndex},{queue:false, duration:settings.issuesSpeed});
			} else if(settings.orientation == 'vertical') {
				$j(settings.issuesDiv).animate({'marginTop':-heightIssue*currentIndex},{queue:false, duration:settings.issuesSpeed});
			}
			$j(settings.issuesDiv+' li').animate({'opacity':settings.issuesTransparency},{queue:false, duration:settings.issuesSpeed}).removeClass(settings.issuesSelectedClass).eq(currentIndex).addClass(settings.issuesSelectedClass).fadeTo(settings.issuesTransparencySpeed,1);
			
			// now moving the dates
			$j(settings.datesDiv+' a').removeClass(settings.datesSelectedClass);
			$j(this).addClass(settings.datesSelectedClass);
			if(settings.orientation == 'horizontal') {
				$j(settings.datesDiv).animate({'marginLeft':defaultPositionDates-(widthDate*currentIndex)},{queue:false, duration:settings.datesSpeed});
			} else if(settings.orientation == 'vertical') {
				$j(settings.datesDiv).animate({'marginTop':defaultPositionDates-(heightDate*currentIndex)},{queue:false, duration:settings.datesSpeed});
			}
		});

		$j(settings.nextButton).bind('click', function(event){
			event.preventDefault();
			if(settings.orientation == 'horizontal') {
				var currentPositionIssues = parseInt($j(settings.issuesDiv).css('marginLeft').substring(0,$j(settings.issuesDiv).css('marginLeft').indexOf('px')));
				var currentIssueIndex = currentPositionIssues/widthIssue;
				var currentPositionDates = parseInt($j(settings.datesDiv).css('marginLeft').substring(0,$j(settings.datesDiv).css('marginLeft').indexOf('px')));
				var currentIssueDate = currentPositionDates-widthDate;
				if(currentPositionIssues <= -(widthIssue*howManyIssues-(widthIssue))) {
					$j(settings.issuesDiv).stop();
					$j(settings.datesDiv+' li:last-child a').click();
				} else {
					if (!$j(settings.issuesDiv).is(':animated')) {
						$j(settings.issuesDiv).animate({'marginLeft':currentPositionIssues-widthIssue},{queue:false, duration:settings.issuesSpeed});
						$j(settings.issuesDiv+' li').animate({'opacity':settings.issuesTransparency},{queue:false, duration:settings.issuesSpeed});
						$j(settings.issuesDiv+' li.'+settings.issuesSelectedClass).removeClass(settings.issuesSelectedClass).next().fadeTo(settings.issuesTransparencySpeed, 1).addClass(settings.issuesSelectedClass);
						$j(settings.datesDiv).animate({'marginLeft':currentIssueDate},{queue:false, duration:settings.datesSpeed});
						$j(settings.datesDiv+' a.'+settings.datesSelectedClass).removeClass(settings.datesSelectedClass).parent().next().children().addClass(settings.datesSelectedClass);
					}
				}
			} else if(settings.orientation == 'vertical') {
				var currentPositionIssues = parseInt($j(settings.issuesDiv).css('marginTop').substring(0,$j(settings.issuesDiv).css('marginTop').indexOf('px')));
				var currentIssueIndex = currentPositionIssues/heightIssue;
				var currentPositionDates = parseInt($j(settings.datesDiv).css('marginTop').substring(0,$j(settings.datesDiv).css('marginTop').indexOf('px')));
				var currentIssueDate = currentPositionDates-heightDate;
				if(currentPositionIssues <= -(heightIssue*howManyIssues-(heightIssue))) {
					$j(settings.issuesDiv).stop();
					$j(settings.datesDiv+' li:last-child a').click();
				} else {
					if (!$j(settings.issuesDiv).is(':animated')) {
						$j(settings.issuesDiv).animate({'marginTop':currentPositionIssues-heightIssue},{queue:false, duration:settings.issuesSpeed});
						$j(settings.issuesDiv+' li').animate({'opacity':settings.issuesTransparency},{queue:false, duration:settings.issuesSpeed});
						$j(settings.issuesDiv+' li.'+settings.issuesSelectedClass).removeClass(settings.issuesSelectedClass).next().fadeTo(settings.issuesTransparencySpeed, 1).addClass(settings.issuesSelectedClass);
						$j(settings.datesDiv).animate({'marginTop':currentIssueDate},{queue:false, duration:settings.datesSpeed});
						$j(settings.datesDiv+' a.'+settings.datesSelectedClass).removeClass(settings.datesSelectedClass).parent().next().children().addClass(settings.datesSelectedClass);
					}
				}
			}
		});

		$j(settings.prevButton).click(function(event){
			event.preventDefault();
			if(settings.orientation == 'horizontal') {
				var currentPositionIssues = parseInt($j(settings.issuesDiv).css('marginLeft').substring(0,$j(settings.issuesDiv).css('marginLeft').indexOf('px')));
				var currentIssueIndex = currentPositionIssues/widthIssue;
				var currentPositionDates = parseInt($j(settings.datesDiv).css('marginLeft').substring(0,$j(settings.datesDiv).css('marginLeft').indexOf('px')));
				var currentIssueDate = currentPositionDates+widthDate;
				if(currentPositionIssues >= 0) {
					$j(settings.issuesDiv).stop();
					$j(settings.datesDiv+' li:first-child a').click();
				} else {
					if (!$j(settings.issuesDiv).is(':animated')) {
						$j(settings.issuesDiv).animate({'marginLeft':currentPositionIssues+widthIssue},{queue:false, duration:settings.issuesSpeed});
						$j(settings.issuesDiv+' li').animate({'opacity':settings.issuesTransparency},{queue:false, duration:settings.issuesSpeed});
						$j(settings.issuesDiv+' li.'+settings.issuesSelectedClass).removeClass(settings.issuesSelectedClass).prev().fadeTo(settings.issuesTransparencySpeed, 1).addClass(settings.issuesSelectedClass);
						$j(settings.datesDiv).animate({'marginLeft':currentIssueDate},{queue:false, duration:settings.datesSpeed});
						$j(settings.datesDiv+' a.'+settings.datesSelectedClass).removeClass(settings.datesSelectedClass).parent().prev().children().addClass(settings.datesSelectedClass);
					}
				}
			} else if(settings.orientation == 'vertical') {
				var currentPositionIssues = parseInt($j(settings.issuesDiv).css('marginTop').substring(0,$j(settings.issuesDiv).css('marginTop').indexOf('px')));
				var currentIssueIndex = currentPositionIssues/heightIssue;
				var currentPositionDates = parseInt($j(settings.datesDiv).css('marginTop').substring(0,$j(settings.datesDiv).css('marginTop').indexOf('px')));
				var currentIssueDate = currentPositionDates+heightDate;
				if(currentPositionIssues >= 0) {
					$j(settings.issuesDiv).stop();
					$j(settings.datesDiv+' li:first-child a').click();
				} else {
					if (!$j(settings.issuesDiv).is(':animated')) {
						$j(settings.issuesDiv).animate({'marginTop':currentPositionIssues+heightIssue},{queue:false, duration:settings.issuesSpeed});
						$j(settings.issuesDiv+' li').animate({'opacity':settings.issuesTransparency},{queue:false, duration:settings.issuesSpeed});
						$j(settings.issuesDiv+' li.'+settings.issuesSelectedClass).removeClass(settings.issuesSelectedClass).prev().fadeTo(settings.issuesTransparencySpeed, 1).addClass(settings.issuesSelectedClass);
						$j(settings.datesDiv).animate({'marginTop':currentIssueDate},{queue:false, duration:settings.datesSpeed},{queue:false, duration:settings.issuesSpeed});
						$j(settings.datesDiv+' a.'+settings.datesSelectedClass).removeClass(settings.datesSelectedClass).parent().prev().children().addClass(settings.datesSelectedClass);
					}
				}
			}
		});
		
		// keyboard navigation, added since 0.9.1
		if(settings.arrowKeys=='true') {
			if(settings.orientation=='horizontal') {
				$(document).keydown(function(event){
					if (event.keyCode == 39) { 
				       $j(settings.nextButton).click();
				    }
					if (event.keyCode == 37) { 
				       $j(settings.prevButton).click();
				    }
				});
			} else if(settings.orientation=='vertical') {
				$(document).keydown(function(event){
					if (event.keyCode == 40) { 
				       $j(settings.nextButton).click();
				    }
					if (event.keyCode == 38) { 
				       $j(settings.prevButton).click();
				    }
				});
			}
		}
		
		// default position startAt, added since 0.9.3
		$j(settings.datesDiv+' li').eq(settings.startAt-1).find('a').trigger('click');
		
		// autoPlay, added since 0.9.4
		if(settings.autoPlay == 'true') { 
			setInterval("autoPlay()", settings.autoPlayPause);
		}
	});

};

// autoPlay, added since 0.9.4
function autoPlay(){
	var currentDate = $j(settings.datesDiv).find('a.'+settings.datesSelectedClass);
	if(settings.autoPlayDirection == 'forward') {
		if(currentDate.parent().is('li:last-child')) {
			$j(settings.datesDiv+' li:first-child').find('a').trigger('click');
		} else {
			currentDate.parent().next().find('a').trigger('click');
		}
	} else if(settings.autoPlayDirection == 'backward') {
		if(currentDate.parent().is('li:first-child')) {
			$j(settings.datesDiv+' li:last-child').find('a').trigger('click');
		} else {
			currentDate.parent().prev().find('a').trigger('click');
		}
	}
}