

$(document).ready(function() {
	$(".icon").css({ opacity: 0.3 });
	$("div.side").toggle();
	$('div.link').hover(function() {
		$(this).children('div.side').fadeIn(100);
		$(this).css("background","#eee");
		
	}, function() {
		$(this).css("background","#fff");
		$(this).children("div.side").fadeOut(100);
	})
});