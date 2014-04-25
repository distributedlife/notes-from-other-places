soundManager.onready(function () {
	"use strict";

	$("li.song").each(function () {
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
					e.removeClass("paused");
				}
			},
			onpause: function () {
				e.addClass("paused");
			},
			onstop: function () {
				message("");

				e.removeClass("active");
				e.removeClass("paused");
			},
			onfinish: function () {
				this.options.onstop();
			}
		}));
	});

	$("li.song").click(function () {
		var track = $(this).data("sound");

		if (track.playState) {
			track.togglePause();
		} else {
			soundManager.stopAll();
			track.play();
		}

		return false;
	});
});