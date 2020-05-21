/*
 *= require rails-ujs
 *= require jquery3
 *= require activestorage
 *= require turbolinks
 *= require perfect-scrollbar.min
 *= require cropper.min
 *= require slick.min
 *= require Chart.min
 *= require progressbar.min
 *= require cocoon
 */

function ratingColor(rating) {
	var color_value;
	if (rating < 0.5 ) {
		color_value = '#'+(Math.round(255-(rating*2))).toString(16)+(Math.round(107+(rating*288))).toString(16)+(Math.round(108+(rating*180))).toString(16);
	} else {
		color_value = '#'+(Math.round(29+((1-rating)*450))).toString(16)+(Math.round(218+((1-rating)*66))).toString(16)+(Math.round(175+((1-rating)*46))).toString(16);
	}
	return color_value;
}
function ratecircle(id,text_id,val) {
    var tId = document.getElementById(text_id)
    var bar = new ProgressBar.Circle(id, {
        strokeWidth: 8,
        color: ratingColor(val),
        svgStyle: null,
        step: function(state, circle) {
            circle.path.setAttribute('stroke', ratingColor(circle.value()));
            var value = Math.round(circle.value() * 100);
            tId.innerHTML = value/10.0;
			tId.style.color = ratingColor(value/100.0);
        }
    });
    bar.animate(val);
}