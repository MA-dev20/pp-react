/*
 *= require rails-ujs
 *= require activestorage
 *= require turbolinks
 *= require jquery3
 *= require cable
 *= require typed.min
 *= require progressbar.min
 *= require rangeslider
 */
var MyApp = {};
// Text Effect on gdesktop Turn
function textanim() {
const resolver = {
  resolve: function resolve(options, callback) {
    // The string to resolve
    const resolveString = options.resolveString || options.element.getAttribute('data-target-resolver');
    const combinedOptions = Object.assign({}, options, {resolveString: resolveString});
    
    function getRandomInteger(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    };
    
    function randomCharacter(characters) {
      return characters[getRandomInteger(0, characters.length - 1)];
    };
    
    function doRandomiserEffect(options, callback) {
      const characters = options.characters;
      const timeout = options.timeout;
      const element = options.element;
      const partialString = options.partialString;
      let iterations = options.iterations;

      setTimeout(() => {
        if (iterations >= 0) {
          const nextOptions = Object.assign({}, options, {iterations: iterations - 1});

          // Ensures partialString without the random character as the final state.
          if (iterations == 0) {
            element.textContent = partialString;

            if (partialString.length == options.resolveString.length){
              callback();
              return
            }
          } else {

            element.textContent = partialString.substring(0, partialString.length - 1) + randomCharacter(characters);
          }

          doRandomiserEffect(nextOptions, callback)
        } else if (typeof callback === "function") {
          callback(); 
        }else{
        }
      }, options.timeout);
    };
    
    function doResolverEffect(options, callback) {
      const resolveString = options.resolveString;
      const characters = options.characters;
      const offset = options.offset;
      const partialString = resolveString.substring(0, offset);
      const combinedOptions = Object.assign({}, options, {partialString: partialString});
      doRandomiserEffect(combinedOptions, () => {
        const nextOptions = Object.assign({}, options, {offset: offset + 1});

        if (offset <= resolveString.length) {
          doResolverEffect(nextOptions, callback);
        } else if (typeof callback === "function") {
          callback();
        }
      });
    };
    doResolverEffect(combinedOptions, callback);
  } 
};

const strings = [
    document.getElementById('word').innerHTML
];

let counter = 0;

const options = {
  // Initial position
  offset: 0,
  // Timeout between each random character
  timeout: 10,
  // Number of random characters to show
  iterations: 10,
  // Random characters to pick from
  characters: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'x', 'y', 'x', '#', '%', '&', '-', '+', '_', '?', '/', '\\', '='],
  // String to resolve
  resolveString: strings[counter],
  // The element
  element: document.querySelector('[data-target-resolver]')
}

resolver.resolve(options, callback);
}
/* END */

//Color in Circles
function myColor(val) {
    if (val < 0.5 ) {
        return '#'+(Math.round(255-(val*2))).toString(16)+(Math.round(107+(val*288))).toString(16)+(Math.round(108+(val*180))).toString(16);
    } else {
        return '#'+(Math.round(29+((1-val)*450))).toString(16)+(Math.round(218+((1-val)*66))).toString(16)+(Math.round(175+((1-val)*46))).toString(16);
    }
}
/* Animated Circle on game_desktop/rating */
function ratecircle(id,text_id,val) {
    var tId = document.getElementById(text_id)
    var bar = new ProgressBar.Circle(id, {
        strokeWidth: 8,
        easing: 'linear',
        duration: 2000,
        color: myColor(val),
        svgStyle: null,
        from: {color: '#ff0000'},
        to: {color: '#00ff00'},
        step: function(state, circle) {
            circle.path.setAttribute('stroke', myColor(circle.value()));
            var value = Math.round(circle.value() * 100);
            tId.innerHTML = value/10.0;
        }
    });
    bar.animate(val);
}
function ratecircleg(id,text_id,val) {
    var tId = document.getElementById(text_id)
    var bar = new ProgressBar.Circle(id, {
        strokeWidth: 8,
        easing: 'linear',
        duration: 5000,
        color: myColor(val),
        svgStyle: null,
        from: {color: '#ff0000'},
        to: {color: '#00ff00'},
        step: function(state, circle) {
            circle.path.setAttribute('stroke', myColor(circle.value()));
            var value = Math.round(circle.value() * 100);
            tId.innerHTML = value/10.0;
        }
    });
    bar.animate(val);
}
/* END */
