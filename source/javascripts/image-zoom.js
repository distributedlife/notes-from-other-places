$(document).ready(function (){
	$(window).scroll(function () {
		$("img").each(function() {
			if ($("#lightbox").is(':visible')) {
				$("#lightbox").hide();
			}

			$(this).css({transform: 'translate(0px, 0px) scale(1)', 'z-index': 1000});
		});
	});

	$("img").on('click', function(e) {
		var image = this;
		var padding = 25;
		var scale = 1;
		
		if ($(image).height() > $(image).width()) {
			var new_height = $(window).height() - (padding * 2);
			scale = new_height / $(image).height();	
		} else {
			var new_width = $(window).width() - (padding * 2);
			scale = new_width / $(image).width();	
		}

		if (scale < 1.0) {
			e.preventDefault();
			return;
		}
		
		var image_wrt_window_top = $(image).offset().top - $(window).scrollTop();
		var margin = ($(window).height() - $(image).height()) / 2;
		var new_top = margin - image_wrt_window_top;

		if ($("#lightbox").is(':visible')) {
			$("#lightbox").hide();
			$(image).css({transform: 'translate(0px, 0px) scale(1)', 'z-index': 1000});

			$("img").each(function() {
				if (image !== this) {
					$(this).css({transform: 'translate(0px, 0px) scale(1)', 'z-index': 998});
				}
			});
		} else {
			$("#lightbox").show();
			$(image).css({transform: 'translate(0px,' + new_top + 'px) scale(' + scale + ')', 'z-index': 1000});

			$("img").each(function() {
				if (image !== this) {
					$(this).css({transform: 'translate(0px, 0px) scale(1)', 'z-index': 998});
				}
			});
		}
		
		e.preventDefault();
	});
});