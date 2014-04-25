soundManager.onready(function () {
	"use strict";

	$("div.song").each(function () {
		var e       = $(this),
		    next_e  = e.next(),
		    message = function (html) { e.find(".position").html(html); };

		e.data("sound", soundManager.createSound({
			id: e.attr("id"),
			url: e.find("a").attr("href"),
			whileloading: function () {
				e.addClass("active");

				if (!this.position) {
					timer("&hellip;");
				}
			},
			whileplaying: function () {
				e.addClass("active");

				if (this.position) {
					e.addClass("playing");
					e.removeClass("paused");
				}
			},
			onpause: function () {
				e.addClass("paused");
				e.removeClass("playing");
			},
			onstop: function () {
				message("");

				e.removeClass("active");
				e.removeClass("paused");
				e.removeClass("playing");

				document.title = original_title;
			},
			onfinish: function () {
				this.options.onstop();
			}
		}));
	});

	$("div.song").click(function () {
		var track = $(this).data("sound");

		if (track.playState) {
			track.togglePause();
		} else {
			soundManager.stopAll();
			track.play();
		}

		e.preventDefault();
	});
});